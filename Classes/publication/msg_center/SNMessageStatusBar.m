//
//  SNMsgerStatusBar.m
//  sohunews
//
//  Created by handy wang on 6/28/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNMessageStatusBar.h"
#import "UIColor+ColorUtils.h"
#import "SNDownloadManager.h"
#import "SNDownloadViewController.h"
#import "SNDownloadingExViewController.h"

#if kNeedDownloadRollingNews
#import "SNDownloadScheduler.h"
#endif

#define kInvocation                                          (@"kInvocation")
#define kExcuteDelay                                         (@"kExcuteDelay")
#define kDelayTimeInterval                                   3

@interface SNMessageStatusBar()

@property(nonatomic, assign)BOOL busy;

- (void)doPostNormalMessage:(NSString *)message;

- (void)doPostImmediateMessage:(NSString *)message;

- (void)doHideMessageDalay:(NSNumber *)seconds;

- (void)doHideMessageImmediately;

- (void)tapOnStatusBar:(UIGestureRecognizer *)gestureRecognizer;

- (void)showStatusBarWhenDownloaderDisappear;

- (void)postImmediateMsgAnimationDidStop;

- (void)reshowNormalMessageLabel;

- (void)reshowNormalMessageLabelAnimationDidStop;

- (void)excuteOnMainThread:(NSDictionary *)userInfo;

@end

@implementation SNMessageStatusBar
@synthesize busy;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        [SNNotificationManager addObserver:self
                                                 selector:@selector(updateStausBarStyle:)
                                                     name:kUpdateStatusBarStyleChangeNotification
                                                   object:nil];
        _canTap = NO;
        
		self.windowLevel = UIWindowLevelStatusBar + 1.0f;
		self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20);
        
        _messageQueue = [[NSMutableArray alloc] init];
        
        //Black bg view
		_backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        
        _backgroundView.backgroundColor = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? [UIColor whiteColor] : [UIColor blackColor];
        
		[self addSubview:_backgroundView];
        
        //TapGestureRecognizer
        UITapGestureRecognizer *_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnStatusBar:)];
        [self addGestureRecognizer:_tapGestureRecognizer];
        
        //Normal message label
		_normalMessageLabel = [[SNNormalMessageStatusBarLabel alloc] initWithFrame:CGRectMake(5, 
                                                                  0.0, 
                                                                  self.frame.size.width-5, 
                                                                  self.frame.size.height)];
		[self addSubview:_normalMessageLabel];
        
        //Immediate message label
		_immediateMessageLabel = [[SNImmediateMessageStatusBarLabel alloc] initWithFrame:CGRectMake(-self.frame.size.width+5, 
                                                                           0, 
                                                                           self.frame.size.width-5, 
                                                                           self.frame.size.height)];
		[self addSubview:_immediateMessageLabel];
        
        [SNNotificationManager addObserver:self selector:@selector(hide) name:kSNDownloaderAppearNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(showStatusBarWhenDownloaderDisappear) name:kSNDownloaderDisappearNotification object:nil];   
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
    _messageQueue = nil;
    
    _backgroundView = nil;
    
    _normalMessageLabel = nil;
    
    [SNNotificationManager removeObserver:self];
    
}

// for reset frame
- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    self.origin = CGPointZero;
}

#pragma mark - Public methods implementatioin

- (void)updateStausBarStyle:(NSNotification *)note
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        NSString *style = [note object][@"style"];
        if ([style isEqualToString:@"blackStyle"])
        {
            //黑底
            _backgroundView.backgroundColor = [UIColor blackColor];
            
        }
        else
        {
            //白底
            _backgroundView.backgroundColor = [UIColor whiteColor];
        }
        [_normalMessageLabel updateStausBarStyle:style];
        [_immediateMessageLabel updateStausBarStyle:style];
    }
}


- (void)postNormalMessage:(NSString *)message {
    SNDebugLog(SN_String("INFO: %@--%@, Posting normal message [%@] on status bar......"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), message);
    [self performSelectorOnMainThread:@selector(doPostNormalMessage:) withObject:message waitUntilDone:NO];
}

- (void)postImmediateMessage:(NSString *)message {
    SNDebugLog(SN_String("INFO: %@--%@, Posting immediate message [%@] on status bar, and cant' tap."), NSStringFromClass(self.class), NSStringFromSelector(_cmd), message);
    _canTap = NO;
    [self performSelectorOnMainThread:@selector(doPostImmediateMessage:) withObject:message waitUntilDone:NO];
}

