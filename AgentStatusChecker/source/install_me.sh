#!/usr/bin/env bash

###########################################################################################################
#
#    DESCRIPTION:  Install requirements for Agent-Status-Checker and generate report Agent-Status
#    REQUIREMENTS:  Unix/Linux based Operating System
#    VERSION:  1.0.0
#    
#
###########################################################################################################

###################################################################################
#
#  VARIABLE DECLARATION
#
###################################################################################

# Program version
declare -r VERSION="1.0"

# Script name
declare -r SCRIPTNAME=$(basename $0)

# Program name
declare -r PROGNAME='Agentinstall'

#Required packages
package=( wget ansible python3 pip3 python3-pip )
#Script path
GET_PATH=`pwd | sed 's/\/source//'`
PKG="$GET_PATH/packages"
SRC="$GET_PATH/source"
RESOURCE="$GET_PATH/resources"
OUT="$GET_PATH/excel"

#GOVC LINK
GITLINK="https://github.com/vmware/govmomi/releases/download/v0.23.0"


#Function to take user crendtials 
function creds_take () {
  echo "Welcome $USER!"
  cat $RESOURCE/example.txt
  sleep 1;
  echo -n "press y/Y if you have already satisfied dependency: "
  read getopt
  if [[ $getopt == y ]] || [[ $getopt == Y ]];
  then 
	  printf "%s\n\n%s\n%s\n\n" "Please Enter your Sudo credentials" "#Username with sudo access: abc" "#Password: ****"
	  sleep 1
	  echo -n "Username with sudo access: "
	  read username
	  echo -n "Password: "
	  read -s password
	  echo "vault_pass" > "$RESOURCE"/password_file
	  os_check
	  
  else
	  exit 1
  fi
}

#Function to check Operating System
function os_check () {
case "$OSTYPE" in

  darwin*)
    printf "\n%s\n" "This is Mac Os"
    darwin
    ;;

  linux*)
    printf "\n%s\n" "This is Linux Os"
    linux
  ;;
  msys*)
   printf "\n%s\n" "This is Windows Os"
   win_pkg
    ;;
  cyg*)
   printf "\n%s\n" "This is Windows Os"
   win_pkg
    ;;
  *)
      printf "\n%s\n" "unknown: $OSTYPE"
          exit 1
          ;;
esac
}

###################################################################################
#							  
# Required Package Install 
#							  
###################################################################################

#Mac Os package install
function darwin () {
        printf "\n%s\n" "Checking required packages.."
    for i in ${package[@]}; do
                which $i >> $RESOURCE/install.log 2>&1
                if [[ "$?" != 0 ]];then
                        printf "\n%s\n" "Installing package $i"
                        if [[ "$i" == "sshpass" ]];
                        then
                                cd $PKG
                                gzip -d sshpass-1.06.tar.gz;tar -xvf sshpass-1.06.tar >> $RESOURCE/install.log 2>&1
                                cd $PKG/sshpass-1.06;./configure;make install >> $RESOURCE/install.log 2>&1
                                ./install-sh -c -d '/usr/local/bin';/usr/bin/install -c sshpass '/usr/local/bin'
                                ./install-sh -c -d '/usr/local/share/man/man1';/usr/bin/install -c -m 644 sshpass.1 '/usr/local/share/man/man1'
                                which sshpass >> $RESOURCE/install.log 2>&1
                                cd $SRC
                        else
                        brew install $i  >> $RESOURCE/install.log 2>&1
                        fi
                else
                        printf "%s\n" " $i package is already present"
                fi
    done
    dar_pkg
}
# Linux packages install
function linux () {
    which yum
    if [[ ""$?"" == 0 ]];then
       cent_pkg
    else
      deb_pkg
    fi
}

##############################											
#
#  GOVC SETUP		   	
#  	    
##############################


