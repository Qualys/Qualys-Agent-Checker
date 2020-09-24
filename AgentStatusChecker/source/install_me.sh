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
package=( wget ansible python3 sshpass )
py_pkg=( openpyxl  pathlib Pillow )

#Script path
export GET_PATH=`pwd | sed 's/\/source//'`
export PKG="$GET_PATH/packages"
export SRC="$GET_PATH/source"
export RESOURCE="$GET_PATH/resources"
export OUT="$GET_PATH/excel"


#GOVC LINK
GITLINK="https://github.com/vmware/govmomi/releases/download/v0.23.0"


#Variables
GET_OS=''
PKG_CHECK=true
GOVC_CHECK=true
GET_USER=false

#Function to take user crendtials 
function creds_take () {
  echo "Welcome $USER!"
  cat $RESOURCE/example.txt
  sleep 1;
  printf "%s\n" "Please make sure you have satisfied the dependency"
  echo -n "[y/Y] to procced [n/N] to exit: "
  read  getopt
  if [[ $getopt == y ]] || [[ $getopt == Y ]];
  then 
	  echo "vault_pass" > "$RESOURCE"/password_file
	  chmod -R 755 $RESOURCE
	  echo "" > $RESOURCE/install.log
	  pre_check
	  
  elif [[ $getopt == n ]] || [[ $getopt == N ]];
  then
	  exit 0
  else
	  printf "%s" "Invalid option"
	  exit 1
  fi
}

#Function Pre Checker

function pre_check () {

for i in ${package[@]};
do 
    which $i >> $RESOURCE/install.log 2>&1
    if [[ "$?" != 0 ]];
	then
	    PKG_CHECK=false
	    os_check
	    break
	fi
	PKG_CHECK=true
done

if [[ $PKG_CHECK == "true" ]];
then
	which govc >> $RESOURCE/install.log 2>&1
	if [[ "$?" != 0 ]];
	then
	  os_check
	  break
	fi
	GOVC_CHECK=true
fi

if [[ $GOVC_CHECK == "true" ]];
then
	which pip >> $RESOURCE/install.log 2>&1
	if [[ $? == 0 ]];
	then
		for i in ${py_pkg[@]};
		do
		   pip show $i >> $RESOURCE/install.log 2>&1
		   if [[ "$?" != 0 ]];
		   then
			os_check
			break
		   fi
		done
	else
		which pip3 >> $RESOURCE/install.log 2>&1
		if [[ $? == 0 ]];
		then
			for i in ${py_pkg[@]};
			do
				pip3 show $i >> $RESOURCE/install.log 2>&1
				if [[ "$?" != 0 ]];
				then
					os_check
					break
				fi
			done
		fi
	fi
	$SRC/user_input.sh
fi
 
}

#Function to check Operating System
function os_check () {
case "$OSTYPE" in

  darwin*)
    printf "\n%s\n" "This is Mac Os"
    GET_OS="darwin"
    $SRC/pkg_check.sh $GET_OS
    ;;

  linux*)
    printf "\n%s\n" "This is Linux Os"
    GET_OS="linux"
    $SRC/pkg_check.sh $GET_OS
  ;;
  msys*)
   printf "\n%s\n" "This is Windows Os"
   GET_OS="mysys"
   $SRC/pkg_check.sh $GET_OS
    ;;
  cyg*)
   printf "\n%s\n" "This is Windows Os"
   GET_OS="cyg"
   $SRC/pkg_check.sh $GET_OS
    ;;
  *)
      printf "\n%s\n" "unknown: $OSTYPE"
      exit 1
          ;;
esac
}

creds_take
