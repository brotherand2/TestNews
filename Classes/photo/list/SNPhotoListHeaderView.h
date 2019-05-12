//
//  SNPhotoListHeaderView.h
//  sohunews
//
//  Created by 雪 李 on 11-12-14.
//  Copyright (c) 2011年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface SNPhotoListHeaderView : UIView
{
    UILabel *_titleLabel;
    UILabel *_sourceInfoLabel;
    UIImageView *_seperator;
    UIView *_redDecorationView;
    id _delegate;
}

@property(nonatomic,assign)id delegate;
@property(nonatomic, retain)UILabel *sourceInfoLabel;

-(id)initWithTitle:(NSString*)title 
              time:(NSString*)time
              from:(NSString*)from
         likeCount:(NSString*)likeCount
          delegate:(id)delegate 
             frame:(CGRect)frame;

- (void)setReadCount:(NSString *)readCount;
- (void)updateTheme;

@end
