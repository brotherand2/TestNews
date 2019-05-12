//
//  SNPopOverMenu.h
//  sohunews
//
//  Created by 李腾 on 2016/11/5.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  SNPopOverMenuDoneBlock
 *
 *  @param index SlectedIndex
 */
typedef void (^SNPopOverMenuDoneBlock)(NSInteger selectedIndex);
/**
 *  SNPopOverMenuDismissBlock
 */
typedef void (^SNPopOverMenuDismissBlock)();

/**
 *  -----------------------SNPopOverMenuCell-----------------------
 */
@interface SNPopOverMenuCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *menuNameLabel;
@end
/**
 *  -----------------------SNPopOverMenuView-----------------------
 */
@interface SNPopOverMenuView : UIControl

@end

/**
 *  -----------------------SNPopOverMenu-----------------------
 */

@interface SNPopOverMenu : NSObject


/**
 *  show method with sender with imageNameArray
 *
 *  @param sender         sender
 *  @param senderFrame    the frame of sender
 *  @param menuArray      menuArray
 *  @param imageNameArray imageNameArray
 *  @param doneBlock      SNPopOverMenuDoneBlock
 *  @param dismissBlock   SNPopOverMenuDismissBlock
 */
+ (void)showForSender:(UIView *)sender
          senderFrame:(CGRect )senderFrame
             withMenu:(NSArray<NSString*> *)menuArray
       imageNameArray:(NSArray<NSString*> *)imageNameArray
            doneBlock:(SNPopOverMenuDoneBlock)doneBlock
         dismissBlock:(SNPopOverMenuDismissBlock)dismissBlock;

/**
 *  show method with sender with imageNameArray
 *
 *  @param sender         sender
 *  @param haveUnabled    have unable touch row
 *  @param unabledIndex   the unable touch row of index
 *  @param senderFrame    the frame of sender
 *  @param menuArray      menuArray
 *  @param imageNameArray imageNameArray
 *  @param doneBlock      SNPopOverMenuDoneBlock
 *  @param dismissBlock   SNPopOverMenuDismissBlock
 */
+ (void)showForSender:(UIView *)sender
          haveUnabled:(BOOL)haveUnabled
         unabledIndex:(NSInteger)unabledIndex
          senderFrame:(CGRect )senderFrame
             withMenu:(NSArray<NSString*> *)menuArray
       imageNameArray:(NSArray<NSString*> *)imageNameArray
            doneBlock:(SNPopOverMenuDoneBlock)doneBlock
         dismissBlock:(SNPopOverMenuDismissBlock)dismissBlock;

/**
 *  dismiss method
 */
+ (void) dismiss;

#pragma mark - 为小说添加方法，因为小说模块日夜间模式与主线不一致
+ (void)showForStorySender:(UIView *)sender
               senderFrame:(CGRect )senderFrame
                 superView:(UIView *)superView
                  withMenu:(NSArray<NSString*> *)menuArray
            imageNameArray:(NSArray<NSString*> *)imageNameArray
                 doneBlock:(SNPopOverMenuDoneBlock)doneBlock
              dismissBlock:(SNPopOverMenuDismissBlock)dismissBlock;

@end
