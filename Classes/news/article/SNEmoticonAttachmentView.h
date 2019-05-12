//
//  SNEmoticonTextView.h
//  sohunews
//
//  Created by jialei on 14-5-20.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FastTextView.h"

@class SNEmoticonObject;
@interface SNEmoticonAttachmentView : UIView<FastTextAttachmentCell>
{
    CGRect _cellRect;
    CGSize _fullcellsize;
}

@property (nonatomic, assign) NSRange range ;
@property (nonatomic, strong)SNEmoticonObject *emoticon;

@property (nonatomic, assign)CGRect imgRect;
@property (nonatomic, assign)CGRect cellRect;

- (id)initWithEmoticonObject:(SNEmoticonObject *)emoticon;


- (CGRect)cellRect;
- (UIView *)attachmentView;
- (CGSize)attachmentSize;
- (void)attachmentDrawInRect: (CGRect)rect;

@end