# Windows packages install and setup govc
function win_pkg () {
    printf "\n%s\n" "Checking required packages.."
        for i in ${package[@]};
        do
                which $i >> $RESOURCE/install.log 2>&1
                if [[ "$?" != 0 ]]; then
                   apt-cyg install $i -y >> $RESOURCE/install.log 2>&1
                else
                        printf "%s\n" " $i package is already present"
                fi
        done
        printf "\n%s\n" "Checking govc "
        govc version >> $RESOURCE/install.log 2>&1
        if [[ "$?" == 0 ]];then
                printf "%s\n" "Govc is already installed"
                win_python
        else
                printf "%s\n" "Installing govc"
                if [[ -f  "$PKG"/govc_windows_amd64.exe ]] || [[ -f "$PKG"/govc_windows_amd64.exe.zip ]];
				then
                        chmod +x "$PKG"/govc_windows_amd64.exe
                        cp "$PKG"/govc_windows_amd64.exe /usr/bin/govc_windows_amd64.exe
						ln -s /usr/bin/govc_windows_amd64.exe /usr/bin/govc
                        which govc >> $RESOURCE/install.log 2>&1
                        if [[ "$?" == 0 ]];then
                                printf "\n\n%s\n" "Govc setup is completed "
                        else
                                printf  "\n%s\n" "Unable to install Govc"
                        exit 1
                        fi

                else
                        printf "\n%s\n" "Govc package not found downloading.."
						cd $RESOURCE
                        wget $GITLINK/govc_windows_amd64.exe.zip
						cd $GET_PATH
                        if [[ -f "$PKG/govc_windows_amd64.exe.zip" ]];then
							unzip govc_windows_amd64.exe.zip;chmod +x "$PKG"/govc_windows_amd64.exe
							cp "$PKG"/govc_windows_amd64.exe /usr/bin/govc_windows_amd64.exe
							ln -s /usr/bin/govc_windows_amd64.exe /usr/bin/govc
							which govc >> $RESOURCE/install.log 2>&1
                            if [[ "$?" == 0 ]];then
                                printf "\n\n%s\n" "Govc setup is completed "
                            else
                                    printf  "\n%s\n" "Unable to install Govc"
                                    exit 1
                            fi

                        else
                                printf "\n%s\n" "Failed to download govc.."
                                exit 1
                        fi

                fi
                
			win_python
    fi
}

function dar_pkg () {
        printf "\n%s\n" "Checking govc "
        govc version >> $RESOURCE/install.log 2>&1
        if [[ "$?" == 0 ]];then
                printf "%s\n" "Govc is already installed"
                python_pkg
        else
                printf "%s\n" "Installing govc"
                if [[ -f  "$PKG"/govc_darwin_amd64.gz ]] || [[ -f "$PKG"/govc_darwin_amd64 ]];
				then
                        gzip -d "$PKG"/govc_darwin_amd64.gz;chmod +x "$PKG"/govc_darwin_amd64;mv "$PKG"/govc_darwin_amd64 "$PKG"/govc
                        cp "$PKG"/govc /usr/local/bin/govc
                        which govc >> $RESOURCE/install.log 2>&1
                        if [[ "$?" == 0 ]];then
                                printf "\n\n%s\n" "Govc setup is completed "
                        else
                                printf  "\n%s\n" "Unable to install Govc"
                                exit 1
                        fi

                else
                        printf "\n%s\n" "Govc package not found downloading.."
						cd $RESOURCE
                        wget $GITLINK/govc_darwin_amd64.gz
						cd $GET_PATH
                        if [[ -f "$PKG"/govc_darwin_amd64.gz ]];then
                                gzip -d "$PKG"/govc_darwin_amd64.gz;chmod +x "$PKG"/govc_darwin_amd64;mv "$PKG"/govc_darwin_amd64 "$PKG"/govc
                                cp "$PKG"/govc  /usr/local/bin/govc
                                which govc >> $RESOURCE/install.log 2>&1
                                if [[ "$?" == 0 ]];then
                                        printf "\n\n%s\n" "Govc setup is completed "
                                else
                                        printf  "\n%s\n" "Unable to install Govc"
                                        exit 1
                                fi

                        else
                                printf "\n%s\n" "Failed to download govc.."
                                exit 1
                        fi

                fi
                python_pkg
    fi
}


