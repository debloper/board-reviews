# Vicharak Axon

[Home](https://vicharak.in/axon) • [Docs](https://docs.vicharak.in/vicharak_sbcs/axon/axon-home/) • [Forum](https://discuss.vicharak.in/)

## Challenges

### The GPU driver fiasco

> [!TIP]  
> Use the new Kernel 6.1 based Ubuntu 24.04 [beta image](https://downloads.vicharak.in/vicharak-axon/beta-images/V1.0_vicharak_axon_6.1-ubuntu-24.04-emmc-beta.tar.gz). It's quite stable and performant; and the GPU driver is working quite well.

The difference between the SD card image and eMMC images create a weird situation
- SD Card image uses llvmpipe
  - which allows most applications to work (e.g. VLC, OBS & media players), but without hardware accelerations
  - which also makes some other very important applications to fail or crash (e.g. Chromium)
- eMMC uses OpenGL-ES driver of the BSP
  - Hence, it needs gl4es adapter layer to work with OpenGL 3 apps (like VLC, OBS et al. which crash complaining about libGL)
  - But it allows Chromium to work, with fair bit of GPU acceleration (so at least you can search why VLC isn't working lol)
- Apparently the work is going on to port `panthor` driver with native OpenGL 3 support to solve this

### The HDMI-RX is very hard to use
This is perhaps due to multilateral issues involving OpenGL, FFMPEG, V4L2 etc
- HDMI-RX needs to be enabled in devicetree & requires some packages\
  - which exact ones are necessary & sufficient are hard to tell; that maze was long winded
- Even though it can be shown to work, it's not feasible for practical usage scenario
  - Using [gstreamer](https://github.com/Joshua-Riek/ubuntu-rockchip/issues/252#issuecomment-1629302255) it's possible to create a pipeline
  - Was able to capture raw YUV with `v4l2-ctl --verbose -d /dev/video40 --set-fmt-video=width=1920,height=1080,pixelformat='NV12' --stream-mmap=4 --stream-skip=5 --stream-count=10 --stream-to=hdmirx.yuv --stream-poll`
  - That could be played with `ffplay -f rawvideo -video_size 1920x1080 hdmirx.yuv`
- Hopefully with native OpenGL 3.0 support it can become usable
  - So that VLC or OBS can record from it a much more convenient manner (on eMMC, because...)
  - On SD card (i.e. with llvmpipe for framebuffer) OBS runs, but the HDMI-RX is completely black

### Preinstalled FFMPEG doesn't support RKMPP
- So far no luck trying to build [ffmpeg-rockchip](https://github.com/nyanmisaka/ffmpeg-rockchip) from scratch
- However, [Jellyfin's FFMPEG](https://github.com/jellyfin/jellyfin-ffmpeg) uses hardware transcoder just fine
- Although running `jellyfin-ffmpeg` prebuilt release binary doesn't work
- The binaries installed as part of Jellyfin installation works properly instead

### No RKNPU support out of the box
- RKNN Toolkit installation is not the most complicated thing, but it should come preinstalled
- There are a ton on outdated & obsolete information for setting up RKNPU.
- However, [this ez install script](https://github.com/Pelochus/ezrknn-toolkit2/blob/master/install.sh) is most comprehensive of them all.

### The power rail design could have been better
- The VIN (USB PD negotiated raw input power) is passed through as 12V bus - even if the PD negotiation failed
- Which makes all the 12V bus actually get 5V without raising any error, blinking any indicator, or disabling compromised rails
- There should have been either UVLO to disable 12V bus or PWR_OK indicator to show faults at the basic level
- A better design would've been to use a better PMIC with SS, PG, UVLO along with DC-DC conversion
  - So that it could accept wide voltage input (5-20V PD, maybe even PPS)
  - Disable particular rails if they can't be properly powered
  - Display indicator for PD negotiation being lower than 12V (i.e. 9V or 5V fallback)

### The FPC connectors lack planning & need major overhaul
- The wide FPC with PCIe Gen 2x2 (combo PIPE PHY0 & PHY1) lanes have all the supporting signals (clkreq, wake, perst)
  - but it carries no 12V power to power a proper PCIe card (NIC/HBA)
  - the single 3.3V pin won't carry sufficient current to even drive an NVMe drive (i.e. something that doesn't need 12V)
- The small FPC (previously SATA connector, actually combo PIPE PHY2) has a x1 duplex lane
  - It has 12V and 5V power in spades (3pins each; no 3.3V pin)
  - But it doesn't even have PCIe clkref; let alone be clkreq, wake or perst
  - So it's not optimal to be used for anything else than as a SATA interface
  - Which makes removing the standard SATA connector kinda pointless
  - Even to use the lanes as USB 3.0 (which is one of the alt modes of the PHY2), it'll need the USB Dp/Dn & CC lines

## Tips

- Boot from SD card & take a full backup of the eMMC before messing with it.
  - It's easier to un-screw-up that way, than needing to use `maskrom` 
  - Make sure not to overwrite the first 2 very small eMMC partitions. If you mess them up, you WILL have to use maskrom mode.
  - [Download prebuilt images](https://downloads.vicharak.in/vicharak-axon/)
  - SD Card has boot priority
- The board totally works with a 5V power supply (i.e. fallback if 12V PD negotiation fails)
  - It even seems to runs cooler with 5V supply (~45-50°C) than 12V supply (~60-70°C)
  - 12V only seems to be relevant for the PCIe peripherals (FPC connectors)
- You can [put the cores on performance mode](https://askubuntu.com/a/1406529) to go the extra mile in benchmarks
