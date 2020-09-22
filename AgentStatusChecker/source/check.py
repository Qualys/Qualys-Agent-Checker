#!/usr/bin/python
import subprocess

import os

import datetime

email_list = ['cyu@qualys.com']
hostname = subprocess.Popen('uname -n', stdout=subprocess.PIPE, shell=True).communicate()[0].strip().decode()


def main():

    time = str(datetime.datetime.now()).replace(' ', '')
    cmd_out_ca_version = 'NA'
    cmd_out_ca_check = qualys_cloud_check(subprocess_cmd('sudo service qualys-cloud-agent status'))
    if cmd_out_ca_check == 'running':
        cmd_out_ca_version = qualys_cloud_version(subprocess_cmd('rpm -qi qualys-cloud-agent'))

    json = '{"hostname":"' + hostname +  \
           '","cloud_agent_version":"' + cmd_out_ca_version + \
           '","cloud_agent":"' + cmd_out_ca_check + '"}'
    print(json)


def qualys_cloud_check(cmd_out):
    if 'running' in cmd_out:
        return 'running'
    else:
        return 'not_running'


def qualys_cloud_version(cmd_out):
    if 'not install' in cmd_out:
        return 'not_installed'
    else:
        return cmd_out[cmd_out.index('Version     :') + 13: cmd_out.index('Version     :') + 13 + 6]


def subprocess_cmd(command):
    process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
    stdout = process.communicate()[0].strip()
    return stdout.decode('utf-8')


# def send_email(recipient, subject, body):
#    try:
#        process = subprocess.Popen(['mail', '-s', subject, recipient], stdin=subprocess.PIPE)
#        print('Report email sent to: ' + recipient)
#        process.communicate(body.encode())
#    except Exception as error:
#        print(error)
#

if __name__ == "__main__":
    main()