function cent_pkg () {
        printf "\n%s\n" "Checking required packages.."
        for i in ${package[@]}; do
                which $i
                if [[ "$?" != 0 ]];then
                printf "%s" "Installing package $i"
                yum install $i -y  >> $RESOURCE/install.log 2>&1
                else
                        printf "%s\n" " $i package is already present"
                fi
        done
        printf "\n%s\n" "Checking govc "
        govc version >> $RESOURCE/install.log 2>&1
        if [[ "$?" == 0 ]];then
                printf "%s\n" "Govc is already installed"
        python_pkg
        else
                printf "%s\n" "Installing govc"
                if [[ -f  "$PKG"/govc_linux_amd64.gz ]] ||  [[ -f "$PKG"/govc_linux_amd64 ]];
				then
                        gzip -d "$PKG"/govc_linux_amd64.gz;chmod +x "$PKG"/govc_linux_amd64;mv "$PKG"/govc_linux_amd64 "$PKG"/govc
                        sudo cp "$PKG"/govc /usr/local/bin/govc
                        which govc >> $RESOURCE/install.log 2>&1
                        if [[ "$?" == 0 ]];then
                                printf "\n%s\n" "Govc setup is completed "
                        else
                                printf  "\n%s\n" "Unable to install Govc"
                                exit 1
                        fi

                else
                        printf "\n%s\n" "Govc package not found downloading.."
						cd $RESOURCE
                        wget $GITLINK/govc_linux_amd64.gz
						cd $GET_PATH
                        if [[ -f "$PKG"/govc_linux_amd64.gz ]];then
                                gzip -d "$PKG"/govc_linux_amd64.gz;chmod +x "$PKG"/govc_linux_amd64;mv "$PKG"/govc_linux_amd64 "$PKG"/govc
                                sudo cp "$PKG"/govc  /usr/local/bin/govc
                                which govc >> $RESOURCE/install.log 2>&1
                                if [[ "$?" == 0 ]];then
                                        printf "\n\n%s" "Govc setup is completed "
                                else
                                        printf  "\n%s\n" "Unable to install Govc"
                                        exit 1
                                fi

                        else
                                printf "\n%s" "Failed to download govc.."
                        exit 1
                        fi
                fi
    fi
        python_pkg

}

function deb_pkg () {
        printf "\n%s\n" "Checking required packages.."
        for i in ${package[@]}; do
                which $i >> $RESOURCE/install.log 2>&1
                if [[ "$?" != 0 ]]; then
                apt-get install $i -y >> $RESOURCE/install.log 2>&1
                else
                        printf "%s\n" " $i package is already present"
                fi
        done
        printf "\n%s\n" "Checking govc "
        govc version >> $RESOURCE/install.log 2>&1
        if [[ "$?" == 0 ]];then
                printf "%s\n" "Govc is already installed"
                python_pkg
        else
                printf "%s\n" "Installing govc"
                if [[ -f  "$PKG"/govc_linux_amd64.gz ]] || [[ -f  "$PKG"/govc_linux_amd64 ]];
				then
                        gzip -d "$PKG"/govc_linux_amd64.gz;chmod +x "$PKG"/govc_linux_amd64;mv "$PKG"/govc_linux_amd64 "$PKG"/govc
                        sudo cp "$PKG"/govc /usr/local/bin/govc
                        which govc >> $RESOURCE/install.log 2>&1
                        if [[ "$?" == 0 ]];then
                                printf "\n\n%s\n" "Govc setup is completed "
                        else
                                printf  "\n%s\n" "Unable to install Govc"
                        exit 1
                        fi

                else
                        printf "\n%s\n" "Govc package not found downloading.."
						cd $RESOURCE
                        wget $GITLINK/govc_linux_amd64.gz
						cd $GET_PATH
                        if [[ -f "$PKG/govc_linux_amd64.gz" ]];then
                                gzip -d "$PKG/govc_linux_amd64.gz";chmod +x "$PKG"/govc_linux_amd64;mv "$PKG"/govc_linux_amd64 "$PKG"/govc
                                sudo cp "$PKG"/govc  /usr/local/bin/govc
                                which govc >> $RESOURCE/install.log 2>&1
                                if [[ "$?" == 0 ]];then
                                        printf "\n\n%s\n" "Govc setup is completed "
                                else
                                        printf  "\n%s\n" "Unable to install Govc"
                                        exit 1
                                fi

                        else
                                printf "\n%s\n" "Failed to download govc.."
                                exit 1
                        fi

                fi
                python_pkg
    fi
}

