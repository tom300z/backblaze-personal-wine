# backblaze-personal-wine

Looking for a (relatively) easy way to backup your personal linux system via Backblaze Personal unlimited? 
Then look no further, this container automatically creates a tiny Wine prefix that runs the Backblaze personal client to backup any mounted directory in your linux filesystem.
Please note, Linux specific file attributes (like ownership, acls or permissions) will not be backed up;

## docker compose example
```
version: "2.2"
services:
# Backblaze Personal
  backblaze-personal-wine:
    image: tom300z/backblaze-personal-wine
    container_name: backblaze-personal-wine
    init: true
    volumes:
      - /opt/docker/backblaze-personal-wine:/wine/  # The location to store the backblaze Wine prefix in
      - /my/important/photos:/data/photos  # All directories that should be backed up should be mounted under the "/data/" directory
      - /my/important/spreadsheets:/data/spreadsheets
    ports:
      - 25900:5900 # Expose the (unencrypted) VNC server to the host make sure to only allow local connections to the server. This can be removed after the initial installation and backup phase.
```

## Setup guide
### Security
The server runs an unencrypted integrated VNC server. 
If you need to connect to the vnc server from a different machine (on headless systems), please make sure to configure your firewall to only allow local connections to the VNC.
firewalld example:
```
firewall-cmd --permanent --add-rich-rule "rule family="ipv4" source address="192.168.178.0/24" port port="25900" protocol="tcp" accept"
firewall-cmd --reload
```

### Installation
When starting the container for the first time, it will automatically initialize a new Wine prefix and download & run the backblaze installer.

To go through the setup process you must connect to the integrated vnc server via a client like RealVNC Client.
address: your.linux.ip.address:25900
user: none (admin)
password: none

When you only see a black screen once you are connected press alt-tab to activate the installer window.
The installer might look a bit weird (all white) at the very beginning. Just enter your backblaze account email into the white box and hit enter, then the you should see the rest of the ui. 
Enter your password and hit "Install", the installer will start scanning your drive.

### Configuration
Once the Installer is finished the backblaze client should open automatically.

You will notice that currently only around 10 files are backed up. 
To change that click the Settings button and check the box for the "D:" drive, this drive corresponds to the /data/ directory of your container. 
You can also set a better name for your backup here, by default the rather obscure container id is used.
I'd also reccommend to remove the blacklisted file extensions from the "Exclusions" tab.

Once you hit "Ok" or "Apply" the client will start scanning your drives again, this might take a very long time depending on the number of files you mounted under the /data/ dir, just be patient and leave the container running.
You can dis- and reconnect from and to the VNC server at any time, this will not affect the Backblaze client.

When the analysis is complete make shoure the client performs the initial backup (this should happen automatically).
Depending on the number and size of the files you want to back up and your upload speed, this will take quite some time.
If you have to stop the container during the initial backup the backup will continue where it left once the container is started again.

Backblaze is now configured to automatically backup your linux files,  to check the pprogress or change settings use the VNC Server.
