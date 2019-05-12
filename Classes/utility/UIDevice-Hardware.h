/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define IFPGA_NAMESTRING                @"iFPGA"

#define IPHONE_1G_NAMESTRING            @"iPhone 1G"
#define IPHONE_3G_NAMESTRING            @"iPhone 3G"
#define IPHONE_3GS_NAMESTRING           @"iPhone 3GS" 
#define IPHONE_4_NAMESTRING             @"iPhone 4" 
#define IPHONE_4S_NAMESTRING            @"iPhone 4S"
#define IPHONE_5_NAMESTRING             @"iPhone 5"
#define IPHONE_5C_NAMESTRING            @"iPhone 5c"
#define IPHONE_5S_NAMESTRING            @"iPhone 5s"
#define IPHONE_SE_NAMESTRING            @"iPhone SE"
#define IPHONE_6PLUS_NAMESTRING         @"iPhone 6plus"
#define IPHONE_6_NAMESTRING             @"iPhone 6"
#define IPHONE_6SPLUS_NAMESTRING         @"iPhone 6Splus"
#define IPHONE_6S_NAMESTRING             @"iPhone 6S"
#define IPHONE_7PLUS_NAMESTRING         @"iPhone 7plus"
#define IPHONE_7_NAMESTRING             @"iPhone 7"
#define IPHONE_UNKNOWN_NAMESTRING       @"Unknown iPhone"

#define IPOD_1G_NAMESTRING              @"iPod touch 1G"
#define IPOD_2G_NAMESTRING              @"iPod touch 2G"
#define IPOD_3G_NAMESTRING              @"iPod touch 3G"
#define IPOD_4G_NAMESTRING              @"iPod touch 4G"
#define IPOD_5G_NAMESTRING              @"iPod touch 5G"
#define IPOD_UNKNOWN_NAMESTRING         @"Unknown iPod"

#define IPAD_1G_NAMESTRING              @"iPad 1G"
#define IPAD_2G_NAMESTRING              @"iPad 2G"
#define IPAD_3G_NAMESTRING              @"iPad 3G"
#define IPAD_4G_NAMESTRING              @"iPad 4G"
#define IPAD_5G_NAMESTRING              @"iPad Air 5G"
#define IPAD_UNKNOWN_NAMESTRING         @"Unknown iPad"

#define IPAD_MINI_NAMESTRING            @"iPad mini"
#define IPAD_MINI2_NAMESTRING           @"iPad mini 2"

#define APPLETV_2G_NAMESTRING           @"Apple TV 2G"
#define APPLETV_3G_NAMESTRING           @"Apple TV 3G"
#define APPLETV_4G_NAMESTRING           @"Apple TV 4G"
#define APPLETV_UNKNOWN_NAMESTRING      @"Unknown Apple TV"

#define IOS_FAMILY_UNKNOWN_DEVICE       @"Unknown iOS device"

#define SIMULATOR_NAMESTRING            @"iPhone Simulator"
#define SIMULATOR_IPHONE_NAMESTRING     @"iPhone Simulator"
#define SIMULATOR_IPAD_NAMESTRING       @"iPad Simulator"
#define SIMULATOR_APPLETV_NAMESTRING    @"Apple TV Simulator" // :)

typedef enum {
    UIDeviceUnknown,
    
    UIDeviceSimulator,
    UIDeviceSimulatoriPhone,
    UIDeviceSimulatoriPad,
    UIDeviceSimulatorAppleTV,
    
    UIDevice1GiPhone,
    UIDevice3GiPhone,
    UIDevice3GSiPhone,
    UIDevice4iPhone,
    UIDevice4SiPhone,
    UIDevice5iPhone,
    UIDevice5CiPhone,
    UIDevice5SiPhone,
    
    UIDevice1GiPod,
    UIDevice2GiPod,
    UIDevice3GiPod,
    UIDevice4GiPod,
    UIDevice5GiPod,
    
    UIDevice1GiPad,
    UIDevice2GiPad,
    UIDevice3GiPad,
    UIDevice4GiPad,
    UIDevice5GiPad,
    
    UIDevice1GiPadMini,
    UIDevice2GiPadMini,
    
    UIDeviceAppleTV2,
    UIDeviceAppleTV3,
    UIDeviceAppleTV4,
    
    UIDeviceUnknowniPhone,
    UIDeviceUnknowniPod,
    UIDeviceUnknowniPad,
    UIDeviceUnknownAppleTV,
    UIDeviceIFPGA,
    
    UIDevice6PlusiPhone,
    UIDevice6iPhone,
    
    UIDeviceSEiPhone,
    
    UIDevice7PlusiPhone,
    UIDevice7iPhone,
    
    UIDevice8PlusiPhone,
    UIDevice8iPhone,
    
    UIDeviceiPhoneX,
    
} UIDevicePlatform;

typedef enum {
    UIDeviceFamilyiPhone,
    UIDeviceFamilyiPod,
    UIDeviceFamilyiPad,
    UIDeviceFamilyAppleTV,
    UIDeviceFamilyUnknown
} UIDeviceFamily;

@interface UIDevice (Hardware)
- (NSString *)platformForSohuNews;
- (NSString *)hwmodel;
- (UIDevicePlatform)platformTypeForSohuNews;
- (UIDevicePlatform)platformTypeForScreen;
- (NSString *)platformStringForSohuNews;

- (NSUInteger) cpuFrequency;
- (NSUInteger) busFrequency;
- (NSUInteger) cpuCount;
- (NSUInteger) totalMemory;
- (NSUInteger) userMemory;
- (NSString*)getCPUType;

- (NSNumber *) totalDiskSpace;
- (NSNumber *) freeDiskSpace;

- (NSString *) macaddress;

- (UIDeviceFamily) deviceFamily;
@end

@interface UIDevice (Helper)

/*
 * @method uniqueDeviceIdentifier
 * @description use this method when you need a unique identifier in one app.
 * It generates a hash from the MAC-address in combination with the bundle identifier
 * of your app.
 */
- (NSString *) uniqueDeviceIdentifier;

/*
 * @method uniqueGlobalDeviceIdentifier
 * @description use this method when you need a unique global identifier to track a device
 * with multiple apps. as example a advertising network will use this method to track the device
 * from different apps.
 * It generates a hash from the MAC-address only.
 */
- (NSString *) uniqueGlobalDeviceIdentifier;

/*
 * Available device memory in MB
 */
+(double)getAvailableMemory;
+(void)reportMemory;
+(void)printDeviceMemInfo;

/*
 Disk Space in MB
 */
//C方法
+(float)getFreeDiskSpace;
+(float)getTotalDiskSpace;
//sdk方法
+(float)getFreeDiskSpaceBySDK;
+(float)getTotalDiskSpaceBySDK;

+(unsigned long long int)getFolderSize:(NSString*)folderPath;

+(BOOL)isJailbroken;

- (NSString *) macAddress;

+(NSString *)deviceUDID;
+(NSString *)deviceIDFA;

//获取ios进程的程序
- (void)reportRunningProcesses;
- (NSArray *)runningProcesses;

+ (BOOL)isRetina;

+ (NSString *)ipAddress;
+ (NSString *)portID;

- (CGSize)screenSizeForSohuNews;
- (NSString *)screenSizeStringForSohuNews;

//获取像素密度
- (CGFloat)getPhysicalPixels;

@end