##############################
#					        
# Python libraries install  
#                           
##############################
function win_python () {
	printf "\n%s\n" "Installing python library.."
	python3 -m ensurepip >> $RESOURCE/install.log 2>&1
	cd $PKG;pip -q install  openpyxl  pathlib Pillow
	if [[ "$?" == 0 ]]; then
		py_pkg=`pip3 show Pillow | grep -o '\d\.\d\.\d$'| awk -F "." '{print $1}'`
		if [[ $py_pkg -lt 7 ]];
		then
			python3 -m pip install --upgrade pip >> $RESOURCE/install.log 2>&1
			python3 -m pip install --upgrade Pillow >> $RESOURCE/install.log 2>&1
		fi
			printf "%s\n" "python library is installed"
		else
			printf "\n%s" "Something went wrong.."
			exit 1
	fi
    user_pass
}

#Function to setup python library 
function python_pkg () {
        printf "\n%s\n" "Installing python library.."
        cd $PKG;pip3 -q install  openpyxl  pathlib Pillow
        if [[ "$?" == 0 ]]; then
                py_pkg=`pip3 show Pillow | grep -o '\d\.\d\.\d$'| awk -F "." '{print $1}'`
                if [[ $py_pkg -lt 7 ]];
                then
                   python3 -m pip install --upgrade pip >> $RESOURCE/install.log 2>&1
                   python3 -m pip install --upgrade Pillow >> $RESOURCE/install.log 2>&1
                fi
                printf "%s\n" "python library is installed"
        else
                printf "\n%s" "Something went wrong.."
                exit 1
        fi
        user_pass
}

#Function to take Pin for vault credential encryption 
function user_pass () {
        printf "\n%s\n" "#Generate vault encrypted password from user credentials,Password should be same for all three prompt" "#Note: Please do not enter sudo password: "
        printf "\n%s\n%s\n%s\n%s\n\n" "#This is an example:" "#Enter password(foo): ****" "#New vault password (foo): ****" "#Confirm new vault password (foo): ****"
        sleep 2
        echo -n  "Enter password($username): "
        read -s pin
        echo "$pin" > "$RESOURCE"/password_file
        printf "%s\n" ""
        encrypt_pass=`ansible-vault encrypt_string --vault-id $username@prompt $password --name 'ansible_password'`
        echo -e "$username\n$encrypt_pass" > "$RESOURCE"/get_pass.txt
        if [[ -f "$RESOURCE"/get_pass.txt ]];
        then
                collect_inv
        else
                printf "%s" "Unable to encrypt password"
                exit 1
        fi

}

#Function to collect the hosts from vcenter and generate inventory 
function collect_inv () {
        printf "\n%s\n" "Executing collect_inv"
        printf "%s\n%s\n%s\n%s\n%s\n\n"  "#This is an example" "#Please input the number of GOVC IP: X" "#Please input your GOVC IP X: x.x.x.x " "#Please input your GOVC username X : abc@example.com" "#GOVC password X : ****"
        sleep 1
        python3 "$SRC"/collect_inv_from_govc.py
        if [[ $? == 0 ]];
        then
                printf "\n%s\n" "collect_inv is completed.."
                gen_out
        else
                printf "\n%s\n" "Something went worng"
                exit 1
        fi
}

#Function to get the hosts agent status and generate the excel sheet 
function gen_out () {
        echo -n "Do you want to exclude any host Y/N: "
        read option
        if [[ "$option" == y ]] || [[ "$option" == Y ]];then
                read -p "Enter the hosts names separated by space: " -a exclude_hosts
                for hosts in "{exclude_hosts[@]}";
                do
                        echo "$i" >> "$RESOURCE"/exclusion.list
                done
                python3 "$SRC"/main.py
                if [[ $? == 0 ]];then
                        printf "\n%s\n" "Generating file"
                        if [[ -f "$OUT"/Agent_Status.xlsx ]];
                        then
                                printf "%s" "Script is completed,Agent Status Excel Sheet is generated at excel directory"
								rm -f "$RESOURCE"/password_file
								open $OUT/Agent_Status.xlsx >> $RESOURCE/install.log 2>&1

                        else
                                printf "%s" "Error generating Agent_status excel sheet"
                                exit 1
                        fi
                fi
        elif [[ "$option" == n ]] || [[ "$option" = N ]];then
                python3 "$SRC"/main.py
                if [[ $? == 0 ]];
                then
                    printf "\n%s" "Script is completed,Agent Status Excel Sheet is generated at excel directory"
					rm -f "$RESOURCE"/password_file
					open $OUT/Agent_Status.xlsx >> $RESOURCE/install.log 2>&1
			
                fi
        else
                printf "\n%s\n" "Invalid option"
                exit 1
        fi

}

creds_take
