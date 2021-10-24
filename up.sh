#!/bin/bash
#Interactive update program for use with mobile devices
#David Åkesson 2017-2021
#https://github.com/akeda2/up.git

#Install (git clone) in $HOME/dev/ (for example)

VERSION=2021.42.297-153515
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
		if [ -f "$INSTLOCATION" ]; then
			sudo rm "$INSTLOCATION"
		fi
		sudo ln -s "$1" "$INSTLOCATION"
	fi
}

function cont {
	read -p "Continue? " -n 1 -r
        echo    # (optional) move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
               	echo "0"
        else
		exit 1
	fi
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
			update && list-upgradable && cont && dist-upgrade && clean
			;;
		aa)
			update && dist-upgrade && clean
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
			update
			;;
		uu)
			update && upgrade
			;;
		d)
			dist-upgrade
			;;
		ud)
			update && dist-upgrade
			;;
		r)
			rpi-upd
			;;
		c)
			clean
			;;
		a)
			dist-upgrade
			;;
		pa)
			dist-upgrade && pi-upd
			;;
		L)
			#Will run link function for making a symlink in /usr/local/bin
			MYPATH=$(realpath $0)
			link "$MYPATH"
			;;
		l)
			list-upgradable
			;;
		f)
			flatpak update
			;;
		ph)
			pihole-update
			;;
		smb)
			if systemctl is-enabled smbd.service; then
				sudo systemctl restart smbd.service
			fi
			;;
		reb)
			sudo reboot
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
			sudo shutdown -Ph now
			;;
		vprint)
                        #Print version (date) to the file /usr/local/bin/up points to.
			#Only do this if you really want to change the version number (before committing).
			#For obvious reasons, this is a hidden option.
                        UPVER="$(date +%Y.%V.%j-%H%M%S)"
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

	printf "_.-=*UP*=-._ (c)David Åkesson 2017-21 - Version: $VERSION\n\
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
	\t  f \t flatpak-update \n\
	\t  ph \t PiHole-update \n\
	\t  smb \t Samba service restart \n\
	\t  L \t Create symlink (/usr/local/bin/up) \n\
	\t  q \t quit \n\
	\t  qc \t clear screen, then quit \n\
	\t  qe \t quit and exit (kill) shell \n\
	\t  reb \t reboot \n\
	\t  shut \t shutdown \n\
	\t  sup \t Self update (git pull), quit\n"
	read -p "(u/uu/l/d/ud/c/r/a/pa/f/ph/smb/L/q/qe/reb/sup): " glenn
case_interact
done