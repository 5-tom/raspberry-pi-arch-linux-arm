#!/usr/bin/env bash
set -e
#run in root. u: root, p: root
#timedatectl set-ntp false
#timedatectl set-time "yyyy-mm-dd hh:mm:ss"
userdel -r alarm
passwd root
useradd -d /home/tom tom
mkdir -p /home/tom
passwd tom
wpa_supplicant -B -i wlan0 -c <(wpa_passphrase NAME PASSWORD)
dhcpcd wlan0
pacman-key --init
pacman-key --populate archlinuxarm
pacman -Syu
pacman -S ufw
ufw --force enable
pacman -S gcc git kodi-rpi make pulseaudio swh-plugins xfce4-terminal xorg xorg-xinit

while read
do
	printf '%s\n' "$REPLY"
done <<EOF >> /etc/pulse/default.pa
set-default-sink alsa_output.platform-fef00700.hdmi.hdmi-stereo
.ifexists module-ladspa-sink.so
.nofail
load-module module-ladspa-sink sink_name=compressor-stereo plugin=sc4_1882 label=sc4 control=1,1.5,401,-30,20,5,12
.fail
.endif
set-default-sink compressor-stereo
EOF

mkdir /home/tom/movies
chown -R tom:tom /home/tom

git clone git://git.suckless.org/dwm
cd dwm
make
make install
cd ..
git clone git://git.suckless.org/dmenu
cd dmenu
make
make install

echo "#exec dwm
#&
exec kodi" > /home/tom/.xinitrc
chown tom:tom /home/tom/.xinitrc

while read
do
	printf '%s\n' "$REPLY"
done <<EOF > /home/tom/connect
#!/usr/bin/env bash
ufw enable
wpa_supplicant -B -i wlan0 -c <(wpa_passphrase NAME PASSWORD)
dhcpcd wlan0
EOF
#echo "alias c='/home/tom/connect'" >> /home/tom/.bashrc

#https://wiki.archlinux.org/title/Xinit#Autostart_X_at_login
#https://wiki.archlinux.org/title/Getty#Automatic_login_to_virtual_console
