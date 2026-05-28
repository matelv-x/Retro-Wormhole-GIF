# Installation

## Standard install

```bash
cd /home/pi/Retro-Wormhole-GIF
sudo ./install.sh --target /home/pi/sg1_v4
sudo systemctl restart stargate.service
```

## Install while keeping the original crosshair

```bash
cd /home/pi/Retro-Wormhole-GIF
sudo ./install.sh --target /home/pi/sg1_v4 --keep-crosshair
sudo systemctl restart stargate.service
```

## Dry run

```bash
cd /home/pi/Retro-Wormhole-GIF
sudo ./install.sh --target /home/pi/sg1_v4 --dry-run
```
