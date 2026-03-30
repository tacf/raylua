CFLAGS  ?= -O2 -s
LDFLAGS ?= -O2 -s

AR      ?= ar
CC      ?= cc
LUA     ?= luajit/src/luajit
WINDRES ?= windres
MKDIR_P ?= mkdir -p
RM_F    ?= rm -f
RM_RF   ?= rm -rf
CP      ?= cp

OUT_DIR       := raylua-out
DIST_DIR      := dist
AUTOGEN_DIR   := src/autogen
TOOLS_DIR     := tools
AC_DIR        := autocomplete
AC_API_DIR    := $(AC_DIR)/api
RL_PARSER_DIR := raylib/tools/rlparser
RL_PARSER     := $(RL_PARSER_DIR)/rlparser

LAUNCHER_SRC  := src/raylua_main.c

# raylib settings
PLATFORM ?= PLATFORM_DESKTOP
GRAPHICS ?= GRAPHICS_API_OPENGL_33

USE_WAYLAND_DISPLAY ?= FALSE
USE_EXTERNAL_GLFW   ?= FALSE

MODULES := raymath rlgl gestures physac raygui rcamera

# Generated binding headers
BINDING_HEADERS := \
	$(TOOLS_DIR)/api.h \
	$(TOOLS_DIR)/raymath.h \
	$(TOOLS_DIR)/rlgl.h \
	$(TOOLS_DIR)/gestures.h \
	$(TOOLS_DIR)/rcamera.h \
	$(TOOLS_DIR)/physac.h \
	$(TOOLS_DIR)/raygui.h

# Source headers that feed the binding snapshot generator
BINDING_SOURCES := \
	raylib/src/raylib.h \
	raylib/src/raymath.h \
	raylib/src/rlgl.h \
	raylib/src/rgestures.h \
	raylib/src/rcamera.h \
	physac/src/physac.h \
	raygui/src/raygui.h

# Stamp files
BINDINGS_STAMP     := $(TOOLS_DIR)/.bindings.stamp
AUTOCOMPLETE_STAMP := $(AC_API_DIR)/.autocomplete.stamp

# External library outputs
LUAJIT_LIB  := luajit/src/libluajit.a
RAYLIB_LIB  := raylib/src/libraylib.a
STATIC_LIBS := $(LUAJIT_LIB) $(RAYLIB_LIB)

CFLAGS += -Iluajit/src -Iraylib/src -Iraygui/src -Iphysac/src
CFLAGS += -D$(GRAPHICS) -D$(PLATFORM)

# ------------------------------------------------------------------------------
# Platform-specific settings
# ------------------------------------------------------------------------------

EXE_EXT :=
SYS_LIBS :=
SYS_LIBS_DEV :=
RAYLIB_MAKE_LDFLAGS :=
EXTERNAL_FILES :=

ifeq ($(OS),Windows_NT)
	EXE_EXT := .exe
	SYS_LIBS     += -lm -lopengl32 -lgdi32 -lwinmm -static -mwindows
	SYS_LIBS_DEV += -lm -lopengl32 -lgdi32 -lwinmm -static
	RAYLIB_MAKE_LDFLAGS := -lm -lopengl32 -lgdi32 -lwinmm -static -mwindows
	EXTERNAL_FILES := src/res/icon.res

else ifeq ($(shell uname -s),MINGW64_NT)
	EXE_EXT := .exe
	SYS_LIBS     += -lm -lopengl32 -lgdi32 -lwinmm -static -mwindows
	SYS_LIBS_DEV += -lm -lopengl32 -lgdi32 -lwinmm -static
	RAYLIB_MAKE_LDFLAGS := -lm -lopengl32 -lgdi32 -lwinmm -static -mwindows
	EXTERNAL_FILES := src/res/icon.res

else ifeq ($(shell uname),Darwin)
	SYS_LIBS += -lm \
		-framework CoreVideo -framework IOKit -framework Cocoa \
		-framework GLUT -framework OpenGL
	SYS_LIBS_DEV := $(SYS_LIBS)
	RAYLIB_MAKE_LDFLAGS := $(SYS_LIBS)

	ifeq ($(shell uname -m),arm64)
		CFLAGS += -target arm64-apple-macos11
	else
		CFLAGS += -Wl,-pagezero_size,10000,-image_base,100000000
	endif