- (void)postImmediateMessage:(NSString *)message canTap:(BOOL)canTap {
    SNDebugLog(SN_String("INFO: %@--%@, Posting immediate message [%@] on status bar and canTap is %d"), 
               NSStringFromClass(self.class), NSStringFromSelector(_cmd), message, canTap);
    _canTap = canTap;
    [self performSelectorOnMainThread:@selector(doPostImmediateMessage:) withObject:message waitUntilDone:NO];
}

- (void)hideMessageDalay:(NSTimeInterval)seconds {
    SNDebugLog(SN_String("INFO: %@--%@, Hide status bar delay %lf seconds."), NSStringFromClass(self.class), NSStringFromSelector(_cmd), seconds);
    [self performSelectorOnMainThread:@selector(doHideMessageDalay:) withObject:[NSNumber numberWithDouble:seconds] waitUntilDone:NO];
}

- (void)hideMessageImmediately {
    SNDebugLog(SN_String("INFO: %@--%@, Hide status bar immediately."), NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self performSelectorOnMainThread:@selector(doHideMessageImmediately) withObject:nil waitUntilDone:NO];
}

#pragma mark - Private methods implementation

- (void)doPostNormalMessage:(NSString *)message {
    _backgroundView.backgroundColor = SNUICOLOR(kSubCenterStatusBarBackgroundColor);
    [_normalMessageLabel updateTheme];
    
    self.hidden = NO;
    _normalMessageLabel.text = message;
}

- (void)doPostImmediateMessage:(NSString *)message {
    if (_immediateMessageLabel) {
        self.hidden = NO;
        _immediateMessageLabel.text = message;
        _immediateMessageLabel.hidden = NO;

        _backgroundView.backgroundColor = SNUICOLOR(kSubCenterStatusBarBackgroundColor);
        [_immediateMessageLabel updateTheme];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.1];
        CGRect _tmpNMLRect = _normalMessageLabel.frame;
        _tmpNMLRect.origin.x = self.frame.size.width+5;
        _normalMessageLabel.frame = _tmpNMLRect;
        
        CGRect _tmpIMLRect = _immediateMessageLabel.frame;
        _tmpIMLRect.origin.x = 5;
        _immediateMessageLabel.frame = _tmpIMLRect;
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(postImmediateMsgAnimationDidStop)];
        [UIView commitAnimations];
    }
}

- (void)doHideMessageDalay:(NSNumber *)secondsNumber {
    NSTimeInterval seconds = [secondsNumber doubleValue];
    
    if (seconds == 0) {
        [self hideMessageImmediately];
    } else {
        NSMutableDictionary *_userInfo = [[NSMutableDictionary alloc] init];
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(hideMessageImmediately)]];
        [invocation setTarget:self];
        [invocation setSelector:@selector(hideMessageImmediately)];
        [invocation retainArguments];
        
        [_userInfo setObject:invocation forKey:kInvocation];
        [_userInfo setObject:[NSNumber numberWithInt:seconds] forKey:kExcuteDelay];
        [self performSelectorOnMainThread:@selector(excuteOnMainThread:) withObject:_userInfo waitUntilDone:NO];
        _userInfo = nil;
    }
}

- (void)doHideMessageImmediately {
    self.hidden = YES;
    _normalMessageLabel.text = @"";
}

