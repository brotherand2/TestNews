//
//  SNGalleryPhotoView.m
//  sohunews
//
//  Created by chenhong on 14-4-23.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNGalleryPhotoView.h"
#import "SNNotificationCenter.h"
#import "FGalleryPhotoView.h"
#import "UIImage+MultiFormat.h"
#import "OLImageView.h"
#import "OLImage.h"


#define Photo_Slide_Show_Back 1
#define Photo_Slide_Show_Download 2

@interface SNGalleryPhotoView ()<FGalleryPhotoViewDelegate> {
    FGalleryPhotoView *_photoView;
    BOOL _isImageDownloaded;
    
}

@end

@implementation SNGalleryPhotoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor   = [UIColor blackColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _photoView = [[FGalleryPhotoView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _photoView.photoDelegate = self;
        [self setDefaultPhotoImageView];
        [self addSubview:_photoView];
        
        UIImage *backImage = [UIImage imageNamed:@"photo_slideshow_back.png"];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                   self.height - backImage.size.height,
                                                                   backImage.size.width,
                                                                   backImage.size.height)];
        [btn setImage:backImage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(cancelViewSharedImage:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = Photo_Slide_Show_Back;
        [self addSubview:btn];
        
        UIImage *downloadImage = [UIImage imageNamed:@"photo_slideshow_download.png"];
        UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(self.width - downloadImage.size.width,
                                                                    self.size.height - downloadImage.size.height,
                                                                    downloadImage.size.width,
                                                                    downloadImage.size.height)];
        [btn1 setImage:downloadImage forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(downloadViewSharedImage:) forControlEvents:UIControlEventTouchUpInside];
        btn1.tag = Photo_Slide_Show_Download;
        [self addSubview:btn1];
        _downloadBtn = btn1;
        _downloadBtn.enabled = NO;
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

- (void)loadImageWithUrlPath:(NSString *)urlPath {
    if (urlPath.length == 0 && _image == nil) {
        return;
    }
    
    [_photoView resetImageScale];
    
    NSRange range = [urlPath rangeOfString:kCommentImageFolderId];
    if ((range.location != NSNotFound && range.length != 0) || _image != nil) {
        UIImage *image = [OLImage imageWithContentsOfFile:urlPath];
        if (image) {
            _photoView.imageView.image = image;
            //            _photoView.imageView.frame = CGRectMake(0, 0,
            //                                                    self.frame.size.width,
            //                                                    self.frame.size.width / image.size.width * image.size.height);
            //            _photoView.contentSize = _photoView.imageView.size;
            //            if (_photoView.imageView.height < _photoView.height) {
            //                _photoView.imageView.centerY = CGRectGetMidY(_photoView.bounds);
            //            }
            [self resizePhotoImageView];
        } else {
            _photoView.imageView.image = _image;
            [self resizePhotoImageView];
        }
    }
    else {
        
        NSString *filePath = [[[TTURLCache sharedCache] cachePath] stringByAppendingPathComponent:urlPath];
        
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir]) {
            _isImageDownloaded = YES;
            UIImage *image = [OLImage imageWithContentsOfFile:filePath];
            _photoView.imageView.image = image;
            [self resizePhotoImageView];
            _downloadBtn.enabled = YES;
        } else {
            [self setDefaultPhotoImageView];
            
            _photoView.activity.status = SNTripletsLoadingStatusLoading;
            //[_photoView.activity startAnimating];
            
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:urlPath] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                _photoView.progressLabel.text = [NSString stringWithFormat:@"%d%%", (int)(receivedSize*100.0/expectedSize)];
                if (receivedSize == expectedSize) {
                    _photoView.activity.status = SNTripletsLoadingStatusStopped;
                }
            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[_photoView.activity stopAnimating];
                    
                    _photoView.progressLabel.text = @"";
                    if (finished && (data || image)) {
                        _isImageDownloaded = YES;
                        _downloadBtn.enabled = YES;
                        if (data) {
                            UIImage *aImage = [OLImage imageWithData:data];
                            _photoView.imageView.image = aImage;
                            [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
                        }
                        else if (image) {
                            _photoView.imageView.image = image;
                        }
                        
                        [self resizePhotoImageView];
                    }
                    
                    if (error) {
                        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"PhotoDownloadFail", @"Photo Download Failed") toUrl:nil mode:SNCenterToastModeWarning];
                    }
                });
        
            }];
        }
    }
    
}

- (void)resizePhotoImageView {
    //    _photoView.imageView.frame = CGRectMake(0, 0,
    //                                            self.frame.size.width,
    //                                            self.frame.size.width / _photoView.imageView.image.size.width * _photoView.imageView.image.size.height);
    //    _photoView.contentSize = _photoView.imageView.size;
    //    if (_photoView.imageView.height < _photoView.height) {
    //        _photoView.imageView.centerY = CGRectGetMidY(_photoView.bounds);
    //    }
    
    [_photoView changeImageViewFrame];
}

- (void)setDefaultPhotoImageView {
    UIImage *placeholder = [UIImage themeImageNamed:@"app_logo_gray.png"];
    _photoView.imageView.image = placeholder;
    _photoView.imageView.frame = CGRectMake(0, 0, placeholder.size.width, placeholder.size.height);
    _photoView.imageView.centerX = CGRectGetMidX(_photoView.bounds);
    _photoView.imageView.centerY = CGRectGetMidY(_photoView.bounds) + 30;
}

- (void)cancelViewSharedImage:(id)sender {
    if (self.alpha > 0) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else {
        [self removeFromSuperview];
    }
}

- (void)downloadViewSharedImage:(id)sender {
    if (_isImageDownloaded && _photoView.imageView.image) {
        UIImageWriteToSavedPhotosAlbum(_photoView.imageView.image, [SNUtility getApplicationDelegate], @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

#pragma mark - FGalleryPhotoViewDelegate

- (void)didTapPhotoView:(FGalleryPhotoView*)photoView {
    if (self.alpha == 1.0) {
        [self cancelViewSharedImage:nil];
    }
}

- (void)updateTheme {
    UIButton *photoBackBtn = (UIButton *)[self viewWithTag:Photo_Slide_Show_Back];
    [photoBackBtn setImage:[UIImage imageNamed:@"photo_slideshow_back.png"] forState:UIControlStateNormal];
    UIButton *photoDownloadBtn = (UIButton *)[self viewWithTag:Photo_Slide_Show_Download];
    [photoDownloadBtn setImage:[UIImage imageNamed:@"photo_slideshow_download.png"] forState:UIControlStateNormal];
}

@end
