# Copyright (c) 2015, Plume Design Inc. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#    1. Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#    2. Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#    3. Neither the name of the Plume Design Inc. nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL Plume Design Inc. BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

###############################################################################
#
# Connector API library
#
###############################################################################
UNIT_NAME := connector

UNIT_TYPE := LIB

UNIT_SRC  += src/connector_stub.c

UNIT_CFLAGS := -I$(UNIT_PATH)/inc
UNIT_CFLAGS += -I$(UNIT_BUILD)

UNIT_LDFLAGS := -ldl -lpthread -lev

UNIT_EXPORT_CFLAGS := $(UNIT_CFLAGS)
UNIT_EXPORT_LDFLAGS := $(UNIT_LDFLAGS)

UNIT_DEPS := src/lib/common
UNIT_DEPS += src/lib/ds
UNIT_DEPS += src/lib/const
UNIT_DEPS += src/lib/schema

UNIT_CFLAGS += -DCONNECTOR_H='"connector_$(TARGET).h"'

#
# Stubs
#
CONNECTOR_IMPL_H := $(UNIT_BUILD)/connector_impl.h
UNIT_CLEAN := $(CONNECTOR_IMPL_H)

# auto stubs: generate a list of implemented apis
define UNIT_POST_MACRO
CONNECTOR_OBJ_IMPL := $$(filter-out %connector_stub.o,$$(UNIT_OBJ))
CONNECTOR_OBJ_STUB := $$(filter %connector_stub.o,$$(UNIT_OBJ))
$$(CONNECTOR_OBJ_STUB): $$(CONNECTOR_IMPL_H)
$$(CONNECTOR_IMPL_H): $$(CONNECTOR_OBJ_IMPL)
	$$(Q) for API in `nm --defined-only $$(CONNECTOR_OBJ_IMPL) | grep ' [A-Z] connector_' | cut -d' ' -f3 `; \
		do echo "#define IMPL_$$$$API"; done > $$(CONNECTOR_IMPL_H).tmp
	$$(Q) if ! cmp -s $$(CONNECTOR_IMPL_H).tmp $$(CONNECTOR_IMPL_H); then \
		echo " $$(call color_generate,generate)[$$(call color_connector,connector)] $$(CONNECTOR_IMPL_H)"; \
		mv $$(CONNECTOR_IMPL_H).tmp $$(CONNECTOR_IMPL_H); \
		fi
endef
