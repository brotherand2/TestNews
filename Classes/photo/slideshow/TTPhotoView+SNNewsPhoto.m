//
//  TTPhotoView+SNNewsPhoto.m
//  sohunews
//
//  Created by qi pei on 6/1/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "TTPhotoView+SNNewsPhoto.h"
#import "NSObject+MethodExchange.h"
#import "SNUtility.h"
#import "Three20UI/private/TTImageViewInternal.h"

@implementation TTPhotoView (SNNewsPhoto)


+ (void)load
{
    [self replaceMethod:@selector(imageViewDidLoadImage:) withNewMethod:@selector(inner_imageViewDidLoadImage:)];
    [self replaceMethod:@selector(imageViewDidFailLoadWithError:) withNewMethod:@selector(inner_imageViewDidFailLoadWithError:)];
}




///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    if (self) {
        _photoVersion = TTPhotoVersionNone;
        self.clipsToBounds = NO;
        
        NSString *alpha = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kImageAlpha];
        self.alpha = [alpha floatValue];
    }
    
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    CGRect screenBounds = TTScreenBounds();
    CGFloat width = self.width;
    CGFloat height = self.height;
    CGFloat cx = self.bounds.origin.x + width/2;
    CGFloat cy = self.bounds.origin.y + height/2;
    CGFloat marginRight = 0.0f, marginLeft = 0.0f, marginBottom = TTToolbarHeight()*3;
    
    // Since the photo view is constrained to the size of the image, but we want to position
    // the status views relative to the screen, offset by the difference
    CGFloat screenOffset = -floor(screenBounds.size.height/2 - height/2);
    
    // Vertically center in the space between the bottom of the image and the bottom of the screen
    CGFloat imageBottom = screenBounds.size.height/2 + self.defaultImage.size.height/2;
    CGFloat textWidth = screenBounds.size.width - (marginLeft+marginRight);
    
    if (_statusLabel.text.length) {
        CGSize statusSize = [_statusLabel sizeThatFits:CGSizeMake(textWidth, 0)];
        _statusLabel.frame =
        CGRectMake(marginLeft + (cx - screenBounds.size.width/2),
                   cy + floor(screenBounds.size.height/2 - (statusSize.height+marginBottom)),
                   textWidth, statusSize.height);
        
    } else {
        _statusLabel.frame = CGRectZero;
    }
    
    if (_captionLabel.text.length) {
        CGSize captionSize = [_captionLabel sizeThatFits:CGSizeMake(textWidth, 0)];
        _captionLabel.frame = CGRectMake(marginLeft + (cx - screenBounds.size.width/2),
                                         cy + floor(screenBounds.size.height/2
                                                    - (captionSize.height+marginBottom)),
                                         textWidth, captionSize.height);
        
    } else {
        _captionLabel.frame = CGRectZero;
    }
    
    CGFloat spinnerTop = _captionLabel.height
    ? _captionLabel.top - floor(_statusSpinner.height + _statusSpinner.height/2)
    : screenOffset + imageBottom + floor(_statusSpinner.height/2);
    
    _statusSpinner.frame =
    CGRectMake(self.bounds.origin.x + floor(self.bounds.size.width/2 - _statusSpinner.width/2),
               spinnerTop, _statusSpinner.width, _statusSpinner.height);
}


- (void)inner_imageViewDidLoadImage:(UIImage*)image {
    if ([_photo.photoSource respondsToSelector:@selector(isLoading)]) {
        if (!_photo.photoSource.isLoading) {
            [self showProgress:-1];
            [self showStatus:nil];
        }
    }
    
    if (!_photo.size.width) {
        _photo.size = image.size;
        [self.superview setNeedsLayout];
    }
    
    if (_photoDelegate && [_photoDelegate respondsToSelector:@selector(didLoadImage4ImageView:)]) {
        [_photoDelegate didLoadImage4ImageView:self];
    }
}

- (void)inner_imageViewDidFailLoadWithError:(NSError*)error {
    isError = YES;
    
    [self showProgress:0];
    if (error) {
        [self showStatus:NSLocalizedString(@"LoadFailRefresh", @"加载失败，点击屏幕刷新")];
    }
}

#pragma mark -
#pragma mark Public

- (void)reloadImage {
    if (nil == _request && nil != _urlPath) {
        UIImage* image = [[TTURLCache sharedCache] imageForURL:_urlPath];
        
        if (nil != image) {
            self.image = [UIImage rotateImage:image];
            
        } else {
            TTURLRequest* request = [TTURLRequest requestWithURL:_urlPath delegate:self];
            request.response = [[[TTURLImageResponse alloc] init] autorelease];
            // Give the delegate one chance to configure the requester.
            if ([_delegate respondsToSelector:@selector(imageView:willSendARequest:)]) {
                [_delegate imageView:self willSendARequest:request];
            }
            
            if (![request send]) {
                // Put the default image in place while waiting for the request to load
                if (_defaultImage && nil == self.image) {
                    self.image = _defaultImage;
                }
            }
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reload {
	if (nil == _request && nil != _urlPath) {
        
		//http image
		if ([_urlPath hasPrefix:@"http"]) {
            
            [self reloadImage];
			
		} 
		//local image
		else {
			UIImage* image = [UIImage imageWithContentsOfFile:_urlPath];
			
			if (nil != image) {
				self.image = [UIImage rotateImage:image];
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
- (void)requestDidFinishLoad:(TTURLRequest*)request {
    TTURLImageResponse* response = request.response;
    [self setImage:[UIImage rotateImage:response.image]];
    
    self.alpha = 0.3;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    NSString *alpha = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kImageAlpha];
    self.alpha = [alpha floatValue];
    [UIView commitAnimations];
    
    TT_RELEASE_SAFELY(_request);
}

@end
