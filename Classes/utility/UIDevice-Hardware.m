/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

// Thanks to Emanuele Vulcano, Kevin Ballard/Eridius, Ryandjohnson, Matt Brown, etc.

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

//---获取IP地址
#include <ifaddrs.h>
#include <arpa/inet.h>
//---

#import "UIDevice-Hardware.h"
#include <mach/machine.h>

#pragma mark - UIDevice Hardware =============
@implementation UIDevice (Hardware)
/*
 Platforms
 
 iFPGA ->        ??

 iPhone1,1 ->    iPhone 1G, M68
 iPhone1,2 ->    iPhone 3G, N82
 iPhone2,1 ->    iPhone 3GS, N88
 iPhone3,1 ->    iPhone 4/AT&T, N89
 iPhone3,2 ->    iPhone 4/Other Carrier?, ??
 iPhone3,3 ->    iPhone 4/Verizon, TBD
 iPhone4,1 ->    (iPhone 4S/GSM), TBD
 iPhone4,2 ->    (iPhone 4S/CDMA), TBD
 iPhone4,3 ->    (iPhone 4S/???)
 iPhone5,1 ->    iPhone Next Gen, TBD
 iPhone5,1 ->    iPhone Next Gen, TBD
 iPhone5,1 ->    iPhone Next Gen, TBD

 iPod1,1   ->    iPod touch 1G, N45
 iPod2,1   ->    iPod touch 2G, N72
 iPod2,2   ->    Unknown, ??
 iPod3,1   ->    iPod touch 3G, N18
 iPod4,1   ->    iPod touch 4G, N80
 
 // Thanks NSForge
 iPad1,1   ->    iPad 1G, WiFi and 3G, K48
 iPad2,1   ->    iPad 2G, WiFi, K93
 iPad2,2   ->    iPad 2G, GSM 3G, K94
 iPad2,3   ->    iPad 2G, CDMA 3G, K95
 iPad3,1   ->    (iPad 3G, WiFi)
 iPad3,2   ->    (iPad 3G, GSM)
 iPad3,3   ->    (iPad 3G, CDMA)
 iPad4,1   ->    (iPad 4G, WiFi)
 iPad4,2   ->    (iPad 4G, GSM)
 iPad4,3   ->    (iPad 4G, CDMA)

 AppleTV2,1 ->   AppleTV 2, K66
 AppleTV3,1 ->   AppleTV 3, ??

 i386, x86_64 -> iPhone Simulator
*/


#pragma mark sysctlbyname utils
- (NSString *) getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];

    free(answer);
    return results;
}

- (NSString *)platformForSohuNews
{
    return [self getSysInfoByName:"hw.machine"];
}

// Thanks, Tom Harrington (Atomicbird)
- (NSString *) hwmodel
{
    return [self getSysInfoByName:"hw.model"];
}

#pragma mark sysctl utils
- (NSUInteger) getSysInfo: (uint) typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

- (NSUInteger) cpuFrequency
{
    return [self getSysInfo:HW_CPU_FREQ];
}

- (NSUInteger) busFrequency
{
    return [self getSysInfo:HW_BUS_FREQ];
}

- (NSUInteger) cpuCount
{
    return [self getSysInfo:HW_NCPU];
}

- (NSString*)getCPUType
{
    NSMutableString *cpu = [NSMutableString string];
    size_t size;
    cpu_type_t type;
    cpu_subtype_t subtype;
    size = sizeof(type);
    sysctlbyname("hw.cputype", &type, &size, NULL, 0);
    
    size = sizeof(subtype);
    sysctlbyname("hw.cpusubtype", &subtype, &size, NULL, 0);
    
    // values for cputype and cpusubtype defined in mach/machine.h
    if (type == CPU_TYPE_X86)
    {
        [cpu appendString:@"x86 "];
        // check for subtype ...
        
    } else if (type == CPU_TYPE_ARM)
    {
        [cpu appendString:@"ARM"];
        [cpu appendFormat:@",Type:%d",subtype];
    }
    return cpu;
    
}

