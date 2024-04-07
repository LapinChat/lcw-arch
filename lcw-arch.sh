#!/usr/bin/env -S bash -e

########################
# How to get this file from Arch Linux live environment
#
# 1. Enable WIFI
#   1.1 Identify your device (DEVICE)
#       $ iwctl device list
#   1.2 Scan wifi networks
#       $ iwctl station DEVICE scan
#   1.3 list wifi networks
#       $ iwctl station DEVICE get-networks
#   1.4 Connect to wifi
#       $ iwctl --passphrase=PASSPHRASE station DEVICE connect SSID
#
# 2. Set keyboard layout
#   $ loadkeys ca
#
# 3. Get script
#   $ curl -O https://raw.githubusercontent.com/LapinChat/lcw-arch/main/lcw-arch.sh
#
# 4. Run script
#   $ chmod +x lcw-arch.sh
#   $ ./lcw-arch.sh
########################

# Cleaning the TTY.
clear

# Cosmetics (colours for text).
BOLD='\e[1m'
BRED='\e[91m'
BBLUE='\e[34m'  
BGREEN='\e[92m'
BYELLOW='\e[93m'
RESET='\e[0m'

# Pretty print (function).
info_print () {
    echo -e "${BOLD}${BGREEN}[ ${BYELLOW}•${BGREEN} ] $1${RESET}"
}

# Pretty print for input (function).
input_print () {
    echo -ne "${BOLD}${BYELLOW}[ ${BGREEN}•${BYELLOW} ] $1${RESET}"
}

# Alert user of bad input (function).
error_print () {
    echo -e "${BOLD}${BRED}[ ${BBLUE}•${BRED} ] $1${RESET}"
}

# Selecting a kernel to install (function).
kernel_selector () {
    info_print "List of kernels:"
    info_print "1) Stable: Vanilla Linux kernel with a few specific Arch Linux patches applied"
    info_print "2) Hardened: A security-focused Linux kernel"
    info_print "3) Longterm: Long-term support (LTS) Linux kernel"
    info_print "4) Zen Kernel: A Linux kernel optimized for desktop usage"
    input_print "Please select the number of the corresponding kernel (e.g. 1) (enter empty to use 'Stable'): " 
    read -r kernel_choice
    case $kernel_choice in
        '') kernel="linux"
            return 0;;
        1 ) kernel="linux"
            return 0;;
        2 ) kernel="linux-hardened"
            return 0;;
        3 ) kernel="linux-lts"
            return 0;;
        4 ) kernel="linux-zen"
            return 0;;
        * ) error_print "You did not enter a valid selection, please try again."
            return 1
    esac
}

# Selecting a way to handle internet connection (function).
network_selector () {
    info_print "Network utilities (default = 1):"
    info_print "1) IWD: Utility to connect to networks written by Intel (WiFi-only, built-in DHCP client)"
    info_print "2) NetworkManager: Universal network utility (both WiFi and Ethernet, highly recommended)"
    info_print "3) wpa_supplicant: Utility with support for WEP and WPA/WPA2 (WiFi-only, DHCPCD will be automatically installed)"
    info_print "4) dhcpcd: Basic DHCP client (Ethernet connections or VMs)"
    input_print "Please select the number of the corresponding networking utility (e.g. 1): "
    read -r network_choice
    case $network_choice in
        '') network="iwd"
            network_choice=1
            return 0;;
        1 ) network="iwd"
            return 0;;
        2 ) network="networkmanager"
            return 0;;
        3 ) network="wpa_supplicant dhcpcd"
            return 0;;
        4 ) network="dhcpcd"
            return 0;;
        * ) error_print "You did not enter a valid selection, please try again."
            return 1;;
    esac
}

# Selecting network interface to handle internet connection (function)
network_interface_selector () {
    info_print "Network interface (default = wlan0):"
    info_print "Currently available interfaces:"
    ls /sys/class/net/
    input_print "Please enter the interface name to be used. (e.g. wlan0) (Empty for default): "
    read -r network_interface
    if [[ -z "$network_interface" ]]; then
        network_interface="wlan0"
    fi
    return 0
}

