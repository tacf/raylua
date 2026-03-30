#!/bin/sh
set -eu

root="$(CDPATH= cd -- "$(dirname -- "$0")/../../" && pwd)"
echo $root
parser="${root}/raylib/tools/rlparser/rlparser"

if [ ! -x "$parser" ]; then
  cd ${root}/raylib/tools/rlparser/
  make
  cd -
  if [ ! -x "$parser" ]; then
    echo "error: parser not found at $parser"
    echo "build it first from raylib/tools/rlparser"
    exit 1
  fi
fi

mkdir -p api

"$parser" -i "$root/raylib/src/raylib.h"    -o api/raylib_api.lua  -d RLAPI      -f LUA
"$parser" -i "$root/raylib/src/rcamera.h"   -o api/rcamera_api.lua -d RLAPI      -f LUA
"$parser" -i "$root/raylib/src/rlgl.h"      -o api/rlgl_api.lua    -d RLAPI      -f LUA
"$parser" -i "$root/raygui/src/raygui.h"    -o api/raygui_api.lua  -d RAYGUIAPI  -f LUA
"$parser" -i "$root/physac/src/physac.h"    -o api/physac_api.lua  -d PHYSACDEF  -f LUA

# Optional, if you vendor easings or other raylib-style headers:
# "$parser" -i "$root/raylib/src/reasings.h" -o api/easings_api.lua -d EASEDEF -f LUA

echo "autocomplete api files regenerated"