- (NSUInteger) totalMemory
{
    return [self getSysInfo:HW_PHYSMEM];
}

- (NSUInteger) userMemory
{
    return [self getSysInfo:HW_USERMEM];
}

- (NSUInteger) maxSocketBufferSize
{
    return [self getSysInfo:KIPC_MAXSOCKBUF];
}

#pragma mark file system -- Thanks Joachim Bean!

/*
 extern NSString *NSFileSystemSize;
 extern NSString *NSFileSystemFreeSize;
 extern NSString *NSFileSystemNodes;
 extern NSString *NSFileSystemFreeNodes;
 extern NSString *NSFileSystemNumber;
*/

- (NSNumber *) totalDiskSpace
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}

- (NSNumber *) freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

- (UIDevicePlatform)platformTypeForScreen
{
    NSInteger height = [UIScreen mainScreen].bounds.size.height;
    
    switch (height)
    {
        case 480:
        case 960:
            return UIDevice4SiPhone;
        case 568:
        case 1136:
            return UIDevice5SiPhone;
        case 667:
        case 1334:
            return UIDevice6iPhone;
        default:
            return UIDevice6PlusiPhone;
    }
}

#pragma mark platform type and name utils
- (UIDevicePlatform)platformTypeForSohuNews
{
    NSString *platform = [self platformForSohuNews];
    
    // The ever mysterious iFPGA
    if ([platform isEqualToString:@"iFPGA"])        return UIDeviceIFPGA;

    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return UIDevice1GiPhone;
    if ([platform isEqualToString:@"iPhone1,2"])    return UIDevice3GiPhone;
    if ([platform hasPrefix:@"iPhone2"])            return UIDevice3GSiPhone;
    if ([platform hasPrefix:@"iPhone3"])            return UIDevice4iPhone;
    if ([platform hasPrefix:@"iPhone4"])            return UIDevice4SiPhone;
    if ([platform isEqualToString:@"iPhone5,1"] ||
        [platform isEqualToString:@"iPhone5,2"])
        return UIDevice5iPhone;
    
    if ([platform isEqualToString:@"iPhone5,3"] ||
        [platform isEqualToString:@"iPhone5,4"])
        return UIDevice5CiPhone;
    
    if ([platform isEqualToString:@"iPhone6,1"] ||
        [platform isEqualToString:@"iPhone6,2"])
        return UIDevice5SiPhone;
    
    if ([platform isEqualToString:@"iPhone7,1"]) {
        return UIDevice6PlusiPhone;
    }
    if ([platform isEqualToString:@"iPhone7,2"]) {
        return UIDevice6iPhone;
    }
    if ([platform isEqualToString:@"iPhone8,1"]) {
        return UIDevice6iPhone;
    }
    if ([platform isEqualToString:@"iPhone8,2"]) {
        return UIDevice6PlusiPhone;
    }
    if ([platform isEqualToString:@"iPhone8,4"]) {
        return UIDeviceSEiPhone;
    }
    if ([platform isEqualToString:@"iPhone9,1"]) {
        return UIDevice7iPhone;
    }
    if ([platform isEqualToString:@"iPhone9,3"]) {
        return UIDevice7iPhone;
    }
    if ([platform isEqualToString:@"iPhone9,2"]) {
        return UIDevice7PlusiPhone;
    }
    if ([platform isEqualToString:@"iPhone9,4"]) {
        return UIDevice7PlusiPhone;
    }
    
    if ([platform isEqualToString:@"iPhone10,1"] || [platform isEqualToString:@"iPhone10,4"]){
        return UIDevice8iPhone;
    }

    if ([platform isEqualToString:@"iPhone10,2"] || [platform isEqualToString:@"iPhone10,5"]){
        return UIDevice8PlusiPhone;
    }
//
//    if ([deviceString isEqualToString:@"iPhone10,3"] || [deviceString isEqualToString:@"iPhone10,6"]){
//        return UIDeviceiPhoneX;
//    }
    
//    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"国行(A1863)、日行(A1906)iPhone 8";
//    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"美版(Global/A1905)iPhone 8";
//    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"国行(A1864)、日行(A1898)iPhone 8 Plus";
//    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"美版(Global/A1897)iPhone 8 Plus";
//    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"国行(A1865)、日行(A1902)iPhone X";
//    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"美版(Global/A1901)iPhone X";

    if (CGSizeEqualToSize([[UIScreen mainScreen] currentMode].size,CGSizeMake(1125, 2436)))
    {
        return UIDeviceiPhoneX;
    }
//    if ([platform isEqualToString:@"iPhone10,5"]) {
//        return UIDeviceiPhoneX;
//    }
    
    // iPod
    if ([platform hasPrefix:@"iPod1"])              return UIDevice1GiPod;
    if ([platform hasPrefix:@"iPod2"])              return UIDevice2GiPod;
    if ([platform hasPrefix:@"iPod3"])              return UIDevice3GiPod;
    if ([platform hasPrefix:@"iPod4"])              return UIDevice4GiPod;
    if ([platform hasPrefix:@"iPod5"])              return UIDevice5GiPod;

    // iPad
    if ([platform isEqualToString:@"iPad1,1"])      return UIDevice1GiPad; //@"iPad 1G";
    if ([platform isEqualToString:@"iPad2,1"])      return UIDevice2GiPad; //@"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return UIDevice2GiPad; //@"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return UIDevice2GiPad; //@"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return UIDevice2GiPad; //@"iPad 2 (Rev A)";
    if ([platform isEqualToString:@"iPad3,1"])      return UIDevice3GiPad; //@"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return UIDevice3GiPad; //@"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,3"])      return UIDevice3GiPad; //@"iPad 3 (Global)";
    if ([platform isEqualToString:@"iPad3,4"])      return UIDevice4GiPad; //@"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return UIDevice4GiPad; //@"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return UIDevice4GiPad; //@"iPad 4 (Global)";
    
    if ([platform isEqualToString:@"iPad4,1"])      return UIDevice5GiPad; //@"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return UIDevice5GiPad; //@"iPad Air (Cellular)";
    
    // iPad mini
    if ([platform isEqualToString:@"iPad2,5"])      return UIDevice1GiPadMini;
    if ([platform isEqualToString:@"iPad2,6"])      return UIDevice1GiPadMini;
    if ([platform isEqualToString:@"iPad2,7"])      return UIDevice1GiPadMini;
    if ([platform isEqualToString:@"iPad4,4"])      return UIDevice2GiPadMini;
    if ([platform isEqualToString:@"iPad4,5"])      return UIDevice2GiPadMini;
    
    // Apple TV
    if ([platform hasPrefix:@"AppleTV2"])           return UIDeviceAppleTV2;
    if ([platform hasPrefix:@"AppleTV3"])           return UIDeviceAppleTV3;

    if ([platform hasPrefix:@"iPhone"])             return UIDeviceUnknowniPhone;
    if ([platform hasPrefix:@"iPod"])               return UIDeviceUnknowniPod;
    if ([platform hasPrefix:@"iPad"])               return UIDeviceUnknowniPad;
    if ([platform hasPrefix:@"AppleTV"])            return UIDeviceUnknownAppleTV;
    
    // Simulator thanks Jordan Breeding
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? UIDeviceSimulatoriPhone : UIDeviceSimulatoriPad;
    }

    return UIDeviceUnknown;
}

