#include "web_marshal.h"

#include <lauxlib.h>
#include <lua.h>
#include <stdlib.h>
#include <string.h>

double web_box_get_num(lua_State *L, int idx) {
  if (lua_istable(L, idx)) {
    lua_rawgeti(L, idx, 1);
    double v = lua_tonumber(L, -1);
    lua_pop(L, 1);
    return v;
  }
  return lua_tonumber(L, idx);
}

void web_box_set_num(lua_State *L, int idx, double v) {
  if (lua_istable(L, idx)) {
    lua_pushnumber(L, v);
    lua_rawseti(L, idx, 1);
  }
}

int web_box_get_bool(lua_State *L, int idx) {
  if (lua_istable(L, idx)) {
    lua_rawgeti(L, idx, 1);
    int v = lua_toboolean(L, -1);
    lua_pop(L, 1);
    return v;
  }
  return lua_toboolean(L, idx);
}

void web_box_set_bool(lua_State *L, int idx, int v) {
  if (lua_istable(L, idx)) {
    lua_pushboolean(L, v);
    lua_rawseti(L, idx, 1);
  }
}

void web_textbox_get(lua_State *L, int idx, char *buf, size_t bufsize) {
  const char *s = NULL;
  if (lua_istable(L, idx)) {
    lua_rawgeti(L, idx, 1);
    s = lua_tostring(L, -1);
    if (s) snprintf(buf, bufsize, "%s", s);
    lua_pop(L, 1);
  } else if (lua_isstring(L, idx)) {
    s = lua_tostring(L, idx);
  }
  if (!s) buf[0] = '\0';
  else if (buf[0] == '\0' && s[0] != '\0') snprintf(buf, bufsize, "%s", s);
}

void web_textbox_set(lua_State *L, int idx, const char *buf) {
  if (lua_istable(L, idx)) {
    lua_pushstring(L, buf);
    lua_rawseti(L, idx, 1);
  }
}

void *web_check_opaque(lua_State *L, int idx) {
  if (lua_isnoneornil(L, idx)) return NULL;
  if (lua_islightuserdata(L, idx) || lua_isuserdata(L, idx)) {
    return lua_touserdata(L, idx);
  }
  return NULL;
}

void web_push_opaque(lua_State *L, void *ptr) {
  if (ptr) {
    lua_pushlightuserdata(L, ptr);
  } else {
    lua_pushnil(L);
  }
}

void web_check_opaque_struct(lua_State *L, int idx, void *out, size_t sz) {
  memset(out, 0, sz);
  void *p = web_check_opaque(L, idx);
  if (p) memcpy(out, p, sz);
}

void web_push_opaque_struct(lua_State *L, const void *src, size_t sz) {
  void *p = lua_newuserdata(L, sz);
  memcpy(p, src, sz);
}

#define DEFINE_ARRAY_GET(fnname, ctype)                                     \
  ctype *fnname(lua_State *L, int idx, int *count) {                        \
    int n = 0;                                                              \
    if (lua_istable(L, idx)) n = (int)lua_rawlen(L, idx);                   \
    ctype *out = (ctype *)malloc(sizeof(ctype) * (size_t)(n > 0 ? n : 1));   \
    for (int i = 0; i < n; i++) {                                           \
      lua_rawgeti(L, idx, i + 1);                                           \
      out[i] = (ctype)lua_tonumber(L, -1);                                  \
      lua_pop(L, 1);                                                        \
    }                                                                       \
    *count = n;                                                             \
    return out;                                                             \
  }

DEFINE_ARRAY_GET(web_array_get_float, float)
DEFINE_ARRAY_GET(web_array_get_double, double)
DEFINE_ARRAY_GET(web_array_get_int, int)
DEFINE_ARRAY_GET(web_array_get_uint, unsigned int)
DEFINE_ARRAY_GET(web_array_get_short, short)
DEFINE_ARRAY_GET(web_array_get_ushort, unsigned short)
DEFINE_ARRAY_GET(web_array_get_uchar, unsigned char)
DEFINE_ARRAY_GET(web_array_get_long, long)