else
	SYS_LIBS += -lm -ldl -lpthread

	ifeq ($(PLATFORM),PLATFORM_DRM)
		SYS_LIBS += -ldrm -lGLESv2 -lEGL -lgbm
	else
		CFLAGS += -D_GLFW_X11
		SYS_LIBS += -lX11
	endif

	SYS_LIBS_DEV := $(SYS_LIBS)
	RAYLIB_MAKE_LDFLAGS := $(SYS_LIBS)
endif

APP_LIBS     := $(STATIC_LIBS) $(SYS_LIBS)
APP_LIBS_DEV := $(STATIC_LIBS) $(SYS_LIBS_DEV)

RAYLUA_BIN  := $(OUT_DIR)/raylua$(EXE_EXT)
RAYLUAC_BIN := $(OUT_DIR)/rayluac$(EXE_EXT)

# ------------------------------------------------------------------------------
# Default targets
# ------------------------------------------------------------------------------

all: $(LUAJIT_LIB) $(RAYLIB_LIB) $(RAYLUA_BIN) $(RAYLUAC_BIN)

luajit: $(LUAJIT_LIB)
raylib: $(RAYLIB_LIB)
bindings: $(BINDINGS_STAMP)
autocomplete: $(AUTOCOMPLETE_STAMP)
update: bindings autocomplete

package: all | $(DIST_DIR)
	$(MAKE) clean-package
	$(CP) $(RAYLUA_BIN) $(DIST_DIR)/
	$(CP) $(RAYLUAC_BIN) $(DIST_DIR)/

# ------------------------------------------------------------------------------
# Directories and generic compile rules
# ------------------------------------------------------------------------------

$(OUT_DIR):
	$(MKDIR_P) $@

$(DIST_DIR):
	$(MKDIR_P) $@

$(AC_API_DIR):
	$(MKDIR_P) $@

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

# Shared launcher source compiled twice with different shell modes
src/raylua_d.o: $(LAUNCHER_SRC)
	$(CC) -c -o $@ $< $(CFLAGS) -DRAYLUA_ENABLE_SHELL=0

src/raylua_s.o: $(LAUNCHER_SRC)
	$(CC) -c -o $@ $< $(CFLAGS) -DRAYLUA_ENABLE_SHELL=1

# ------------------------------------------------------------------------------
# External deps
# ------------------------------------------------------------------------------

$(LUAJIT_LIB):
	$(MAKE) -C luajit amalg \
		CC=$(CC) BUILDMODE=static \
		MACOSX_DEPLOYMENT_TARGET=10.13

$(RAYLIB_LIB): $(LUAJIT_LIB)
	$(MAKE) -C raylib/src \
		CC=$(CC) AR=$(AR) \
		CFLAGS="$(CFLAGS)" \
		LDFLAGS="$(RAYLIB_MAKE_LDFLAGS)" \
		USE_WAYLAND_DISPLAY="$(USE_WAYLAND_DISPLAY)" \
		USE_EXTERNAL_GLFW="$(USE_EXTERNAL_GLFW)" \
		PLATFORM="$(PLATFORM)" \
		GRAPHICS="$(GRAPHICS)"

# ------------------------------------------------------------------------------
# Metadata generation
# ------------------------------------------------------------------------------

$(BINDINGS_STAMP): $(TOOLS_DIR)/update_bindings.lua $(BINDING_SOURCES) | $(LUAJIT_LIB)
	$(LUA) $(TOOLS_DIR)/update_bindings.lua
	@touch $@

$(RL_PARSER):
	$(MAKE) -f $(RL_PARSER_DIR)/Makefile

