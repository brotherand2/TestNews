//
//  SNEmoticonButton.h
//  sohunews
//
//  Created by jialei on 14-5-15.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNEmoticonObject;
typedef void(^eomitconButtonClickedBlock)(SNEmoticonObject *obj);

@interface SNEmoticonButton : UIControl

@property (nonatomic, strong) SNEmoticonObject* emoticonObj;
@property (nonatomic, copy) eomitconButtonClickedBlock clickedBlock;

- (id)initWithEmoticon:(SNEmoticonObject *)emoticon frame:(CGRect)frame;

@end
