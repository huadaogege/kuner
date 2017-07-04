//
//  tgk_control.h
//  FsOperation
//
//  Created by philip on 15-2-2.
//  Copyright (c) 2015年 philip. All rights reserved.
//

#ifndef FsOperation_tgk_control_h
#define FsOperation_tgk_control_h

#include "common.h"
#include "kac.h"

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */
    /*
     * return /var/mobile/Media 's path
     */
    const char* fso_get_Media_path();
    
    typedef enum{
        DEVICE_STATUS_DISCONN = 0,
        DEVICE_STATUS_WAIT_PAIR,//1
        DEVICE_STATUS_WORK, //2
        DEVICE_STATUS_SD_INSERTED,
        DEVICE_STATUS_SD_MISSED,
    }DEVICE_STATUS_TYPE;
    /*
     * return usb device's status,
     *      if DEVICE_STATUS_WAIT_PAIR, u can only call fso_set_pair to continue
     *      if DEVICE_STATUS_WORK, u can continue do something depending fs_status
     */
    DEVICE_STATUS_TYPE fso_get_device_status();
    
    
    typedef enum{
        FS_STATUS_UNINITED = 0,
        FS_STATUS_INITED,       //1
        FS_STATUS_WAIT_FORMAT,  //2
        FS_STATUS_INIT_ERROR,    //3
        FS_STATUS_FORMATTING,
        FS_STATUS_HW_UNAVAILABLE
    }FS_STATUS_TYPE;
    /*
     * return file system's status. if success, return FS_STATUS_INITED.
     *      if return FS_STATUS_WAIT_FORMAT, u must call fso_format to format the filesystem before do fs operations.
     */
    FS_STATUS_TYPE fso_get_fs_status();
    
    
    //1 lookup not support
    //2 forget not support
    
    typedef struct {
        union {
            uint8_t head[sizeof(uint32_t) + 16 + sizeof(emmc_inf)];
            struct {
                uint32_t mktime;  // When the filesystem was created
                uint8_t uuid[16]; // uuid of filesystem
                emmc_inf emmc;
            };
        };
        char name[PATH_MAX];
    }fso_proto_init;
    
    /* used to get configuration of connected device
     * @param
     *  conf, used to receive the result, include mktime, uuid, and name
     * return:
     *      return 0 if success, otherwise return -1.
     * details:
     *      For Kuke:
     *          fs_free & egrp_len[] is 0                        -- fs mount failed
     *          fs_free & egrp_len[] is valid                    -- fs mount ok
     *
     *      For Kubao:
     *          sd_card_state = 1, fs_free & egrp_len[] is 0     -- fs mount failed;
     *          sd_card_state = 1, fs_free & egrp_len[] is valid -- fs mount ok;
     *          sd_card_state = 0                                -- sd card not inserted
     */
    int     fso_get_configuration(fso_proto_init* conf);
    
    
    typedef void (*CALLBACK_TYPE)(int msg_cmd, const void* msg_context, int msg_len);
    typedef int (*SOCKET_INIT_FUNC)();
    /* used to init file system, called only once
     *
     * return:
     *     return 0 if success, otherwise return non-zero
     */
    int     fso_init(const char* appid, int dev, CALLBACK_TYPE notify_cb, SOCKET_INIT_FUNC sock_func); //26
    int     fso_active(const char* appid, CALLBACK_TYPE notify_cb, SOCKET_INIT_FUNC sock_func);
#ifdef WIN32
    /* used in WIN32 system, to set sock_func, and execute it to get socket.
     * if the socket is invalid(-1), msg thread are sleep to wait
     *      else, ready to recv msg.
     *
     * return always 0.
     */
    int fso_update_device(SOCKET_INIT_FUNC sock_func);
#endif
    
    
    /* used to release the filesystem
     * return:
     *      return 0 if success, otherwise return -1.
     */
    int     fso_destroy();//38
    
    /* used to release socket etc. system resource
     * return:
     *      return 0 if success, otherwise return -1.
     */
    int fso_shutdown();
    
    /*
     * use like system function
     *    int socket(int domain, int type, int protocol);
     */
    int fso_socket(int domain, int type, int protocol);
    /*
     * use like system function
     *    int connect(int socket, const struct sockaddr *address, socklen_t address_len);
     */
    int fso_connect(int socket, const struct sockaddr *address, socklen_t address_len);
    
    /* create a socket and connect to peer dport
     * @param dport, tcp peer port
     * return socket fd or -1
     */
    int fso_taig_socket(uint16_t dport);
#ifndef WIN32
    int fso_taig_ctrl_on();
