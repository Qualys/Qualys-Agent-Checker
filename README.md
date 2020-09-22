# Agent-Status-Checker

Agent-Status-Checker maintains multiple Ansible roles and mudules that can be deployed to easily configure and manage various parts of the vmwarew and Linux infrastructure. Ansible roles & modules provide a method of modularizing your Ansible code, in other words; it enables you to break up large playbooks into smaller reusable files. This enables you to have a separate role for each component of the infrustructure, and allows you to reuse and share roles with other users. For more information about roles, see Creating Reusable Playbooks in the Ansible Documentation. Module and Roles included bunch of python codes, govc scripts, which help to generate dynamic inventory from vcenter and then getting agent status of all nodes and provided the except report.

### Currently we have implemented following Ansible roles:

- <code>get.vm-inventory</code> - login to vCenter from via goVC and generate the VM inventory in csv or excel fromat. 
- <code>get.vm-status</code> - login to vCenter from via goVC and generate the VM inventory with VM status, Running or poweroff.
- <code>get.agent-installed</code> - login to hosts with dynamic inventory and generare report where agent installed or where not.
- <code>get.agent-status</code> - login to hosts with dynamic inventory and generare report where agent is running where not.
- <code>get.agent-status-reporting</code> - login to hosts with dynamic inventory and generare report in excel format with multiple tabs where you can see VM Status, Agent installed and version, running status.


### Dependencies
 1) For Windows:
 
    - Cygwin should be installed with following packages.
	
      - ansible >= 2.8.4
	  - python3 >= 3.6.10
	  - wget    >= 1.19.1
	  - pip     >= 20.2.3
	  
	[Cygwin dowload](https://cygwin.com/install.html)   
	
	
  2) For Mac:
  
    - Latest Xcode should be installed.
	
	[https://developer.apple.com/downloads/index.action]
 
 
### Running Agent-Status-Checker:


### Installing from a unzip:
<code>
unzip -d Agent-Status-Checker.zip
</code>

### Example

1) Go to Agent-Status-Checker/AgentStatusChecker.

<code>
cd Agent-Status-Checker/AgentStatusChecker
</code>

2) Run install_me.sh

<code>
sh install_me.sh
</code>

3) During script execuation it asks for some user input please follow the setup

<code>
a) Promt for confirmation of Satisfied dependencies

b) Take User Credentials

  - Username with sudo access:  foo
  - Password: *****

c) After below message we have to enter password(please do not enter sudo password),please make sure password should be same for all three prompt.

e.g
 - "Generate vault encrypted password from user credentials,Password should be same for all three prompt".
 - "Note: Please do not enter sudo password".
 

   - Enter password(foo): *****
   - New vault password (foo): *****
   - Confirm new vault password (foo): *****

 
d) Enter Govc Credentials for login
 

   - Please input the number of GOVC URLs: X
   - Please input your GOVC IP 1 : x.x.x.x
   - Please input your GOVC username 1 : xyz
   - GOVC password 1 : ****
</code>
