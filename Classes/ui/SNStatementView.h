//
//  SNStatementView.h
//  sohunews
//
//  Created by guoyalun on 1/29/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface SNStatementView : UIView
{
    NSMutableAttributedString *_statment;
}
@property (nonatomic,strong) NSMutableAttributedString *statment;
@end
