//
//  SNStoryGetContentFailedView.h
//  sohunews
//
//  Created by chuanwenwang on 2016/11/8.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SNStoryGetContentNoNet = 0,
    SNStoryGetContentFailed
}SNStoryGetContentFailedType;

@protocol SNStoryGetContentFailedViewDelegate <NSObject>

@optional
-(void)refreshRequestWithDic:(NSDictionary *)dic;

@end

@interface SNStoryGetContentFailedView : UIView

@property(nonatomic,weak)id<SNStoryGetContentFailedViewDelegate>delegate;
@property(nonatomic,assign)SNStoryGetContentFailedType storyGetContentFailedType;
- (void)updateNovelTheme;
@end
