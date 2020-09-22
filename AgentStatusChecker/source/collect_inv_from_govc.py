import getpass
import os
from pathlib import Path

base_path = Path(__file__).parent
file_path = (base_path / "../resources/exclusion.list").resolve()
user_pass_path = str((base_path / "../resources/get_pass.txt").resolve())
exclusion = str(open(file_path).readlines())
user = open(user_pass_path).readlines()[0].strip()
encrypted_pass = ''
encrypted_pass_lines = open(user_pass_path).readlines()[1:]
for line in encrypted_pass_lines:
    encrypted_pass = encrypted_pass + line
encrypted_pass = encrypted_pass.replace('ansible_password:', '')

keywords = ['swarm', 'vault', 'consul', 'yrva', 'vscn', 'template', 'backup', 'bkp', 'old', 'clone', 'OLD',
            '.mp0', 'mac01', 'kub', 'test', 'sandbox', 'Clone', ' ']

yml = 'all:\n  vars:\n    ansible_user: ' + user + '\n    ansible_ssh_pass: ' \
      + encrypted_pass + '\n    ansible_become_pass: ' + encrypted_pass + '\n  hosts:\n'


def exclude_keywords(l):
    for word in keywords:
        if word in l:
            return False
    return True


def main():
    global yml
    l_num = input('Please input the number of GOVC URLs:')
    try:
        int(l_num)
    except ValueError:
        print('Please input a number')
        return
    f = open((base_path / "../resources/inv_govc.txt").resolve(), 'w')
    f.close()
    f = open((base_path / "../resources/inv.yml").resolve(), 'w')
    f.write(yml)
    f.close()
    my_map_pass = {}
    my_map_user = {}
    my_set = set()
    for i in range(1, int(l_num) + 1):
        m_url = input('Please input your GOVC IP %s :' % i)
        m_user = input('Please input your GOVC username %s :' % i)
        m_password = getpass.getpass("GOVC password %s :" % i)
        my_map_pass[m_url] = m_password
        my_map_user[m_url] = m_user

    for l_url in my_map_user.keys():
        l_user = my_map_user[l_url]
        l_password = my_map_pass[l_url]
        os.putenv('GOVC_PASSWORD', l_password)
        os.putenv('GOVC_USERNAME', l_user)
        os.putenv('GOVC_INSECURE', 'true')
        os.putenv('GOVC_URL', l_url)
        os.system(
            'govc find . -type m -runtime.powerState poweredOn > ' + str(
                (base_path / "../resources/inv_govc.tmp").resolve()))

        new_out = ''

        f = open((base_path / "../resources/inv_govc.tmp").resolve()).readlines()
        f.sort()

        yml_out = ''
        for line in f:
            for i in range(len(line) - 1, -1, -1):
                if i < len(line) - 1 and line[i] == '/' and \
                        '/' not in line[i + 1: len(line)].strip() \
                        and line[i + 1: len(line)].strip() not in exclusion \
                        and '.com' in line and exclude_keywords(line):
                    if line[i + 1: len(line)] in my_set:
                        continue
                    my_set.add(line[i + 1: len(line)])
                    new_out = new_out + line[i + 1: len(line)]
                    yml_out = yml_out + '    ' + line[i + 1: len(line)].strip() + ':\n'
                    break

        f = open((base_path / "../resources/inv_govc.txt").resolve(), 'a')
        f.write(new_out)
        f.close()

        f = open((base_path / "../resources/inv.yml").resolve(), 'a')
        f.write(yml_out)
        f.close()


if __name__ == "__main__":
    main()