- (NSString *)platformStringForSohuNews
{
    //因为plus和 splus区分改动地方过多，为保证最小影响，暂时这样处理splus，和iphone6s
    NSString *platform = [self platformForSohuNews];
    if ([platform isEqualToString:@"iPhone8,1"]) {
        return IPHONE_6S_NAMESTRING;
    }
    if ([platform isEqualToString:@"iPhone8,2"]) {
        return IPHONE_6SPLUS_NAMESTRING;
    }
    
    switch ([self platformTypeForSohuNews])
    {
        case UIDevice1GiPhone: return IPHONE_1G_NAMESTRING;
        case UIDevice3GiPhone: return IPHONE_3G_NAMESTRING;
        case UIDevice3GSiPhone: return IPHONE_3GS_NAMESTRING;
        case UIDevice4iPhone: return IPHONE_4_NAMESTRING;
        case UIDevice4SiPhone: return IPHONE_4S_NAMESTRING;
        case UIDevice5iPhone: return IPHONE_5_NAMESTRING;
        case UIDevice5CiPhone: return IPHONE_5C_NAMESTRING;
        case UIDevice5SiPhone: return IPHONE_5S_NAMESTRING;
        case UIDeviceSEiPhone: return IPHONE_SE_NAMESTRING;
        case UIDevice6PlusiPhone: return IPHONE_6PLUS_NAMESTRING;
        case UIDevice6iPhone: return IPHONE_6_NAMESTRING;
        case UIDevice7PlusiPhone: return IPHONE_7PLUS_NAMESTRING;
        case UIDevice7iPhone: return IPHONE_7_NAMESTRING;
        case UIDeviceUnknowniPhone: return IPHONE_UNKNOWN_NAMESTRING;
        
        case UIDevice1GiPod: return IPOD_1G_NAMESTRING;
        case UIDevice2GiPod: return IPOD_2G_NAMESTRING;
        case UIDevice3GiPod: return IPOD_3G_NAMESTRING;
        case UIDevice4GiPod: return IPOD_4G_NAMESTRING;
        case UIDevice5GiPod: return IPOD_5G_NAMESTRING;
        case UIDeviceUnknowniPod: return IPOD_UNKNOWN_NAMESTRING;
            
        case UIDevice1GiPad : return IPAD_1G_NAMESTRING;
        case UIDevice2GiPad : return IPAD_2G_NAMESTRING;
        case UIDevice3GiPad : return IPAD_3G_NAMESTRING;
        case UIDevice4GiPad : return IPAD_4G_NAMESTRING;
        case UIDevice5GiPad : return IPAD_5G_NAMESTRING;
            
        case UIDevice1GiPadMini: return IPAD_MINI_NAMESTRING;
        case UIDevice2GiPadMini: return IPAD_MINI2_NAMESTRING;
            
        case UIDeviceUnknowniPad : return IPAD_UNKNOWN_NAMESTRING;
            
        case UIDeviceAppleTV2 : return APPLETV_2G_NAMESTRING;
        case UIDeviceAppleTV3 : return APPLETV_3G_NAMESTRING;
        case UIDeviceAppleTV4 : return APPLETV_4G_NAMESTRING;
        case UIDeviceUnknownAppleTV: return APPLETV_UNKNOWN_NAMESTRING;
            
        case UIDeviceSimulator: return SIMULATOR_NAMESTRING;
        case UIDeviceSimulatoriPhone: return SIMULATOR_IPHONE_NAMESTRING;
        case UIDeviceSimulatoriPad: return SIMULATOR_IPAD_NAMESTRING;
        case UIDeviceSimulatorAppleTV: return SIMULATOR_APPLETV_NAMESTRING;
            
        case UIDeviceIFPGA: return IFPGA_NAMESTRING;
            
        default: return IOS_FAMILY_UNKNOWN_DEVICE;
    }
}

