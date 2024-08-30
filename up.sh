#!/bin/bash
# Interactive update program for use with mobile devices
# David Åkesson 2017-2024
# https://github.com/akeda2/up.git

# Install (git clone) in $HOME/dev/ (for example)

VERSION=2024-08-30.v35.d243-1725025080-153800
INSTLOCATION="/usr/local/bin/up"

#Old string variable used in function below.
DEVLOCATION="$HOME/dev/up"
function link-old {
#Old linking function, do not use. Just here for reference.
	if [ -f "$DEVLOCATION/up" ]; then
		if [ -f "/usr/local/bin/up" ]; then
			sudo rm "/usr/local/bin/up"
		fi
		sudo ln -s "$DEVLOCATION/up" /usr/local/bin/
	fi
}

#New link function. This is used.
function link {
	if [ -f "$1" ]; then
		#[ -f "$INSTLOCATION" ] && sudo rm "$INSTLOCATION"
		sudo ln -sf "$1" "$INSTLOCATION"
	fi
}
areweroot() {
    # Check if we are running as root/sudo
    if [ "$EUID" -ne 0 ]; then
        echo "This script must be run as root or with sudo."
        exit 1
    fi
}
installToUsrLocalBin() {
    # Installs the script to /usr/local/bin
    [[ -f "$1" ]] && sudo install -m 755 "$1" "$INSTLOCATION"
}
make_backup() {
    # Copies the file to /tmp with a .bak extension
    if [ -f "$1" ]; then
        cp -a --remove-destination "$1" /tmp/"$(basename "$1")".bak
    fi
}
function cont {
	# Should we continue? Supply a string to be printed, or use default.
    local ASK="${1:-Continue?}"
    #[[ -z $1 ]] && ASK="Continue? (y/n): " || ASK="$1"
	read -p "$ASK (y/n): " -n 1 -r
        echo    # (optional) move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
               	return
        else
			false
		fi
}
check_reboot() {
    # Checks for /var/run/reboot-required
    [[ -f /var/run/reboot-required ]] && return || false
}
check-reboot-print() {
	# Checks for /var/run/reboot-required
	check_reboot && echo "Reboot required!" || echo "No reboot required"
}

#Various functions, this could just as well be done in the main case,
#but this makes it a bit more flexible.
function list-upgradable {
	sudo apt list --upgradable
}
function pihole-update {
	sudo pihole updatePihole
}
function update {
	sudo apt update
}
function upgrade {
	sudo apt -y upgrade
}
function dist-upgrade {
	sudo apt -y dist-upgrade
}
function rpi-upd {
	sudo rpi-update	
}
function clean {
	sudo apt -y autoremove && sudo apt -y autoclean
}
#Main case
function case_interact (){
	case $glenn in
		a)
			command -v apt && update && list-upgradable && cont "Upgrade?" && upgrade && clean && check-reboot-print
			;;
		aa)
			command -v apt && update && upgrade && clean && check-reboot-print
			;;
		q)
			exit 0
			;;
		qc)
			clear
			exit 0
			;;
		qe)
			kill -9 $PPID
			;;
		u)
			command -v apt && update
			;;
		uu)
			command -v apt && update && upgrade && check-reboot-print
			;;
		d)
			command -v apt && dist-upgrade && check-reboot-print
			;;
		ud)
			command -v apt && update && dist-upgrade && check-reboot-print
			;;
		r)
			command -v rpi-update && rpi-upd
			;;
		c)
			command -v apt && clean
			;;
		pa)
			command -v apt && dist-upgrade
			command -v rpi-update && pi-upd
			;;
		pama*)
			command -v pamac && pamac upgrade
			;;
		L)
			#Will run link function for making a symlink in /usr/local/bin
			MYPATH=$(realpath $0)
			link "$MYPATH"
			;;
		I)
            # Will run installToUsrLocalBin function for installing the script to /usr/local/bin
            MYPATH=$(realpath $0)
            installToUsrLocalBin "$MYPATH"
            ;;
		l)
			command -v apt && list-upgradable
			;;
		f)
			command -v flatpak && flatpak update
			;;
		ff)
			command -v flatpak && sudo flatpak update && flatpak update
			;;
		sn*)
			command -v snap && sudo snap refresh
			;;
		ph)
			command -v pihole && pihole-update
			;;
		smb)
			if systemctl is-enabled smbd.service; then
				sudo systemctl restart smbd.service
			fi
			;;
		rr)
            # Checks for reboot-required
            check-reboot-print
            ;;
		reb)
			cont "Really reboot?" && sudo reboot
			;;
		sup)
			#Self update
			MYPATH="$(dirname $(realpath $0))"
			if [ -d "$MYPATH" ]; then
				pushd "$MYPATH"
				git pull
				pwd
				popd
				exit 0
			else
				printf "\nNo dir found!\n"
			fi
			;;
		shut)
			cont "Really shutdown?!" && sudo shutdown -Ph now
			;;
		vprint)
            #Print version (date) to the file /usr/local/bin/up points to.
			#Only do this if you really want to change the version number (before committing).
			#For obvious reasons, this is a hidden option.
            UPVER="$(date +%Y-%m-%d.v%V.d%j-%s-%H%M%S)"
			vpPath="$(realpath "$0")"
            if [ -f "$vpPath" ]; then
                sudo sed -i "1,10 s/VERSION=.*/VERSION=$UPVER/" "$vpPath"
            fi
			;;
	esac
}
glenn="e"

if [ "$1" ]; then
	glenn="$1"
	case_interact
	exit 0
fi
while true; do
	if [ $glenn == "q" -a -n $glenn ]; then
		break
	fi

	printf "_.-=*UP*=-._ (c)David Åkesson 2017-23 - Version: $VERSION\n\
	Cmdline: $0, Source: $(realpath "$0")\n\
\tType corresponding keywords to run:\n\
	\tAPT: \n\
	\t  u \t update \n\
	\t  uu \t update & upgrade \n\
	\t  l \t list upgradable \n\
	\t  d \t dist-upgrade \n\
	\t  ud \t update & dist-upgrade \n\
	\t  c \t autoremove & autoclean \n\
        \t  a \t all, but ask before upgrading \n\
	\t  aa \t all/auto (update,dist-upgrade,auto-remove/clean) \n\
	\tRPI: \n\
	\t  r \t rpi-update \n\
	\t  pa \t apt update, dist-upgrade & rpi-update \n\
	\tMISC: \n\
	\t  snap   snap refresh \n\
	\t  pamac  pamac upgrade \n\
	\t  f \t flatpak-update \n\
	\t  ff\t f with sudo, then without \n\
	\t  ph \t PiHole-update \n\
	\t  smb \t Samba service restart \n\
	\t  L \t Create symlink (/usr/local/bin/up) \n\
	\t  rr \t Check for reboot-required \n\
	\t  q \t quit \n\
	\t  qc \t clear screen, then quit \n\
	\t  qe \t quit and exit (kill) shell \n\
	\t  reb \t reboot \n\
	\t  shut \t shutdown \n\
	\t  sup \t Self update (git pull), quit\n"
	read -p ": " glenn
case_interact
done