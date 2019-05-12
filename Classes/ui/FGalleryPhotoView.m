//
//  FGalleryPhotoView.m
//  FGallery
//
//  Created by Grant Davis on 5/19/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import "FGalleryPhotoView.h"

@interface FGalleryPhotoView (Private)

- (UIImage*)createHighlightImageWithFrame:(CGRect)rect;
- (void)killActivityIndicator;
- (void)startTapTimer;
- (void)stopTapTimer;
@end



@implementation FGalleryPhotoView


- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	self.userInteractionEnabled = YES;
	self.clipsToBounds = YES;
	self.delegate = self;
	self.contentMode = UIViewContentModeCenter;
	self.maximumZoomScale = 3.0;
	self.minimumZoomScale = 1.0;
	self.decelerationRate = .85;
	self.contentSize = CGSizeMake(frame.size.width, frame.size.height);
	
	// create the image view
	_imageView = [[OLImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	_imageView.contentMode = UIViewContentModeScaleAspectFit;
    //_imageView.showFade = NO;
	[self addSubview:_imageView];
	
	// create an activity inidicator
    // Cae 37是大菊花的系统固定尺寸
    _activity = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
    [_activity setColorBackgroundClear];
    // [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activity.status = SNTripletsLoadingStatusStopped;
    _activity.center = CGPointMake(self.center.x, self.center.y);
	[self addSubview:_activity];
    
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 14)];
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    _progressLabel.backgroundColor = [UIColor clearColor];
    _progressLabel.textColor = [UIColor whiteColor];
    _progressLabel.font = [UIFont systemFontOfSize:12];
    _progressLabel.center = CGPointMake(self.center.x, _activity.center.y - 30);
    [self addSubview:_progressLabel];
	
	return self;
}


- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action
{
	self = [self initWithFrame:frame];
	
	// fit them images!
	_imageView.contentMode = UIViewContentModeScaleAspectFill;
    
	// disable zooming
	self.minimumZoomScale = 1.0;
	self.maximumZoomScale = 1.0;
	
	// allow buttons to be clicked
	[self setUserInteractionEnabled:YES];
	
	// but don't allow zooming/panning
	self.scrollEnabled = NO;
	
	// create button
	_button = [[UIButton alloc] initWithFrame:CGRectZero];
	[_button setBackgroundColor:[UIColor clearColor]];
	[_button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_button];
	
	// create outline
	[self.layer setBorderWidth:1.0];
	[self.layer setBorderColor:[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.25] CGColor]];
	
	return self;
}

- (void)resetZoom
{
	_isZoomed = NO;
	[self stopTapTimer];
	[self setZoomScale:self.minimumZoomScale animated:NO];
	[self zoomToRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height ) animated:NO];
	self.contentSize = CGSizeMake(self.frame.size.width * self.zoomScale, self.frame.size.height * self.zoomScale );
}

- (void)setFrame:(CGRect)theFrame
{
	// store position of the image view if we're scaled or panned so we can stay at that point
	CGPoint imagePoint = _imageView.frame.origin;
	
	[super setFrame:theFrame];
	
	// update content size
	self.contentSize = CGSizeMake(theFrame.size.width * self.zoomScale, theFrame.size.height * self.zoomScale );
	
	// resize image view and keep it proportional to the current zoom scale
	_imageView.frame = CGRectMake( imagePoint.x, imagePoint.y, theFrame.size.width * self.zoomScale, theFrame.size.height * self.zoomScale);
	
	// center the activity indicator
	[_activity setCenter:CGPointMake(theFrame.size.width * .5, theFrame.size.height * .5)];
    
    _progressLabel.center = CGPointMake(_activity.center.x, _activity.center.y - 30);
	
	// update button
	if( _button )
	{
		// resize the button
		_button.frame = CGRectMake(0, 0, theFrame.size.width, theFrame.size.height);
		
		// create a fresh image for button highlight state
		[_button setImage:[self createHighlightImageWithFrame:theFrame] forState:UIControlStateHighlighted];
	}
}


- (UIImage*)createHighlightImageWithFrame:(CGRect)rect
{
	if( rect.size.width == 0 || rect.size.height == 0 ) return nil;
	
	// create a tint layer for the selected state of the button
	UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
	CALayer *blankLayer = [CALayer layer];
	[blankLayer setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
	[blankLayer setBackgroundColor:[[UIColor colorWithRed:0 green:0 blue:0 alpha:.4] CGColor]];
	[blankLayer renderInContext: UIGraphicsGetCurrentContext()];
	UIImage *clearImg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return clearImg;
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_imageView.image) {
        return;
    }
    
	UITouch *touch = [[event allTouches] anyObject];
	
	if (touch.tapCount == 2) {
		[self stopTapTimer];
		
        [self setScrollViewZoom];
//		if( _isZoomed ) 
//		{
//			_isZoomed = NO;
//			[self setZoomScale:self.minimumZoomScale animated:YES];
//		}
//		else {
//			
//			_isZoomed = YES;
//			
//			// define a rect to zoom to. 
//			CGPoint touchCenter = [touch locationInView:self];
//			CGSize zoomRectSize = CGSizeMake(self.frame.size.width / self.maximumZoomScale, self.frame.size.height / self.maximumZoomScale );
//			CGRect zoomRect = CGRectMake( touchCenter.x - zoomRectSize.width * .5, touchCenter.y - zoomRectSize.height * .5, zoomRectSize.width, zoomRectSize.height );
//			
//			// correct too far left
//			if( zoomRect.origin.x < 0 )
//				zoomRect = CGRectMake(0, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height );
//			
//			// correct too far up
//			if( zoomRect.origin.y < 0 )
//				zoomRect = CGRectMake(zoomRect.origin.x, 0, zoomRect.size.width, zoomRect.size.height );
//			
//			// correct too far right
//			if( zoomRect.origin.x + zoomRect.size.width > self.frame.size.width )
//				zoomRect = CGRectMake(self.frame.size.width - zoomRect.size.width, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height );
//			
//			// correct too far down
//			if( zoomRect.origin.y + zoomRect.size.height > self.frame.size.height )
//				zoomRect = CGRectMake( zoomRect.origin.x, self.frame.size.height - zoomRect.size.height, zoomRect.size.width, zoomRect.size.height );
//			
//			// zoom to it.
//			[self zoomToRect:zoomRect animated:YES];
//		}
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if([[event allTouches] count] == 1 ) {
		UITouch *touch = [[event allTouches] anyObject];
		if( touch.tapCount == 1 ) {
			
			if(_tapTimer ) [self stopTapTimer];
			[self startTapTimer];
		}
	}
}

- (void)startTapTimer
{
	_tapTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:.3] interval:.3 target:self selector:@selector(handleTap) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:_tapTimer forMode:NSDefaultRunLoopMode];
	
}

- (void)stopTapTimer
{
	if([_tapTimer isValid])
		[_tapTimer invalidate];
	
	_tapTimer = nil;
}

- (void)handleTap
{
	// tell the controller
	if([_photoDelegate respondsToSelector:@selector(didTapPhotoView:)])
		[_photoDelegate didTapPhotoView:self];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _imageView;
}

//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
//{
//	if( self.zoomScale == self.minimumZoomScale ) _isZoomed = NO;
//	else _isZoomed = YES;
//}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width)/2.f : 0.f;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height)/2.f : 0.f;
    _imageView.center = CGPointMake(scrollView.contentSize.width*.5f + offsetX, scrollView.contentSize.height/2.f + offsetY);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (scale < 1.f)
    {
        [scrollView setZoomScale:1.f animated:YES];
    }
}

- (void)killActivityIndicator
{
    _activity.status = SNTripletsLoadingStatusStopped;
//	[_activity stopAnimating];
	[_activity removeFromSuperview];
	_activity = nil;
}

- (void)dealloc {
	[self stopTapTimer];
	
	
	[self killActivityIndicator];
	
    
	
}


//根据图片和屏幕尺寸的宽高来决定_imageView的宽和高
- (void)changeImageViewFrame
{
    if (!_imageView.image)
    {
        return;
    }
    
	CGRect pictureRect = _imageView.frame;
	pictureRect.size = _imageView.image.size;
	
	if (_imageView.image.size.height <= self.frame.size.height && _imageView.image.size.width <= self.frame.size.width)
	{
		_imageView.frame = pictureRect;
		_imageView.center = CGPointMake(self.width/2.f, self.height/2.f);
		self.contentSize = _imageView.frame.size;
	}
	else if (_imageView.image.size.height > self.frame.size.height && _imageView.image.size.width <= self.frame.size.width)
	{
		int image_x = (self.frame.size.width -_imageView.image.size.width)/2.f;
		pictureRect.origin.x = 0.f + image_x;
		pictureRect.origin.y = 0.f;
		_imageView.frame = pictureRect;
		self.contentSize =_imageView.image.size;
		self.contentOffset = CGPointMake(0.f, 0.f);
		
	}
	else if (_imageView.image.size.height <= self.frame.size.height && _imageView.image.size.width > self.frame.size.width)
	{
		pictureRect.size.width = self.frame.size.width;
		pictureRect.size.height = pictureRect.size.width * _imageView.image.size.height / _imageView.image.size.width;
		_imageView.frame = pictureRect;
		_imageView.center = CGPointMake(self.width/2.f, self.height/2.f);
	}
	else
	{
		pictureRect.origin.x = 0.f;
		pictureRect.origin.y = 0.f;
		pictureRect.size.width = self.frame.size.width ;
		pictureRect.size.height = pictureRect.size.width * _imageView.image.size.height / _imageView.image.size.width;
		_imageView.frame = pictureRect;
		
		if (pictureRect.size.height < self.frame.size.height)
		{
            _imageView.center = CGPointMake(self.width/2.f, self.height/2.f);
		}
		
		self.contentSize = _imageView.frame.size;
		self.contentOffset = CGPointMake(0.f, 0.f);
	}
}


- (void)setScrollViewZoom
{
    if (self.zoomScale == 1.f)
    {
        //放大
        [self setZoomScale:2.3f animated:YES];
    }
    else
    {
        //还原
        [self setZoomScale:1.f animated:YES];
    }
}

- (void)resetImageScale
{
    [self setZoomScale:1.f animated:NO];
}


@end
