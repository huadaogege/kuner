#ifndef _GLOB_DEV_H_
#define _GLOB_DEV_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <pthread.h>
#include <libimobiledevice/lockdown.h>

extern pthread_mutex_t _mb_synclock;
#define dev_lock() pthread_mutex_lock(&_mb_synclock)
#define dev_unlock() pthread_mutex_unlock(&_mb_synclock)
extern idevice_t dev_ref(void);
extern void dev_deref(idevice_t);
extern lockdownd_client_t lockdownd_ref(void);
extern void lockdownd_deref(lockdownd_client_t);
    
#ifdef __cplusplus
}
#endif

#endif
