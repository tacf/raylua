/*
  Web engine driver.

  Desktop raylua embeds LuaJIT and calls into raylib via FFI cdata function
  pointers -- a mechanism that has no WebAssembly equivalent (there is no
  wasm backend for LuaJIT's assembly VM/FFI call trampolines). This driver
  instead runs standard Lua 5.4 against the generated lua_CFunction bindings
  in web/autogen/web_bind.c.

  Under Emscripten this is compiled with -sASYNCIFY, so the classic
  `while not rl.WindowShouldClose() do ... end` loop shape used by every
  raylua example keeps working unmodified: raylib's own PLATFORM_WEB backend
  yields to the browser each frame, and Asyncify transparently suspends and
  resumes the whole C/Lua call stack around that yield.
*/

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

#include <raylib.h>

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#else
#define EMSCRIPTEN_KEEPALIVE
#endif

void web_bind_register(lua_State *L, int tbl_index);
extern const char *raylua_web_boot_lua;

static int g_stop_requested = 0;

static int l_web_window_should_close(lua_State *L) {
  lua_pushboolean(L, WindowShouldClose() || g_stop_requested);
  return 1;
}

static int web_traceback(lua_State *L) {
  const char *msg = lua_tostring(L, 1);
  luaL_traceback(L, L, msg, 1);
  return 1;
}

static void run_script(const char *src, size_t len) {
  g_stop_requested = 0;

  lua_State *L = luaL_newstate();
  if (!L) {
    fprintf(stderr, "RAYLUA(web): out of memory creating Lua state\n");
    return;
  }
  luaL_openlibs(L);

  lua_newtable(L);
  web_bind_register(L, -1);
  lua_pushcfunction(L, l_web_window_should_close);
  lua_setfield(L, -2, "WindowShouldClose");
  lua_setglobal(L, "rl");

  lua_newtable(L);
  lua_setglobal(L, "arg");

  if (luaL_dostring(L, raylua_web_boot_lua) != LUA_OK) {
    fprintf(stderr, "RAYLUA(web) boot error: %s\n", lua_tostring(L, -1));
    lua_close(L);
    return;
  }

  if (luaL_loadbuffer(L, src, len, "=script") != LUA_OK) {
    fprintf(stderr, "RAYLUA(web) load error: %s\n", lua_tostring(L, -1));
    lua_close(L);
    return;
  }

  lua_pushcfunction(L, web_traceback);
  lua_insert(L, -2);
  if (lua_pcall(L, 0, 0, -2) != LUA_OK) {
    fprintf(stderr, "%s\n", lua_tostring(L, -1));
  }

  if (IsWindowReady()) CloseWindow();
  lua_close(L);
}

EMSCRIPTEN_KEEPALIVE
void raylua_web_run(const char *src) {
  run_script(src, strlen(src));
}

EMSCRIPTEN_KEEPALIVE
void raylua_web_request_stop(void) {
  g_stop_requested = 1;
}

#ifdef __EMSCRIPTEN__

int main(void) {
  /* Everything happens in raylua_web_run(), called from JS per "Run" click.
     Keep the runtime alive between calls (see -sEXIT_RUNTIME=0). */
  return 0;
}

#else

/* Native CLI entry point, used only for fast local smoke-testing of the
   generated bindings -- not part of the web build. */
int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "usage: %s script.lua\n", argv[0]);
    return 1;
  }

  FILE *f = fopen(argv[1], "rb");
  if (!f) {
    perror("fopen");
    return 1;
  }
  fseek(f, 0, SEEK_END);
  long sz = ftell(f);
  fseek(f, 0, SEEK_SET);
  char *buf = malloc((size_t)sz + 1);
  size_t rd = fread(buf, 1, (size_t)sz, f);
  buf[rd] = 0;
  fclose(f);

  run_script(buf, rd);

  free(buf);
  return 0;
}

#endif
