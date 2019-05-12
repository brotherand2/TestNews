//
//  SNPhotoListTitleSection.h
//  sohunews
//
//  Created by 雪 李 on 11-12-16.
//  Copyright (c) 2011年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNPhotoListTitleSection : UIView
{
    UIButton *_btnShare;
    UILabel *_titleLabel;
    
}

- (id)initWithTitle:(NSString*)title delegate:(id)delegate;

@end
