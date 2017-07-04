#ifndef _SYNC_AFC_H_
#define _SYNC_AFC_H_

#ifdef __cplusplus
extern "C" {
#endif
	
#include "glob_dev.h"
	
	typedef struct {
		char* appid;
		char* path;
		char* execname;
		char* dispname;
	} sync_afc_appinfo;
	
	extern int sync_afc_start(const char* appid);
	extern int sync_afc_set_root(const char* appid);
	extern int sync_afc_stop(void);
	
	extern int sync_afc_get_device_info(char*** infos);
	extern int sync_afc_get_device_info_key(const char* key, char** value);
	extern int sync_afc_get_file_info(const char* filename, struct stat* stbuf);
	
	extern int sync_afc_make_directory(const char* dir);
	extern int sync_afc_read_directory(const char* dir, char*** dirs);
	extern int sync_afc_dictionary_free(char** dirs);
	extern int sync_afc_get_appinfos(sync_afc_appinfo*** infos);
	extern int sync_afc_appinfos_free(sync_afc_appinfo** infos);
	extern int sync_afc_get_appinfo(const char* appid, sync_afc_appinfo** info);
	extern int sync_afc_get_self_path(const char** path);

	/**
	 * @param file_mode:
	 *  AFC_FOPEN_RDONLY   = 0x00000001,  r   O_RDONLY
	 *  AFC_FOPEN_RW       = 0x00000002,  r+  O_RDWR   | O_CREAT
	 *  AFC_FOPEN_WRONLY   = 0x00000003,  w   O_WRONLY | O_CREAT  | O_TRUNC
	 *  AFC_FOPEN_WR       = 0x00000004,  w+  O_RDWR   | O_CREAT  | O_TRUNC
	 *  AFC_FOPEN_APPEND   = 0x00000005,  a   O_WRONLY | O_APPEND | O_CREAT
	 *  AFC_FOPEN_RDAPPEND = 0x00000006   a+  O_RDWR   | O_APPEND | O_CREAT
	 */
	extern int sync_afc_file_open(const char* filename, int file_mode, uint64_t* handle);
	
	/**
	 * @param operation:
	 *  AFC_LOCK_SH = 1 | 4,  shared lock
	 *  AFC_LOCK_EX = 2 | 4,  exclusive lock
	 *  AFC_LOCK_UN = 8 | 4   unlock
	 */
	extern int sync_afc_file_lock(uint64_t handle, int operation);
	
	extern int sync_afc_file_close(uint64_t handle);
	extern int sync_afc_file_read(uint64_t handle, char* data, uint32_t length, uint32_t* bytes_read);
	extern int sync_afc_file_read_offset(uint64_t handle, int64_t offset, char* data, uint32_t length, uint32_t* bytes_read);
	extern int sync_afc_file_write(uint64_t handle, const char* data, uint32_t length, uint32_t* bytes_written);
	extern int sync_afc_file_write_offset(uint64_t handle, int64_t offset, const char* data, uint32_t length, uint32_t* bytes_written);
	extern int sync_afc_file_seek(uint64_t handle, int64_t offset, int whence);
	extern int sync_afc_file_tell(uint64_t handle, uint64_t* position);
	extern int sync_afc_file_truncate(uint64_t handle, uint64_t newsize);
	
	extern int sync_afc_set_file_time(const char* path, uint64_t mtime);
	extern int sync_afc_truncate(const char* path, uint64_t newsize);
	extern int sync_afc_remove_path(const char* path);
	extern int sync_afc_rename_path(const char* from, const char* to);
	extern int sync_afc_make_link(int is_hard_link, const char* target, const char* linkname);
	
#ifdef __cplusplus
}
#endif

#endif
