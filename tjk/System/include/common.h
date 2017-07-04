//
//  commonHeader.h
//  FsOperation
//
//  Created by philip on 14-5-27.
//  Copyright (c) 2014年 philip. All rights reserved.
//

#ifndef FsOperation_commonHeader_h
#define FsOperation_commonHeader_h

#include <stdio.h>

#ifndef PATH_MAX 
#define PATH_MAX 256 
#endif

#ifndef WIN32
#include <stdarg.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <sys/socket.h>
#include <dirent.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/mount.h>
#include <sys/param.h>
#include <sys/errno.h>
#include <sys/xattr.h>
#include <netinet/tcp.h>

#define fso_inline inline
#else
#define fso_inline _inline
#include <io.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <WinSock.h>
#include <assert.h>

typedef int boolean_t;
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned __int64 uint64_t;
typedef signed char int8_t;
typedef short int16_t;
typedef int int32_t;
typedef long long int64_t;

/*
 * File types
 */
#define	DT_UNKNOWN	 0
#define	DT_FIFO		 1
#define	DT_CHR		 2
#define	DT_DIR		 4
#define	DT_BLK		 6
#define	DT_REG		 8
#define	DT_LNK		10
#define	DT_SOCK		12
#define	DT_WHT		14
typedef struct dirent{
    uint32_t d_ino;        /* inode number */
    uint32_t d_off;        /* offset to the next dirent */
    uint16_t d_reclen;     /* length of this record */
    uint8_t d_type;        /* type of file; not supported by all file system types */
    uint8_t d_namlen;	   /* length of string in d_name */
	char d_name[MAX_PATH]; /* filename */
} dirent;

#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
struct statfs{
	uint32_t f_type;     /* type of file system (see below) */
	uint32_t f_bsize;    /* optimal transfer block size */
	uint32_t f_blocks;   /* total data blocks in file system */
	uint32_t f_bfree;    /* free blocks in fs */
	uint32_t f_bavail;   /* free blocks avail to non-superuser */
	uint32_t f_files;    /* total file nodes in file system */
	uint32_t f_ffree;    /* free file nodes in fs */
	uint64_t f_fsid;     /* file system id */
	uint32_t f_namelen;  /* maximum length of filenames */
};
typedef int mode_t;
//typedef int dev_t;
typedef uint64_t DIR;
typedef int64_t ssize_t;
//typedef uint64_t off_t;
#define INVALID_HANDLE (-1)
//typedef uint8_t uuid_t[16];
typedef int socklen_t;

#define MIN(x,y) ((x) < (y) ? (x) : (y))

#define	TH_FIN	0x01
#define	TH_SYN	0x02
#define	TH_RST	0x04
#define	TH_PUSH	0x08
#define	TH_ACK	0x10
#define	TH_URG	0x20
#define	TH_ECE	0x40
#define	TH_CWR	0x80
#define	TH_FLAGS	(TH_FIN|TH_SYN|TH_RST|TH_ACK|TH_URG|TH_ECE|TH_CWR)

typedef uint32_t uid_t;
typedef uint32_t gid_t;
uid_t _inline getuid(){return 0;}
gid_t _inline getgid(){return 0;}
//stat
#define	S_ISCHR(m)	(((m) & S_IFMT) == S_IFCHR)	/* char special */
#define	S_ISDIR(m)	(((m) & S_IFMT) == S_IFDIR)	/* directory */
#define	S_ISREG(m)	(((m) & S_IFMT) == S_IFREG)	/* regular file */

//fcntl
/* open-only flags */
#define	O_RDONLY	0x0000		/* open for reading only */
#define	O_WRONLY	0x0001		/* open for writing only */
#define	O_RDWR		0x0002		/* open for reading and writing */
#define	O_ACCMODE	0x0003		/* mask for above modes */
#define	FREAD		0x0001
#define	FWRITE		0x0002
#define	O_NONBLOCK	0x0004		/* no delay */
#define	O_APPEND	0x0008		/* set append mode */
#define	O_SHLOCK	0x0010		/* open with shared file lock */
#define	O_EXLOCK	0x0020		/* open with exclusive file lock */
#define	O_ASYNC		0x0040		/* signal pgrp when data ready */
#define	O_FSYNC		O_SYNC		/* source compatibility: do not use */
#define O_NOFOLLOW  0x0100      /* don't follow symlinks */
#define	O_CREAT		0x0200		/* create if nonexistant */
#define	O_TRUNC		0x0400		/* truncate to zero length */
#define	O_EXCL		0x0800		/* error if already exists */

//errors
#define	ENOTSOCK	38		/* Socket operation on non-socket */
#define ENOTSUP		45		/* Operation not supported */
#endif

/* File mode */
/* Read, write, execute/search by owner */
#define	S_IRWXU		0000700		/* [XSI] RWX mask for owner */
#define	S_IRUSR		0000400		/* [XSI] R for owner */
#define	S_IWUSR		0000200		/* [XSI] W for owner */
#define	S_IXUSR		0000100		/* [XSI] X for owner */
/* Read, write, execute/search by group */
#define	S_IRWXG		0000070		/* [XSI] RWX mask for group */
#define	S_IRGRP		0000040		/* [XSI] R for group */
#define	S_IWGRP		0000020		/* [XSI] W for group */
#define	S_IXGRP		0000010		/* [XSI] X for group */
/* Read, write, execute/search by others */
#define	S_IRWXO		0000007		/* [XSI] RWX mask for other */
#define	S_IROTH		0000004		/* [XSI] R for other */
#define	S_IWOTH		0000002		/* [XSI] W for other */
#define	S_IXOTH		0000001		/* [XSI] X for other */

#define	S_ISUID		0004000		/* [XSI] set user id on execution */
#define	S_ISGID		0002000		/* [XSI] set group id on execution */
#define	S_ISVTX		0001000		/* [XSI] directory restrcted delete */

#define	ACCESSPERMS	(S_IRWXU|S_IRWXG|S_IRWXO)	/* 0777 */
/* 7777 */
#define	ALLPERMS	(S_ISUID|S_ISGID|S_ISTXT|S_IRWXU|S_IRWXG|S_IRWXO)
/* 0666 */
#define	DEFFILEMODE	(S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH)
/* end file mode*/

#ifndef PATH_MAX
#define PATH_MAX 256
#else
#undef PATH_MAX
#define PATH_MAX 256
#endif

#ifndef _UNUSED_
#define _UNUSED_
#define UNUSED(x) (x = x);
#endif /* _UNUSED_ */

#endif
