###########################################################
#
# perl-mime-base64
#
###########################################################

PERL-MIME-BASE64_SITE=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
PERL-MIME-BASE64_VERSION=3.05
PERL-MIME-BASE64_SOURCE=MIME-Base64-$(PERL-MIME-BASE64_VERSION).tar.gz
PERL-MIME-BASE64_DIR=MIME-Base64-$(PERL-MIME-BASE64_VERSION)
PERL-MIME-BASE64_UNZIP=zcat

PERL-MIME-BASE64_IPK_VERSION=2

PERL-MIME-BASE64_CONFFILES=

PERL-MIME-BASE64_BUILD_DIR=$(BUILD_DIR)/perl-mime-base64
PERL-MIME-BASE64_SOURCE_DIR=$(SOURCE_DIR)/perl-mime-base64
PERL-MIME-BASE64_IPK_DIR=$(BUILD_DIR)/perl-mime-base64-$(PERL-MIME-BASE64_VERSION)-ipk
PERL-MIME-BASE64_IPK=$(BUILD_DIR)/perl-mime-base64_$(PERL-MIME-BASE64_VERSION)-$(PERL-MIME-BASE64_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-MIME-BASE64_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-MIME-BASE64_SITE)/$(PERL-MIME-BASE64_SOURCE)

perl-mime-base64-source: $(DL_DIR)/$(PERL-MIME-BASE64_SOURCE) $(PERL-MIME-BASE64_PATCHES)

$(PERL-MIME-BASE64_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-MIME-BASE64_SOURCE) $(PERL-MIME-BASE64_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-MIME-BASE64_DIR) $(PERL-MIME-BASE64_BUILD_DIR)
	$(PERL-MIME-BASE64_UNZIP) $(DL_DIR)/$(PERL-MIME-BASE64_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL-MIME-BASE64_DIR) $(PERL-MIME-BASE64_BUILD_DIR)
	(cd $(PERL-MIME-BASE64_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		perl Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-MIME-BASE64_BUILD_DIR)/.configured

perl-mime-base64-unpack: $(PERL-MIME-BASE64_BUILD_DIR)/.configured

$(PERL-MIME-BASE64_BUILD_DIR)/.built: $(PERL-MIME-BASE64_BUILD_DIR)/.configured
	rm -f $(PERL-MIME-BASE64_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-MIME-BASE64_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-MIME-BASE64_BUILD_DIR)/.built

perl-mime-base64: $(PERL-MIME-BASE64_BUILD_DIR)/.built

$(PERL-MIME-BASE64_BUILD_DIR)/.staged: $(PERL-MIME-BASE64_BUILD_DIR)/.built
	rm -f $(PERL-MIME-BASE64_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-MIME-BASE64_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-MIME-BASE64_BUILD_DIR)/.staged

perl-mime-base64-stage: $(PERL-MIME-BASE64_BUILD_DIR)/.staged

$(PERL-MIME-BASE64_IPK): $(PERL-MIME-BASE64_BUILD_DIR)/.built
	rm -rf $(PERL-MIME-BASE64_IPK_DIR) $(BUILD_DIR)/perl-mime-base64_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-MIME-BASE64_BUILD_DIR) DESTDIR=$(PERL-MIME-BASE64_IPK_DIR) install
	find $(PERL-MIME-BASE64_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-MIME-BASE64_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-MIME-BASE64_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	install -d $(PERL-MIME-BASE64_IPK_DIR)/CONTROL
	install -m 644 $(PERL-MIME-BASE64_SOURCE_DIR)/control $(PERL-MIME-BASE64_IPK_DIR)/CONTROL/control
#	install -m 644 $(PERL-MIME-BASE64_SOURCE_DIR)/postinst $(PERL-MIME-BASE64_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(PERL-MIME-BASE64_SOURCE_DIR)/prerm $(PERL-MIME-BASE64_IPK_DIR)/CONTROL/prerm
	echo $(PERL-MIME-BASE64_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-MIME-BASE64_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-MIME-BASE64_IPK_DIR)

perl-mime-base64-ipk: $(PERL-MIME-BASE64_IPK)

perl-mime-base64-clean:
	-$(MAKE) -C $(PERL-MIME-BASE64_BUILD_DIR) clean

perl-mime-base64-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-MIME-BASE64_DIR) $(PERL-MIME-BASE64_BUILD_DIR) $(PERL-MIME-BASE64_IPK_DIR) $(PERL-MIME-BASE64_IPK)
