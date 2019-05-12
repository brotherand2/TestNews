//
//  SohuSloganView.h
//  SohuAR
//
//  Created by sun on 2016/12/5.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SohuSloganView : UIView

+(void)showToView:(UIView *)view
      sloganImage:(UIImage *)image
             size:(CGSize)size
sloganinformation:(NSDictionary *)information;

+(void)showToView1:(UIView *)view
       sloganImage:(UIImage *)image
              size:(CGSize)size
 sloganinformation:(NSDictionary *)information;

@end
