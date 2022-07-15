# vcs-creator
Small gui for the VCS (Video Contact Sheet *NIX) script

<p align=center>
  <img align="center" width="430" height="311" src="https://raw.githubusercontent.com/tudo75/vcs-creator/main/images/1.png">
</p>
<p align=center>
  <img align="center" width="508" height="556" src="https://raw.githubusercontent.com/tudo75/vcs-creator/main/images/2.png">
</p>

## Requirements
First of all the system must support threads.

To compile some libraries are needed:

* meson
* ninja-build
* valac
* libgtk-3-dev
* libglib2.0-dev
* libgee-0.8-dev

To install on Ubuntu based distros:

    sudo apt install meson ninja-build build-essential valac cmake libgtk-3-dev libpeas-dev xed-dev libxapp-dev libgee-0.8-dev libgtksourceview-4-dev

Need the VCS (Video Contact Sheet *NIX) script must be installed.
You can find it here:

https://p.outlyer.net/vcs

## Install
Clone the repository:
	
	git clone https://github.com/tudo75/vcs-creator.git
	cd vcs-creator

And from inside the cloned folder:
	
	meson setup build --prefix=/usr
	ninja -v -C build com.github.tudo75.vcs-creator-gmo
	ninja -v -C build
	ninja -v -C build install

## Uninstall
To uninstall and remove all added files, go inside the cloned folder and:

	sudo ninja -v -C build uninstall
	sudo rm /usr/share/locale/en/LC_MESSAGES/com.github.tudo75.vcs-creator.mo
	sudo rm /usr/share/locale/it/LC_MESSAGES/com.github.tudo75.vcs-creator.mo
