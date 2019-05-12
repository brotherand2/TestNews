//
//  SNCheckIcon.h
//  sohunews
//
//  Created by jialei on 14-3-13.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SNCheckIconTouchedChooseBlock)(NSString *checkKey, BOOL selected);
typedef void (^SNCheckIconTouchedLoginBlock)(NSString *checkKey);

@interface SNCommentEditorCheckIcon : UIView

@property (nonatomic, assign)BOOL selected;
@property (nonatomic, copy)SNCheckIconTouchedChooseBlock touchedChooseBlock;
@property (nonatomic, copy)SNCheckIconTouchedLoginBlock touchedLoginBlock;
@property (nonatomic, strong)NSString *key;
@property (nonatomic, strong)ShareListItem *item;

- (id)initWithItem:(ShareListItem *)item iconKey:(NSString *)key;
- (void)loginFinished;

@end