- (void)tapOnStatusBar:(UIGestureRecognizer *)gestureRecognizer {
    if (!_canTap) {
        SNDebugLog(SN_String("INFO: %@--%@, Dont response tap on status bar, because not showing normal message now."), NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        return;
    }
    
    SNDebugLog(SN_String("INFO: %@--%@, Tapping on status bar......"), NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    [SNNotificationManager postNotificationName:kStatusBarMessageDidTappedNotification object:nil];
    
    /*
    #if kNeedDownloadRollingNews
    if (![[SNDownloadScheduler sharedInstance] isDownloaderVisible]) {
        [SNNotificationManager postNotificationName:kNotificationWillOpenDownloader object:nil];
        
        NSMutableDictionary *_query = [[NSMutableDictionary alloc] init];
        //[_query setObject:[NSString stringWithFormat:@"%d", FKDownloadListViewDownloadingMode] forKey:kReferOfDownloader];
        
        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://globalDownloader"] applyAnimated:YES] applyQuery:_query];
        [[TTNavigator navigator] openURLAction:_urlAction];
         //(_query);
    }
    #else
    if (![[SNDownloadManager sharedInstance] isDownloaderVisible])
    {
        [SNNotificationManager postNotificationName:kNotificationWillOpenDownloader object:nil];
        
        NSMutableDictionary *_query = [[NSMutableDictionary alloc] init];
        [_query setObject:[NSString stringWithFormat:@"%d", FKDownloadListViewDownloadingMode] forKey:kReferOfDownloader];
        
        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://globalDownloader"] applyAnimated:YES] applyQuery:_query];
        [[TTNavigator navigator] openURLAction:_urlAction];
         //(_query);
    }
    #endif*/

    NSString* currentString = _normalMessageLabel.text;
    if(_immediateMessageLabel.text!=nil && [_immediateMessageLabel.text length]>0)
        currentString = _immediateMessageLabel.text;
    
    if (currentString!=nil && ([currentString hasPrefix:@"正在离线"] || [currentString hasPrefix:@"已添加内容到"]))
    {
        [SNNotificationManager postNotificationName:kNotificationWillOpenDownloader object:nil];
        
        SNDownloadingExViewController* contronller = [[SNDownloadingExViewController alloc] init];
        if(contronller!=nil && ![SNDownloadingExViewController isPresentingNow])
        {
            SNNavigationController* navigationController = [[SNNavigationController alloc] initWithRootViewController:contronller];
            //navigationController.navigationBar.hidden = YES;
            
            if ([[self getTopNavigation] respondsToSelector:@selector(presentViewController:animated:completion:)])
                [[self getTopNavigation] presentViewController:navigationController animated:YES completion:nil];
            else
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                SEL selector = @selector(presentModalViewController:animated:);
                [[self getTopNavigation] performSelector:selector withObject:navigationController withObject:[NSNumber numberWithBool:YES]];
#pragma clang diagnostic pop
            }
        }
    }
    else if (currentString!=nil && [currentString hasPrefix:@"离线下载完毕"])
    {
    }
}

- (void)showStatusBarWhenDownloaderDisappear {
    SNDebugLog(SN_String("INFO: %@--%@, Show status bar."), NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    if (![SNDownloadManager sharedInstance].isAllFinished) {
        self.hidden = NO;
    }
}

- (void)postImmediateMsgAnimationDidStop {
    CGRect _tmpNMLRect = _normalMessageLabel.frame;
    _tmpNMLRect.origin.x = -self.frame.size.width+5;
    _normalMessageLabel.frame = _tmpNMLRect;
    
    NSMutableDictionary *_userInfo = [[NSMutableDictionary alloc] init];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(reshowNormalMessageLabel)]];
    [invocation setTarget:self];
    [invocation setSelector:@selector(reshowNormalMessageLabel)];
    [invocation retainArguments];
    
    [_userInfo setObject:invocation forKey:kInvocation];
    [_userInfo setObject:[NSNumber numberWithInt:kDelayTimeInterval] forKey:kExcuteDelay];
    [self performSelectorOnMainThread:@selector(excuteOnMainThread:) withObject:_userInfo waitUntilDone:NO];
    _userInfo = nil;
}

- (void)reshowNormalMessageLabel {    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
    CGRect _tmpIMLRect = _immediateMessageLabel.frame;
    _tmpIMLRect.origin.x = self.frame.size.width+5;
    _immediateMessageLabel.frame = _tmpIMLRect;
    
    CGRect _tmpNMLRect = _normalMessageLabel.frame;
    _tmpNMLRect.origin.x = 5;
    _normalMessageLabel.frame = _tmpNMLRect;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(reshowNormalMessageLabelAnimationDidStop)];
    [UIView commitAnimations];
}

- (void)reshowNormalMessageLabelAnimationDidStop {
    _immediateMessageLabel.hidden = YES;
    _immediateMessageLabel.text = @"";
    
    CGRect _tmpIMLRect = _immediateMessageLabel.frame;
    _tmpIMLRect.origin.x = -self.frame.size.width+5;
    _immediateMessageLabel.frame = _tmpIMLRect;
    
    if (!_normalMessageLabel || (_normalMessageLabel.text == nil) || [@"" isEqualToString:_normalMessageLabel.text] || _normalMessageLabel.hidden) {
        self.hidden = YES;
        if (_normalMessageLabel) {
            _normalMessageLabel.text = @"";
        }
    }
    
    _canTap = NO;
}

- (void)excuteOnMainThread:(NSDictionary *)userInfo {
    NSInvocation *_invocation = [userInfo objectForKey:kInvocation];
    NSNumber *_delay = [userInfo objectForKey:kExcuteDelay];
    if (_invocation) {
        if (_delay) {
            [_invocation performSelector:@selector(invoke) withObject:nil afterDelay:[_delay intValue]];
        } else {
            [_invocation performSelector:@selector(invoke)];
        }
    }
}

- (SNNavigationController*)getTopNavigation {
    return [TTNavigator navigator].topViewController.flipboardNavigationController;
}

- (void)makeKeyWindow {
    sohunewsAppDelegate * appDelegate = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window makeKeyAndVisible];
}

@end
