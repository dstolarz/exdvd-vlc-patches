#!/bin/sh
# Build VLC 3.0.23's dvdnav module with dvdnav-default-button.patch, as one
# plugin for a stock VLC 3.0.23 on macOS. libdvdnav 6.1.1 and libdvdread
# 6.1.3 (VLC's versions, with VLC's contrib patches) are linked statically.
# Needs Xcode's compiler, autoconf, automake, libtool.
set -e
V=3.0.23; R=6.1.3; N=6.1.1
HERE=$(cd "$(dirname "$0")" && pwd)
W=${WORK:-$PWD/vlc-dvdnav-build}; mkdir -p "$W"; cd "$W"; P=$W/prefix
VL=https://download.videolan.org/pub/videolan
[ -f vlc-$V.tar.xz ] || curl -sSfLO $VL/vlc/$V/vlc-$V.tar.xz
[ -f libdvdread-$R.tar.bz2 ] || curl -sSfLO $VL/libdvdread/$R/libdvdread-$R.tar.bz2
[ -f libdvdnav-$N.tar.bz2 ] || curl -sSfLO $VL/libdvdnav/$N/libdvdnav-$N.tar.bz2
rm -rf vlc-$V libdvdread-$R libdvdnav-$N
tar xf vlc-$V.tar.xz; tar xjf libdvdread-$R.tar.bz2; tar xjf libdvdnav-$N.tar.bz2
C=$W/vlc-$V/contrib/src
(cd libdvdread-$R && for f in "$C"/dvdread/*.patch; do patch -p1 -s < "$f"; done \
  && CFLAGS="-O2 -fPIC" ./configure --prefix="$P" --disable-shared --disable-apidoc >/dev/null \
  && make -s install >/dev/null)
(cd libdvdnav-$N && for f in "$C"/dvdnav/*.patch; do patch -p1 -s < "$f"; done \
  && { [ -n "$SKIP_AUTORECONF" ] || autoreconf -fi >/dev/null 2>&1; } \
  && DVDREAD_CFLAGS="-I$P/include" DVDREAD_LIBS="-L$P/lib -ldvdread" \
     CFLAGS="-O2 -fPIC" ./configure --prefix="$P" --disable-shared >/dev/null \
  && make -s install >/dev/null)
cd vlc-$V
patch -p1 < "$HERE/dvdnav-default-button.patch"
# configure only writes config.h; nothing else of VLC is built.
./configure --disable-lua --disable-qt --disable-skins2 --disable-macosx \
  --disable-sparkle --disable-vlc --disable-nls --disable-avcodec \
  --disable-swscale --disable-postproc --disable-a52 --disable-libgcrypt \
  --disable-sout --disable-live555 --disable-freetype > ../configure.log
cc -c modules/access/dvdnav.c -o ../dvdnav.o -I. -Iinclude -Imodules \
  -I"$P/include" -DHAVE_CONFIG_H -DHAVE_STREAM_CB_IN_DVDNAV_H=1 \
  -DMODULE_STRING='"dvdnav"' -D__PLUGIN__ -D_FILE_OFFSET_BITS=64 \
  -std=gnu99 -fvisibility=hidden -fPIC -O2
cc -dynamiclib -Wl,-undefined,dynamic_lookup -o ../libdvdnav_plugin.dylib \
  ../dvdnav.o "$P/lib/libdvdnav.a" "$P/lib/libdvdread.a" \
  -L/Applications/VLC.app/Contents/MacOS/lib -lvlccore
echo "Built $W/libdvdnav_plugin.dylib. Load it from a full copy of VLC's plugins folder (VLC_PLUGIN_PATH)."
