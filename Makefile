OVERLORD_PREFIX ?= $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

bin/i3: src/i3/x86_64-unknown-linux-gnu
	cd src/i3/x86_64-unknown-linux-gnu; make install-exec-am

src/i3/x86_64-unknown-linux-gnu: src/i3/configure
	cd src/i3; ./configure --prefix=${OVERLORD_PREFIX} 

src/i3/configure: src/i3 src/i3/configure.ac lib/libxcb-cursor.so lib/libxcb-xrm.so lib/libxkbcommon.so.0.0.0
	cd src/i3; autoreconf -fi

lib/libxcb-cursor.so: src/xcb-util-cursor/Makefile
	cd src/xcb-util-cursor; make
	cd src/xcb-util-cursor; make install

src/xcb-util-cursor/Makefile: src/xcb-util-cursor/configure
	cd src/xcb-util-cursor; ./configure --prefix=${OVERLORD_PREFIX}

src/xcb-util-cursor/configure: src/xcb-util-cursor src/xcb-util-cursor/configure.ac
	cd src/xcb-util-cursor; autoreconf -fi

lib/libxcb-xrm.so: src/xcb-util-xrm/Makefile
	cd src/xcb-util-xrm; make
	cd src/xcb-util-xrm; make install

src/xcb-util-xrm/Makefile: src/xcb-util-xrm/configure
	cd src/xcb-util-xrm; ./configure --prefix=${OVERLORD_PREFIX}

src/xcb-util-xrm/configure: src/xcb-util-xrm src/xcb-util-xrm/configure.ac
	cd src/xcb-util-xrm; autoreconf -fi

lib/libxkbcommon.so.0.0.0: src/libxkbcommon/pkg/libxkbcommon.so.0.0.0 bin/ninja
	cd src/libxkbcommon; ninja -C build install

src/libxkbcommon/pkg/libxkbcommon.so.0.0.0: src/libxkbcommon/build bin/ninja
	cd src/libxkbcommon; ninja -C build

src/libxkbcommon/build: src/libxkbcommon src/libxkbcommon/meson.build bin/meson
	cd src/libxkbcommon; meson setup build --prefix ${OVERLORD_PREFIX}

bin/meson: bin/ninja
	pip3 install --prefix ${OVERLORD_PREFIX} meson

bin/ninja: src/ninja/ninja
	install -m755 $^ $@

src/ninja/ninja: src/ninja
	cd src/ninja; ./configure.py --bootstrap

bin/dmenu: src/dmenu
	cd src/dmenu; make clean install PREFIX=${OVERLORD_PREFIX}

src/xcb-util-cursor:
	git clone --recursive https://anongit.freedesktop.org/git/xcb/util-cursor.git $@ -b 0.1.3

src/xcb-util-xrm:
	git clone --recursive https://github.com/Airblader/xcb-util-xrm $@ -b v1.2

src/libxkbcommon:
	git clone --recursive https://github.com/xkbcommon/libxkbcommon $@ -b xkbcommon-0.8.0

src/ninja:
	git clone --recursive https://github.com/ninja-build/ninja $@ -b release

src/dmenu:
	git clone https://git.suckless.org/dmenu $@ -b 4.7

src/i3:
	git clone https://github.com/i3/i3 $@ -b master
