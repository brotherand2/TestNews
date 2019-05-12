//
//  SNPicInputViewController.m
//  sohunews
//
//  Created by jialei on 13-6-19.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNCommentEditorPicInputView.h"

@implementation SNPicInputView

@synthesize pickerDelegate = _pickerDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.frame = frame;
        
        UIImage *backgroundImage = [UIImage themeImageNamed:@"comment_input_background.png"];
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundImageView.frame = self.bounds;
        backgroundImageView.tag = 101;
        [self addSubview:backgroundImageView];
        
        UIImage *sepImage = [UIImage themeImageNamed:@"comment_image_background.png"];
        UIImageView *sepImageView = [[UIImageView alloc]initWithImage:sepImage];
        sepImageView.frame = self.bounds;
        sepImageView.tag = 102;
        [self addSubview:sepImageView];
        
        float unitPointX = self.width / 6;
        float unitPointY = self.height / 4;
        
        UIImage *camraImage = [UIImage themeImageNamed:@"comment_from_photo_library.png"];
        photoLibraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [photoLibraryButton setImage:camraImage forState:UIControlStateNormal];
        [photoLibraryButton addTarget:self action:@selector(photoLibraryButtonFunc) forControlEvents:UIControlEventTouchUpInside];
        photoLibraryButton.frame = CGRectMake(0, 0, camraImage.size.width, camraImage.size.height);
        photoLibraryButton.center = CGPointMake(unitPointX, unitPointY);
        photoLibraryButton.accessibilityLabel = @"从相册选取";
        [self addSubview:photoLibraryButton];
        
        UIImage *libraryImage = [UIImage themeImageNamed:@"comment_from_camra.png"];
        photographButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [photographButton setImage:libraryImage forState:UIControlStateNormal];
        [photographButton addTarget:self action:@selector(photographButtonFunc) forControlEvents:UIControlEventTouchUpInside];
        photographButton.frame = CGRectMake(0, 0, libraryImage.size.width, libraryImage.size.height);
        photographButton.center = CGPointMake(unitPointX * 3, unitPointY);
        photographButton.accessibilityLabel = @"拍摄照片";
        [self addSubview:photographButton];
    }
    return self;
}


#pragma mark - 
#pragma mark buttonFunction
- (void)photoLibraryButtonFunc
{
    if (self.pickerDelegate && [self.pickerDelegate respondsToSelector:@selector(commentImageFromPhotoLibrary)]) {
        [self.pickerDelegate commentImageFromPhotoLibrary];
    }
}

- (void)photographButtonFunc
{
    if (self.pickerDelegate && [self.pickerDelegate respondsToSelector:@selector(commentImageFromCamera)]) {
        [self.pickerDelegate commentImageFromCamera];
    }
}

#pragma mark -
- (void)updateTheme {
    UIImageView *backgroundImageView = (UIImageView *)[self viewWithTag:101];
    UIImage *backgroundImage = [UIImage themeImageNamed:@"comment_input_background.png"];
    backgroundImageView.image = backgroundImage;
    
    UIImage *sepImage = [UIImage themeImageNamed:@"comment_image_background.png"];
    UIImageView *sepImageView = (UIImageView *)[self viewWithTag:102];
    sepImageView.image = sepImage;
    
    UIImage *camraImage = [UIImage themeImageNamed:@"comment_from_photo_library.png"];
    [photoLibraryButton setImage:camraImage forState:UIControlStateNormal];
    
    UIImage *libraryImage = [UIImage themeImageNamed:@"comment_from_camra.png"];
    [photographButton setImage:libraryImage forState:UIControlStateNormal];
}

@end
