#!/bin/bash
#Interactive update program for use with mobile devices
#David Åkesson 2017-2021

#Install (git clone) in $HOME/dev/


INSTLOCATION="$(pwd)"
DEVLOCATION="$HOME/dev/up"

function link () {
	if [ -f "$DEVLOCATION/up" ]; then
		if [ -f "/usr/local/bin/up" ]; then
			sudo rm "/usr/local/bin/up"
		fi
		sudo ln -s "$DEVLOCATION/up" /usr/local/bin/
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
			link
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
			if [ -d "$DEVLOCATION" ]; then
				pushd "$DEVLOCATION"
				git pull
				popd
				exit 0
			else
				printf "\nNo dir found!\n"
			fi
			;;
	esac
}
glenn="e"

while true; do
	if [ $glenn == "q" -a -n $glenn ]; then
		break
	fi

	printf "_.-=*UP*=-._\n\
Interactive update program for use with mobile devices\n\
David Åkesson 2017-2021\n\
	Type corresponding keywords to run:\n\
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
	\t  reb \t reboot \n\
	\t  sup \t Self update (git pull), quit\n"
	read -p "(u/uu/d/c/r/pa/f/ph/l/q/reb/sup): " glenn
case_interact
done