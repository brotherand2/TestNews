//
//  SNGuideMaskController.m
//  sohunews
//
//  Created by Cong Dan on 4/16/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNGuideMaskController.h"

#define kMaxMaskGuideCount 3

@implementation SNGuideMaskController

@synthesize maskIndex;

- (id)initWithIndex:(int)i delegate:(id<SNGuideMaskControllerDelegate>)dele
{
    self = [super init];
    if (self) {
        maskIndex = i;
        _delegate = dele;
    }
    
    return self;
}

- (id)initWithIndex:(int)i
{
    self = [super init];
    if (self) {
        maskIndex = i;
    }
    
    return self;
}

- (void)viewDidUnload {
    [SNNotificationManager removeObserver:self name:kNotifyDidReceive object:nil];
    [super viewDidUnload];
}

- (void)loadView {
	[super loadView];
    [SNNotificationManager addObserver:self selector:@selector(tapOnView) name:kNotifyDidReceive object:nil];
    
    NSString *name = [NSString stringWithFormat:@"guide_mask_%d.png", maskIndex];
	UIImage *img = [UIImage imageWithBundleName:name];
	UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    
	[imgView setFrame:CGRectMake(0, 
								 0, 
								 TTScreenBounds().size.width, 
								 TTScreenBounds().size.height - TTStatusHeight())];
	
	[self.view addSubview:imgView];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self 
																		  action:@selector(tapOnView)];
	[self.view addGestureRecognizer:tap];
        
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView)];
    [self.view addGestureRecognizer:pan];
}

- (void)show:(BOOL)show animated:(BOOL)animated {
	CGFloat alpha = show ? 1 : 0;
	if (alpha == self.view.alpha)
		return;
	
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationDidStopSelector:@selector(showAnimationDidEnd)];
		[UIView setAnimationDelegate:self];
	}
	
	self.view.alpha = alpha;
	
	if (animated) {
		[UIView commitAnimations];
	}
	
	if (!show) {
        
        NSString *key = nil;
        switch (maskIndex) {
//            case 1:
//                key = kProfileMaskGuideHomeOnFirstRun;
//                break;
//            case 2:
//                key = kProfileMaskGuidePaperOnFirstRun;
//                break;
//            case 3:
//                key = kProfileMaskGuideGroupPicOnFirstRun;
//                break; 
//            case 4:
//                key = kProfileMaskGuideHomeAddSubOnFirstRun;
//                break;
//            case 5:
//                key = kProfileMaskGuidePhotoRecommedOnFirstRun;
//                break;
//            case 6:
//                key = kProfileMaskGuideNewsContentOnFirstRun;
//                break;
            case 1:
                key = kGuideMaskSetNickNameOnFirstRun_1;
                break;
            case 2:
                key = kGuideMaskReplyCommentOnFirstRun_2;
                break;
            case 3:
                key = kGuideMaskOfflineManageAOnFirstRun_3;
                break;
            case 4:
                key = kGuideMaskOfflineManageBOnFirstRun_4;
                break;
                
            case 5:
                key = kGuideMaskSubCenterMyList;
                break;
                

            default:
                break;
        }
        
		[[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)tapOnView {
	[self show:NO animated:YES];
}


- (void)showAnimationDidEnd {
	[self.view removeFromSuperview];
    [_delegate guideMaskDidFinish];
}

- (void)close {
    [self.view removeFromSuperview];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}


@end