# Selecting selected network interface type (function)
network_interface_type_selector () {
    info_print "Type of the selected network interface (default = Wireless):"
    info_print "1) Wireless"
    info_print "2) Wired"
    input_print "Please select the number of the corresponding kernel (e.g. 1) (enter empty to use 'Wireless'): " 
    read -r network_interface_type
    case $network_interface_type in
        '') network_interface_type="wireless"
            return 0;;
        1 ) network_interface_type="wireless"
            return 0;;
        2 ) network_interface_type="wired"
            return 0;;
        * ) error_print "You did not enter a valid selection, please try again."
            return 1
    esac
}

# Installing the chosen networking method to the system (function).
network_installer () {
    case $network_choice in
        1 ) info_print "Installing and enabling IWD."
            systemctl enable iwd --root=/mnt &>/dev/null
            ;;
        2 ) info_print "Installing and enabling NetworkManager."
            systemctl enable NetworkManager --root=/mnt &>/dev/null
            ;;
        3 ) info_print "Installing and enabling wpa_supplicant and dhcpcd."
            systemctl enable wpa_supplicant --root=/mnt &>/dev/null
            systemctl enable dhcpcd --root=/mnt &>/dev/null
            ;;
        4 ) info_print "Installing dhcpcd."
            systemctl enable dhcpcd --root=/mnt &>/dev/null
    esac
}

# Setting up a password for the user account (function).
userpass_selector () {
    input_print "Please enter name for a user account (enter empty to not create one): "
    read -r username
    if [[ -z "$username" ]]; then
        return 0
    fi
    input_print "Please enter a password for $username (you're not going to see the password): "
    read -r -s userpass
    if [[ -z "$userpass" ]]; then
        echo
        error_print "You need to enter a password for $username, please try again."
        return 1
    fi
    echo
    input_print "Please enter the password again (you're not going to see it): " 
    read -r -s userpass2
    echo
    if [[ "$userpass" != "$userpass2" ]]; then
        echo
        error_print "Passwords don't match, please try again."
        return 1
    fi
    return 0
}

# Setting up a password for the root account (function).
rootpass_selector () {
    input_print "Please enter a password for the root user (you're not going to see it): "
    read -r -s rootpass
    if [[ -z "$rootpass" ]]; then
        echo
        error_print "You need to enter a password for the root user, please try again."
        return 1
    fi
    echo
    input_print "Please enter the password again (you're not going to see it): " 
    read -r -s rootpass2
    echo
    if [[ "$rootpass" != "$rootpass2" ]]; then
        error_print "Passwords don't match, please try again."
        return 1
    fi
    return 0
}

# Microcode detector (function).
microcode_detector () {
    CPU=$(grep vendor_id /proc/cpuinfo)
    if [[ "$CPU" == *"AuthenticAMD"* ]]; then
        info_print "An AMD CPU has been detected, the AMD microcode will be installed."
        microcode=" amd-ucode"
    elif [[ "$CPU" == *"GenuineIntel"* ]]; then
        info_print "An Intel CPU has been detected, the Intel microcode will be installed."
        microcode=" intel-ucode"
    else
        info_print "An Unknown CPU has been detected ($CPU), no microcode will be installed."
        info_print "'grep vendor_id /proc/cpuinfo' to find out which microcode you need, if any."
        microcode=""
    fi
}

# User enters a hostname (function).
hostname_selector () {
    input_print "Please enter the hostname: "
    read -r hostname
    if [[ -z "$hostname" ]]; then
        error_print "You need to enter a hostname in order to continue."
        return 1
    fi
    return 0
}

