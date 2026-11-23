import os
import subprocess
import time
import requests
import random
import string

__version__ = 'dev'

import os

def setup_ssh(id_rsa, id_rsa_pub):
  """Creates and populates an SSH directory with provided keys.

  Args:
    id_rsa: The private SSH key.
    id_rsa_pub: The public SSH key.
  """

  ssh_dir = os.path.expanduser("~/.ssh")
  os.makedirs(ssh_dir, exist_ok=True)

  with open(os.path.join(ssh_dir, "id_rsa"), "w") as f:
    f.write(id_rsa)

  with open(os.path.join(ssh_dir, "id_rsa.pub"), "w") as f:
    f.write(id_rsa_pub)

  for filename in ("id_rsa", "id_rsa.pub"):
    os.chmod(os.path.join(ssh_dir, filename), 0o600)

def shell(colab=False,w=700,h=500,user='nokey',pw=''):
	
    print("Starting up...")

    subprocess.Popen(["ssh", "-o", "StrictHostKeyChecking=no", "-R", "80:localhost:8568", user+"@localhost.run","--","--no-inject-http-proxy-headers"], stdout=open('log', 'w'), stderr=subprocess.STDOUT)

    fname = 'ttyd.x86_64'
    os.system(f"mkdir -p /usr/local/bin &>/dev/null || true")
    if not os.path.exists("./ttyd"):
        response = requests.head("https://github.com/tsl0922/ttyd/releases/latest/")
        ver = response.headers['Location'].split('/')[-1]
        os.system(f"wget -q https://github.com/tsl0922/ttyd/releases/download/{ver}/{fname} -O ttyd")
        os.chmod("ttyd", 0o755)

    while True:
        with open('log', 'r') as f:
            if "tunneled" in f.read():
                break
        time.sleep(1)

    with open('log', 'r') as f:
        hh = [line for line in f if "tunneled" in line][-1].split()[5]
    if pw=='':
        pw = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(6))
        print(f"\nYour password is: {pw}\n")

    with open('dosh', 'w') as f:
        f.write('''#!/bin/bash
clear
echo -n "Password: "
read -srn ''' + str(len(pw)) + ''' p
[ "$p" == "''' + pw + '''" ] && ( clear
exec bash -i
) || exit
''')

    os.chmod('dosh', 0o755)

    print("Starting server...")
    print(f"Your server is: {hh}")

    subprocess.Popen(["./ttyd", "-p", "8568", "--writable", "-t", "fontSize=20", "-t", "theme={'foreground':'#d2d2d2','background':'#1b1b1b','cursor':'#adadad','black':'#000000','red':'#d81e00','green':'#5ea702','yellow':'#cfae00','blue':'#427ab3','magenta':'#89658e','cyan':'#00a7aa','white':'#dbded8','brightBlack':'#686a66','brightRed':'#f54235','brightGreen':'#99e343','brightYellow':'#fdeb61','brightBlue':'#84b0d8','brightMagenta':'#bc94b7','brightCyan':'#37e6e8','brightWhite':'#f1f1f0'}", "-t", "fontFamily='Menlo For Powerline,Consolas,Liberation Mono,Menlo,Courier,monospace'", "-t", "enableTrzsz=true", "./dosh"], stdout=open(os.devnull, 'w'), stderr=subprocess.STDOUT)
    if(colab):
        from google.colab import userdata
        try:
            id_rsa=userdata.get('id_rsa')
            id_rsa_pub=userdata.get('id_rsa_pub')
        except:
            pass
        else:
            setup_ssh(id_rsa, id_rsa_pub)

        from IPython.display import IFrame
        return IFrame(hh, width=w, height=h)
    else:
    	  return True