#endif
    /*
     * use like system function
     *    ssize_t recv(int socket, void *buffer, size_t length, int flags);
     */
    ssize_t fso_recv(int socket, void *buffer, size_t length, int flags);
    /*
     * use like system function
     *    ssize_t send(int socket, const void *buffer, size_t length, int flags);
     */
    ssize_t fso_send(int socket, const void *buffer, size_t length, int flags);
    /*
     * use like system function
     *    int close(int fildes);
     */
    int fso_closesocket(int fd);
    
    /* used to get device info of iPhone, contains ProductID and SerialNumber
     * @param dev_info
     *           a pointer of struct dev_inf's pointer
     *
     * return:
     *      return 0 if success, otherwise return -1.
     */
    int fso_get_dev_info(dev_inf** dev_info);
    /* used to get usr_pref info of iPhone
     * @param type
     *           a value of usrpref_type, a enum type
     *        out_buffer
     *           a pointer, pointer to a char* string
     *
     * return:
     *      return 0 if success, otherwise return -1.
     */
    int fso_get_usr_pref_info(usrpref_type type, char** out_buffer);
    
    /* used to set password of pair
     * @param verify_pwd
     *           old password to verify if have limits
     *        new_pwd
     *           new password
     *
     * return:
     *      return 0 if success, otherwise return -1.
     */
    int fso_set_pair_password(char* verify_pwd, char* new_pwd);
    
    /* used to check whether kuke bind passcode
     *
     * return:
     *      return 0 if not bind, return 1 if bind, other value for internal error.
     */
    int fso_is_bind_passcode();
    
    /* used to check whether kuke locked
     *
     * return:
     *      return 0 if not locked, return 1 if locked, other value for internal error.
     */
    int fso_query_is_locked();
    
    /* used to set initial security question,answer and passcode
     * @param security_question
     *          at least 1 Bytes, at most 100 Bytes
     *        security_answer
     *          at least 1 Bytes, at most 100 Bytes
     *        passcode
     *          at least 4 Bytes, at most 10 Bytes
     *
     * return:
     *      return 0 if success, return -1 if false, other value for param error.
     */
    int fso_set_init_security_question_answer_and_passcode(char* security_question, char* security_answer, char* passcode);
    
    /* used to query security question
     * @param buffer
     *      buffer at least 100 Bytes for security question
     *      buffer_size ...
     *
     * return:
     *      return 0 if success, return -1 if false, other value for internal error.
     */
    int fso_query_security_question(char* buffer, unsigned int buffer_size);
    
    /* used to check whether match security answer
     * @param answer
     *          at least 1 Bytes, at most 100 Bytes
     *
     * return:
     *      return 1 if match, return 0 if not match, return -1 if param error.
     */
    int fso_is_match_security_answer(char* answer);
    
    /* used to check whether match passcode
     * @param passcode
     *          at least 4 Bytes, at most 10 Bytes
     *
     * return:
     *      return 1 if match, return 0 if not match, return -1 if param error.
     */
    int fso_is_match_passcode(char* passcode);
    
    /* used to modify passcode with security answer
     * @param answer
     *          at least 1 Bytes, at most 100 Bytes
     *        new_passcode
     *          at least 4 Bytes, at most 10 Bytes
     *
     * return:
     *      return 0 if success, return -1 if false, other value for param error.
     */
    int fso_modify_passcode_with_security_answer(char* answer, char* new_passcode);
    
    /* used to modify passcode with old passcode
     * @param old_passcode current passcode
     *          at least 4 Bytes, at most 10 Bytes
     *        new_passcode
     *          at least 4 Bytes, at most 10 Bytes
     *
     * return:
     *      return 0 if success, return -1 if false, other value for param error.
     */
    int fso_modify_passcode_with_old_passcode(char* old_passcode, char* new_passcode);
    
    /* used to clear security question,answer and current passcode with security answer
     * @param answer
     *          at least 1 Bytes, at most 100 Bytes
     *
     * return:
     *      return 0 if success, return -1 if false, other value for param error.
     */
    int fso_clear_security_question_answer_and_current_passcode_with_security_answer(char* answer);
    
    /* used to clear security question,answer and current passcode with current passcode
     * @param current_passcode
     *          at least 4 Bytes, at most 10 Bytes
     *
     * return:
     *      return 0 if success, return -1 if false, other value for param error.
     */
    int fso_clear_security_question_answer_and_current_passcode_with_current_passcode(char* current_passcode);
    

    /* used to get power info of tgk
     * @param ppow_info, a struct pointer to receive data returned
     *
     * return:
     *      return 0 if success, otherwise return -1.
     */
    int     fso_get_power_info(powr_inf* ppow_info);//48 getpowerinfo
    /*
     * set charging gear with @param value
     * @param ppwr_ctrl , pointer to a struct of setup parameters
     *
     * return:
     *      return 0 if success, otherwise return -1.
     */
    int     fso_set_charging_gear(powr_ctrl* ppwr_ctrl);//49 setcharging gear
    /*
     * set device type with @param dtype
     * @param pdev_ctrl , pointer to a struct of setup parameters
     *
     * return:
     *      return 0 if success, otherwise return -1.
     */
    int     fso_set_device_type(dev_ctrl* pdev_ctrl);//50 setdevicetype
    
    /* used to register callback to handle notification
     * @param p, is a function pointer with type void(*)(int)
     *          the param int means cmd , or called notification id
     *
     * return:
     *      return 0 if success, otherwise return -1.
     * note:
     *      there are 16 callbacks at most, register more will fail.
     */
    int     fso_register_notification_callback(CALLBACK_TYPE p);
    /*
     * used to unregister all callbacks of notifications
     */
    void    fso_remove_all_notification_callbacks();
    
    /* used to format file system, after format, u need call init before use
     * @param uuid
     *
     * return:
     *      return 0 if success, otherwise return -1.
     */
    int     fso_format(uuid_t uuid);//44
    
    /*
     * used to set wait socket time, if no need timeout give value -1.
     * @timeout units seconds.
     */
    void fso_set_timeout(int timeout);
#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif
