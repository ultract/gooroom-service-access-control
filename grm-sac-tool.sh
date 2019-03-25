#!/bin/bash

#
#	Gooroom Service Access Controller
#	
#	Description: Control Authentication Types To Access Gooroom System Services
#   			 ( Make a Gooroom Pkla File for Gooroom System Services by a Identification Number )
#
#	Default Path of a Pkla File : /etc/polkit-1/localauthority/90-mandatory.d/
#

usage(){
	echo "usage: grm-sac-tool.sh -s<service number> -t<authentication type number>
Control Authentication Types for Gooroom System Services

options:
	-s<service number>			Service ID Number to change a permission
	-c					Check Authentication Types of All Services or a Service with -s<action number>
	-d					Delete All Pkla Files in /etc/polkit-1/localauthority/90-mandatory.d/
						Delete Pkla Files of -s<service number>
	-f					Force Mode (Ignore Exist Policy)
	-t<authentication type number>		Number of the Authetication Type for The Action
	-l					Print a List of System Service for Pkla
	-h					Help me!


[ Authentication type numbers ]
  (0)yes, (1)no, (2)auth_self, (3)auth_self_keep, (4)auth_admin, (5)auth_admin_keep

* This program should be run by root permission.

<example>
\$ pkexec /bin/bash -c \"cd \$PWD && ./grm_sac_tool.sh\" -s1 -t0 # Set an Action ID Number & an Authentication Type Number
\$ sudo ./grm-sac-tool.sh -s1 -t0
"
}

perm_check(){
	if [[ $EUID -ne 0 ]]; then
		echo "This script must be run as root" 1>&2
		exit 1
	fi
}

