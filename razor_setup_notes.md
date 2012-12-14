# This can be improved...

## Building Smart-proxy TCZ (on Debian):

	apt-get install squashfs-tools
	cd /tmp
	mkdir tcz
	mkdir -p tcz/usr/share
	mkdir -p tcz/usr/local/tce.installed 
	mkdir -p tcz/var/run/foreman-proxy
	mkdir -p tcz/var/log/foreman-proxy
	git clone https://github.com/GregSutcliffe/smart-proxy.git -b razor tcz/usr/share/foreman-proxy
	cp tcz/usr/share/foreman-proxy/config/settings.yml{.example,}
  echo -e "\n:run: true\n" >> tcz/usr/share/foreman-proxy/config/settings.yml
	cat <<EOF > tcz/usr/local/tce.installed/foreman-proxy
  touch /var/log/foreman-proxy/proxy.log
	sudo /usr/share/foreman-proxy/bin/smart-proxy
	sudo /usr/share/foreman-proxy/bin/discover_host
	EOF
	chown -R 0:50 tcz/usr/local/tce.installed
	chmod -R 775 tcz/usr/local/tce.installed
	mksquashfs tcz/ foreman-proxy.tcz
	md5sum foreman-proxy.tcz > foreman-proxy.tcz.md5.txt
	touch foreman-proxy.tcz.dep
	chmod 644 foreman-proxy.tcz

## Foreman side:
Get Razor iso

Configure PXE default to boot iso, eg:

	LABEL razor
	LINUX boot/memdisk
	INITRD boot/razor.iso
	APPEND iso raw

Create Gem List

	echo "sinatra" > /usr/share/foreman/public/gem.list

Create gem mirror (can streamline this with bundler?)

	gem install builder (bundler breaks this)
	mkdir /usr/share/foreman/public/mirror/gems
	cd /usr/share/foreman/public/mirror/gems
	gem fetch rack
	gem fetch rack-protection
	gem fetch tilt
	gem fetch sinatra
	cd ..
	gem generate_index -d .  #ie. public/mirror _not_ public/mirror/gems

Create TCZ list

	echo '["foreman-proxy.tcz"]' > /usr/share/foreman/public/tcz.list

Create tcz mirror

	mkdir -p /usr/share/foreman/public/mirror/tcz/4.x/x86/tcz
	mv /tmp/foreman-proxy.tcz* /usr/share/foreman/public/mirror/tcz/4.x/x86/tcz/.

## Razor side:
Create Razor DNS name (or unpack ISO and use razor.ip in PXE)

Configure /opt/razor/conf/razor_server.conf with

	mk_gem_mirror_uri: http://foreman/mirror/
	mk_gemlist_uri: http://foreman/gem.list
	mk_tce_mirror_port: 80
	mk_tce_mirror_uri: http://foreman/mirror/tcz
	mk_tce_install_list_uri: http://foreman/tcz.list

Start razor server

## DiscoveredHost
Create a host outside of Foreman, boot it

	Should boot the Razor iso
	Should install Sinatra (gem list)
	Should install smart-proxy (tcz list)
	Should start proxy
	Should register to foreman
