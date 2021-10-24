# up
Interactive update program for use when ssh:ing from mobile devices.

Clone repo and run  `./up.sh`
Press `L` in the interactive menu to create a symlink in `/usr/local/bin`.
Use `sup` for self-update. This just runs a `git pull` in your local repo.

```
	Type corresponding keywords to run:
		APT: 
		  u 	 update 
		  uu 	 update & upgrade 
		  l 	 list upgradable 
		  d 	 dist-upgrade 
		  ud 	 update & dist-upgrade 
		  c 	 autoremove & autoclean 
		  a 	 all (update,dist-upgrade,a-remove/clean) 
		RPI: 
		  r 	 rpi-update 
		  pa 	 apt update, dist-upgrade & rpi-update 
		MISC: 
		  f 	 flatpak-update 
		  ph 	 PiHole-update 
		  smb 	 Samba service restart 
		  L 	 Create symlink (/usr/local/bin/up) 
		  q 	 quit 
		  qc 	 clear screen, then quit 
		  qe 	 quit and exit (kill) shell 
		  reb 	 reboot 
		  shut 	 shutdown 
		  sup 	 Self update (git pull), quit
(u/uu/l/d/ud/c/r/a/pa/f/ph/smb/L/q/qe/reb/sup):
```
