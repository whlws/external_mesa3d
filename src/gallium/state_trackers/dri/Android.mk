# Mesa 3-D graphics library
#
# Copyright (C) 2015 Chih-Wei Huang <cwhuang@linux.org.tw>
# Copyright (C) 2015 Android-x86 Open Source Project
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

LOCAL_PATH := $(call my-dir)

include $(LOCAL_PATH)/Makefile.sources

include $(CLEAR_VARS)

LOCAL_SRC_FILES := $(common_SOURCES)

LOCAL_C_INCLUDES := \
	$(MESA_TOP)/src/mapi \
	$(MESA_TOP)/src/mesa \

LOCAL_EXPORT_C_INCLUDE_DIRS := \
	$(LOCAL_PATH) \
	$(LOCAL_C_INCLUDES) \

LOCAL_STATIC_LIBRARIES := \
	libmesa_dri_common \

ifneq ($(filter swrast,$(MESA_GPU_DRIVERS)),)
LOCAL_SRC_FILES += $(drisw_SOURCES)
endif

ifneq ($(filter-out swrast,$(MESA_GPU_DRIVERS)),)
LOCAL_SRC_FILES += $(dri2_SOURCES)
LOCAL_SHARED_LIBRARIES := libdrm
endif

LOCAL_MODULE := libmesa_st_dri
LOCAL_MODULE_CLASS := STATIC_LIBRARIES

intermediates := $(call local-generated-sources-dir)
MESA_DRI_OPTIONS_H := $(intermediates)/xmlpool/options.h
LOCAL_GENERATED_SOURCES := $(MESA_DRI_OPTIONS_H)

MESA_DRI_COMMON := $(MESA_TOP)/src/mesa/drivers/dri/common

#
# Generate options.h from gettext translations.
#

MESA_DRI_OPTIONS_LANGS := de es nl fr sv
POT := $(intermediates)/xmlpool.pot

$(POT): $(MESA_DRI_COMMON)/xmlpool/t_options.h
	@mkdir -p $(dir $@)
	xgettext -L C --from-code utf-8 -o $@ $<

$(intermediates)/xmlpool/%.po: $(MESA_DRI_COMMON)/xmlpool/%.po $(POT)
	lang=$(basename $(notdir $@)); \
	mkdir -p $(dir $@); \
	if [ -f $< ]; then \
		msgmerge -o $@ $^; \
	else \
		msginit -i $(POT) \
			-o $@ \
			--locale=$$lang \
			--no-translator; \
		sed -i -e 's/charset=.*\\n/charset=UTF-8\\n/' $@; \
	fi

$(intermediates)/xmlpool/de/LC_MESSAGES/options.mo: $(intermediates)/xmlpool/de.po
	mkdir -p $(dir $@)
	msgfmt -o $@ $<

$(intermediates)/xmlpool/es/LC_MESSAGES/options.mo: $(intermediates)/xmlpool/es.po
	mkdir -p $(dir $@)
	msgfmt -o $@ $<

$(intermediates)/xmlpool/nl/LC_MESSAGES/options.mo: $(intermediates)/xmlpool/nl.po
	mkdir -p $(dir $@)
	msgfmt -o $@ $<

$(intermediates)/xmlpool/fr/LC_MESSAGES/options.mo: $(intermediates)/xmlpool/fr.po
	mkdir -p $(dir $@)
	msgfmt -o $@ $<

$(intermediates)/xmlpool/sv/LC_MESSAGES/options.mo: $(intermediates)/xmlpool/sv.po
	mkdir -p $(dir $@)
	msgfmt -o $@ $<

$(MESA_DRI_OPTIONS_H): PRIVATE_SCRIPT := $(MESA_DRI_COMMON)/xmlpool/gen_xmlpool.py
$(MESA_DRI_OPTIONS_H): PRIVATE_LOCALEDIR := $(intermediates)/xmlpool
$(MESA_DRI_OPTIONS_H): PRIVATE_TEMPLATE_HEADER := $(MESA_DRI_COMMON)/xmlpool/t_options.h
$(MESA_DRI_OPTIONS_H): $(PRIVATE_SCRIPT) $(PRIVATE_TEMPLATE_HEADER) \
		$(intermediates)/xmlpool/de/LC_MESSAGES/options.mo \
		$(intermediates)/xmlpool/es/LC_MESSAGES/options.mo \
		$(intermediates)/xmlpool/nl/LC_MESSAGES/options.mo \
		$(intermediates)/xmlpool/fr/LC_MESSAGES/options.mo \
		$(intermediates)/xmlpool/sv/LC_MESSAGES/options.mo
	@mkdir -p $(dir $@)
	$(hide) $(MESA_PYTHON2) $(PRIVATE_SCRIPT) $(PRIVATE_TEMPLATE_HEADER) \
		$(PRIVATE_LOCALEDIR) $(MESA_DRI_OPTIONS_LANGS) > $@

include $(GALLIUM_COMMON_MK)
include $(BUILD_STATIC_LIBRARY)
