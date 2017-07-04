//
//  fs_interface.h
//  FsOperation
//
//  Created by philip on 15-2-2.
//  Copyright (c) 2015年 philip. All rights reserved.
//

#ifndef FsOperation_fs_interface_h
#define FsOperation_fs_interface_h

#include "common.h"

#define AFC_ERRNO_PREFIX 0x00010000

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */
    
    /*
     * stat
     */
    int	fso_stat(const char * path, struct stat * st);//3
    /*
     * fstat
     */
    int	fso_fstat(int fd, struct stat * st);//3
    /*
     * lstat
     */
    int	fso_lstat(const char * path, struct stat * st);//3
    
    
    int fso_setattr(const char* path, struct stat* st, uint16_t mask);
    int fso_fsetattr(int fd, struct stat* st, uint16_t mask);
/*setattr mask value */
#define SETATTR_MASK_MODE           0x0020
#define SETATTR_MASK_UID            0x0080
#define SETATTR_MASK_GID            0x0100
#define SETATTR_MASK_SIZE           0x0400
#define SETATTR_MASK_ATIME          0x2000
#define SETATTR_MASK_MTIME          0x4000
#define SETATTR_MASK_CTIME          0x8000
#define SETATTR_MASK_ALL_SUPPORT    0xe5a0
    /*
     * readlink
     */
    ssize_t fso_readlink(const char * path, char * buf, size_t bufsize); //5
    /*
     * symlink
     */
    int     fso_symlink(const char * target, const char *linkname);//6
    /*
     * lseek
     */
    off_t   fso_lseek(int fd, off_t offset, int fromwhere);//7
    
    /*
     * mknod, not support
     */
    int     fso_mknod(const char *, mode_t, dev_t);//8
    
    /*
     * mkdir
     */
    int     fso_mkdir(const char * path, mode_t mode); //9
    /*
     * ulink
     */
    int     fso_unlink(const char * path);//10
    /*
     * rmdir
     */
    int     fso_rmdir(const char * path);//11
    /*
     * rename
     */
    int     fso_rename(const char * from, const char * to);//12
    /*
     * link
     */
    int     fso_link(const char * target, const char * linkname);//13
    /*
     * open
     */
    int     fso_open(const char * path, int oflag, ...);//14
    /*
     * read
     */
    ssize_t	fso_read(int fd, void* buffer, size_t size);//15
    /*
     * write
     */
    ssize_t	fso_write(int fd, const void* buffer, size_t size);//16
    /*
     * fstatfs
     */
    int     fso_fstatfs(int fd, struct statfs* stbuf);//17
    /*
     * statfs
     */
    int     fso_statfs(const char* path, struct statfs* stbuf);//17
    /*
     * close
     */
    int     fso_close(int fd);//18
    /*
     * truncate
     */
    int     fso_truncate(const char *path, off_t length);//19
    
    /*
     * fsync
     */
    int     fso_fsync(int fd);//20
    
    /*
     * setxattr, not support
     */
    int     fso_setxattr(const char *path, const char *name, const void *value, size_t size, uint32_t position, int options);//21
    /*
     * getxattr, not support
     */
    ssize_t fso_getxattr(const char *path, const char *name, void *value, size_t size, uint32_t position, int options);//22
    /*
     * listxattr, not support
     */
    ssize_t fso_listxattr(const char *path, char *namebuff, size_t size, int options);//23
    /*
     * removexattr, not support
     */
    int     fso_removexattr(const char *path, const char *name, int options);//24
    /*
     * flush
     */
    int     fso_flush(int fd);// 25
    /*
     * opendir
     */
    DIR*    fso_opendir(const char * path);//27
    
    /*
     * readdir
     */
    struct dirent* fso_readdir(DIR * dir);//28
    /*
     * closedir
     */
    int     fso_closedir(DIR* dir);//29
    /*
     * fsyncdir, not support
     */
    int     fso_fsyncdir(const char* path, int isdatasync, void* fi);//30
    /*
     * fcntl, not support
     */
    int     fso_fcntl(int, int, ...);//31 F_GETLK //32 F_SETLK //33 F_SETLKW
    
    /*
     * access
     */
    int     fso_access(const char * path, int mode);//34
    /*
     * creat
     */
    int     fso_creat(const char * path, mode_t mode);//35
    /*
     * icotl, not support
     */
    int     fso_ioctl(int, unsigned long, ...);//39
#ifndef WIN32
    typedef struct _afc_app_info{
        char* _appid;
        char* _path;
        char* _execname;
        char* _dispname;
    }afc_app_info;
    int fso_afc_get_appinfos(afc_app_info*** infos);
#endif
#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif
