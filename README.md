# Qualys-Agent-Checker
Qualys-Agent-Checker

Agent-Status-Checker maintains multiple Ansible roles and mudules that can be deployed to easily configure and manage various parts of the vmwarew and Linux infrastructure. Ansible roles & modules provide a method of modularizing your Ansible code, in other words; it enables you to break up large playbooks into smaller reusable files. This enables you to have a separate role for each component of the infrustructure, and allows you to reuse and share roles with other users. For more information about roles, see Creating Reusable Playbooks in the Ansible Documentation. Module and Roles included bunch of python codes, govc scripts, which help to generate dynamic inventory from vcenter and then getting agent status of all nodes and provided the except report.

Currently we have implemented following Ansible roles:
get.vm-inventory - login to vCenter from via goVC and generate the VM inventory in csv or excel fromat.
get.vm-status - login to vCenter from via goVC and generate the VM inventory with VM status, Running or poweroff.
get.agent-installed - login to hosts with dynamic inventory and generare report where agent installed or where not.
get.agent-status - login to hosts with dynamic inventory and generare report where agent is running where not.
get.agent-status-reporting - login to hosts with dynamic inventory and generare report in excel format with multiple tabs where you can see VM Status, Agent installed and version, running status.
Dependencies
For Windows:

Cygwin should be installed with following packages.

ansible >= 2.8.4
python3 >= 3.6.10
wget >= 1.19.1
pip >= 20.2.3
Cygwin dowload

For Mac:

Latest Xcode should be installed.
[https://developer.apple.com/downloads/index.action]
Running Agent-Status-Checker:
Installing from a unzip:
unzip -d Agent-Status-Checker.zip
Example
Go to Agent-Status-Checker/AgentStatusChecker.
cd Agent-Status-Checker/AgentStatusChecker
Run install_me.sh
sh install_me.sh
During script execuation it asks for some user input please follow the setup
a) Promt for confirmation of Satisfied dependencies
b) Take User Credentials

Username with sudo access: foo
Password: *****
c) After below message we have to enter password(please do not enter sudo password),please make sure password should be same for all three prompt.

e.g

"Generate vault encrypted password from user credentials,Password should be same for all three prompt".

"Note: Please do not enter sudo password".

Enter password(foo): *****
New vault password (foo): *****
Confirm new vault password (foo): *****
d) Enter Govc Credentials for login

Please input the number of GOVC URLs: X
Please input your GOVC IP 1 : x.x.x.x
Please input your GOVC username 1 : xyz
GOVC password 1 : ****