- (UIDeviceFamily) deviceFamily
{
    NSString *platform = [self platformForSohuNews];
    if ([platform hasPrefix:@"iPhone"]) return UIDeviceFamilyiPhone;
    if ([platform hasPrefix:@"iPod"]) return UIDeviceFamilyiPod;
    if ([platform hasPrefix:@"iPad"]) return UIDeviceFamilyiPad;
    if ([platform hasPrefix:@"AppleTV"]) return UIDeviceFamilyAppleTV;
    
    return UIDeviceFamilyUnknown;
}

#pragma mark MAC addy
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString *) macaddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Error: Memory allocation error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf); // Thanks, Remy "Psy" Demerest
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];

    free(buf);
    return outstring;
}

// Illicit Bluetooth check -- cannot be used in App Store
/* 
Class  btclass = NSClassFromString(@"GKBluetoothSupport");
if ([btclass respondsToSelector:@selector(bluetoothStatus)])
{
    printf("BTStatus %d\n", ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0);
    bluetooth = ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0;
    printf("Bluetooth %s enabled\n", bluetooth ? "is" : "isn't");
}
*/
@end

#pragma mark - UIDevice Helper =============
#import <AdSupport/ASIdentifierManager.h>

//获取系统内存
#include <sys/sysctl.h>
#include <mach/mach.h>
//获取系统存储空间
#include <sys/param.h>
#include <sys/mount.h>

