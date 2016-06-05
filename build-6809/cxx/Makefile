#
# This makefile controls the configuration and building of libsupc++
#
# Targets
# ------------------------------------------------------------------
# build (default)            Build the source tree
# clean                      Remove object files and libraries
# distclean                  Revert back to pristine copy from source control
# install                    Install built version
# uninstall                  Uninstall built version
#
# Command-Line Variables
# ------------------------------------------------------------------
# prefix                     Mandatory
# target                     Mandatory
# program_prefix             Mandatory
# GCC_VERSION                Mandatory
# SRCDIR                     Mandatory
# SUDO                       Optional, sudo command
# hosted                     Optional, set to 'enable' or 'disable'
#

# If set to 'enable' a full hosted library is built,
# or 'disable' for a freestanding one.
hosted ?= enable
#hosted ?= disable

##########################################################################

AR := $(prefix)/bin/$(program_prefix)ar
CXX := $(prefix)/bin/$(program_prefix)g++
INCPATH := $(prefix)/$(target)/include
LIBPATH := $(prefix)/$(target)/lib
BLDDIR := $(PWD)/$(target)
LIBNAME := libstdc++
ARCHIVE := $(BLDDIR)/install/$(LIBNAME)-cache
CXXCONFIG := $(BLDDIR)/install/c++/$(GCC_VERSION)/bits/c++config.h

ifeq ($(target),)
$(error null target)
endif
ifeq ($(prefix),)
$(error null prefix)
endif
ifeq ($(program_prefix),)
$(error null program_prefix)
endif
ifeq ($(GCC_VERSION),)
$(error null GCC_VERSION)
endif
ifeq ($(SRCDIR),)
$(error null SRCDIR)
endif

##########################################################################

.PHONY: build
build: $(ARCHIVE)

.PHONY: clean
clean:
	cd $(BLDDIR)/libsupc++ && $(MAKE) clean
	rm -rf $(BLDDIR)/install/*$(LIBNAME)* $(BLDDIR)/install/*libsupc++*

.PHONY: distclean
distclean:
	rm -rf '$(BLDDIR)'

.PHONY: install
install: build
	$(SUDO) cp -r '$(BLDDIR)/install/c++/' '$(INCPATH)/c++/'
	$(SUDO) cp    '$(BLDDIR)/install/$(LIBNAME).a' '$(LIBPATH)'
	$(SUDO) cp    '$(BLDDIR)/install/as-$(LIBNAME).a' '$(LIBPATH)'
	$(SUDO) cp -r '$(BLDDIR)/install/$(LIBNAME)-cache/' '$(LIBPATH)'

.PHONY: uninstall
uninstall:
	$(SUDO) rm -fr '$(INCPATH)/c++/'
	$(SUDO) rm -f  '$(LIBPATH)/$(LIBNAME).a'
	$(SUDO) rm -f  '$(LIBPATH)/as-$(LIBNAME).a'
	$(SUDO) rm -fr '$(LIBPATH)/$(LIBNAME)-cache/'

##########################################################################

$(ARCHIVE): $(BLDDIR)/install/$(LIBNAME).a
	@echo "Building $(LIBNAME) cache ..." && \
	$(AR) --cache $(BLDDIR)/install/$(LIBNAME).a

$(BLDDIR)/install/$(LIBNAME).a: $(BLDDIR)/install/libsupc++.a
	cp $< $@

$(BLDDIR)/install/libsupc++.a: $(CXXCONFIG)
	@echo "Building libsupc++ sources ..." && \
	echo "#include <stdlib.h>\n"\
	"char* __cxa_demangle(const char* __mangled_name, char* __output_buffer,\n"\
	"	size_t* __length, int* __status)\n"\
	"{ \n"\
	"	*__status = -1;\n"\
	"	return NULL;\n"\
	"}" > $(BLDDIR)/libsupc++/cp-demangle.c && \
	cd $(BLDDIR)/libsupc++ && $(MAKE) install

##########################################################################

# TODO multilib support, need newlib multilib support
$(BLDDIR)/config.status: $(CXX) | $(BLDDIR)
	@echo "Configuring libsupc++ ..." && rm -rf $(BLDDIR)/* && cd $(BLDDIR) && \
		$(SRCDIR)/libstdc++-v3/configure --enable-sjlj-exceptions \
			--disable-multilib --$(hosted)-hosted-libstdcxx --disable-nls \
			--disable-shared --disable-libstdcxx-pch --disable-long-long \
			--with-newlib --prefix=$(BLDDIR)/install --host=$(target) \
			--with-gxx-include-dir=$(BLDDIR)/install/include/c++ --libdir=$(BLDDIR)/install \
			CXXFLAGS='-Os -fno-function-sections -fno-data-sections'

$(CXXCONFIG): $(BLDDIR)/config.status
	@echo "Building libsupc++ headers ..." && \
		cd $(BLDDIR)/include && $(MAKE) && $(MAKE) install-headers
	mkdir -p $(BLDDIR)/install/c++/$(GCC_VERSION) $(BLDDIR)/install/c++/$(GCC_VERSION)/bits $(BLDDIR)/install/c++/$(GCC_VERSION)/ext
	cd $(BLDDIR)/install/include/c++ && cp -r $(CXXINCLUDE) -t ../../c++/$(GCC_VERSION)
	cd $(BLDDIR)/install/include/c++/bits && cp -r $(CXXINCBITS) -t ../../../c++/$(GCC_VERSION)/bits
	cd $(BLDDIR)/install/include/c++/ext && cp -r $(CXXINCEXT) -t ../../../c++/$(GCC_VERSION)/ext
	cp $(BLDDIR)/install/include/c++/$(target)/bits/c++config.h $(CXXCONFIG)

$(BLDDIR):
	mkdir -p $@

CXXINCLUDE = \
	cassert cctype cerrno cfloat ciso646 climits clocale cmath csetjmp \
	csignal cstdarg cstddef cstdio cstdlib cstring ctime cwchar cwctype \
	$(SRCDIR)/libstdc++-v3/libsupc++/cxxabi.h \
	$(SRCDIR)/libstdc++-v3/libsupc++/cxxabi-forced.h \
	$(SRCDIR)/libstdc++-v3/libsupc++/exception_defines.h \
	$(SRCDIR)/libstdc++-v3/libsupc++/exception \
	$(SRCDIR)/libstdc++-v3/libsupc++/new \
	$(SRCDIR)/libstdc++-v3/libsupc++/typeinfo

CXXINCBITS = \
	functexcept.h cpp_type_traits.h \
	../$(target)/bits/cxxabi_tweaks.h ../$(target)/bits/gthr.h \
	../$(target)/bits/gthr-single.h ../$(target)/bits/atomic_word.h \
	../$(target)/bits/os_defines.h ../$(target)/bits/cpu_defines.h

CXXINCEXT = \
	type_traits.h concurrence.h atomicity.h

##########################################################################

