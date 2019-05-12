//
//  SNArticleDownView.h
//  sohunews
//
//  Created by qz on 09/03/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNArticleDownView : UIView
@property (nonatomic, assign) id delegate;
@end

@protocol SNArticleSheetDelegate <NSObject>
-(void)tipOffOperation;//举报
-(void)updateFontSize:(NSInteger)fontSize;//
-(void)nightShiftOperation:(BOOL)nightMode;//
@end
