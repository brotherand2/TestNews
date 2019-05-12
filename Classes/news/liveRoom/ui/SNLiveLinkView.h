//
//  SNLiveLinkView.h
//  sohunews
//
//  Created by chenhong on 13-4-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNLiveLinkView : UIView {
    UIButton *_linkBtn;
    UILabel  *_linkLabel;
}

@property(nonatomic,copy)NSString *link;

- (void)updateTheme;

@end
