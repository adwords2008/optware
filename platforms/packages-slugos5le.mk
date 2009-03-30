PERL_MAJOR_VER = 5.10
LIBNSL_SO_DIR = $(TARGET_TOP)/staging/armv5te-linux-gnueabi/lib

SPECIFIC_PACKAGES = \
	optware-bootstrap \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	atk \
	bitchx bzflag \
	gtk ipac-ng iptables iptraf ldconfig \
	microdc2 netatalk nfs-utils \
	player puppy mod-python qemu \
	slimserver \
	softflowd \
	taged transcode vte xchat \