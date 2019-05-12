//
//  SNEmptyView.h
//  sohunews
//
//  Created by kuanxi zhu on 7/22/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SNEmptyView : UIView {
	SNWebImageView *_bgView;
	SNWebImageView *_iconView;
	UILabel *_errorLabel;
	NSString *_errorTitle;
	NSString *_bgImagePath;
	NSString *_iconImagePath;
}

@property (nonatomic, strong) NSString *errorTitle;
@property (nonatomic, strong) NSString *bgImagePath;
@property (nonatomic, strong) NSString *iconImagePath;
@end
