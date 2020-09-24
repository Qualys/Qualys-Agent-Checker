#!/usr/bin/env bash

#Variable
OS=$1
DAR_PY=false
py_pkg=( openpyxl  pathlib Pillow )
package=( wget ansible python3 pip3 sshpass )
function os_check () {
case "$OS" in

  darwin)
    darwin
    ;;
  linux)
    linux
  ;;
  msys)
   win_pkg
    ;;
  cyg)
   win_pkg
    ;;
  *)
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
		DAR_PY=true
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
                        cp "$PKG"/govc /usr/local/bin/govc
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
                                cp "$PKG"/govc  /usr/local/bin/govc
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
	                if [[ "$i" == "sshpass" ]];
                    then
                        cd $PKG
                        tar -xvf sshpass-1.06.tar.gz >> $RESOURCE/install.log 2>&1
                        cd $PKG/sshpass-1.06;./configure;make install >> $RESOURCE/install.log 2>&1
                        ./install-sh -c -d '/usr/local/bin';/usr/bin/install -c sshpass '/usr/local/bin'
                        ./install-sh -c -d '/usr/local/share/man/man1';/usr/bin/install -c -m 644 sshpass.1 '/usr/local/share/man/man1'
                        which sshpass >> $RESOURCE/install.log 2>&1
                        cd $SRC
                    else
		        apt-get install $i -y >> $RESOURCE/install.log 2>&1
		    fi
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
    $SRC/user_input.sh
}

#Function to setup python library 
function python_pkg () {
	cd $PKG
    printf "\n%s\n" "Installing python library.."
	pip3 install openpyxl pathlib pillow >> $RESOURCE/install.log 2>&1
    if [[ "$?" == 0 ]] && [[ $DAR_PY == "true" ]];
    then
        py_pkg=`pip3 show Pillow | grep -o '\d\.\d\.\d$'| awk -F "." '{print $1}'`
        if [[ $py_pkg -lt 7 ]];
        then
            python3 -m pip install --upgrade pip >> $RESOURCE/install.log 2>&1
            python3 -m pip install --upgrade Pillow >> $RESOURCE/install.log 2>&1
        fi
	elif [[ "$?" == 0 ]];
	then
            printf "%s\n" "python library is installed"
    else
        printf "\n%s" "Something went wrong.."
        exit 1
    fi
    $SRC/user_input.sh 
}
os_check
