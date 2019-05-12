//
//  SohuARAlertView.h
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ARAlertViewItemType){
    ARAlertViewItemTypeBackGround,
    ARAlertViewItemTypeImageView,
    ARAlertViewItemTypeButton,
    ARAlertViewItemTypeAgain,
    ARAlertViewItemTypeStart,
    ARAlertViewItemTypeGoHTML,
};

@class SohuARAlertView;

@protocol SohuARAlertViewDelegate <NSObject>

-(void)sohuARAlertView:(SohuARAlertView *)sohuARAlertView didClickItemType:(ARAlertViewItemType)arARAlertViewItemType parameter:(NSDictionary *)parameter;

@end

@interface SohuARAlertView : UIView

@property(nonatomic,strong) UIImage *alertImage;
@property(nonatomic,strong) UIImageView *alertImageView;
@property(nonatomic,weak) id<SohuARAlertViewDelegate> delegate;

-(void)showAlertView;
-(void)showAlertViewWithSize:(CGSize)size;
-(BOOL)hideHUDForWindow;

@end
