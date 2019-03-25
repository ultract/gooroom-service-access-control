#!/bin/bash

#
# Gooroom Policy Kit Local Authority File Writer
#
# Ex) $ pkexec /home/ultract/grm-pkla-writer.sh 
#       -I unix-user:* -A com.example.awesomeproduct.* 
#       -a no - -i no -c yes
#
#
#   - Pkla file Data
#
#     [Gooroom Polkit Local Authority]
#     Identity=unix-user:*
#     Action=com.example.awesomeproduct.*
#     ResultAny=no
#     ResultInactive=no
#     ResultActive=yes
#
#
#     Default Path of Pkla Files : /etc/polkit-1/localauthority/90-mandatory.d/com.example.awesomeproduct.pkla


# Path for Policy Kit Local Authority
pkla_file_path="/etc/polkit-1/localauthority/90-mandatory.d/"

usage(){
	echo "Usage: grm-pkla-writer.sh -I<Identity> -A<Action> -a<ResultAny> -i<ResultInactive> -c <ResultActive>
Gooroom Policy Kit Local Authority File Writer

Options:
	-I<Identity>		Users or Groups, e.g. unix-user, unix-group, unix-netgroup
	-A<Action>		Policy Kit Action for Control by Local Authority(Run pkaction command)
	-a<ResultAny>		Authentication Type for Remote Process
	-i<ResultInactive>	Authentication Type for Not X-Desktop Local Process(tty terminal)
	-c<ResultActive>	Authentication Type for X-Desktop Local Process
	-d<Action>		Details about The Action
	-f			(Enforce) Ignore Already Exist Pkla File
	-l<0,1,2>		Print Policy Kit Local Authority Files 
				0:All, 1:/etc/polkit-1/, 2:/var/lib/polkit-1
	-h			Help Me!


Authentication Types are  \"yes, no, auth_self, auth_self_keep, auth_admin and auth_admin_keep\"
The Policy Kit Local Authority file(*.pkla will be written in /etc/polkit-1/localauthority/90-mandatory.d/
This program should be run by root permission.

<Example>
\$pkexec /home/../grm-pkla-writer.sh -I unix-user:* -A com.example.awesomeproduct.* -a no -i no -c yes
\$sudo ./grm-pkla-writer.sh -I unix-user:* -A com.example.awesomeproduct.* -a no -i no -c yes
"
}

perm_check(){
	if [[ $EUID -ne 0 ]]; then
		echo "This script must be run as root" 1>&2
		exit 1
	fi
}

#<<'COMMENT'
if [[ $# -eq 0 ]]; then
	usage
	exit 1
fi
#COMMENT

while getopts "I:A:a:i:c:d:fl:h" opt; do
	case ${opt} in
		I)
			perm_check
			if [[ -z $(echo "${OPTARG}" | grep "unix-user:\|unix-group:\|unix-netgroup:") ]]; then
				echo "Wrong identity!"
				exit 1
			fi
			id=${OPTARG}
			;;
		A)
			perm_check
			action=${OPTARG}
			;;
		a)
			perm_check
			if [[ -z $(echo "${OPTARG}" | grep "yes\|no\|auth_self\|auth_self_keep\|auth_admin\|auth_admin_keep") ]]; then
				echo "Wrong ResultAny Value!"
				exit 1
			fi
			r_any=${OPTARG}
			;;
		c)
			perm_check
			if [[ -z $(echo "${OPTARG}" | grep "yes\|no\|auth_self\|auth_self_keep\|auth_admin\|auth_admin_keep") ]]; then
				echo "Wrong ResultActive Value!"
				exit 1
			fi
			r_active=${OPTARG}
			;;
		d)
			/usr/bin/pkaction --action-id "${OPTARG}" --verbose
			exit
			;;
		f)
			;;
		i)
			perm_check
			if [[ -z $(echo "${OPTARG}" | grep "yes\|no\|auth_self\|auth_self_keep\|auth_admin\|auth_admin_keep") ]]; then
				echo "Wrong ResultInactive Value!"
				exit 1
			fi
			r_inactive=${OPTARG}
			;;

		l)
			perm_check
			print_opt=${OPTARG}
			print_pkla="1"
<<'COMMENT'			
			# /etc/polkit-1/localauthority
			echo "================================"
			echo "/etc/polkit-1/localauthority"
			echo "================================"
			find /etc/polkit-1/localauthority -type f -name "*.pkla" -print -exec cat {} \; -exec echo "" \; 2>/dev/null
			
			# /var/lib/polkit-1/localauthority
			echo "================================"
			echo "/var/lib/polkit-1/localauthority"
			echo "================================"
			find /var/lib/polkit-1/localauthority -type f -name "*.pkla" -print -exec cat {} \; -exec echo "" \; 2>/dev/null
			exit
