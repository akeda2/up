#!/bin/bash -x
#Interactive update program for use with mobile devices
#David Åkesson 2017-2021

#Install (git clone) in $HOME/dev/

VERSION=
INSTLOCATION="/usr/local/bin/up"
DEVLOCATION="$HOME/dev/up"

function link-old () {
	if [ -f "$DEVLOCATION/up" ]; then
		if [ -f "/usr/local/bin/up" ]; then
			sudo rm "/usr/local/bin/up"
		fi
		sudo ln -s "$DEVLOCATION/up" /usr/local/bin/
	fi
}
function link () {
	if [ -f "$1" ]; then
		if [ -f "$INSTLOCATION" ]; then
			sudo rm "$INSTLOCATION"
		fi
		sudo ln -s "$1" "$INSTLOCATION"
	fi
}
function list-upgradable () {
	sudo apt list --upgradable
}
function pihole-update () {
	sudo pihole updatePihole
}
function update () {
	sudo apt update
}
function upgrade () {
	sudo apt -y upgrade
}
function dist-upgrade () {
	sudo apt -y dist-upgrade
}
function rpi-upd (){
	sudo rpi-update	
}
function clean (){
	sudo apt -y autoremove && sudo apt -y autoclean
}

function case_interact (){
	case $glenn in
		q)
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
		vp)
                        #Print version (date) to this file
                        UPVER="$(date +%Y.%V.%j)"
                        if [ -f "/usr/local/bin/up" ]; then
                               sudo sed -i "1,10 s/VERSION=.*/VERSION=$UPVER/" "/usr/local/bin/up"
                        fi
			;;
	esac
}
glenn="e"

while true; do
	if [ $glenn == "q" -a -n $glenn ]; then
		break
	fi

	printf "$0"
	printf "Version: $VERSION"
	printf "_.-=*UP*=-._\n\
Interactive update program for use with mobile devices\n\
David Åkesson 2017-2021\n\
\tType corresponding keywords to run:\n\
	\tAPT: \n\
	\t  u \t update \n\
	\t  uu \t update & upgrade \n\
	\t  l \t list upgradable \n\
	\t  d \t dist-upgrade \n\
	\t  ud \t update & dist-upgrade \n\
	\t  c \t autoremove & autoclean \n\
	\tRPI: \n\
	\t  r \t rpi-update \n\
	\t  pa \t apt update, dist-upgrade & rpi-update \n\
	\tMISC: \n\
	\t  f \t flatpak-update \n\
	\t  ph \t PiHole-update \n\
	\t  L \t link \n\
	\t  q \t quit \n\
	\t  qe \t quit and exit (kill) shell \n\
	\t  reb \t reboot \n\
	\t  shut \t shutdown \n\
	\t  sup \t Self update (git pull), quit\n"
	read -p "(u/uu/l/d/ud/c/r/pa/f/ph/L/q/qe/reb/sup): " glenn
case_interact
done