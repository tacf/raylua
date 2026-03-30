/*
  raylua runtime binary - runs .zip/.rlua game packages
  and .lua files directly or folders containing main.lua

  Build-time switches:
    RAYLUA_ENABLE_SHELL=1  -> enables --shell
    RAYLUA_ENABLE_SHELL=0  -> distributable build, no shell
*/

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#define NOGDI
#define NOUSER
#define NOSOUND
#include <direct.h>
#include <windows.h>
#define chdir _chdir
#define PATH_SEP '\\'
#else
#include <dirent.h>
#include <unistd.h>
#define PATH_SEP '/'
#endif

#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

#include "lib/miniz.h"
#include <raylib.h>

#include "raylua.h"

#ifndef RAYLUA_ENABLE_SHELL
#define RAYLUA_ENABLE_SHELL 1
#endif

#define RAYLUA_PATH_MAX 4096

static mz_zip_archive zip_file;

/* ============================================================================
   Path helpers
   ========================================================================== */

static bool has_ext(const char *path, const char *ext) {
	size_t pl = strlen(path), el = strlen(ext);
	return pl >= el && strcmp(path + pl - el, ext) == 0;
}

static void copy_string(char *dst, size_t dst_size, const char *src) {
	if (dst_size == 0) return;
	snprintf(dst, dst_size, "%s", src ? src : "");
}

static void to_native_separators(char *s) {
	for (; *s; s++) {
		if (*s == '/' || *s == '\\') *s = PATH_SEP;
	}
}

static void to_forward_separators(char *s) {
	for (; *s; s++) {
		if (*s == '\\') *s = '/';
	}
}

static const char *path_basename(const char *path) {
	const char *a = strrchr(path, '/');
	const char *b = strrchr(path, '\\');
	const char *p = a;

	if (!p || (b && b > p)) p = b;
	return p ? p + 1 : path;
}

static void path_dirname(const char *path, char *out, size_t out_size) {
	const char *base = path_basename(path);
	size_t len = (size_t)(base - path);

	if (len == 0) {
		copy_string(out, out_size, ".");
		return;
	}

	while (len > 0 && (path[len - 1] == '/' || path[len - 1] == '\\')) len--;

	if (len == 0) {
		snprintf(out, out_size, "%c", PATH_SEP);
		return;
	}

	snprintf(out, out_size, "%.*s", (int)len, path);
}

static bool path_join_native(char *out, size_t out_size, const char *a, const char *b) {
	int n;

	if (!a || !*a) {
		n = snprintf(out, out_size, "%s", b ? b : "");
		if (n < 0 || (size_t)n >= out_size) return false;
		to_native_separators(out);
		return true;
	}

	if (!b || !*b) {
		n = snprintf(out, out_size, "%s", a);
		if (n < 0 || (size_t)n >= out_size) return false;
		to_native_separators(out);
		return true;
	}

	if (a[strlen(a) - 1] == '/' || a[strlen(a) - 1] == '\\') {
		n = snprintf(out, out_size, "%s%s", a, b);
	} else {
		n = snprintf(out, out_size, "%s%c%s", a, PATH_SEP, b);
	}

	if (n < 0 || (size_t)n >= out_size) return false;
	to_native_separators(out);
	return true;
}

static bool path_join_rel(char *out, size_t out_size, const char *a, const char *b) {
	int n;

	if (!a || !*a) {
		n = snprintf(out, out_size, "%s", b ? b : "");
	} else if (!b || !*b) {
		n = snprintf(out, out_size, "%s", a);
	} else if (a[strlen(a) - 1] == '/') {
		n = snprintf(out, out_size, "%s%s", a, b);
	} else {
		n = snprintf(out, out_size, "%s/%s", a, b);
	}

	return n >= 0 && (size_t)n < out_size;
}

static bool is_directory(const char *path) {
	struct stat st;
	return stat(path, &st) == 0 && S_ISDIR(st.st_mode);
}

static bool is_regular_file(const char *path) {
	struct stat st;
	return stat(path, &st) == 0 && S_ISREG(st.st_mode);
}

/* ============================================================================
   ZIP package mode
   ========================================================================== */

