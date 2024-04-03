Script for bootstrapping Arch Linux for my needs with my personnal defaults. Based on 'classy-girafe/easy-arch'

## Preparation

1. Enable WIFI
	1.1 Identify your device (DEVICE)
		'$ iwctl device list'
	1.2 Scan wifi networks
		$ iwctl station DEVICE scan
	1.3 list wifi networks
		$ iwctl station DEVICE get-networks
	1.4 Connect to wifi
		$ iwctl --passphrase=PASSPHRASE station DEVICE connect SSID

## Installation
```bash 
wget -O lcw-arch.sh https://raw.githubusercontent.com/LapinChat/lcw-arch/main/lcw-arch.sh
chmod +x lcw-arch.sh
bash lcw-arch.sh
```