# User chooses the locale (function).
locale_selector () {
    input_print "Please insert the locale you use (format: xx_XX. Enter nothing to use en_CA, or \"/\" to search locales): " mainlocale
    read -r mainlocale
    case "$mainlocale" in
        '') mainlocale="en_CA.UTF-8"
            info_print "$mainlocale will be the default locale."
            return 0;;
        '/') sed -E '/^# +|^#$/d;s/^#| *$//g;s/ .*/ (Charset:&)/' /etc/locale.gen | less -M
                clear
                return 1;;
        *)  if ! grep -q "^#\?$(sed 's/[].*[]/\\&/g' <<< "$mainlocale") " /etc/locale.gen; then
                error_print "The specified locale doesn't exist or isn't supported."
                return 1
            fi
            return 0
    esac
}

# User chooses the optional locale (function).
optional_locale_selector () {
    input_print "Please insert an OPTIONAL locale you use (format: xx_XX. Enter nothing to use fr_CA or 's' to skip optional locale, or \"/\" to search locales): " optionallocale
    read -r locale
    case "$optionallocale" in
        '') optionallocale="fr_CA.UTF-8"
            info_print "$optionallocale will be the secondary locale."
            return 0;;
        's') info_print "No secondary locale has been selected."
             return 0;;
        '/') sed -E '/^# +|^#$/d;s/^#| *$//g;s/ .*/ (Charset:&)/' /etc/locale.gen | less -M
                clear
                return 1;;
        *)  if ! grep -q "^#\?$(sed 's/[].*[]/\\&/g' <<< "$optionallocale") " /etc/locale.gen; then
                error_print "The specified locale doesn't exist or isn't supported."
                return 1
            fi
            return 0
    esac
}

# User chooses the console keyboard layout (function).
keyboard_selector () {
    input_print "Please insert the keyboard layout to use in console (enter empty to use CA, or \"/\" to look up for keyboard layouts): "
    read -r kblayout
    case "$kblayout" in
        '') kblayout="ca"
            info_print "The canadian multilingual standard keyboard layout will be used."
            return 0;;
        '/') localectl list-keymaps
             clear
             return 1;;
        *) if ! localectl list-keymaps | grep -Fxq "$kblayout"; then
               error_print "The specified keymap doesn't exist."
               return 1
           fi
        info_print "Changing console layout to $kblayout."
        loadkeys "$kblayout"
        return 0
    esac
}

# Setting up a name and an email for Git configuration (function).
git_info_selector () {
    input_print "Please enter a name for a git user (usualy your full name) (e.g. Bob Picard): "
    IFS= read -r gitname
    if [[ -z "$gitname" ]]; then
        echo
        error_print "You need to enter a name, please try again."
        return 1
    fi
    input_print "Please enter an email for $gitname: "
    read -r gitemail
    if [[ -z "$gitemail" ]]; then
        echo
        error_print "You need to enter an email for $gitname, please try again."
        return 1
    fi
    return 0
}

# Welcome screen.
echo -ne "${BOLD}${BYELLOW}
===== Pierre Tremblay-Thériault =================================
██╗      ██████╗██╗     ██╗       █████╗ ██████╗  ██████╗██╗  ██╗
██║     ██╔════╝██║ ██╗ ██║      ██╔══██╗██╔══██╗██╔════╝██║  ██║
██║     ██║     ██║████╗██║█████╗███████║██████╔╝██║     ███████║
██║     ██║     ████╔═████║╚════╝██╔══██║██╔══██╗██║     ██╔══██║
███████╗╚██████╗╚██╔╝  ██╔╝      ██║  ██║██║  ██║╚██████╗██║  ██║
╚══════╝ ╚═════╝ ╚═╝   ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
================================================ since 2024 =====
${RESET}"
info_print "Welcome to LCW-Arch, a script made in order to simplify the process of installing Arch Linux."

# Setting up keyboard layout.
until keyboard_selector; do : ; done

# Choosing the target for the installation.
info_print "Detected disks:"
lsblk -dp
info_print "Available disks for the installation:"
PS3="Please select the number of the corresponding disk (e.g. 1): "
select ENTRY in $(lsblk -dpno NAME | grep -P "/dev/mmc|/dev/sd|nvme|vd");
do
    DISK="$ENTRY"
    info_print "Arch Linux will be installed on the following disk: $DISK"
    break