int raylua_loadfile(lua_State *L) {
	const char *path = luaL_checkstring(L, 1);
	int index = mz_zip_reader_locate_file(&zip_file, path, NULL, 0);
	if (index == -1) {
		lua_pushnil(L);
		lua_pushfstring(L, "%s: File not found.", path);
		return 2;
	}

	mz_zip_archive_file_stat stat;
	if (!mz_zip_reader_file_stat(&zip_file, index, &stat)) {
		lua_pushnil(L);
		lua_pushfstring(L, "%s: Can't get file info.", path);
		return 2;
	}

	size_t size = stat.m_uncomp_size;
	char *buffer = (char *)malloc(size);
	if (!buffer) {
		lua_pushnil(L);
		lua_pushfstring(L, "%s: Can't allocate buffer.", path);
		return 2;
	}

	if (!mz_zip_reader_extract_to_mem(&zip_file, index, buffer, size, 0)) {
		free(buffer);
		lua_pushnil(L);
		lua_pushfstring(L, "%s: Can't extract.", path);
		return 2;
	}

	lua_pushlstring(L, buffer, size);
	free(buffer);
	return 1;
}

int raylua_listfiles(lua_State *L) {
	size_t count = mz_zip_reader_get_num_files(&zip_file);
	char filename[1024];

	lua_createtable(L, (int)count, 0);
	for (size_t i = 0; i < count; i++) {
		mz_zip_reader_get_filename(&zip_file, i, filename, sizeof(filename));
		lua_pushstring(L, filename);
		lua_rawseti(L, -2, (int)i + 1);
	}
	return 1;
}

unsigned char *raylua_loadFileData(const char *path, int *out_size) {
	int index = mz_zip_reader_locate_file(&zip_file, path, NULL, 0);
	if (index == -1) return NULL;

	mz_zip_archive_file_stat stat;
	if (!mz_zip_reader_file_stat(&zip_file, index, &stat)) return NULL;

	unsigned char *buffer = RL_MALLOC(stat.m_uncomp_size);
	if (!buffer) return NULL;

	if (!mz_zip_reader_extract_to_mem(&zip_file, index, buffer, stat.m_uncomp_size, 0)) {
		RL_FREE(buffer);
		return NULL;
	}

	*out_size = (int)stat.m_uncomp_size;
	return buffer;
}

char *raylua_loadFileText(const char *path) {
	int index = mz_zip_reader_locate_file(&zip_file, path, NULL, 0);
	if (index == -1) return NULL;

	mz_zip_archive_file_stat stat;
	if (!mz_zip_reader_file_stat(&zip_file, index, &stat)) return NULL;

	char *buffer = RL_MALLOC(stat.m_uncomp_size + 1);
	if (!buffer) return NULL;

	buffer[stat.m_uncomp_size] = '\0';
	if (!mz_zip_reader_extract_to_mem(&zip_file, index, buffer, stat.m_uncomp_size, 0)) {
		RL_FREE(buffer);
		return NULL;
	}

	return buffer;
}

static bool init_payload(FILE *f) {
	mz_zip_zero_struct(&zip_file);
	return mz_zip_reader_init_cfile(&zip_file, f, 0, 0);
}

/* ============================================================================
   Filesystem mode (.lua files and folders)
   ========================================================================== */

static char fs_root[RAYLUA_PATH_MAX] = ".";
static char fs_entry[RAYLUA_PATH_MAX] = "main.lua";
static bool fs_alias_main = false;

static bool read_file_all(const char *path, char **out_buffer, size_t *out_size) {
	FILE *f = fopen(path, "rb");
	long size_long;
	size_t size;
	char *buffer;

	if (!f) return false;

	if (fseek(f, 0, SEEK_END) != 0) {
		fclose(f);
		return false;
	}

	size_long = ftell(f);
	if (size_long < 0) {
		fclose(f);
		return false;
	}

	size = (size_t)size_long;
	if (fseek(f, 0, SEEK_SET) != 0) {
		fclose(f);
		return false;
	}

	buffer = (char *)malloc(size);
	if (!buffer) {
		fclose(f);
		return false;
	}

	if (size > 0 && fread(buffer, 1, size, f) != size) {
		free(buffer);
		fclose(f);
		return false;
	}

	fclose(f);
	*out_buffer = buffer;
	*out_size = size;
	return true;
}

static bool fs_resolve_request(const char *request, char *resolved, size_t resolved_size) {
	const char *actual = request;

	if (fs_alias_main && strcmp(request, "main.lua") == 0) {
		actual = fs_entry;
	}

	return path_join_native(resolved, resolved_size, fs_root, actual);
}

int raylua_fs_loadfile(lua_State *L) {
	const char *path = luaL_checkstring(L, 1);
	char real_path[RAYLUA_PATH_MAX];
	char *buffer = NULL;
	size_t size = 0;

	if (!fs_resolve_request(path, real_path, sizeof(real_path))) {
		lua_pushnil(L);
		lua_pushfstring(L, "%s: Path too long.", path);
		return 2;
	}

	if (!read_file_all(real_path, &buffer, &size)) {
		lua_pushnil(L);
		lua_pushfstring(L, "%s: File not found.", path);
		return 2;
	}

	lua_pushlstring(L, buffer, size);
	free(buffer);
	return 1;
}

