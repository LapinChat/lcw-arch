Script for bootstrapping Arch Linux for my needs with my personnal defaults. Based on 'classy-girafe/easy-arch'

## Preparation

1. Enable WIFI
	1. Identify your device (DEVICE)
		```bash 
		$ iwctl device list
		```
	2. Scan wifi networks
		```bash 
		$ iwctl station DEVICE scan
		```
	3. list wifi networks
		```bash 
		$ iwctl station DEVICE get-networks
		```
	4. Connect to wifi
		```bash 
		$ iwctl --passphrase=PASSPHRASE station DEVICE connect SSID
		```

## Installation
```bash 
wget -O lcw-arch.sh https://raw.githubusercontent.com/LapinChat/lcw-arch/main/lcw-arch.sh
chmod +x lcw-arch.sh
bash lcw-arch.sh
```