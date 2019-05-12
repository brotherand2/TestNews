//
//  SNPhotoListTitleSection.m
//  sohunews
//
//  Created by 雪 李 on 11-12-16.
//  Copyright (c) 2011年 Sohu.com Inc. All rights reserved.
//

#import "SNPhotoListTitleSection.h"

@implementation SNPhotoListTitleSection

- (id)initWithTitle:(NSString*)title delegate:(id)delegate
{
    self = [super init];
    if (self) {
        //分享按钮
        _btnShare   = [[UIButton alloc] init];
        [_btnShare setImage:[[UIImage imageNamed:@"tb_share_hl.png"] scaledImage] forState:UIControlStateNormal];
        [_btnShare setImage:[[UIImage imageNamed:@"tb_share.png"] scaledImage] forState:UIControlStateNormal];
        [_btnShare setBackgroundColor:[UIColor clearColor]];
        if ([delegate respondsToSelector:@selector(clickShare:)]) {
            [_btnShare addTarget:delegate action:@selector(clickShare:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self addSubview:_btnShare];
        [_btnShare release];
        
        //标题
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text     = title;
		[_titleLabel setTextAlignment:UITextAlignmentCenter];
		[_titleLabel setFont:[UIFont systemFontOfSize:kPhotoListTitleFont]];
		[_titleLabel setTextColor:[UIColor blackColor]];
		[_titleLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_titleLabel];
        [_titleLabel release];
        
        [self setBackgroundColor:[UIColor grayColor]];
        [self setAlpha:0.5];
    }
    return self;
}

-(void)layoutSubviews
{
    CGSize sizeShareBtn = CGSizeMake(kShareBtnWidth, kShareBtnHeight);
    CGRect rcShareBtn   = CGRectMake(self.frame.origin.x + self.frame.size.width - sizeShareBtn.width - kControlSpace
                                     , self.frame.origin.y + (self.frame.size.height - sizeShareBtn.height)/2
                                     , sizeShareBtn.width, sizeShareBtn.height);
    
    [_btnShare setFrame:rcShareBtn];
    
    CGRect rcTitle  = CGRectMake(0, 0, self.frame.size.width - sizeShareBtn.width, self.frame.size.height);
    [_titleLabel setFrame:rcTitle]; 
}

-(void)dealloc
{
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
