# exdvd-vlc-patches

Changes exDVD makes to VLC 3.0.x, published per its licences.

## dvdnav/ (VLC 3.0.23, GPL via libdvdnav)

`dvdnav-default-button.patch`: when a DVD menu has buttons but none is
selected, the first arrow or Select selects button 1, as standalone players
do. Without it some discs (e.g. Disney's Bill Nye set) cannot be operated
with arrow keys, and VLC falls back to changing volume and seeking.
`build.sh` builds the one plugin against VLC's own libdvdnav/libdvdread
versions. It defines `HAVE_STREAM_CB_IN_DVDNAV_H`; without it the plugin
cannot read a DVD image from a stream.

## vlckit/ (VLCKit 3.6.0 for tvOS, LGPL 2.1+)

- `0001`: three libvlc functions to set the video filter chain and filter
  options on a playing media player; build fixes for current Apple SDKs.
- `0002`: `atadenoise`, a VLC video filter ported from FFmpeg's (LGPL),
  using past frames only so it adds no delay.
- `vlckit-buildMobileVLCKit.diff`: build-script changes (adds gradfun,
  tvOS 15 minimum, an LGPL-only switch).

Apply 0001-0002 to VLC 3.0.x at VLCKit 3.6.0's tested hash (dd8bfdba),
after VLCKit's own patches.
