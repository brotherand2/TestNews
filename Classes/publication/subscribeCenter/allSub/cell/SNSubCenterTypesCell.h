//
//  SNSubCenterTypesCell.h
//  sohunews
//
//  Created by wang yanchen on 12-11-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableViewCell.h"
@class SCSubscribeTypeObject;

@interface SNSubCenterTypesCell : SNTableViewCell {
//    UIImageView *_selectBackImageView;
    UILabel *_typeNameLabel;
    
    SCSubscribeTypeObject *_typeObj;
}

@property(nonatomic, strong) SCSubscribeTypeObject *typeObj;

@end
