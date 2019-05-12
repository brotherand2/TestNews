//
//  SNPicInputViewController.h
//  sohunews
//
//  Created by jialei on 13-6-19.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNCommentImageInputViewDelegate <NSObject>

- (void)commentImageFromCamera;
- (void)commentImageFromPhotoLibrary;

@end

@interface SNPicInputView : UIView
{
    UIButton *photoLibraryButton;
    UIButton *photographButton;
    id<SNCommentImageInputViewDelegate>__weak _pickerDelegate;
}

@property (nonatomic, weak) id<SNCommentImageInputViewDelegate>pickerDelegate;

- (void)updateTheme;

@end
