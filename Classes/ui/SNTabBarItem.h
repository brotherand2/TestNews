//
//  SNTabBarItem.h
//  sohunews
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNTabBarItem : UITabBarItem {  
    UIImage *cSelectedImage;
	UIImage *cUnselectedImage;
}  

@property (nonatomic, strong) UIImage *cSelectedImage;  
@property (nonatomic, strong) UIImage *cUnselectedImage;  

@end