// 获取mac地址得到唯一码
#include <sys/socket.h> // Per msqr
//#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#include <sys/stat.h>
#include <dirent.h>

@implementation UIDevice (Helper)
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
- (NSString *) macAddress{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

- (NSString *) uniqueDeviceIdentifier{
    NSString *macAddress = [[UIDevice currentDevice] macAddress];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@",macAddress,bundleIdentifier];
    NSString *uniqueIdentifier = [stringToHash stringFromMD5];
    
    return uniqueIdentifier;
}

- (NSString *) uniqueGlobalDeviceIdentifier{
    NSString *macAddress = [[UIDevice currentDevice] macAddress];
    NSString *uniqueIdentifier = [macAddress stringFromMD5];
    
    if ([uniqueIdentifier length] == 0) {
        // 在某些越狱机器上  拿不到mac地址  所以可以用client id作为区分设备的唯一id
        NSString *savedUid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
        if (savedUid.length) {
            savedUid = [NSString stringWithFormat:@"com.sohu.newspaper%@", savedUid];
            NSString *encodeUid = [[savedUid dataUsingEncoding:NSUTF8StringEncoding] base64String];
            uniqueIdentifier = [encodeUid stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
        }
    }
    
    if (!uniqueIdentifier) {
        uniqueIdentifier = @"";
    }
    
    return uniqueIdentifier;
}

+(double)getAvailableMemory{
	vm_statistics_data_t vmStats;
	mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
	kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
	
	if(kernReturn != KERN_SUCCESS) {
		return NSNotFound;
	}
	
	return ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
}

+(void)reportMemory {
    //暂不需要使用
    /*static NSUInteger last_resident_size=0;
    static NSUInteger greatest = 0;
    static NSUInteger last_greatest = 0;
    
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        int diff = (int)info.resident_size - (int)last_resident_size;
        NSUInteger latest = info.resident_size;
        if( latest > greatest   )   greatest = latest;  // track greatest mem usage
        NSUInteger greatest_diff = greatest - last_greatest;
        NSUInteger latest_greatest_diff = latest - greatest;
        SNDebugLog(@"Mem: %10lu (%10d) : %10ld :   greatest: %10ld (%ld)", info.resident_size, diff,
              latest_greatest_diff,
              greatest, greatest_diff  );
    } else {
        SNDebugLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
    last_resident_size = info.resident_size;
    last_greatest = greatest;*/
}

+(void)printDeviceMemInfo {
    int mem;
    int mib[2];
    mib[0] = CTL_HW;
    mib[1] = HW_PHYSMEM;
    size_t length = sizeof(mem);
    sysctl(mib, 2, &mem, &length, NULL, 0);
    SNDebugLog(@"Physical memory: %.2fMB", mem/1024.0f/1024.0f);
    
    mib[1] = HW_USERMEM;
    length = sizeof(mem);
    sysctl(mib, 2, &mem, &length, NULL, 0);
    SNDebugLog(@"User memory: %.2fMB", mem/1024.0f/1024.0f);
}

+(float)getFreeDiskSpace
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	struct statfs tStats;
	statfs([[paths lastObject] cString], &tStats);
	float freeSpace = (float)(tStats.f_bsize * tStats.f_bfree);
	
	return freeSpace/(1024.0 * 1024.0);
}

+(float)getTotalDiskSpace
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	struct statfs tStats;
	statfs([[paths lastObject] cString], &tStats);
	float totalSpace = (float)(tStats.f_blocks * tStats.f_bsize);
	
	return totalSpace/(1024.0 * 1024.0);
}