done

# Setting up the kernel.
until kernel_selector; do : ; done

# User choses the network.
until network_selector; do : ; done
# User choses the network interface.
until network_interface_selector; do : ; done
# User choses the network interface type.
until network_interface_type_selector; do : ; done

# User choses the locale.
until locale_selector; do : ; done
until optional_locale_selector; do : ; done

# User choses the hostname.
until hostname_selector; do : ; done

# User sets up the user/root passwords.
until userpass_selector; do : ; done
until rootpass_selector; do : ; done

# User sets Git name and email.
until git_info_selector; do : ; done

# Warn user about deletion of old partition scheme.
input_print "This will delete the current partition table on $DISK once installation starts. Do you agree [y/N]?: "
read -r disk_response
if ! [[ "${disk_response,,}" =~ ^(yes|y)$ ]]; then
    error_print "Quitting."
    exit
fi
info_print "Wiping $DISK."
wipefs -af "$DISK" &>/dev/null
sgdisk -Zo "$DISK" &>/dev/null

# Creating a new partition scheme.
info_print "Creating the partitions on $DISK."
parted -s "$DISK" \
    mklabel gpt \
    mkpart ESP fat32 1MiB 513MiB \
    set 1 esp on \
    mkpart swap linux-swap 513MiB 4609MiB \
    mkpart system ext4 4609MiB 100% \

ESP_DEVICE="/dev/disk/by-partlabel/ESP"
SWAP_DEVICE="/dev/disk/by-partlabel/swap"
SYSTEM_DEVICE="/dev/disk/by-partlabel/system"

# Informing the Kernel of the changes.
info_print "Informing the Kernel about the disk changes."
partprobe "$DISK"

# Formatting the ESP as FAT32.
info_print "Formatting the EFI Partition as FAT32."
mkfs.fat -F 32 "$ESP_DEVICE" &>/dev/null

# Initialize swap partition
info_print "Initialize SWAP partition."
mkswap "$SWAP_DEVICE" &>/dev/null

# Formatting the System partition as ext4.
info_print "Formatting the system partition as Ext4."
mkfs.ext4 "$SYSTEM_DEVICE" &>/dev/null

# Mounting the newly created subvolumes.
info_print "Mounting the newly created subvolumes."
mount "$SYSTEM_DEVICE" /mnt
mount --mkdir "$ESP_DEVICE" /mnt/boot
swapon "$SWAP_DEVICE"

# Checking the microcode to install.
microcode_detector

# Pacstrap (setting up a base sytem onto the new root).
info_print "Installing the base system (it may take a while). Requested packages: "
REQUESTEDPACKAGES="base $kernel$microcode linux-firmware e2fsprogs exfatprogs $network man-db man-pages texinfo nano neofetch grub efibootmgr sudo git lynx"
info_print "$REQUESTEDPACKAGES"
pacstrap -K /mnt base $kernel$microcode linux-firmware e2fsprogs exfatprogs $network man-db man-pages texinfo nano neofetch grub efibootmgr sudo git lynx &>/dev/null

# Generating /etc/fstab.
info_print "Generating a new fstab."
genfstab -U /mnt >> /mnt/etc/fstab

# Set time and timezone
info_print "Set timezone (America/Montreal) and sync hwclock."
arch-chroot /mnt ln -sf /usr/share/zoneinfo/America/Montreal /etc/localtime
arch-chroot /mnt hwclock --systohc
info_print "Set and enable SNTP service."
# Append lines to file
cat <<EOT >> /mnt/etc/systemd/timesyncd.conf
NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org
FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org
EOT
# Enable service
systemctl enable systemd-timesyncd.service --root=/mnt &>/dev/null

