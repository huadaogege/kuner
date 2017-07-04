#ifndef __KAC_H__
#define __KAC_H__

#define USB_SINGLEX 0

#define FS_NOTIFY_BASE 10000

#define FS_NOTIFY_FINE     0    // every thing is fine, payload is version number.
#define FS_NOTIFY_PWR_LOW  1    // KUKE has entered into the low power state, please stop the file system to protect data
#define FS_NOTIFY_HOT      2    // The temperature is too high, please do necessary protect
#define FS_NOTIFY_PWR_INF  3    // notifies fs current power info
#define FS_NOTIFY_USB_OFF  10   // lightning port is pulled out
#define FS_NOTIFY_ADP_INST  11   // power adaptor plugged in
#define FS_NOTIFY_PC        12           // pc connected  （这个在电量信息里会被跟新，但不会在通知里面出现）
#define FS_NOTIFY_TRANPARENT_INST 110    // iPhone(透传mode) the same as before pc
#define FS_NOTIFY_U_DISK          111    // MSWindows(U盘mode)
#define FS_NOTIFY_SLEEP    100  // KUKE is entering into sleep stat
#define FS_NOTIFY_FW_OK    200  // the firmware is changed and working fine, payload is version number.
#define FS_NOTIFY_FW_ERR   201  // the firmware can't be changed, data invalid.
#define FS_NOTIFY_POWERDOWN 202 // the firmware request power down
#define FS_NOTIFY_SD_INSERT 210 // the sd card insert
#define FS_NOTIFY_SD_REMOVE 211 // the sd card remove
#define FS_NOTIFY_WAKEUP   FS_NOTIFY_FINE  //

#define FS_NOTIFY_DEVCON_KB   9991
#define FS_NOTIFY_POWERDOWN_REQUEST  9995  // KUKE notify power down then fs need send dev_ctrl shutdown bit to KuKe to shutdown KuKe
#define FS_NOTIFY_PAIR   9996 // need to re-pair KUKE and device
#define FS_NOTIFY_DEBUG  9997 // debug msg
#define FS_NOTIFY_DEVCON 9998 // device connected
#define FS_NOTIFY_DEVOFF 9999 // device disconnected

enum emmc_group {
	EGRP_FS_DAT  = 0, // file system data
	EGRP_FS_SWAP = 1, // file system swap area, fixed 8M bytes space
	EGRP_USR_DAT = 2, // user private data
	EGRP_APPLE   = 3, // app for apple
	EGRP_PC      = 4, // app for pc
	EGRP_FIRMW   = 5, // firmware
    EGRP_ABSOLUTE = 6, // absolute address
	_EGRP_COUNT_
};

#pragma pack(push, 1)

typedef union {
	uint32_t value;
	struct {
		uint32_t major: 8;
		uint32_t minor: 8;
		uint32_t inner: 16;
	};
} fwver_t;

typedef enum {
    DEV_TYPE_KUKE = 0,
    DEV_TYPE_KUBAO,
    DEV_TYPE_CNT,
} device_type;

#define SN_STR_LEN 32

typedef struct {
	fwver_t fwver;                   // the firmware version
	uint32_t serial;
	uint64_t fs_free;                // file system free space in bytes
	uint64_t egrp_len[_EGRP_COUNT_]; // total length of each emmc group
	char sn[SN_STR_LEN];
    union {
        uint32_t hard_info;
        struct {
            uint16_t hard_version;
            uint8_t device_type;      //DEV_TYPE_KUBAO or DEV_TYPE_KUKE
            uint8_t sd_card_state;
        };
    };
//    int8_t has_passcode; // 0 : no, 1 : yes;
} emmc_inf;

typedef struct {
	uint16_t pid;       // ProductID
	uint8_t serial[46]; // SerialNumber
} dev_inf;

typedef enum {
	USERPREF_DEVICE_CERTIFICATE = 0x1,   // "DeviceCertificate"
	USERPREF_ESCROW_BAG         = 0x2,   // "EscrowBag"
	USERPREF_HOST_CERTIFICATE   = 0x4,   // "HostCertificate"
	USERPREF_ROOT_CERTIFICATE   = 0x8,   // "RootCertificate" **
	USERPREF_HOST_PRIVATE_KEY   = 0x10,  // "HostPrivateKey"
	USERPREF_ROOT_PRIVATE_KEY   = 0x20,  // "RootPrivateKey" **
	USERPREF_HOST_ID            = 0x40,  // "HostID" **
	USERPREF_SYSTEM_BUID        = 0x80,  // "SystemBUID" **
	USERPREF_WIFI_MAC_ADDRESS   = 0x100, // "WiFiMACAddress"
} usrpref_type;