+(float)getFreeDiskSpaceBySDK
{
	float freeSpace = 0.0f;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
	
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemFreeSize];
        freeSpace = [fileSystemSizeInBytes floatValue]/(1024.0 * 1024.0);
    } else {
        SNDebugLog(@"getTotalDiskSpaceBySDK,Error Obtaining File System Info, Domain = %@, Code = %d", [error domain], [error code]);
    }
	
    return freeSpace;
}

+(float)getTotalDiskSpaceBySDK
{
	float totalSpace = 0.0f;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
	
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        totalSpace = [fileSystemSizeInBytes floatValue]/(1024.0 * 1024.0);
    } else {
        SNDebugLog(@"getTotalDiskSpaceBySDK,Error Obtaining File System Info, Domain = %@, Code = %d", [error domain], [error code]);
    }
	
    return totalSpace;
}

+(unsigned long long int)getFolderSize:(NSString*)folderPath
{
    return [self _folderSizeAtPath:[folderPath cStringUsingEncoding:NSUTF8StringEncoding]];
}

+ (long long) _folderSizeAtPath: (const char*)folderPath{
    long long folderSize = 0;
    DIR* dir = opendir(folderPath);
    if (dir == NULL) return 0;
    struct dirent* child;
    while ((child = readdir(dir))!=NULL) {
        if (child->d_type == DT_DIR && (
                                        (child->d_name[0] == '.' && child->d_name[1] == 0) || // 忽略目录 .
                                        (child->d_name[0] == '.' && child->d_name[1] == '.' && child->d_name[2] == 0) // 忽略目录 ..
                                        )) continue;
        
        NSInteger folderPathLength = strlen(folderPath);
        char childPath[1024]; // 子文件的路径地址
        stpcpy(childPath, folderPath);
        if (folderPath[folderPathLength-1] != '/'){
            childPath[folderPathLength] = '/';
            folderPathLength++;
        }
        stpcpy(childPath+folderPathLength, child->d_name);
        childPath[folderPathLength + child->d_namlen] = 0;
        if (child->d_type == DT_DIR){ // directory
            folderSize += [self _folderSizeAtPath:childPath]; // 递归调用子目录
            // 把目录本身所占的空间也加上
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }else if (child->d_type == DT_REG || child->d_type == DT_LNK){ // file or link
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
		}
	}
    closedir(dir);
    return folderSize;
}

+ (BOOL)isJailbroken {
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    return jailbroken;
}

- (void)reportRunningProcesses
{
    SNDebugLog(@"runningProcesses %@", [[UIDevice currentDevice] runningProcesses]);
}

