#!/bin/sh
# Build VLC 3.0.23's dvdnav module with dvdnav-default-button.patch, as one
# plugin for a stock VLC 3.0.23 on macOS. Needs libdvdnav and libdvdread
# (Homebrew) and Xcode's compiler.
set -e
V=3.0.23; B=${BREW:-$(brew --prefix)}
curl -sSLO https://download.videolan.org/pub/videolan/vlc/$V/vlc-$V.tar.xz
tar xf vlc-$V.tar.xz && cd vlc-$V
patch -p1 < ../dvdnav-default-button.patch
PKG_CONFIG_PATH=$B/lib/pkgconfig ./configure --disable-lua --disable-qt \
  --disable-skins2 --disable-macosx --disable-sparkle --disable-vlc \
  --disable-nls --disable-avcodec --disable-swscale --disable-postproc \
  --disable-a52 --disable-libgcrypt --disable-sout --disable-live555 \
  --disable-freetype --enable-dvdnav > ../configure.log
cc -c modules/access/dvdnav.c -o ../dvdnav.o -I. -Iinclude -Imodules \
  -I$B/include -DHAVE_CONFIG_H -DMODULE_STRING='"dvdnav"' -D__PLUGIN__ \
  -D_FILE_OFFSET_BITS=64 -std=gnu99 -fvisibility=hidden -fPIC -O2
cc -dynamiclib -Wl,-undefined,dynamic_lookup -o ../libdvdnav_plugin.dylib \
  ../dvdnav.o -L/Applications/VLC.app/Contents/MacOS/lib -lvlccore \
  -L$B/lib -ldvdnav -ldvdread
echo "Built libdvdnav_plugin.dylib. Use it from a copy of VLC's plugins"
echo "folder (VLC_PLUGIN_PATH); a partial folder stops libVLC starting."
