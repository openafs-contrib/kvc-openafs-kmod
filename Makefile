ifndef DESTDIR
DESTDIR=/usr/
endif
ifndef CONFDIR
CONFDIR=/etc
endif

install:
	install -v -m 644 openafs-kmod-lib.sh $(DESTDIR)/lib/kvc/
	install -v -m 644 openafs-kmod.conf $(CONFDIR)/kvc/