//返回所有正在运行的进程的 id，name，占用cpu，运行时间
//使用函数int	sysctl(int *, u_int, void *, size_t *, void *, size_t)
- (NSArray *)runningProcesses
{
	//指定名字参数，按照顺序第一个元素指定本请求定向到内核的哪个子系统，第二个及其后元素依次细化指定该系统的某个部分。
	//CTL_KERN，KERN_PROC,KERN_PROC_ALL 正在运行的所有进程
	int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL ,0};
    
    
    u_int miblen = 4;

	//值-结果参数：函数被调用时，size指向的值指定该缓冲区的大小；函数返回时，该值给出内核存放在该缓冲区中的数据量
	//如果这个缓冲不够大，函数就返回ENOMEM错误
    size_t size;
	//返回0，成功；返回-1，失败
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    do
	{
		size += size / 10;
        newprocess = realloc(process, size);
        if (!newprocess)
		{
			if (process)
			{
                free(process);
				process = NULL;
            }
            return nil;
        }
        
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
    } while (st == -1 && errno == ENOMEM);
    
    if (st == 0)
	{
        if (size % sizeof(struct kinfo_proc) == 0)
		{
            NSInteger nprocess = size / sizeof(struct kinfo_proc);
            if (nprocess)
			{
                NSMutableArray * array = [NSMutableArray array];
                for (NSInteger i = nprocess - 1; i >= 0; i--)
				{
                    @autoreleasepool {
                        NSString * processID = [NSString stringWithFormat:@"%d", process[i].kp_proc.p_pid];
                        NSString * processName = [NSString stringWithFormat:@"%s", process[i].kp_proc.p_comm];
                        NSString * proc_CPU = [NSString stringWithFormat:@"%d", process[i].kp_proc.p_estcpu];
                        double t = [[NSDate date] timeIntervalSince1970] - process[i].kp_proc.p_un.__p_starttime.tv_sec;
                        NSString * proc_useTiem = [NSString stringWithFormat:@"%f",t];
                        
                        //SNDebugLog(@"process.kp_proc.p_stat = %c",process.kp_proc.p_stat);
                        
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        [dic setValue:processID forKey:@"ProcessID"];
                        [dic setValue:processName forKey:@"ProcessName"];
                        [dic setValue:proc_CPU forKey:@"ProcessCPU"];
                        [dic setValue:proc_useTiem forKey:@"ProcessUseTime"];
                        
                        [array addObject:dic];
                    }
                }
                
                free(process);
				process = NULL;
				//SNDebugLog(@"array = %@",array);
                
				return array;
            }
        }
    }
    
    if (process)
    {
        free(process);
        process = NULL;
    }

    return nil;
}

// 2013年5月1日，Apple禁用uniqueIdentifier，改用mac地址
// 后来iOS7里mac地址返回一个无效值，所以无法跟踪硬件了。
// 改用advertisingIdentifier，假如用户不让跟踪advertisingIdentifier，再改用identifierForVendor

+(NSString *)deviceUDID
{
    NSString *UDID = nil;
    
    if (NSClassFromString(@"ASIdentifierManager")) {
        if ([ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled) {
            UDID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        } else {
            /*
             IDFV:Vindor标示符，适用于对内：例如分析用户在应用内的行为等
             注意：如果用户将属于此Vender的所有App卸载，则idfv的值会被重置，即再重装此Vender的App，idfv的值和之前不同
             */
            UDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }
    } else {
        UDID = [[UIDevice currentDevice] macAddress];
    }
    
    if (UDID.length <= 0) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        UDID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        CFRelease(uuidRef);
    }
    
    return UDID;
}

/*
 IDFA:广告标示符，适用于对外：例如广告推广，换量等跨应用的用户追踪等,如果用户完全重置系统（(设置程序 -> 通用 -> 还原 -> 还原位置与隐私) ，这个广告标示符会重新生成。另外如果用户明确的还原广告(设置程序-> 通用 -> 关于本机 -> 广告 -> 还原广告标示符) ，那么广告标示符也会重新生成;若果用户在隐私->广告->限制广告跟踪，开关开启，则取不到IDFA
 注：iOS 10  弱开启限制广告标示符后，取到的为 00000000-0000-0000-0000-000000000000
 */
+(NSString *)deviceIDFA {
    NSString *IDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return IDFA;
   /* if (NSClassFromString(@"ASIdentifierManager")) {
        if ([ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled) {
            NSString *IDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
            return IDFA;
        }
    }
    return @"";*/
}

+ (BOOL)isRetina {
    static CGFloat scale = 0.0;
    if (scale == 0.0) {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] >= 2){
            scale = [[UIScreen mainScreen] scale];
            return YES;
        } else {
            scale = 1.0;
            return NO;
        }
    }
    return scale > 1.0;
}

