#!/bin/bash

# caveat emptor

#echo apperture_science_laboratory > /etc/hostname

blue_location=/dev/null
orange_location=/dev/null
export blue_location
export orange_location

shorten () { #{{{
	echo $1 |sed -r 's/.*(.{20})/[...]\1/'
} #}}}
find_surface_closeby () { #{{{
	find ../.. -maxdepth 4 -type d -writable 2>/dev/null |
		grep -vP 'proc|sys|lost\+found' |
		xargs -n1 -I% echo $PWD/% | sort -R | head -n1
} #}}}
getabsdir () { #{{{
	getabsdirtmp=$PWD
	cd $1
	pwd -P
	cd $getabsdirtmp
} #}}}
check_if_applicable () { #{{{
	[ ! -w "$1" ] && return 1
	[ ! -d "$1" ] && return 1
	return 0
} #}}}
mkblue () { #{{{
	[ "$1" != "$blue_location" ] && [ "$blue_location" != /dev/null ] && rmblue
	blue_location="$1"
	orange_location="$2"
	ln -sfT "$orange_location" "$blue_location/blue_portal"
	if [ $orange_location != /dev/null ]; then
		ln -sfT "$blue_location" "$orange_location/orange_portal"
		echo -e "$(shorten $blue_location)/\x1b[34mblue_portal \x1b[1m( )\x1b[0m ... \x1b[1;33m( )\x1b[0m $(shorten $orange_location)/\x1b[33morange_portal\x1b[0m"
	else
		echo -e "$(shorten $blue_location)/\x1b[34mblue_portal (@)\x1b[0m ... \x1b[1m/dev/null\x1b[0m"
	fi
} #}}}
mkorange () { #{{{
	[ "$1" != "$orange_location" ] && [ "$orange_location" != /dev/null ] && rmorange
	orange_location="$1"
	blue_location="$2"
	ln -sfT "$blue_location" "$orange_location/orange_portal"
	if [ $blue_location != /dev/null ]; then
		ln -sfT "$orange_location" "$blue_location/blue_portal"
		echo -e "$(shorten $orange_location)/\x1b[33morange_portal \x1b[1m( )\x1b[0m ... \x1b[1;34m( )\x1b[0m $(shorten $blue_location)/\x1b[34mblue_portal\x1b[0m"
	else
		echo -e "$(shorten $orange_location)/\x1b[33morange_portal \x1b[1m(@)\x1b[0m ... \x1b[1m/dev/null\x1b[0m"
	fi
} #}}}
rmblue () { #{{{
	[ -h "$blue_location/blue_portal" ] && rm "$blue_location/blue_portal"
	blue_location=/dev/null
	[ $orange_location != /dev/null ] && mkorange "$orange_location" /dev/null
} #}}}
rmorange () { #{{{
	[ -h "$orange_location/orange_portal" ] && rm "$orange_location/orange_portal"
	orange_location=/dev/null
	[ $blue_location != /dev/null ] && mkblue "$blue_location" /dev/null
} #}}}
blue () { #{{{
	echo "MAKING A PORTAL"
	if [ -n "$1" ]; then
		if check_if_applicable "$1"; then
			mkblue "$1" "$orange_location"
		else
			echo that is not a surface you can put a portal on
		fi
	else
		mkblue $PWD $orange_location
	fi
} #}}}
orange () { #{{{
	echo "MAKING A PORTAL"
	if [ -n "$1" ]; then
		if check_if_applicable "$1"; then
			mkorange "$1" "$blue_location"
		else
			echo that is not a surface you can put a portal on
		fi
	else
		mkorange $PWD $blue_location
	fi
} #}}}
jump () { #{{{
	echo "JUMPING THROUGH A PORTAL"
	if [ $1 == orange_portal ]; then
		cd orange_portal && \
			echo -e "--> \x1b[33;1m( )\x1b[0m ... \x1b[1;34m( )\x1b[0m $(shorten $blue_location)/\x1b[34mblue_portal\x1b[0m -->"
		cd $(pwd -P)
	elif [ $1 == blue_portal ]; then
		cd blue_portal && \
			echo -e "--> \x1b[34;1m( )\x1b[0m ... \x1b[1;33m( )\x1b[0m $(shorten $orange_location)/\x1b[33morange_portal\x1b[0m -->"
		cd $(pwd -P)
	else
		cd $1
		cd $(pwd -P)
	fi
} #}}}
lets_play () { #{{{
	orange
	blue
	while $(true); do
		case $(expr $RANDOM % 10) in
			0 )
				orange
				jump orange_portal
				;;
			1 )
				blue
				jump blue_portal
				;;
			2 )
				orange
				blue $(getabsdir $(find_surface_closeby))
				jump orange_portal
				;;
			3 )
				blue
				orange $(getabsdir $(find_surface_closeby))
				jump blue_portal
				;;
			*)
				case $(expr $RANDOM % 5) in
					0 )
						blue
						;;
					1 )
						orange
						;;
				esac
				d=$(getabsdir $(find -maxdepth 1 -type d -writable 2>/dev/null |
					grep -vP 'proc|sys|lost\+found|blue_portal|orange_portal' |
					sed s/^\.$/../ | xargs -n1 -I% echo $PWD/% | sort -R | head -n1
					))
				echo WALKING TO $(shorten $d)
				cd $d
				;;
		esac
		echo -e '\n\n'
		sleep 2
	done
} #}}}
