//
//  SNPaperLogoView.h
//  sohunews
//
//  Created by guoyalun on 9/25/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNWebImageView.h"
#import "SNDateLabel.h"
typedef enum SubcribeState
{
    UnSubcribe,
    Subscribe
    
} SubcribeState;

@interface SNPaperLogoView : UIView <TTURLRequestDelegate >
{
    SNWebImageView *_logoImageView;
    UIButton       *_addBtn;
    UILabel        *_termNameLabel;
    
    UIView         *_seperatorView;
    
    SubcribeState  state;
    
    NSString       *_subId;
    NSString       *_pubName;
    NSString       *_normalLogoUrl;
    NSString       *_nightLogoUrl;
}
@property (nonatomic,strong)     UILabel        *termNameLabel;
@property (nonatomic,assign)     SubcribeState  state;
@property (nonatomic,strong)     NSString       *subId;
@property (nonatomic,strong)     NSString       *pubName;
@property (nonatomic,strong)     NSString       *normalLogoUrl;
@property (nonatomic,strong)     NSString       *nightLogoUrl;


- (id)initWithFrame:(CGRect)frame Delegate:(id)delegate;

- (void)resetAllViews;

- (void)setLogoUrl:(NSString *)logoUrl;
- (void)setDateString:(NSString *)publishDate;

- (void)updateTheme;

@end
