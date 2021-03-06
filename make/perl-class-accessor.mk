###########################################################
#
# perl-class-accessor
#
###########################################################

PERL-CLASS-ACCESSOR_SITE=http://search.cpan.org/CPAN/authors/id/K/KA/KASEI
PERL-CLASS-ACCESSOR_VERSION=0.30
PERL-CLASS-ACCESSOR_SOURCE=Class-Accessor-$(PERL-CLASS-ACCESSOR_VERSION).tar.gz
PERL-CLASS-ACCESSOR_DIR=Class-Accessor-$(PERL-CLASS-ACCESSOR_VERSION)
PERL-CLASS-ACCESSOR_UNZIP=zcat
PERL-CLASS-ACCESSOR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-CLASS-ACCESSOR_DESCRIPTION=Class::Accessor - Automated accessor generation
PERL-CLASS-ACCESSOR_SECTION=util
PERL-CLASS-ACCESSOR_PRIORITY=optional
PERL-CLASS-ACCESSOR_DEPENDS=perl
PERL-CLASS-ACCESSOR_SUGGESTS=
PERL-CLASS-ACCESSOR_CONFLICTS=

PERL-CLASS-ACCESSOR_IPK_VERSION=2

PERL-CLASS-ACCESSOR_CONFFILES=

PERL-CLASS-ACCESSOR_BUILD_DIR=$(BUILD_DIR)/perl-class-accessor
PERL-CLASS-ACCESSOR_SOURCE_DIR=$(SOURCE_DIR)/perl-class-accessor
PERL-CLASS-ACCESSOR_IPK_DIR=$(BUILD_DIR)/perl-class-accessor-$(PERL-CLASS-ACCESSOR_VERSION)-ipk
PERL-CLASS-ACCESSOR_IPK=$(BUILD_DIR)/perl-class-accessor_$(PERL-CLASS-ACCESSOR_VERSION)-$(PERL-CLASS-ACCESSOR_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-CLASS-ACCESSOR_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-CLASS-ACCESSOR_SITE)/$(PERL-CLASS-ACCESSOR_SOURCE)

perl-class-accessor-source: $(DL_DIR)/$(PERL-CLASS-ACCESSOR_SOURCE) $(PERL-CLASS-ACCESSOR_PATCHES)

$(PERL-CLASS-ACCESSOR_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-CLASS-ACCESSOR_SOURCE) $(PERL-CLASS-ACCESSOR_PATCHES)
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-CLASS-ACCESSOR_DIR) $(PERL-CLASS-ACCESSOR_BUILD_DIR)
	$(PERL-CLASS-ACCESSOR_UNZIP) $(DL_DIR)/$(PERL-CLASS-ACCESSOR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-CLASS-ACCESSOR_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-CLASS-ACCESSOR_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-CLASS-ACCESSOR_DIR) $(PERL-CLASS-ACCESSOR_BUILD_DIR)
	(cd $(PERL-CLASS-ACCESSOR_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-CLASS-ACCESSOR_BUILD_DIR)/.configured

perl-class-accessor-unpack: $(PERL-CLASS-ACCESSOR_BUILD_DIR)/.configured

$(PERL-CLASS-ACCESSOR_BUILD_DIR)/.built: $(PERL-CLASS-ACCESSOR_BUILD_DIR)/.configured
	rm -f $(PERL-CLASS-ACCESSOR_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-CLASS-ACCESSOR_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-CLASS-ACCESSOR_BUILD_DIR)/.built

perl-class-accessor: $(PERL-CLASS-ACCESSOR_BUILD_DIR)/.built

$(PERL-CLASS-ACCESSOR_BUILD_DIR)/.staged: $(PERL-CLASS-ACCESSOR_BUILD_DIR)/.built
	rm -f $(PERL-CLASS-ACCESSOR_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-CLASS-ACCESSOR_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-CLASS-ACCESSOR_BUILD_DIR)/.staged

perl-class-accessor-stage: $(PERL-CLASS-ACCESSOR_BUILD_DIR)/.staged

$(PERL-CLASS-ACCESSOR_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-CLASS-ACCESSOR_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-class-accessor" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-CLASS-ACCESSOR_PRIORITY)" >>$@
	@echo "Section: $(PERL-CLASS-ACCESSOR_SECTION)" >>$@
	@echo "Version: $(PERL-CLASS-ACCESSOR_VERSION)-$(PERL-CLASS-ACCESSOR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-CLASS-ACCESSOR_MAINTAINER)" >>$@
	@echo "Source: $(PERL-CLASS-ACCESSOR_SITE)/$(PERL-CLASS-ACCESSOR_SOURCE)" >>$@
	@echo "Description: $(PERL-CLASS-ACCESSOR_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-CLASS-ACCESSOR_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-CLASS-ACCESSOR_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-CLASS-ACCESSOR_CONFLICTS)" >>$@

$(PERL-CLASS-ACCESSOR_IPK): $(PERL-CLASS-ACCESSOR_BUILD_DIR)/.built
	rm -rf $(PERL-CLASS-ACCESSOR_IPK_DIR) $(BUILD_DIR)/perl-class-accessor_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-CLASS-ACCESSOR_BUILD_DIR) DESTDIR=$(PERL-CLASS-ACCESSOR_IPK_DIR) install
	find $(PERL-CLASS-ACCESSOR_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-CLASS-ACCESSOR_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-CLASS-ACCESSOR_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-CLASS-ACCESSOR_IPK_DIR)/CONTROL/control
	echo $(PERL-CLASS-ACCESSOR_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-CLASS-ACCESSOR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-CLASS-ACCESSOR_IPK_DIR)

perl-class-accessor-ipk: $(PERL-CLASS-ACCESSOR_IPK)

perl-class-accessor-clean:
	-$(MAKE) -C $(PERL-CLASS-ACCESSOR_BUILD_DIR) clean

perl-class-accessor-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-CLASS-ACCESSOR_DIR) $(PERL-CLASS-ACCESSOR_BUILD_DIR) $(PERL-CLASS-ACCESSOR_IPK_DIR) $(PERL-CLASS-ACCESSOR_IPK)
