#ifndef _SIMP_SBS_H_
#define _SIMP_SBS_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "glob_dev.h"

extern int simp_sbs_start(void);
extern int simp_sbs_stop(void);

extern int simp_sbs_get_icon_state(void* state, const char* format_version);
extern int simp_sbs_set_icon_state(const void* newstate);

extern int simp_sbs_get_icon_pngdata(const char* bundleId, char** pngdata, uint64_t* pngsize);
extern int simp_sbs_get_home_screen_wallpaper_pngdata(char** pngdata, uint64_t* pngsize);

/**
 * @param interface_orientation:
 *  SBSERVICES_INTERFACE_ORIENTATION_UNKNOWN                = 0,
 *  SBSERVICES_INTERFACE_ORIENTATION_PORTRAIT               = 1,
 *  SBSERVICES_INTERFACE_ORIENTATION_PORTRAIT_UPSIDE_DOWN   = 2,
 *  SBSERVICES_INTERFACE_ORIENTATION_LANDSCAPE_RIGHT        = 3,
 *  SBSERVICES_INTERFACE_ORIENTATION_LANDSCAPE_LEFT         = 4
 */
extern int simp_sbs_get_interface_orientation(int* interface_orientation);

#ifdef __cplusplus
}
#endif

#endif