COMMENT
			;;
		h)
			usage
			exit
			;;
		?) 
			usage
			exit
			;;
		*)	
			usage
			exit
			;;
	esac
done

# Print Policies of Pkla Files in Directory
if [ -z "$action"  ] && [ "$print_pkla" == "1" ];
then
	if [ "$print_opt" == "0" ] || [ "$print_opt" == "1" ];
	then
		# /etc/polkit-1/localauthority
		echo "================================"
		echo "/etc/polkit-1/localauthority"
		echo "================================"
		find /etc/polkit-1/localauthority -type f -name "*.pkla" -print -exec cat {} \; -exec echo "" \; 2>/dev/null
	fi

	if [ "$print_opt" == "0" ] || [ "$print_opt" == "2" ];
	then
		# /var/lib/polkit-1/localauthority
		echo "================================"
		echo "/var/lib/polkit-1/localauthority"
		echo "================================"
		find /var/lib/polkit-1/localauthority -type f -name "*.pkla" -print -exec cat {} \; -exec echo "" \; 2>/dev/null
	fi

	exit

# Print Policies of Pkla Files Matching a Action
elif [ -n "$action" ] && [ "$print_pkla" == "1" ];
then

	if [ "$print_opt" == "0" ] || [ "$print_opt" == "1" ];
	then
		# /etc/polkit-1/localauthority
		grep -r "Action=" /etc/polkit-1/localauthority | grep "$action" | awk -F':' '{print $1}' | while read line;
		do
			echo "$line"
			cat "$line"
		done
	fi

	if [ "$print_opt" == "0" ] || [ "$print_opt" == "2" ];
	then
		# /var/lib/polkit-1/localauthority
		grep -r "Action=" /var/lib/polkit-1/localauthority | grep "$action" | awk -F':' '{print $1}' | while read line;
		do
			echo "$line"
			cat "$line"
		done
	fi

	exit
fi

# Write Pkla File
if [ -n "$action" ] && [ -n "$id" ] && [ -n "$r_any" ] && [ -n "$r_inactive" ] && [ -n "$r_active" ];
then
	# Check Policy Kit Local Authority Files in /var/lib/polkit-1/localautority
	var_plka="$(find /var/lib/polkit-1/localauthority -type f -name "*.pkla" -print -exec cat {} \; 2>/dev/null | grep "Action=" | awk -F'=' '{print $2}')"
	# Check Policy Kit Local Authority Files in /etc/polkit-1/localautority
	etc_plka="$(find /etc/polkit-1/localauthority -type f -name "*.pkla" -print -exec cat {} \; 2>/dev/null | grep "Action=" | awk -F'=' '{print $2}')"

	# Check Force Option
	for argv in "$@"
	do
			if [ "$argv" == "-f" ];then
					force_flag=1
			fi
	done

	# Check Existing Policy Kit Action
	if [[ -z $(/usr/bin/pkaction | grep "${action}") ]]; then
		echo "Not Exist Action!"
		exit 1

	elif [[ -n $(echo "$var_plka" | grep "^${action}$") ]] || [[ -n $(echo "$etc_plka" | grep "^${action}$") ]] && [[ $force_flag -ne 1 ]]; then
		echo "The Pkla File is Already Exist! :("
		echo "Check Duplication Pkla File!"
		echo "To Ignore, Use Force(-f) Option together"
		exit 1
	fi

	echo "id=$id action=$action resultany=$r_any resultinactive=$r_inactive resultactive=$r_active"

	pkla_data="[Gooroom Polkit Local Authority]\n"
	pkla_data=$pkla_data"Identity=$id\n"
	pkla_data=$pkla_data"Action=$action\n"
	pkla_data=$pkla_data"ResultAny=$r_any\n"
	pkla_data=$pkla_data"ResultInactive=$r_inactive\n"
	pkla_data=$pkla_data"ResultActive=$r_active\n"

	pkla_file="$(echo "$action" | sed 's/\.\*//g').pkla"

	pkla_file="$pkla_file_path$pkla_file"

	echo "$pkla_file"
	echo -e "$pkla_data"

	if [[ -f "$pkla_file" ]]; then
		rm -rf "$pkla_file"
	fi

	echo -e "$pkla_data" > "$pkla_file"

	if [[ -f "$pkla_file" ]]; then
		echo "[*] pkla file created successfully!"
	fi

fi