if [[ $# -eq 0 ]]; then
	usage 
	exit 1
fi


while getopts "s:t:cdflh" opt; do
	case ${opt} in
		s)
			perm_check
			service_num="${OPTARG}"
			case ${OPTARG} in
				0)
					# Execute Any File as Another User Permission by pkexec
					action="org.freedesktop.policykit.exec"
					;;
				1)
					# Gooroom Agent - Gooroom User Deivce Register
					action="kr.gooroom.security.status.settings.gcsr"
					;;
				2)
					# Gooroom Agent - Service Enable/Disable
					action="kr.gooroom.security.status.settings.systemctl"
					;;
				3)
					# Network Enable/Disable
					action[0]="org.freedesktop.NetworkManager.network-control"
					action[1]="org.freedesktop.NetworkManager.enable-disable-wifi"
					action[2]="org.freedesktop.NetworkManager.enable-disable-network"
					;;
				4)
					# Network Configuration Modification
					action[0]="org.freedesktop.NetworkManager.settings.modify.own"
					action[1]="org.freedesktop.NetworkManager.settings.modify.system"
					;;
				5)
					# Lid Brightness of Laptop
					action="org.xfce.power.backlight-helper"
					;;
				6)
					# System State - Hibernate
					action[0]="org.freedesktop.login1.hibernate"
					action[1]="org.freedesktop.login1.hibernate-multiple-sessions"
					;;
				7)
					# System State - Power Off
					action[0]="org.freedesktop.login1.power-off"
					action[1]="org.freedesktop.login1.power-off-multiple-sessions"
					;;
				8)
					# System State - Reboot
					action[0]="org.freedesktop.login1.reboot"
					action[1]="org.freedesktop.login1.reboot-multiple-sessions"
					;;
				9)
					# System State - Suspend
					action[0]="org.freedesktop.login1.suspend"
					action[1]="org.freedesktop.login1.suspend-multiple-sessions"
					;;
				10)
					# File System Mount by udisk
					action="org.freedesktop.udisks2.filesystem-mount"
					;;
				11)
					# Gooroom Control Center - Datetime
					action="kr.gooroom.controlcenter.datetime.set"
					;;
				12)
					# Gooroom Control Center - Language
					action[0]="kr.gooroom.controlcenter.language.set"
					action[1]="kr.gooroom.controlcenter.locale.install-remove"
					;;
				13)
					# Gooroom control Center - Local User Setting
					action="kr.gooroom.controlcenter.user.set"
					;;
				14)
					# Gooroom Control Center - Online User Setting
					action="kr.gooroom.controlcenter.online-user.set"
					;;
				15)
					# Gooroom Control Center - Locale
					action="kr.gooroom.controlcenter.locale.install-remove"
					#action[0]="kr.gooroom.controlcenter.locale.install-remove"
					#action[1]="org.freedesktop.locale1.set-locale"
					;;
				16)
					# Gooroom control Center - Printer
					action[0]="org.opensuse.cupspkhelper.mechanism.all-edit"
					action[1]="org.opensuse.cupspkhelper.mechanism.printer-local-edit"
					action[2]="org.opensuse.cupspkhelper.mechanism.class-edit"
					action[3]="org.opensuse.cupspkhelper.mechanism.devices-get"
					action[4]="org.opensuse.cupspkhelper.mechanism.server-settings"
					action[5]="org.opensuse.cupspkhelper.mechanism.printer-remote-edit"
					;;
				17)
					# Gooroom Updater - Synaptic Package Manager
					action="com.ubuntu.pkexec.synaptic"
					;;
				18)
					# Gooroom Updater - Repository Sources
					action="kr.gooroom.sources"
					;;
				19)
					# Additional..
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

			;;
		t)
			perm_check
			case ${OPTARG} in
				0)
					# Yes
					auth_type="yes"	
					;;
				1)
					# No
					auth_type="no"	
					;;
				2)
					# auth_self
					auth_type="auth_self"
					;;
				3)
					# auth_self_keep
					auth_type="auth_self_keep"
					;;
				4)
					# auth_admin
					auth_type="auth_admin"
					;;
				5)
					# auth_admin_keep
					auth_type="auth_admin_keep"
					;;
			esac
			;;
		c)
			perm_check
			check_auth_type="1"
			;;
		d)
			perm_check
			delete_pkla="1"
			;;
		f)
			force_flag="1"
			;;
		l)
			echo "[ Gooroom Local Service List ]"
			echo " 0 : Execute Any File as Another User Permission by pkexec"
			echo " 1 : Gooroom Agent - Gooroom User Device Regiter"
			echo " 2 : Gooroom Agent - Service Enable/Disable"
			echo " 3 : Network Enable/Disable"
			echo " 4 : Network Configuration Modification"
			echo " 5 : Lid Brightness of Laptop"
			echo " 6 : System State - Hibernate"
			echo " 7 : System State - Power Off"
			echo " 8 : System State - Reboot"
			echo " 9 : System State - Suspend"
			echo "10 : File System Mount by udisk"
			echo "11 : Gooroom Control Center - Datetime"
			echo "12 : Gooroom Control Center - Language"
			echo "13 : Gooroom Control Center - Local User Setting"
			echo "14 : Gooroom Control Center - Online User Setting"
			echo "15 : Gooroom Control Center - Locale"
			echo "16 : Gooroom Control Center - Printer"
			echo "17 : Gooroom Updater - Synaptic Package Manager"
			echo "18 : Gooroom Updater - Repository Sources"
			echo "19 : You Can Add Another Policy For New Function!! :)"
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