// Get IP Address
+ (NSString *)ipAddress {
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    break;
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}
//get 端口号
+ (NSString *)portID {
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for (interface = interfaces; interface; interface = interface->ifa_next) {
            if (!(interface->ifa_flags & IFF_UP) || (interface->ifa_flags & IFF_LOOPBACK)) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            if (addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                char addrBuf[INET6_ADDRSTRLEN];
                if (inet_ntop(addr->sin_family, &addr->sin_addr, addrBuf, sizeof(addrBuf))) {// 把网络地址整数转为点分十进制
                    uint16_t port = ntohs((unsigned short)&addr->sin_port);//获取port
                    freeifaddrs(interfaces);
                    return [NSString stringWithFormat:@"%d", port];
                }
            }
        }
    }
    freeifaddrs(interfaces);
    return @"8080";
}

//注册屏幕分辨率
- (CGSize)screenSizeForSohuNews {
    UIDevicePlatform t = [self platformTypeForSohuNews];
    if (t==UIDevice1GiPhone || t==UIDevice3GiPhone || t==UIDevice3GSiPhone ||
        t==UIDevice1GiPod || t==UIDevice2GiPod || t==UIDevice3GiPod ||
        t==UIDevice1GiPadMini || t==UIDevice1GiPad || t==UIDevice2GiPad) {
        return CGSizeMake(320.0f, 480.0f);
    }
    else if (t==UIDevice4iPhone || t==UIDevice4SiPhone || t==UIDevice4GiPod ||
             t==UIDevice2GiPadMini || t==UIDevice3GiPad || t==UIDevice4GiPad || t==UIDevice5GiPad) {
        return CGSizeMake(640.0f, 960.0f);
    }
    else if (t==UIDevice5iPhone || t==UIDevice5CiPhone || t==UIDevice5SiPhone || t==UIDevice5GiPod) {
        return CGSizeMake(640.0f, 1136.0f);
    }
    else if (t==UIDevice6iPhone) {
        return CGSizeMake(750.0f, 1334.0f);
    }
    else if (t==UIDevice6PlusiPhone) {
//        return CGSizeMake(1080.0f, 1920.0f);
        return CGSizeMake(1242.0f, 2208.0f);
    }
    else if (t==UIDevice7iPhone) {
        return CGSizeMake(750.0f, 1334.0f);
    }
    else if (t==UIDevice7PlusiPhone) {
        //        return CGSizeMake(1080.0f, 1920.0f);
        return CGSizeMake(1242.0f, 2208.0f);
    }
    else if (t==UIDevice8iPhone) {
        return CGSizeMake(750.0f, 1334.0f);
    }
    else if (t==UIDevice8PlusiPhone) {
        return CGSizeMake(1242.0f, 2208.0f);
    }
    else {
        return CGSizeMake(640.0f, 1136.0f);//默认按iPhone5S的分辨率
    }
}

- (NSString *)screenSizeStringForSohuNews {
    CGSize screenCGSize = [[UIDevice currentDevice] screenSizeForSohuNews];
    return [NSString stringWithFormat:@"%gx%g", screenCGSize.width, screenCGSize.height];
}

- (CGFloat)getPhysicalPixels {
    UIDevicePlatform platFrorm = [self platformTypeForSohuNews];
    if (platFrorm == UIDevice3GiPhone) {
        return 163.0;
    }
    else if (platFrorm == UIDevice4iPhone || platFrorm == UIDevice4SiPhone || platFrorm == UIDevice4GiPod) {
        return 330.0;
    }
    else if (platFrorm == UIDevice5GiPod || platFrorm == UIDevice5iPhone || platFrorm == UIDevice5CiPhone || platFrorm == UIDevice5SiPhone || platFrorm == UIDevice6iPhone || platFrorm == UIDevice7iPhone || platFrorm == UIDevice8iPhone) {
        return 326.0;
    }
    else if (platFrorm == UIDevice6PlusiPhone || platFrorm == UIDevice7PlusiPhone || platFrorm == UIDevice8PlusiPhone) {
        return 401.0;
    }
    else if (platFrorm == UIDeviceiPhoneX) {
        return 458.0;
    }
    else {
        return 326.0;
    }
}

@end