#define usrpref_str_dat
typedef struct {
	uint16_t type;  // usrpref_type
	uint16_t len;
	usrpref_str_dat // char[len]
} usrpref_str;

typedef union {
	uint32_t set_powr;
	struct {
		uint8_t mask;            // 0x1: gear-mask 0x2: limit-mask
		uint8_t charging_gear;   // 0-power_down 1-min 2-max
		uint16_t charging_limit; // [0, 100]
	};
} powr_ctrl;

typedef union {
	uint32_t set_dev;
	struct {
		uint32_t class_transparent: 1;
		uint32_t class_mass_storage: 1;
		uint32_t mod_debug: 1;
		uint32_t reboot: 1;
		uint32_t sleep: 1;
        uint32_t erase: 1;             // 清理所谓的安全校验区，安全校验区就是保存安全码MD5值、安全问题、安全问题答案MD5值等等信息的emmc区域。
        uint32_t shutdown: 1;
        uint32_t charging_default: 1;            // 应用启动时缺省充电策略
        uint32_t charging_storage_preferred: 1;  // 应用启动时扩容优先充电策略
        uint32_t _: 7;
		uint32_t debug_info: 16;
	};
} dev_ctrl;

typedef enum {
    PASSCODE_SET_ALL = 0x1,                               // 设置安全问题、安全问题答案和安全码
    PASSCODE_VERIFY_PASSCODE = 0x2,                       // 验证安全码
    PASSCODE_VERIFY_ANSWER = 0x4,                         // 验证安全问题的答案
    PASSCODE_QUERY_PASSCODE_QUESTION = 0x8,               // 查询安全问题
    PASSCODE_MODIFY_PASSCODE_WITH_ANSWER = 0x10,          // 传入问题答案来修改安全码
    PASSCODE_MODIFY_PASSCODE_WITH_OLD_PASSCODE = 0x20,    // 传入老安全码来修改安全码
    PASSCODE_CLEAR_PASSCODE_WITH_ANSWER = 0x40,           // 传入问题答案来清除安全码
    PASSCODE_CLEAR_PASSCODE_WITH_CURRENT_PASSCODE = 0x80, // 传入当前安全码来清除安全码
} passcode_cmd;

typedef struct {
    uint32_t cmd;                    // cmd is passcode_cmd type
    uint8_t old_passcode_md5[16];    // 老安全码的md5值
    uint8_t new_passcode_md5[16];    // 新安全码的md5值,
                                     //     use this field only when cmd == PASSCODE_SET_ALL || cmd == PASSCODE_MODIFY_PASSCODE_WITH_ANSWER ||
                                     //     cmd == PASSCODE_MODIFY_PASSCODE_WITH_OLD_PASSCODE
    uint8_t passcode_answer_md5[16]; // 安全问题答案的md5值
    uint8_t passcode_question[100];  // 安全问题，最大为25个汉字。
} passcode_msg;

typedef struct {
	uint16_t Temperature;
	union {
		uint16_t Flags;
		struct {
			uint16_t dsg: 1;       // 0
			uint16_t socf: 1;      // 1
			uint16_t soc1: 1;      // 2
			uint16_t bat_det: 1;   // 3
			uint16_t cfgupmode: 1; // 4
			uint16_t itpor: 1;     // 5
			uint16_t _6: 1;        // 6
			uint16_t ocvtaken: 1;  // 7
			uint16_t chg: 1;       // 8
			uint16_t fc: 1;        // 9
			uint16_t _13_10: 4;    // 10-13
			uint16_t ut: 1;        // 14
			uint16_t op: 1;        // 15
		};
	};
	uint16_t AverageCurrent;
	uint16_t FullChargeCapacity;
	uint16_t StateOfCharge;
	union {
		uint16_t _soh;
		struct {
			uint16_t StateOfHealth: 8;
			uint16_t StateOfSOH: 8;
		};
	};
	uint16_t charging_gear;
	uint16_t charging_limit;
    uint16_t usb1_line_stat;    // 0-unknown, 10-suspended, 11-adaptor, 12-pc
	uint16_t usb1_kuke_stat;    // 0-unknown, 110-iPhone(透传mode) 111-MSWindows(U盘mode)
	uint16_t voltage;           // battery voltage
} powr_inf;

#pragma pack(pop)

#endif
