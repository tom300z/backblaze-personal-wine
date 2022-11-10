echo "Starting the virtual display & vnc server"
rm -f /tmp/.X0-lock
Xvfb :0 -screen 0 700x570x24 & openbox & x11vnc -nopw -q -forever -loop -shared &

until [ -f $WINEPREFIX/drive_c/Program\ Files/Backblaze/bzbui.exe ]; do
  echo "Backblaze not installed"
  echo "Initializing the wine prefix"
  wineboot -i -u
  unlink $WINEPREFIX/dosdevices/z:
  ln -s /data/ $WINEPREFIX/dosdevices/d:
  echo "Downloading the Backblaze personal installer..."
  wget -q https://www.backblaze.com/win32/install_backblaze.exe -P $WINEPREFIX/drive_c/
  echo "Backblaze installer started, please go through the graphical setup in by logging onto the containers vnc server"
  wine $WINEPREFIX/drive_c/install_backblaze.exe
  echo "Installation finished or aborted, trying to start the Backblaze client..."
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "Deleting x64 Binaries (we are running x86 only in this Container)!"
  echo "Without deleting them the Client try continusly starting them and wine will go in Debug Mode = High CPU Load!"
  echo "When a Message Pops up with Client is not installed correctly....Click OK and ignore. Client will run fine!"
  rm -r $WINEPREFIX/drive_c/Program\ Files/Backblaze/x64
  rm $WINEPREFIX/drive_c/Program\ Files/Backblaze/bzfilelist64.exe
  rm $WINEPREFIX/drive_c/Program\ Files/Backblaze/bztransmit64.exe
  echo "---------------------------------------------------------------------------------------------------------------"
  wineserver -k
done

if [ -f $WINEPREFIX/drive_c/Program\ Files/Backblaze/bzbui.exe ]; then
  unlink $WINEPREFIX/dosdevices/z:
  ln -s /data/ $WINEPREFIX/dosdevices/d:
  echo "Backblaze found, starting the Backblaze client..."
  wine $WINEPREFIX/drive_c/Program\ Files/Backblaze/bzbui.exe -noqiet
fi
