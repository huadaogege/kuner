//
//  emmc_interface.h
//  FsOperation
//
//  Created by philip on 15-2-2.
//  Copyright (c) 2015年 philip. All rights reserved.
//

#ifndef FsOperation_emmc_interface_h
#define FsOperation_emmc_interface_h

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

    /* used to read from usr dat zone
     * @param
     *      buffer, buffer to recevie bytes
     *      size, size of buffer
     * return:
     *      return 0 if success, otherwise return -1.
     */
    int     fso_read_from_usr_dat(uint32_t offset, void* buffer, size_t size);//45 emmc_r
    
    /* used to earse data in usr dat zone
     *
     * return:
     *      return 0 if success, otherwise return -1.
     */
    int     fso_earse_usr_dat(uint32_t offset, size_t size);//47 emcc_e
    /* used to write data from buffer to usr dat zone
     * @param
     *      buffer, buffer to write
     *      size, size of buffer
     *
     * return:
     *      return 0 if success, otherwise return -1.
     */
    int     fso_write_to_usr_dat(uint32_t offset, void* buffer, size_t size);//46 emcc_w
    /* used to write data from buffer to apple zone
     * @param
     *      buffer, buffer to write
     *      size, size of buffer
     *
     * return:
     *      return 0 if success, otherwise return -1.
     */
    int     fso_write_to_apple_zone(uint32_t offset, void* buffer, size_t size);//46 emcc_w
    /* used to write data from buffer to pc zone
     * @param
     *      buffer, buffer to write
     *      size, size of buffer
     *
     * return:
     *      return 0 if success, otherwise return -1.
     */
    int     fso_write_to_pc_zone(uint32_t offset, void* buffer, size_t size);//46 emcc_w
    /* used to write data from buffer to firmware zone
     * @param
     *      buffer, buffer to write
     *      size, size of buffer
     *
     * return:
     *      return 0 if success, otherwise return -1.
     */
    int     fso_write_to_firmware_zone(uint32_t offset, void* buffer, size_t size);//46 emcc_w
    
#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif //FsOperation_emmc_interface_h
