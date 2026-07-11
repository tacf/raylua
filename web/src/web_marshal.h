/*
  Generic (non-generated) marshaling helpers used by the auto-generated
  web binding (web/autogen/web_bind.c, web_structs.c).
*/
#ifndef RAYLUA_WEB_MARSHAL_H
#define RAYLUA_WEB_MARSHAL_H

#include <lua.h>
#include <stddef.h>

/* 1-element Lua table used as a mutable box for scalar in/out params,
   e.g. `local checked = {false}; rl.GuiCheckBox(rect, "x", checked)`. */
double web_box_get_num(lua_State *L, int idx);
void web_box_set_num(lua_State *L, int idx, double v);
int web_box_get_bool(lua_State *L, int idx);
void web_box_set_bool(lua_State *L, int idx, int v);

/* 1-element Lua table used as a mutable box for text-editing buffers. */
void web_textbox_get(lua_State *L, int idx, char *buf, size_t bufsize);
void web_textbox_set(lua_State *L, int idx, const char *buf);

/* Raw pointer passthrough: values Lua can hold and pass back, but not
   inspect. Used for unknown pointer types and opaque handles. */
void *web_check_opaque(lua_State *L, int idx);
void web_push_opaque(lua_State *L, void *ptr);

/* By-value structs with no field metadata: copied into a GC-managed Lua
   full userdata so callers can still round-trip them between calls. */
void web_check_opaque_struct(lua_State *L, int idx, void *out, size_t sz);
void web_push_opaque_struct(lua_State *L, const void *src, size_t sz);

/* Reads a 1-indexed Lua array table of numbers into a malloc'd C array.
   Caller must free() the result. */
float *web_array_get_float(lua_State *L, int idx, int *count);
double *web_array_get_double(lua_State *L, int idx, int *count);
int *web_array_get_int(lua_State *L, int idx, int *count);
unsigned int *web_array_get_uint(lua_State *L, int idx, int *count);
short *web_array_get_short(lua_State *L, int idx, int *count);
unsigned short *web_array_get_ushort(lua_State *L, int idx, int *count);
unsigned char *web_array_get_uchar(lua_State *L, int idx, int *count);
long *web_array_get_long(lua_State *L, int idx, int *count);

#endif
