#!/usr/bin/env bash


function take_creds () {
	  printf "\n\"%s\"\n" "The below credentials will be used to login the hosts"
          sleep 1
          echo -n "Username: "
          read username
          echo -n "Password: "
          read -s password
	  user_pass
  }

#Function to take Pin for vault credential encryption 
function user_pass () {
        printf "\n\n%s\n%s%s" "-----------------------------------------------------------------------------------------------------------"\
		"Please enter any password except vcenter password below,this password will be used by ansible-vault 
to encrypt vcenter credentials." "Password should be same for all three prompt"
        printf "\n%s\n%s\n%s\n%s\n" "#This is an example:" "#Enter password(foo): ****" "#New vault password(foo): ****" "#Confirm new vault password (foo): ****"
        printf "%s\n%s%s" "-----------------------------------------------------------------------------------------------------------"    
	sleep 1
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
                for hosts in "${exclude_hosts[@]}";
                do
                        echo "$hosts" >> "$RESOURCE"/exclusion.list
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
take_creds
