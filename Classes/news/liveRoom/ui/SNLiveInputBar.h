//
//  SNLiveInputBar.h
//  sohunews
//
//  Created by chenhong on 13-6-29.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNLiveRoomConsts.h"

typedef enum {
    INPUT_KEYBOARD = 1,
    INPUT_EMO,
    INPUT_PIC,
    INPUT_REC,
}SNLiveInputModeEnum;

@protocol SNLiveInputBarDelegate <NSObject>

@optional
- (void)liveInputBarDoLogin;
- (void)liveInputBarPostImageDoLogin;
- (void)liveInputBarDoPost;
- (void)liveInputBarDoImagePick;
- (void)liveInputBarDoEmoPick;
- (void)liveInputBarDoRecord;
- (BOOL)liveInputBarImageAllowed:(BOOL)showMsg;
- (void)liveInputBarFrameChanged:(CGRect)frame;

@end

@interface SNLiveInputBar : UIView<UITextViewDelegate> {
    id<SNLiveInputBarDelegate> __weak _delegate;
}

@property(nonatomic,weak)id<SNLiveInputBarDelegate> delegate;
@property(nonatomic,assign)BOOL pickingImage;
@property(nonatomic,assign)SNLiveInputModeEnum inputMode;


- (void)focus;
- (void)resignFocus;
- (BOOL)isFirstResponder;

- (NSString *)strContent;
- (void)setContent:(NSString *)str;
- (UIImage *)editedImage;
- (void)setInputImage:(UIImage *)image;
- (void)setPlaceHolder:(NSString *)txt;
- (void)updateTheme;
- (void)changeTextColorToGray:(BOOL)bGray;

// 在textView当前光标处插入文本
- (void)textViewInsertText:(NSString *)str;
- (void)textViewDeleteEmoticon;

- (void)postSucccess:(SNLiveCommentType)type;
- (void)postFailure:(NSString *)txt;

@end
