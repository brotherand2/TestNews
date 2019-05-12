//
//  SNGuideMaskController.h
//  sohunews
//
//  Created by Cong Dan on 4/16/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNViewController.h"
@protocol SNGuideMaskControllerDelegate;

@interface SNGuideMaskController : SNViewController
{
    int maskIndex;
    id<SNGuideMaskControllerDelegate> _delegate;
}

@property(nonatomic)int maskIndex;

- (id)initWithIndex:(int)i;
- (id)initWithIndex:(int)i delegate:(id<SNGuideMaskControllerDelegate>)dele;
- (void)show:(BOOL)show animated:(BOOL)animated;
- (void)close;

@end

@protocol SNGuideMaskControllerDelegate <NSObject>

-(void)guideMaskDidFinish;

@end
