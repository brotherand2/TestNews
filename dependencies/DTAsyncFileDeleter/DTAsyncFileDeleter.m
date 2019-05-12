//
//  DTAsyncFileDeleter.m
//  DTFoundation
//
//  Created by Oliver Drobnik on 2/10/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "DTAsyncFileDeleter.h"

static dispatch_queue_t _delQueue;
static dispatch_group_t _delGroup;
static dispatch_once_t onceToken;

//static dispatch_queue_t _renameQueue;

static DTAsyncFileDeleter *_sharedInstance;


// private utilites
@interface DTAsyncFileDeleter ()
- (BOOL)_supportsTaskCompletion;
@end


@implementation DTAsyncFileDeleter

+ (DTAsyncFileDeleter *)sharedInstance
{
	static dispatch_once_t instanceOnceToken;
	dispatch_once(&instanceOnceToken, ^{
		_sharedInstance = [[DTAsyncFileDeleter alloc] init];
	});
	
	return _sharedInstance;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		dispatch_once(&onceToken, ^{
			_delQueue = dispatch_queue_create("DTAsyncFileDeleterRemoveQueue", 0);
			_delGroup = dispatch_group_create();
			//_renameQueue = dispatch_queue_create("DTAsyncFileDeleterRenameQueue", 0);
		});
	}
	
	return self;
}

- (void)waitUntilFinished
{
	dispatch_group_wait(_delGroup, DISPATCH_TIME_FOREVER);
}

- (void)removeItemAtPath:(NSString *)path didFinishTarget:(id)callbackTarget selector:(SEL)callbackSelector {
    // schedule the removal and immediately return
    dispatch_group_async(_delGroup, _delQueue, ^{
        //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
//        __block UIBackgroundTaskIdentifier backgroundTaskID = UIBackgroundTaskInvalid;
        
        // block to use for timeout as well as completed task
//        void (^completionBlock)() = ^{
//            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskID];
//            backgroundTaskID = UIBackgroundTaskInvalid;
//            SNDebugLog(@"### completionBlock remove %@: cost %f", path, -[_beginAt1 timeIntervalSinceNow]);
//            
//        };
//        
//        if ([self _supportsTaskCompletion])
//        {
//            // according to docs this is safe to be called from background threads
//            backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:completionBlock];
//        }
        
        SNDebugLog(@"######INFO: cleaning cache transhcan...");
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        [fileManager removeItemAtPath:path error:NULL];
        [fileManager release];
        
        // ... when the task completes:
//        if (backgroundTaskID != UIBackgroundTaskInvalid)
//        {
//            completionBlock();
//        }        
        //[[_stopWatch stop] print:@"===Finish cleaning all cached image(in cache trashcan)==="];
        
        //Callback
        if ([callbackTarget respondsToSelector:callbackSelector]) {
            [callbackTarget performSelector:callbackSelector];
        }
    });
}

- (void)removeItemAtPath:(NSString *)path
{
	// make a unique temporary name in tmp folder
	//NSString *tmpPath = [NSString pathForTemporaryFile];
	
    // schedule the removal and immediately return	
    dispatch_group_async(_delGroup, _delQueue, ^{
        //__block NSDate *_beginAt1 = (NSDate *)[NSDate date];
        __block UIBackgroundTaskIdentifier backgroundTaskID = UIBackgroundTaskInvalid;
        
        // block to use for timeout as well as completed task
        void (^completionBlock)() = ^{
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskID];
            backgroundTaskID = UIBackgroundTaskInvalid;
            //SNDebugLog(@"### completionBlock remove %@: cost %f", path, -[_beginAt1 timeIntervalSinceNow]);

        };
        
        if ([self _supportsTaskCompletion])
        {
            // according to docs this is safe to be called from background threads
            backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:completionBlock];
        }
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        [fileManager removeItemAtPath:path error:NULL];
        [fileManager release];
        
        // ... when the task completes:
        if (backgroundTaskID != UIBackgroundTaskInvalid)
        {
            completionBlock();		
        }
                
//        SNDebugLog(@"### remove %@: cost %f", path, -[_beginAt1 timeIntervalSinceNow]);
    });
}

- (void)removeItemAtURL:(NSURL *)URL
{
	NSAssert([URL isFileURL], @"Parameter URL must be a file URL");
	
	[self removeItemAtPath:[URL path]];
}

#pragma mark Utilities
- (BOOL)_supportsTaskCompletion
{
	UIDevice *device = [UIDevice currentDevice];
	
	if ([device respondsToSelector:@selector(isMultitaskingSupported)])
	{
		if (device.multitaskingSupported)
		{
			return YES;
		}
		else
		{
			return NO;
		}
	}
	
	return NO;
}

@end
