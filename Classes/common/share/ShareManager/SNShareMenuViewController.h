//
//  SNShareMenuViewController.h
//  sohunews
//
//  Created by wang shun on 2017/1/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNShareCollectionViewCell.h"
#import "SNShareCollectionViewLayout.h"

@protocol SNShareMenuControllerDelegate;
@interface SNShareMenuViewController : UIViewController

@property (nonatomic,weak) id <SNShareMenuControllerDelegate> delegate;
@property (nonatomic,assign) BOOL didDisAppearShareView;

- (instancetype)initWithData:(NSDictionary*)dic;

- (void)showActionMenu;
- (void)showActionMenuFromView:(UIView *)fromView;

@end

@protocol SNShareMenuControllerDelegate <NSObject>

- (void)shareIconSelected:(NSString*)title ShareData:(NSDictionary*)dic;

@end
