# Retro Wormhole GIF

Animated wormhole and black-hole GIF enhancement for the Stargate Retro web interface.

<img width="242" height="229" alt="Original_Wormhole" src="https://github.com/user-attachments/assets/2f572690-dd58-448b-880f-6d743ada7184" /> 
<img width="232" height="216" alt="GIF_Wormhole" src="https://github.com/user-attachments/assets/45c580e8-03a8-49d6-8ab0-e2c5e23ce416" />


## Install

Clone or unzip this add-on into `/home/pi`, then run:

```bash
cd /home/pi
rm -rf Retro-Wormhole-GIF
git clone https://github.com/matelv-x/Retro-Wormhole-GIF.git
cd Retro-Wormhole-GIF
chmod +x install.sh restore.sh
sudo ./install.sh --target /home/pi/sg1_v4
sudo systemctl restart stargate.service
```

## Restore / uninstall

```bash
cd /home/pi/Retro-Wormhole-GIF
sudo ./restore.sh --target /home/pi/sg1_v4
sudo systemctl restart stargate.service
```

## What it changes

- Adds `wormhole.gif` and `blackhole.gif`.
- Patches Retro `dial.html`, `dial9.html`, and related CSS.
- Supports `--keep-crosshair` and `--dry-run`.

## Attribution and originality

Original base project: https://github.com/polklabs/stargate-retro
The Retro pages being patched come from the Polklabs Retro UI project:
matelv-x/Codex modification: this repository adds the wormhole/black-hole GIF overlay behavior and packaging for the SG1 v4 Retro web interface.

How much is copied or changed: Medium Retro UI asset/HTML/CSS overlay.
