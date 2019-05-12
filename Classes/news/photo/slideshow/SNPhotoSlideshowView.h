//
//  SNPhotoSlideshowView.h
//  sohunews
//
//  Created by Dan on 12/27/11.
//  Copyright (c) 2011 Sohu.com Inc. All rights reserved.
//

// UI
#import "TTImageView.h"
#import "TTPhotoVersion.h"
#import "TTImageViewDelegate.h"
#import "SNPhoto.h"

@protocol TTPhoto;
@class TTLabel;

@protocol SNPhotoSlideshowViewDelegate <NSObject>
@optional
- (void)imageViewDidStartLoad;
- (void)didLoadImage4ImageView:(UIView *)view;
- (void)imageViewDidFailLoadWithError:(NSError*)error;
@end

@interface SNPhotoSlideshowView : TTImageView <TTImageViewDelegate> {
    id <TTPhoto>              _photo;
    id <SNPhotoSlideshowViewDelegate>  __weak _photoDelegate;
    UIActivityIndicatorView*  _statusSpinner;
    
    TTLabel* _statusLabel;
    TTStyle* _captionStyle;
    
    TTPhotoVersion _photoVersion;
    
    BOOL _hidesExtras;
    BOOL _hidesCaption;
    
    BOOL isError;	
    NSInteger _index;
}

@property (nonatomic, strong) id<TTPhoto> photo;
@property (nonatomic, strong) TTStyle*    captionStyle;
@property (nonatomic)         BOOL        hidesExtras;
@property (nonatomic)         BOOL        hidesCaption;
@property (nonatomic)         BOOL        isError;
@property (nonatomic)         NSInteger   index;
@property (nonatomic, weak) id <SNPhotoSlideshowViewDelegate>  photoDelegate;
- (BOOL)loadPreview:(BOOL)fromNetwork;
- (void)loadImage;

- (void)showProgress:(CGFloat)progress;
- (void)showStatus:(NSString*)text;
- (UIImage *)getLocalImage;

@end