$(AUTOCOMPLETE_STAMP): $(RL_PARSER) \
                       raylib/src/raylib.h \
                       raylib/src/rcamera.h \
                       raylib/src/rlgl.h \
                       raygui/src/raygui.h \
                       physac/src/physac.h | $(AC_API_DIR)
	"$(RL_PARSER)" -i raylib/src/raylib.h  -o $(AC_API_DIR)/raylib_api.lua  -d RLAPI     -f LUA
	"$(RL_PARSER)" -i raylib/src/rcamera.h -o $(AC_API_DIR)/rcamera_api.lua -d RLAPI     -f LUA
	"$(RL_PARSER)" -i raylib/src/rlgl.h    -o $(AC_API_DIR)/rlgl_api.lua    -d RLAPI     -f LUA
	"$(RL_PARSER)" -i raygui/src/raygui.h  -o $(AC_API_DIR)/raygui_api.lua  -d RAYGUIAPI -f LUA
	"$(RL_PARSER)" -i physac/src/physac.h  -o $(AC_API_DIR)/physac_api.lua  -d PHYSACDEF -f LUA
	@touch $@

# ------------------------------------------------------------------------------
# Final binaries
# ------------------------------------------------------------------------------

$(RAYLUAC_BIN): src/raylua_s.o src/raylua_self.o src/raylua_builder.o src/lib/miniz.o \
                $(EXTERNAL_FILES) $(OUT_DIR)/libraylua.a | $(OUT_DIR) $(LUAJIT_LIB) $(RAYLIB_LIB)
	$(CC) -o $@ $^ $(LDFLAGS) $(APP_LIBS_DEV)

$(RAYLUA_BIN): src/raylua_d.o src/raylua_self.o src/raylua_builder.o src/lib/miniz.o \
               $(EXTERNAL_FILES) $(OUT_DIR)/libraylua.a | $(OUT_DIR) $(LUAJIT_LIB) $(RAYLIB_LIB)
	$(CC) -o $@ $^ $(LDFLAGS) $(APP_LIBS)

rayluac: $(RAYLUAC_BIN)
raylua: $(RAYLUA_BIN)

# ------------------------------------------------------------------------------
# Resources and libs
# ------------------------------------------------------------------------------

src/res/icon.res: src/res/icon.rc
	$(WINDRES) $^ -O coff $@

$(OUT_DIR)/libraylua.a: src/raylua.o | $(OUT_DIR)
	$(AR) rcu $@ src/raylua.o

# ------------------------------------------------------------------------------
# Generated sources
# ------------------------------------------------------------------------------

src/raylua.o: $(LUAJIT_LIB) $(RAYLIB_LIB) $(AUTOGEN_DIR)/boot.c $(AUTOGEN_DIR)/bind.c
src/raylua_builder.o: $(AUTOGEN_DIR)/builder.c

$(AUTOGEN_DIR)/boot.c: src/raylib.lua src/compat.lua src/raylua.lua | $(LUAJIT_LIB)
	$(LUA) $(TOOLS_DIR)/lua2str.lua $@ raylua_boot_lua $^

$(AUTOGEN_DIR)/bind.c: $(TOOLS_DIR)/genbind.lua $(BINDINGS_STAMP) $(BINDING_HEADERS) | $(LUAJIT_LIB)
	$(LUA) $(TOOLS_DIR)/genbind.lua $@ $(MODULES)

$(AUTOGEN_DIR)/builder.c: src/raylua_builder.lua | $(LUAJIT_LIB)
	$(LUA) $(TOOLS_DIR)/lua2str.lua $@ raylua_builder_lua $^

# ------------------------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------------------------

clean-package:
	$(RM_F) $(DIST_DIR)/raylua$(EXE_EXT) $(DIST_DIR)/rayluac$(EXE_EXT)

clean:
	$(RM_RF) $(OUT_DIR)
	$(RM_RF) $(DIST_DIR)
	$(RM_F) src/raylua_s.o src/raylua_d.o src/raylua.o src/raylua_self.o src/raylua_builder.o
	$(RM_F) src/lib/miniz.o src/res/icon.res
	$(RM_F) $(AUTOGEN_DIR)/*.c
	$(RM_F) $(BINDINGS_STAMP) $(AUTOCOMPLETE_STAMP)
	$(MAKE) -C luajit clean
	$(MAKE) -C raylib/src clean
	$(RM_F) raylib/libraylib.a

.PHONY: all luajit raylib bindings autocomplete update package clean-package clean raylua rayluac