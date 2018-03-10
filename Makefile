OVERLORD_PREFIX ?= $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

bin/i3: src/i3/x86_64-unknown-linux-gnu
	cd src/i3/x86_64-unknown-linux-gnu; make install-exec-am

src/i3/x86_64-unknown-linux-gnu: src/i3/configure
	cd src/i3; ./configure --prefix=${OVERLORD_PREFIX} 

src/i3/configure: src/i3/configure.ac lib/libxcb-cursor.so lib/libxcb-xrm.so lib/libxkbcommon.so.0.0.0
	cd src/i3; autoreconf -fi

lib/libxcb-cursor.so: src/xcb-util-cursor/Makefile
	cd src/xcb-util-cursor; make
	cd src/xcb-util-cursor; make install

src/xcb-util-cursor/Makefile: src/xcb-util-cursor/configure
	cd src/xcb-util-cursor; ./configure --prefix=${OVERLORD_PREFIX}

src/xcb-util-cursor/configure: src/xcb-util-cursor/configure.ac src/xcb-util-cursor/m4
	cd src/xcb-util-cursor; autoreconf -fi

src/xcb-util-cursor/m4: src/xcb-util-cursor
	cd src/xcb-util-cursor; git submodule update --init --recursive

lib/libxcb-xrm.so: src/xcb-util-xrm/Makefile
	cd src/xcb-util-xrm; make
	cd src/xcb-util-xrm; make install

src/xcb-util-xrm/Makefile: src/xcb-util-xrm/configure
	cd src/xcb-util-xrm; ./configure --prefix=${OVERLORD_PREFIX}

src/xcb-util-xrm/configure: src/xcb-util-xrm/configure.ac src/xcb-util-xrm/m4
	cd src/xcb-util-xrm; autoreconf -fi

src/xcb-util-xrm/m4: src/xcb-util-xrm
	cd src/xcb-util-xrm; git submodule update --init --recursive

lib/libxkbcommon.so.0.0.0: src/libxkbcommon/pkg/libxkbcommon.so.0.0.0 bin/ninja
	cd src/libxkbcommon; ninja -C build install

src/libxkbcommon/pkg/libxkbcommon.so.0.0.0: src/libxkbcommon/build bin/ninja
	cd src/libxkbcommon; ninja -C build

src/libxkbcommon/build: src/libxkbcommon/meson.build bin/meson
	cd src/libxkbcommon; meson setup build --prefix ${OVERLORD_PREFIX}

bin/meson:
	pip3 install --prefix ${OVERLORD_PREFIX} meson

bin/ninja: src/ninja/ninja
	install -m755 $^ $@

src/ninja/ninja:
	cd src/ninja; ./configure.py --bootstrap

bin/dmenu: src/dmenu/config.mk
	cd src/dmenu; make clean install PREFIX=${OVERLORD_PREFIX}
