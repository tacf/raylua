#!/usr/bin/env bash
# Builds the raylua web engine (Lua 5.4 + raylib, compiled to WebAssembly
# with Emscripten) and assembles it with the static IDE frontend into
# web/dist/, ready to publish as a GitHub Pages site.
#
# Requires: emsdk activated (emcc/emmake/emar on PATH, or EMSDK env var
# pointing at an emsdk checkout), a host Lua interpreter to run the
# generator scripts (lua5.4, lua, or luajit), and git (for submodules).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEB_DIR="$ROOT_DIR/web"
DIST_DIR="$WEB_DIR/dist"
AUTOGEN_DIR="$WEB_DIR/autogen"
BUILD_DIR="$WEB_DIR/.build"

cd "$ROOT_DIR"

# ---------------------------------------------------------------------------
# 0. Toolchain checks
# ---------------------------------------------------------------------------

HOST_LUA=""
for candidate in lua5.4 lua luajit; do
  if command -v "$candidate" >/dev/null 2>&1; then
    HOST_LUA="$candidate"
    break
  fi
done
if [ -z "$HOST_LUA" ]; then
  echo "error: need a host Lua interpreter (lua5.4, lua, or luajit) on PATH" >&2
  exit 1
fi
echo "== using host Lua: $HOST_LUA"

if ! command -v emcc >/dev/null 2>&1; then
  if [ -n "${EMSDK:-}" ] && [ -f "$EMSDK/emsdk_env.sh" ]; then
    echo "== activating emsdk from \$EMSDK ($EMSDK)"
    # shellcheck disable=SC1091
    source "$EMSDK/emsdk_env.sh"
  elif [ -f "$HOME/devtools/emsdk/emsdk_env.sh" ]; then
    echo "== activating emsdk from ~/devtools/emsdk"
    # shellcheck disable=SC1091
    source "$HOME/devtools/emsdk/emsdk_env.sh"
  else
    echo "== emsdk not found, installing a local copy into web/emsdk"
    if [ ! -d "$WEB_DIR/emsdk" ]; then
      git clone --depth 1 https://github.com/emscripten-core/emsdk.git "$WEB_DIR/emsdk"
    fi
    (cd "$WEB_DIR/emsdk" && ./emsdk install latest && ./emsdk activate latest)
    # shellcheck disable=SC1091
    source "$WEB_DIR/emsdk/emsdk_env.sh"
  fi
fi
command -v emcc >/dev/null 2>&1 || { echo "error: emcc still not on PATH after emsdk setup" >&2; exit 1; }
echo "== $(emcc --version | head -1)"

# ---------------------------------------------------------------------------
# 1. Submodules (raylib, raygui, physac, web/lua)
# ---------------------------------------------------------------------------

for sub in raylib raygui physac web/lua; do
  if [ ! -e "$ROOT_DIR/$sub/.git" ] && [ ! -f "$ROOT_DIR/$sub/.git" ]; then
    echo "== initializing submodule: $sub"
    git submodule update --init "$sub"
  fi
done

# ---------------------------------------------------------------------------
# 2. Regenerate the web binding layer
# ---------------------------------------------------------------------------

echo "== generating web bindings"
mkdir -p "$AUTOGEN_DIR"
LUA_PATH="tools/?.lua;;" "$HOST_LUA" tools/genbind_web.lua "$AUTOGEN_DIR" tools api raymath rlgl gestures rcamera physac raygui
"$HOST_LUA" tools/genconst_web.lua "$AUTOGEN_DIR/web_constants.lua" src/raylib.lua
"$HOST_LUA" tools/lua2str.lua "$AUTOGEN_DIR/web_boot_embed.c" raylua_web_boot_lua \
  "$AUTOGEN_DIR/web_constants.lua" "$AUTOGEN_DIR/web_ctors.lua" web/src/web_boot.lua

# ---------------------------------------------------------------------------
# 3. Build raylib for PLATFORM_WEB (produces raylib/src/libraylib.web.a)
# ---------------------------------------------------------------------------

echo "== building raylib for PLATFORM_WEB"
emmake make -C raylib/src PLATFORM=PLATFORM_WEB -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"

# ---------------------------------------------------------------------------
# 4. Build Lua 5.4 for wasm
# ---------------------------------------------------------------------------

LUA_OBJ_DIR="$BUILD_DIR/luaobj"
mkdir -p "$LUA_OBJ_DIR"
echo "== compiling Lua 5.4 to wasm"
(
  cd web/lua
  for f in *.c; do
    case "$f" in
      lua.c|luac.c|onelua.c) continue ;;
    esac
    obj="$LUA_OBJ_DIR/${f%.c}.o"
    if [ ! -f "$obj" ] || [ "$f" -nt "$obj" ]; then
      emcc -Os -c "$f" -o "$obj" -I.
    fi
  done
)

# ---------------------------------------------------------------------------
# 5. Compile + link the engine
# ---------------------------------------------------------------------------

echo "== linking raylua_web.wasm"
mkdir -p "$DIST_DIR"
emcc -Os \
  web/src/web_main.c web/src/web_marshal.c \
  "$AUTOGEN_DIR/web_bind.c" "$AUTOGEN_DIR/web_structs.c" "$AUTOGEN_DIR/web_boot_embed.c" \
  "$LUA_OBJ_DIR"/*.o \
  raylib/src/libraylib.web.a \
  -I"$AUTOGEN_DIR" -Iweb/src -Iweb/lua -Iraylib/src -Iraygui/src -Iphysac/src \
  -DPLATFORM_WEB -DGRAPHICS_API_OPENGL_ES2 \
  -sUSE_GLFW=3 -sASYNCIFY -sALLOW_MEMORY_GROWTH=1 -sEXIT_RUNTIME=0 \
  -sEXPORTED_FUNCTIONS=_main,_raylua_web_run,_raylua_web_request_stop \
  -sEXPORTED_RUNTIME_METHODS=ccall,cwrap \
  -sMODULARIZE=1 -sEXPORT_NAME=RayluaModule \
  -o "$DIST_DIR/raylua_web.js"

# ---------------------------------------------------------------------------
# 6. Assemble the static site
# ---------------------------------------------------------------------------

echo "== assembling web/dist"
cp web/ide/index.html web/ide/app.js web/ide/style.css "$DIST_DIR/"
rm -rf "$DIST_DIR/examples"
cp -r web/ide/examples "$DIST_DIR/examples"

echo "== done: $DIST_DIR"
du -sh "$DIST_DIR"/raylua_web.wasm "$DIST_DIR"/raylua_web.js 2>/dev/null || true
