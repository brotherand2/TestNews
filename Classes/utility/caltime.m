//
//  caltime.m
//  qiyi
//
//  Created by luther.cui@gmail.com on 12-5-30.
//  Copyright (c) 2012年 崔道长. All rights reserved.
//

#import "caltime.h"
#import <dispatch/dispatch.h>
#import <pthread.h>

@interface a_timer : NSObject 
{
    NSString * start_time;
    NSString * stop_time;
}
@property (nonatomic, copy) NSString * start_time;
@property (nonatomic, copy) NSString * stop_time;

- (int)cal_dis;

@end


@implementation caltime
@synthesize timer_cap;

- (void)dealloc
{
    self.timer_cap = nil;
	[super dealloc];
}


- (id)init
{
	if ((self = [super init]))
	{
		self.timer_cap = [NSMutableDictionary dictionary];
	}
	return self;
}

NSString * convert_utf(NSString * str_utf8)
{
    NSString * _convert_str = nil;
    @try
    {
        _convert_str = [str_utf8 stringByReplacingOccurrencesOfString:@"\\U" withString:@"\\u"];
        _convert_str = [_convert_str stringByReplacingOccurrencesOfString:@"\\n" withString:@"\\u000A"];
        NSMutableString * _mutable_str = [NSMutableString stringWithFormat:@"%@",_convert_str];
        CFStringTransform((CFMutableStringRef)_mutable_str, NULL,  (CFStringRef)@"Any-Hex/Java", true);
        _convert_str = [_mutable_str stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    }
    @catch (NSException *exception)
    {
        _convert_str = nil;
    }
    @finally
    {
        return _convert_str;
    }
}

static dispatch_queue_t d_debug_queue = NULL;

pthread_mutex_t debug_mutex     = PTHREAD_MUTEX_INITIALIZER;

#define debug_lock                         pthread_mutex_lock(&debug_mutex)
#define debug_unlock                       pthread_mutex_unlock(&debug_mutex)

dispatch_queue_t debug_queue(void);

dispatch_queue_t debug_queue()
{
    if (d_debug_queue)
    {
        return d_debug_queue;
    }
    else
    {
        debug_lock;
        if (!d_debug_queue)
        {
            d_debug_queue = dispatch_queue_create("print_queue", NULL);
        }
        debug_unlock;
    }
    return d_debug_queue;
}


void write_file(NSString * path, NSString * contents)
{
#if DEBUG
    dispatch_async(debug_queue(), ^()
                   {
                       [path retain];
                       [contents retain];
                       NSString * humen_being = convert_utf(contents);
                       if (!humen_being)
                       {
                           [path release];
                           [contents release];
                           return;
                       }
                       printf("%s",[humen_being UTF8String]);
                       NSData *data  = [humen_being dataUsingEncoding:NSUTF8StringEncoding];
                       
                       if(![[NSFileManager defaultManager] fileExistsAtPath:path])
                       {
                           [[NSFileManager defaultManager] createFileAtPath:path
                                                                   contents:nil
                                                                 attributes:nil];
                       }
                       
                       NSFileHandle *file;
                       file = [NSFileHandle fileHandleForUpdatingAtPath:path];
                       [file seekToEndOfFile];
                       [file writeData:data];
                       [file closeFile];
                       [path release];
                       [contents release];
                   });
#endif
}

NSString* PathForCachesResource(NSString* relativePath) {
    static NSString* documentsPath = nil;
    if (!documentsPath) {
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(
                                                            NSCachesDirectory, NSUserDomainMask, YES);
        documentsPath = [[dirs objectAtIndex:0] copy];
    }
    return [documentsPath stringByAppendingPathComponent:relativePath];
}

- (NSString *)set_cal_time:(NSString *)key;
{
    NSString * str_start_time = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    if (!key)
    {
        key = str_start_time;
    }
    a_timer * obj_timer = [[a_timer alloc] init];
    [obj_timer setStart_time:str_start_time];
    [self.timer_cap setValue:obj_timer forKey:key];
    [obj_timer release];
    return key;
}

- (int)end_cal_time:(NSString *)key;
{
    a_timer * obj_tmp = [self.timer_cap objectForKey:key];
    if (obj_tmp)
    {
        [obj_tmp retain];
        [self.timer_cap removeObjectForKey:key];
        NSString * str_stop = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        [obj_tmp setStop_time:str_stop];
        int i_dis = [obj_tmp cal_dis];
        [obj_tmp release];
        return i_dis;
    }
    return -1;
}


@end



@implementation caltime (Singleton)


static caltime *sharedSingleton_ = nil;

- (void) operation
{
}

+ (caltime*) sharedInstance
{
	if (sharedSingleton_ == nil)
	{
		sharedSingleton_ = [NSAllocateObject([self class], 0, NULL) init];
	}
    
	return sharedSingleton_;
}


+ (id) allocWithZone:(NSZone *)zone
{
	return [[self sharedInstance] retain];
}


- (id) copyWithZone:(NSZone*)zone
{
	return self;
}

- (id) retain
{
	return self;
}

- (NSUInteger) retainCount
{
	return NSUIntegerMax; // denotes an object that cannot be released
}

- (void) release
{
	// <#do nothing#>
}

- (id) autorelease
{
	return self;
}

@end




@implementation a_timer
@synthesize start_time;
@synthesize stop_time;

- (void)dealloc
{
    self.start_time = nil;
    self.stop_time  = nil;
	[super dealloc];
}


- (id)init
{
	if ((self = [super init]))
	{
		self.start_time = nil;
        self.stop_time  = nil;
	}
	return self;
}

- (int)cal_dis;
{
    int i_d = 0;
    if (start_time && stop_time)
    {
        double i_s = [start_time doubleValue];
        double i_e = [stop_time doubleValue];
        i_d  = (int)((i_e - i_s) * 1000);
    }
    return i_d;
}

@end
