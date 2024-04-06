Script for bootstrapping Arch Linux for my needs with my personnal defaults. Based on 'classy-girafe/easy-arch'

## Preparation

1. Enable WIFI (if needed)
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
2. Set your keyboard layout to stay sane
```bash 
$ loadkeys ca
```

## Installation
```bash 
curl -O https://raw.githubusercontent.com/LapinChat/lcw-arch/main/lcw-arch.sh
chmod +x lcw-arch.sh
./lcw-arch.sh
```