# Configure selected locale and console keymap
info_print "Configure selected locale and console keymap."
info_print "Select $mainlocale locale."
sed -i "/^#$mainlocale/s/^#//" /mnt/etc/locale.gen
if [[ "$optionallocale" != *"n"* ]]; then
    info_print "Select $optionallocale as a secondary locale."
    sed -i "/^#$optionallocale/s/^#//" /mnt/etc/locale.gen
fi
arch-chroot /mnt locale-gen &>/dev/null
echo "LANG=$mainlocale" > /mnt/etc/locale.conf
echo "KEYMAP=$kblayout" > /mnt/etc/vconsole.conf

# Setting up the hostname.
info_print "Setting up the hostname."
echo "$hostname" > /mnt/etc/hostname

# Setting hosts file.
info_print "Setting hosts file."
cat > /mnt/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain   $hostname
EOF

# Setting systemd-networkd
info_print "Setting systemd-networkd for $network_interface_type."
if [[ "$network_interface_type" == *"wireless"* ]]; then
info_print "Setting /etc/systemd/network/25-wireless.network"
cat <<EOT >> /mnt/etc/systemd/network/25-wireless.network
[Match]
Name=$network_interface

[Network]
DHCP=yes
IgnoreCarrierLoss=3s
EOT
elif [[ "$network_interface_type" == *"wired"* ]]; then
info_print "Setting /etc/systemd/network/20-wired.network"
cat <<EOT >> /mnt/etc/systemd/network/20-wired.network
[Match]
Name=$network_interface

[Network]
DHCP=yes
EOT
fi
# Set symlink for DNS resolver
ln -sf ../run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf
# Setting up the network.
network_installer
systemctl enable systemd-networkd systemd-resolved --root=/mnt &>/dev/null
# Enable services
if [[ "$network_interface_type" == *"wireless"* ]]; then
    systemctl enable iwd --root=/mnt &>/dev/null
fi

# Generating a new initramfs.
arch-chroot /mnt mkinitcpio -P &>/dev/null

# Setting root password.
info_print "Setting root password."
echo "root:$rootpass" | arch-chroot /mnt chpasswd

# Setting user password.
if [[ -n "$username" ]]; then
    echo "%wheel ALL=(ALL:ALL) ALL" > /mnt/etc/sudoers.d/wheel
    info_print "Adding the user $username to the system with root privilege."
    arch-chroot /mnt useradd -m -G wheel -s /bin/bash "$username"
    info_print "Setting user password for $username."
    echo "$username:$userpass" | arch-chroot /mnt chpasswd
fi

info_print "Installing and configuring GRUB."
# Installing GRUB
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB &>/dev/null
# Creating GRUB config file.
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg &>/dev/null

# Configure Git
info_print "Configure Git for user $username."
cat <<EOT >> /mnt/home/$username/.gitconfig
[user]
    name = $gitname
    email = $gitemail
[color]
    branch = auto
    diff = auto
    interactive = auto
    status = auto
[alias]
    st = status -s
    co = checkout
    ci = commit
    br = branch
    gr = log --graph --full-history --all --color --pretty=tformat:"%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s%x20%x1b[33m(%an)%x1b[0m"
[core]
    editor = nano
    precomposeunicode = true
[merge]
    conflictstyle = diff3

EOT

# Pacman eye-candy features.
info_print "Enabling colours, animations, and parallel downloads for pacman."
sed -Ei 's/^#(Color)$/\1\nILoveCandy/;s/^#(ParallelDownloads).*/\1 = 10/' /mnt/etc/pacman.conf

# Terminal eyes-candy features.
info_print "Beautify terminal for user $username."
cat <<EOT >> /mnt/home/$username/.bash_profile
# Colors in the terminal
function parse_git_branch_and_add_brackets {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\ \[\1\]/'
  }
export LSCOLORS=CxdxxxxxExxxxxExExCxCx
PS1="\n\e[36m\$(parse_git_branch_and_add_brackets) \e[32;1m\u\e[0m \e[33;1m[\w]\e[0m\n $ "
EOT

# Finishing up.
info_print "Done, you may now wish to reboot (further changes can be done by chrooting into /mnt)."
exit
