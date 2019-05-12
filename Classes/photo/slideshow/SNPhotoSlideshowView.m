//
//  SNPhotoSlideshowView.m
//  sohunews
//
//  Created by Dan on 12/27/11.
//  Copyright (c) 2011 Sohu.com Inc. All rights reserved.
//

#import "SNPhotoSlideshowView.h"

#import "SNScrollLabel.h"

// UI
#import "Three20UI/TTPhoto.h"
#import "Three20UI/TTPhotoSource.h"
#import "Three20UI/TTLabel.h"
#import "Three20UI/UIViewAdditions.h"

// UI (private)
#import "Three20UI/private/TTImageViewInternal.h"

// UINavigator
#import "Three20UINavigator/TTGlobalNavigatorMetrics.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"

// Style
//#import "Three20Style/TTGlobalStyle.h"
//#import "Three20Style/TTStyleSheet.h"
//#import <Three20Style/UIImageAdditions.h>

// Network
#import "Three20Network/TTURLCache.h"
#import "Three20Network/TTURLRequestQueue.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCoreLocale.h"

#import "SNURLRequest.h"
#import "CacheObjects.h"
#import "SNDBManager.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SNPhotoSlideshowView

@synthesize photo         = _photo;
@synthesize captionStyle  = _captionStyle;
@synthesize hidesExtras   = _hidesExtras;
@synthesize hidesCaption  = _hidesCaption;
@synthesize isError;
@synthesize photoDelegate = _photoDelegate;
@synthesize index = _index;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _photoVersion = TTPhotoVersionNone;
        self.clipsToBounds = NO;
        
        NSString *alpha = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kImageAlpha];
        self.alpha = [alpha floatValue];
        
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    
    [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];

    TT_RELEASE_SAFELY(_photo);
    TT_RELEASE_SAFELY(_captionStyle);
    TT_RELEASE_SAFELY(_statusSpinner);
    TT_RELEASE_SAFELY(_statusLabel);
    
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadVersion:(TTPhotoVersion)version fromNetwork:(BOOL)fromNetwork {
    NSString* URL = [_photo URLForVersion:version];
    if (URL) {
        UIImage* image = [[TTURLCache sharedCache] imageForURL:URL];
        if (image || fromNetwork) {
            _photoVersion = version;
            self.urlPath = URL;
            return YES;
        }
    }
    
    return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showCaption:(NSString*)caption {
    //  if (caption) {
    //    if (!_captionLabel) {
    //      _captionLabel = [[SNScrollLabel alloc] init];
    //      _captionLabel.opaque = NO;
    //      //_captionLabel.style = _captionStyle ? _captionStyle : TTSTYLE(photoCaption);
    //      _captionLabel.alpha = _hidesCaption ? 0 : 1;
    //      [self addSubview:_captionLabel];
    //    }
    //  }
    //
    //  _captionLabel.text = caption;
    //[self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIImageView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setImage:(UIImage*)image {
    if (image != _defaultImage
        || !_photo
        || self.urlPath != [_photo URLForVersion:TTPhotoVersionLarge]) {    
        if (image == _defaultImage) {
            self.contentMode = UIViewContentModeCenter;
            
        } else {
            self.contentMode = UIViewContentModeScaleAspectFill;
        }
        if(image.imageOrientation!=UIImageOrientationUp)
        {
            image = [image transformWidth:image.size.height height:image.size.width rotate:NO];
        }
            
        [super setImage:image];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)imageViewDidStartLoad {
    isError = NO;
    [self showProgress:0];
    
    SNDebugLog(@"imageViewDidStartLoad %d", _index);
    
    if (_photoDelegate && [_photoDelegate respondsToSelector:@selector(imageViewDidStartLoad)]) {
        [_photoDelegate imageViewDidStartLoad];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)imageViewDidLoadImage:(UIImage*)image {
    isError = NO;	
	
    /*
     * fix for :
     *
     * Fatal Exception NSInvalidArgumentException
     * -[__NSCFType isLoading]: unrecognized selector sent to instance 0xd960b70
     *
     * by jojo.
     */
    if ([_photo.photoSource respondsToSelector:@selector(isLoading)] && !_photo.photoSource.isLoading) {
        [self showProgress:-1];
        [self showStatus:nil];
    }
    
    if (!_photo.size.width) {
        _photo.size = image.size;
        [self.superview setNeedsLayout];
    }
    
    if (_photoDelegate && [_photoDelegate respondsToSelector:@selector(didLoadImage4ImageView:)]) {
        [_photoDelegate didLoadImage4ImageView:self];
    }  
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)imageViewDidFailLoadWithError:(NSError*)error {
    isError = YES;
	
//    [self showProgress:-1];
    if (error) {
        [self showStatus:NSLocalizedString(@"LoadFailRefresh", @"加载失败，点击屏幕刷新")];
        
        if (_photoDelegate && [_photoDelegate respondsToSelector:@selector(imageViewDidFailLoadWithError:)]) {
            [_photoDelegate imageViewDidFailLoadWithError:error];
        }  
    } else {
        //[self showStatus:NSLocalizedString(@"NoNetwork", @"无法连接到网络")];
    }
	
}

- (UIImage *)getLocalImage
{
    return [UIImage imageWithContentsOfFile:_urlPath];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidStartLoad:(TTURLRequest*)request {
    
    [self imageViewDidStartLoad];
}

#pragma mark -
#pragma mark SNDatabaseRequestDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
    TTURLImageResponse* response = request.response;
    [self setImage:response.image];
    
    self.alpha = 0.3;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    NSString *alpha = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kImageAlpha];
    self.alpha = [alpha floatValue];
    [UIView commitAnimations];
    
    TT_RELEASE_SAFELY(_request);
}


- (void)request:(NSString*)url didFailLoadWithError:(NSError*)error
{
    
    [self imageViewDidFailLoadWithError:error];
    if ([_delegate respondsToSelector:@selector(imageView:didFailLoadWithError:)]) {
        [_delegate imageView:self didFailLoadWithError:error];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    CGRect screenBounds = TTScreenBounds();
    self.clipsToBounds = YES;
    
    self.backgroundColor = [UIColor blackColor];
    
    CGFloat width = self.width;
    CGFloat height = self.height;
    CGFloat cx = self.bounds.origin.x + width/2;
    CGFloat cy = self.bounds.origin.y + height/2;
    CGFloat marginRight = 0, marginLeft = 0, marginBottom = TTToolbarHeight();
    
    // Since the photo view is constrained to the size of the image, but we want to position
    // the status views relative to the screen, offset by the difference
    //CGFloat screenOffset = -floor(screenBounds.size.height/2 - height/2);
    
    // Vertically center in the space between the bottom of the image and the bottom of the screen
    CGFloat imageBottom = screenBounds.size.height/2 + self.defaultImage.size.height/2;
    CGFloat textWidth = screenBounds.size.width - (marginLeft+marginRight);
    
    if (_statusLabel.text.length) {
        CGSize statusSize = [_statusLabel sizeThatFits:CGSizeMake(textWidth, 0)];
        _statusLabel.frame =
        CGRectMake(marginLeft + (cx - screenBounds.size.width/2),
                   cy + floor(screenBounds.size.height/2 - (statusSize.height+marginBottom)) - TTBarsHeight(),
                   textWidth, statusSize.height);
        
    } else {
        _statusLabel.frame = CGRectZero;
    }
    
//    CGFloat spinnerTop = _captionLabel.height
//        ? _captionLabel.top - floor(_statusSpinner.height + _statusSpinner.height/2)
//        : screenOffset + imageBottom + floor(_statusSpinner.height/2);
	
	CGFloat spinnerTop = imageBottom;
    
    _statusSpinner.frame =
    CGRectMake(self.bounds.origin.x + floor(self.bounds.size.width/2 - _statusSpinner.width/2),
               spinnerTop, _statusSpinner.width, _statusSpinner.height);
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reload {
	if (nil == _request && nil != _urlPath) {
        
		//http image
		if ([_urlPath hasPrefix:@"http"]) {
            
            [super reload];
			
		} 
		//local image
		else {
			UIImage* image = [self getLocalImage];
			
			if (nil != image) {
				self.image = image;
			} else {
				NSError *error = [NSError errorWithDomain:NSURLErrorDomain 
													 code:NSURLErrorCannotOpenFile 
												 userInfo:nil];
				
				[self imageViewDidFailLoadWithError:error];
				if ([_delegate respondsToSelector:@selector(imageView:didFailLoadWithError:)]) {
					[_delegate imageView:self didFailLoadWithError:error];
				}
			}
            
		}
		
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPhoto:(id<TTPhoto>)photo {
    if (!photo || photo != _photo) {
        [_photo release];
        _photo = [photo retain];
        _photoVersion = TTPhotoVersionNone;
        
        self.urlPath = nil;
        
        //[self showCaption:((SNPhoto *)photo).info];
    }
    
    if (!_photo || _photo.photoSource.isLoading) {
        [self showProgress:0];
        
    } else {
        [self showStatus:nil];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHidesExtras:(BOOL)hidesExtras {
    if (!hidesExtras) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:TT_FAST_TRANSITION_DURATION];
    }
    _hidesExtras = hidesExtras;
    _statusSpinner.alpha = _hidesExtras ? 0 : 1;
    _statusLabel.alpha = _hidesExtras ? 0 : 1;
    //_captionLabel.alpha = _hidesExtras || _hidesCaption ? 0 : 1;
    if (!hidesExtras) {
        [UIView commitAnimations];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHidesCaption:(BOOL)hidesCaption {
    _hidesCaption = hidesCaption;
    //_captionLabel.alpha = hidesCaption ? 0 : 1;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadPreview:(BOOL)fromNetwork {
    if (![self loadVersion:TTPhotoVersionLarge fromNetwork:NO]) {
        if (![self loadVersion:TTPhotoVersionSmall fromNetwork:NO]) {
            if (![self loadVersion:TTPhotoVersionThumbnail fromNetwork:fromNetwork]) {
                return NO;
            }
        }
    }
    
    return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadImage {
    if (_photo) {
        _photoVersion = TTPhotoVersionLarge;
        self.urlPath = [_photo URLForVersion:TTPhotoVersionLarge];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showProgress:(CGFloat)progress {
    if (progress >= 0) {
        if (!_statusSpinner) {
            _statusSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleWhiteLarge];
            [self addSubview:_statusSpinner];
        }
        
        [_statusSpinner startAnimating];
        _statusSpinner.hidden = NO;
        [self showStatus:nil];
        [self setNeedsLayout];
        
    } else {
        [_statusSpinner stopAnimating];
        _statusSpinner.hidden = YES;
        //_captionLabel.hidden = !!_statusLabel.text.length;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showStatus:(NSString*)text {
    if (text) {
        if (!_statusLabel) {
            _statusLabel = [[TTLabel alloc] init];
//            _statusLabel.style = TTSTYLE(photoStatusLabel);
            _statusLabel.opaque = NO;
            [self addSubview:_statusLabel];
        }
        
        _statusLabel.hidden = NO;
        [self showProgress:-1];
        [self setNeedsLayout];
        //_captionLabel.hidden = YES;
        
    } else {
        _statusLabel.hidden = YES;
        //_captionLabel.hidden = NO;
    }
    
    _statusLabel.text = text;
}



@end