#ifndef _WIN32
static void fs_list_dir_recursive(lua_State *L, const char *rel_dir, int *index) {
	char full_dir[RAYLUA_PATH_MAX];
	DIR *dir;
	struct dirent *entry;

	if (rel_dir && *rel_dir) {
		if (!path_join_native(full_dir, sizeof(full_dir), fs_root, rel_dir)) return;
	} else {
		copy_string(full_dir, sizeof(full_dir), fs_root);
	}

	dir = opendir(full_dir);
	if (!dir) return;

	while ((entry = readdir(dir)) != NULL) {
		const char *name = entry->d_name;
		char rel_path[RAYLUA_PATH_MAX];
		char full_path[RAYLUA_PATH_MAX];

		if (strcmp(name, ".") == 0 || strcmp(name, "..") == 0) continue;

		if (rel_dir && *rel_dir) {
			if (!path_join_rel(rel_path, sizeof(rel_path), rel_dir, name)) continue;
		} else {
			copy_string(rel_path, sizeof(rel_path), name);
		}

		if (!path_join_native(full_path, sizeof(full_path), fs_root, rel_path)) continue;

		if (is_directory(full_path)) {
			fs_list_dir_recursive(L, rel_path, index);
		} else if (is_regular_file(full_path)) {
			to_forward_separators(rel_path);
			lua_pushstring(L, rel_path);
			lua_rawseti(L, -2, (*index)++);
		}
	}

	closedir(dir);
}
#else
static void fs_list_dir_recursive(lua_State *L, const char *rel_dir, int *index) {
	char full_dir[RAYLUA_PATH_MAX];
	char pattern[RAYLUA_PATH_MAX];
	WIN32_FIND_DATAA data;
	HANDLE h;

	if (rel_dir && *rel_dir) {
		if (!path_join_native(full_dir, sizeof(full_dir), fs_root, rel_dir)) return;
	} else {
		copy_string(full_dir, sizeof(full_dir), fs_root);
	}

	if (!path_join_native(pattern, sizeof(pattern), full_dir, "*")) return;

	h = FindFirstFileA(pattern, &data);
	if (h == INVALID_HANDLE_VALUE) return;

	do {
		const char *name = data.cFileName;
		char rel_path[RAYLUA_PATH_MAX];
		char full_path[RAYLUA_PATH_MAX];

		if (strcmp(name, ".") == 0 || strcmp(name, "..") == 0) continue;

		if (rel_dir && *rel_dir) {
			if (!path_join_rel(rel_path, sizeof(rel_path), rel_dir, name)) continue;
		} else {
			copy_string(rel_path, sizeof(rel_path), name);
		}

		if (!path_join_native(full_path, sizeof(full_path), fs_root, rel_path)) continue;

		if (data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
			fs_list_dir_recursive(L, rel_path, index);
		} else if (is_regular_file(full_path)) {
			to_forward_separators(rel_path);
			lua_pushstring(L, rel_path);
			lua_rawseti(L, -2, (*index)++);
		}
	} while (FindNextFileA(h, &data));

	FindClose(h);
}
#endif

int raylua_fs_listfiles(lua_State *L) {
	int index = 1;

	lua_newtable(L);

	if (fs_alias_main) {
		lua_pushstring(L, "main.lua");
		lua_rawseti(L, -2, index++);
	}

	fs_list_dir_recursive(L, "", &index);
	return 1;
}