# Check Authentication Types of a Service via Action Number
if [ -n "$action" ] && [ "$check_auth_type" == "1" ];
then
	echo "[*] Check Authentication Types of The Service"
	sac_status=$(for i in $(seq 0 $((${#action[@]}-1)))
	do
		# Print Each Authentication Type of Actions per The Service
		#echo -n "${action[i]}: "
		case ${service_num} in
			0)
				echo -n " 0: Execute Any File as Another User Permission by pkexec -> "
				;;
			1)
				echo -n " 1: Gooroom Agent - Gooroom User Deivce Register -> "
				;;
			2)
				echo -n " 2: Gooroom Agent - Service Enable/Disable -> "
				;;
			3)
				echo -n " 3: Network Enable/Disable -> "
				;;
			4)
				echo -n " 4: Network Configuration Modification -> "
				;;
			5)
				echo -n " 5: Lid Brightness of Laptop -> "
				;;
			6)
				echo -n " 6: System State - Hibernate -> "
				;;
			7)
				echo -n " 7: System State - Power Off -> "
				;;
			8)
				echo -n " 8: System State - Reboot -> "
				;;
			9)
				echo -n " 9: System State - Suspend -> "
				;;
			10)
				echo -n "10: File System Mount by udisk -> "
				;;
			11)
				echo -n "11: Gooroom Control Center - Datetime -> "
				;;
			12)
				echo -n "12: Gooroom Control Center - Language -> "
				;;
			13)
				echo -n "13: Gooroom control Center - Local User Setting -> "
				;;
			14)
				echo -n "14: Gooroom Control Center - Online User Setting -> "
				;;
			15)
				echo -n "15: Gooroom Control Center - Locale -> "
				;;
			16)
				echo -n "16: Gooroom control Center - Printer -> "
				;;
			17)
				echo -n "17: Gooroom Updater - Synaptic Package Manager -> "
				;;
			18)
				echo -n "18: Gooroom Updater - Repository Sources -> "
				;;
			19)
				# Additional..
				;;

		esac
		# Print Authentication Type of The Actions in /etc/polkit-1/
		tmp_type=$(./grm-pkla-writer.sh -l1 -A"${action[i]}" | grep "ResultActive=" | awk -F'=' '{print $2}')
		echo "$tmp_type"
		if [ -n "$tmp_type" ];
		then
			echo ""
		fi

	done)
	echo "$sac_status" | sort | uniq
	exit

# Print Authentication Types of All Services
elif [ -z "$action" ] && [ "$check_auth_type" == "1" ];
then
	for i in $(seq 0 18)
	do
		"$0" -c -s"$i" | grep -v "\[*\] Check Authentication Types of The Service"
	done
	exit
fi


# Delete Pkla Files of The Action Number
if [ -z "$action" ] && [ "$delete_pkla" == "1" ];
then
	# Delete All pkla Files in /etc/polkit-1/localauthority/90-mandatory.d/
	echo "[*] Delete All pkla Files"
	rm -rf /etc/polkit-1/localauthority/90-mandatory.d/*
	exit
elif [ -n "$action" ] && [ "$delete_pkla" == "1" ];
then
	# Delete a pkla File of The Action
	for i in $(seq 0 $((${#action[@]}-1)))
	do
		echo "[*] Delete a pkla File of The Action: ${action[i]}"
		rm -rf "/etc/polkit-1/localauthority/90-mandatory.d/${action[i]}.pkla"
	done
	exit
fi


# Write Pkla Files for The Service
if [ -n "$action" ] && [ -n "$auth_type" ];
then
	for i in $(seq 0 $((${#action[@]}-1)))
	do
		#echo "${action[i]}"
		# Set Any & InActive Type by Default Polkit Policy
		echo "[-] Remove a Previous Pkla File!"
		rm -rf "/etc/polkit-1/localauthority/90-mandatory.d/${action[i]}.pkla"

		echo "[*] Make a Pkla File for The Action: ${action[i]}"
		if [ -n "$force_flag" ];
		then
			echo "Force Flag Enabled!!"
			force_option="-f"
		fi
		./grm-pkla-writer.sh -I unix-user:* -A "${action[i]}" -a "$(pkaction -v --action-id "${action[i]}" | grep " implicit any:" | awk '{print $3}')" -i "$(pkaction -v --action-id "${action[i]}" | grep " implicit inactive:" | awk '{print $3}')" -c "$auth_type" "$force_option"
	done
else
	echo "No Authentication Type!!"
	exit
fi

##############################

#
# Etc
# Package Update Check
#./grm-pkla-writer.sh -I unix-user:* -A kr.gooroom.package-update -a no -i no -c auth_self_keep

# Pckage Upgrade(Install)
#./grm-pkla-writer.sh -I unix-user:* -A kr.gooroom.synaptic-script -a no -i no -c auth_self_keep


