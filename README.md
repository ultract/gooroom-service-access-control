# gooroom-service-access-control
Access Control for Gooroom System Services, e.g. network, printer, etc configuration.

### Prerequisite
- Policy Kit (Version : 0.105)
- Gooroom 1.1 or above

### Usage
    usage: grm-sac-tool.sh -s<service number> -t<authentication type number>
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
    $ pkexec /bin/bash -c "cd $PWD && ./grm_sac_tool.sh" -s1 -t0 # Set an Action ID Number & an Authentication Type Number
    $ sudo ./grm-sac-tool.sh -s1 -t0

Print All Service as a List : 

    $ ./grm-sac-tool.sh -l
    [ Gooroom Local Service List ]
     0 : Execute Any File as Another User Permission by pkexec
     1 : Gooroom Agent - Gooroom User Device Regiter
     2 : Gooroom Agent - Service Enable/Disable
     3 : Network Enable/Disable
     4 : Network Configuration Modification
     5 : Lid Brightness of Laptop
     6 : System State - Hibernate
     7 : System State - Power Off
     8 : System State - Reboot
     9 : System State - Suspend
    10 : File System Mount by udisk
    11 : Gooroom Control Center - Datetime
    12 : Gooroom Control Center - Language
    13 : Gooroom Control Center - Local User Setting
    14 : Gooroom Control Center - Online User Setting
    15 : Gooroom Control Center - Locale
    16 : Gooroom Control Center - Printer
    17 : Gooroom Updater - Synaptic Package Manager
    18 : Gooroom Updater - Repository Sources
    19 : You Can Add Another Policy For New Function!! :)
    No Authentication Type!!

Check Authentication Types of All Services : 

    $ sudo ./grm-sac-tool.sh -c
     0: Execute Any File as Another User Permission by pkexec -> 
     1: Gooroom Agent - Gooroom User Deivce Register -> 
     2: Gooroom Agent - Service Enable/Disable -> 
     3: Network Enable/Disable -> 
     4: Network Configuration Modification -> 
     5: Lid Brightness of Laptop -> 
     6: System State - Hibernate -> 
     7: System State - Power Off -> 
     8: System State - Reboot -> 
     9: System State - Suspend -> 
    10: File System Mount by udisk -> 
    11: Gooroom Control Center - Datetime -> 
    12: Gooroom Control Center - Language -> 
    13: Gooroom control Center - Local User Setting -> 
    14: Gooroom Control Center - Online User Setting -> 
    15: Gooroom Control Center - Locale -> 
    16: Gooroom control Center - Printer -> auth_self_keep
    17: Gooroom Updater - Synaptic Package Manager -> 
    18: Gooroom Updater - Repository Sources -> 


### Acknowledgments
This tool has been developed for access control of the Gooroom platform which is an open source project. This work was supported by Institute for Information & communications Technology Promotion (IITP) grant funded by the Korea government (MSIP) (No.R0236-15-1006, Open Source Software Promotion).