#ifndef _WIN32
static bool find_main_lua_recursive(const char *dir, char *out_path, size_t out_size) {
	char direct_main[RAYLUA_PATH_MAX];
	DIR *d;
	struct dirent *entry;

	if (path_join_native(direct_main, sizeof(direct_main), dir, "main.lua") &&
	    is_regular_file(direct_main)) {
		copy_string(out_path, out_size, direct_main);
		return true;
	}

	d = opendir(dir);
	if (!d) return false;

	while ((entry = readdir(d)) != NULL) {
		const char *name = entry->d_name;
		char child[RAYLUA_PATH_MAX];

		if (strcmp(name, ".") == 0 || strcmp(name, "..") == 0) continue;
		if (!path_join_native(child, sizeof(child), dir, name)) continue;

		if (is_directory(child)) {
			if (find_main_lua_recursive(child, out_path, out_size)) {
				closedir(d);
				return true;
			}
		}
	}

	closedir(d);
	return false;
}
#else
static bool find_main_lua_recursive(const char *dir, char *out_path, size_t out_size) {
	char direct_main[RAYLUA_PATH_MAX];
	char pattern[RAYLUA_PATH_MAX];
	WIN32_FIND_DATAA data;
	HANDLE h;

	if (path_join_native(direct_main, sizeof(direct_main), dir, "main.lua") &&
	    is_regular_file(direct_main)) {
		copy_string(out_path, out_size, direct_main);
		return true;
	}

	if (!path_join_native(pattern, sizeof(pattern), dir, "*")) return false;

	h = FindFirstFileA(pattern, &data);
	if (h == INVALID_HANDLE_VALUE) return false;

	do {
		const char *name = data.cFileName;
		char child[RAYLUA_PATH_MAX];

		if (strcmp(name, ".") == 0 || strcmp(name, "..") == 0) continue;
		if (!(data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) continue;
		if (!path_join_native(child, sizeof(child), dir, name)) continue;

		if (find_main_lua_recursive(child, out_path, out_size)) {
			FindClose(h);
			return true;
		}
	} while (FindNextFileA(h, &data));

	FindClose(h);
	return false;
}
#endif

static bool prepare_filesystem_target(const char *input, char *script_path, size_t script_path_size) {
	if (has_ext(input, ".lua") && is_regular_file(input)) {
		copy_string(script_path, script_path_size, input);
		return true;
	}

	if (is_directory(input)) {
		return find_main_lua_recursive(input, script_path, script_path_size);
	}

	return false;
}

/* ============================================================================
   Runtime helpers
   ========================================================================== */

static lua_State *raylua_new_state(int argc, const char **argv) {
	lua_State *L = luaL_newstate();
	if (!L) {
		puts("RAYLUA: Can't init Lua");
		return NULL;
	}

	luaL_openlibs(L);

	lua_newtable(L);
	for (int i = 0; i < argc; i++) {
		lua_pushstring(L, argv[i]);
		lua_rawseti(L, -2, i);
	}
	lua_setglobal(L, "arg");

	return L;
}

static int raylua_run_zip(lua_State *L, const char *input) {
	FILE *f = fopen(input, "rb");

	if (!f || !init_payload(f)) {
		if (f) fclose(f);
		puts("RAYLUA: Can't open game package");
		return 1;
	}

	SetLoadFileDataCallback(raylua_loadFileData);
	SetLoadFileTextCallback(raylua_loadFileText);

	raylua_boot(L, raylua_loadfile, raylua_listfiles, false);

	mz_zip_reader_end(&zip_file);
	fclose(f);
	return 0;
}

static int raylua_run_filesystem(lua_State *L, const char *input) {
	char script_path[RAYLUA_PATH_MAX];
	char script_dir[RAYLUA_PATH_MAX];

	if (!prepare_filesystem_target(input, script_path, sizeof(script_path))) {
		puts("RAYLUA: Expected .zip, .rlua, .lua, or a folder containing main.lua");
		return 1;
	}

	path_dirname(script_path, script_dir, sizeof(script_dir));

	if (chdir(script_dir) != 0) {
		printf("RAYLUA: Can't enter script directory: %s\n", script_dir);
		return 1;
	}

	copy_string(fs_root, sizeof(fs_root), ".");
	copy_string(fs_entry, sizeof(fs_entry), path_basename(script_path));
	fs_alias_main = (strcmp(fs_entry, "main.lua") != 0);

	raylua_boot(L, raylua_fs_loadfile, raylua_fs_listfiles, false);
	return 0;
}

/* ============================================================================
   Main
   ========================================================================== */

int main(int argc, const char **argv) {
	const char *input;
	bool is_zip;
	lua_State *L;
	int rc;

	if (argc < 2) {
		printf("Usage: %s <game.zip|game.rlua|script.lua|folder>\n", argv[0]);
#if RAYLUA_ENABLE_SHELL
		printf("       %s --shell  (interactive Lua)\n", argv[0]);
#endif
		return 1;
	}

#if RAYLUA_ENABLE_SHELL
	if (strcmp(argv[1], "--shell") == 0) {
		L = raylua_new_state(argc, argv);
		if (!L) return 1;

		raylua_boot(L, NULL, NULL, true);
		lua_close(L);
		return 0;
	}
#else
	if (strcmp(argv[1], "--shell") == 0) {
		puts("RAYLUA: Shell support disabled in this build");
		return 1;
	}
#endif

	input = argv[1];
	is_zip = has_ext(input, ".zip") || has_ext(input, ".rlua");

	L = raylua_new_state(argc, argv);
	if (!L) return 1;

	rc = is_zip ? raylua_run_zip(L, input) : raylua_run_filesystem(L, input);

	lua_close(L);
	return rc;
}