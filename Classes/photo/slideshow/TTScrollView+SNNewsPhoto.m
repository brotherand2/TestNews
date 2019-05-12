//
//  TTScrollView+SNNewsPhoto.m
//  sohunews
//
//  Created by qi pei on 5/31/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "TTScrollView+SNNewsPhoto.h"
#import "NSObject+MethodExchange.h"

//static const NSInteger kOffscreenPages = 1;
//static const CGFloat kDefaultPageSpacing = 40.0f;
static const CGFloat kFlickThreshold = 60.0f;
//static const CGFloat kTapZoom = 0.75f;
//static const CGFloat kResistance = 0.15f;
//static const NSInteger kInvalidIndex = -1;
static const NSTimeInterval kFlickDuration = 0.4;
static const NSTimeInterval kBounceDuration = 0.3;
//static const NSTimeInterval kOvershoot = 2;
static const CGFloat kIncreaseSpeed = 1.5f;    // How much increase after release touch.
// (Residual movement).
static const CGFloat kFrameDuration = 1.0/40.0f;

@implementation TTScrollView (SNNewsPhoto)

+ (void)load
{
    [self replaceMethod:@selector(touchEdgesForPoint:) withNewMethod:@selector(inner_touchEdgesForPoint:)];
    [self replaceMethod:@selector(stretchTouchEdges:toPoint:) withNewMethod:@selector(inner_stretchTouchEdges:toPoint:)];
    [self replaceMethod:@selector(touchLocation:) withNewMethod:@selector(inner_touchLocation:)];
    [self replaceMethod:@selector(removeTouch:) withNewMethod:@selector(inner_removeTouch:)];
    [self replaceMethod:@selector(endHolding) withNewMethod:@selector(inner_endHolding)];
    [self replaceMethod:@selector(startTapTimer:) withNewMethod:@selector(inner_startTapTimer:)];
    [self replaceMethod:@selector(canZoom) withNewMethod:@selector(inner_canZoom)];
    [self replaceMethod:@selector(stopDragging:) withNewMethod:@selector(inner_stopDragging:)];
    [self replaceMethod:@selector(pulled) withNewMethod:@selector(inner_pulled)];
    [self replaceMethod:@selector(pinched) withNewMethod:@selector(inner_pinched)];
    [self replaceMethod:@selector(flicked) withNewMethod:@selector(inner_flicked)];
    [self replaceMethod:@selector(flipped) withNewMethod:@selector(inner_flipped)];
    [self replaceMethod:@selector(overflowForFrame:) withNewMethod:@selector(inner_overflowForFrame:)];
    [self replaceMethod:@selector(stretchedWidth) withNewMethod:@selector(inner_stretchedWidth)];
    [self replaceMethod:@selector(zoomFactor) withNewMethod:@selector(inner_zoomFactor)];
    [self replaceMethod:@selector(frameOfPageAtIndex:) withNewMethod:@selector(inner_frameOfPageAtIndex:)];
    [self replaceMethod:@selector(pageHeight) withNewMethod:@selector(inner_pageHeight)];
    [self replaceMethod:@selector(pageWidth) withNewMethod:@selector(inner_pageWidth)];
    [self replaceMethod:@selector(pageEdgesForAnimation) withNewMethod:@selector(inner_pageEdgesForAnimation)];
    [self replaceMethod:@selector(edgesAreZoomed:) withNewMethod:@selector(inner_edgesAreZoomed:)];
    [self replaceMethod:@selector(updateZooming:) withNewMethod:@selector(inner_updateZooming:)];
    [self replaceMethod:@selector(startAnimationTo:duration:) withNewMethod:@selector(inner_startAnimationTo:duration:)];
    [self replaceMethod:@selector(isLastPage) withNewMethod:@selector(inner_isLastPage)];
    [self replaceMethod:@selector(isFirstPage) withNewMethod:@selector(inner_isFirstPage)];
}


- (BOOL)isDraggingFromEdge {
    return (_pageEdges.left < 0 && [self inner_isLastPage] && !self.zoomed)
        || (_pageEdges.left > 0 && [self inner_isFirstPage] && !self.zoomed);
}

-(NSMutableArray *)allPages {
    return _pages;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)inner_isFirstPage {
    return _centerPageIndex == 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)inner_isLastPage {
    return _centerPageIndex + 1 >= [_dataSource numberOfPagesInScrollView:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    [super touchesEnded:touches withEvent:event];
    TT_INVALIDATE_TIMER(_holdingTimer);
    if (_holding) {
        [self inner_endHolding];
    }
    
    for (UITouch* touch in touches) {
        if (touch == _touch1 || touch == _touch2) {
            UITouch* remainingTouch = [self inner_removeTouch:touch];
            
            if (_touchCount == 1) {
                CGPoint point = [self inner_touchLocation:remainingTouch];
                _touchEdges = _touchStartEdges = [self inner_touchEdgesForPoint:point];
                _pageStartEdges = _pageEdges;
                _renewPosition = CGPointMake(_touchEdges.left, _touchEdges.top);
                _executingZoomGesture = NO;
                
            } else if (_touchCount == 0) {
                
                if (touch.tapCount == 1 && !_dragging) {
                    _executingZoomGesture = NO;
                    if ([_delegate respondsToSelector:@selector(scrollView:touchedUpInside:)]) {
                        [_delegate scrollView:self touchedUpInside:touch];
                    }
                    
                    [self inner_startTapTimer:touch];
                    
                    // Double tap, zoom out to fit or zoom in to the 1/3 of the maximum scale.
                    
                } else if (touch.tapCount == 2 && self.inner_canZoom) {
                    CGPoint pointToZoom = [self inner_touchLocation:touch];
                    
                    if (self.zoomed) {
                        [self zoomToFit];
                        
                    } else {
                        [self setZoomScale:_maximumZoomScale / 1.3  withPoint:pointToZoom animated:YES];
                    }
                    
                    //关闭触发双击事件，可用于关闭看图
                    
//                    if ([_delegate respondsToSelector:@selector(scrollView:doubleTapped:)]) {
//                        [_delegate scrollView:self doubleTapped:touch];
//                    }
                }
                
                // The scroll view will continue to move a short distance afterwards.
                // If are zoomed, will still moving after stop drag. Short distance, doesn't animate.
                if (_touchCount == 0 && self.scrollEnabled
                    && self.zoomed && abs(_inertiaSpeed.x) >= 1 && abs(_inertiaSpeed.y) >= 1) {
                    // Increase speed. (Longer residual movement).
                    _inertiaSpeed.x *= kIncreaseSpeed;
                    _inertiaSpeed.y *= kIncreaseSpeed;
                    
                    // Store actual Page Edges.
                    _pageStartEdges = _pageEdges;
                    
                    // Warn delegate.
                    if ([_delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
                        [_delegate scrollViewWillBeginDecelerating:self];
                    }
                    
                    // Start Animation Timer.
                    if (!_animationTimer) {
                        _decelerating = YES;
                        
                        TT_INVALIDATE_TIMER(_tapTimer);
                        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:kFrameDuration target:self
                                                                         selector:@selector(inertiaAnimator) userInfo:nil repeats:YES];
                    }
                }
                
                [self inner_stopDragging:YES];
            }
            
            if ((self.inner_pinched || (_touchCount == 0 && self.inner_pulled)) && self.scrollEnabled) {
                UIEdgeInsets edges = [self inner_pageEdgesForAnimation];
                NSTimeInterval dur = self.inner_flicked ? kFlickDuration : kBounceDuration;
                //_overshoot = kOvershoot;
                [self inner_startAnimationTo:edges duration:dur];
            }
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)inner_startAnimationTo:(UIEdgeInsets)edges duration:(NSTimeInterval)duration {
    if (!_animationTimer) {
        _pageStartEdges = _pageEdges;
        [self inner_updateZooming:edges];
        TT_INVALIDATE_TIMER(_tapTimer);
        
        _animateEdges = edges;
        _animationDuration = duration;
        _animationStartTime = [[NSDate date] retain];
        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:kFrameDuration target:self
                                                         selector:@selector(animator) userInfo:nil repeats:YES];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)inner_updateZooming:(UIEdgeInsets)edges {
    if (!_zooming && (self.zoomed || [self inner_edgesAreZoomed:edges])) {
        _zooming = YES;
        self.centerPage.userInteractionEnabled = NO;
        
        if ([_delegate respondsToSelector:@selector(scrollViewDidBeginZooming:)]) {
            [_delegate scrollViewDidBeginZooming:self];
        }
        
    } else if (_zooming && !self.zoomed) {
        _zooming = NO;
        self.centerPage.userInteractionEnabled = YES;
        
        if ([_delegate respondsToSelector:@selector(scrollViewDidEndZooming:)]) {
            [_delegate scrollViewDidEndZooming:self];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)inner_edgesAreZoomed:(UIEdgeInsets)edges {
    return edges.left != edges.right || edges.top != edges.bottom;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)inner_pageEdgesForAnimation {
    CGFloat left = 0, right = 0, top = 0, bottom = 0;
    
    if (self.inner_pinched) {
        left = -_pageEdges.left;
        right = -_pageEdges.right;
        top = -_pageEdges.top;
        bottom = -_pageEdges.bottom;
        
    } else if (self.inner_flicked) {
        CGRect centerFrame = [self inner_frameOfPageAtIndex:_centerPageIndex];
        CGFloat centerPageOverflow = [self inner_overflowForFrame:centerFrame] * self.inner_zoomFactor;
        
        if (_pageEdges.left < 0) {
            CGRect frame = [self inner_frameOfPageAtIndex:_centerPageIndex + (self.inner_flipped ? -1 : 1)];
            CGFloat overflow = centerPageOverflow + [self inner_overflowForFrame:frame];
            if (fabs(_pageStartEdges.left) >= fabs(_pageEdges.right)) {
                left = right = -((self.inner_pageWidth + _pageSpacing)
                                 + _pageEdges.right + _overshoot + overflow);
                
            } else {
                left = right = -((self.inner_pageWidth + _pageSpacing)
                                 + _pageEdges.left + _overshoot + overflow);
            }
            
        } else {
            CGRect frame = [self inner_frameOfPageAtIndex:_centerPageIndex + (self.inner_flipped ? 1 : -1)];
            CGFloat overflow = centerPageOverflow + [self inner_overflowForFrame:frame];
            if (fabs(_pageEdges.left) >= fabs(_pageEdges.right)) {
                left = right = ((self.inner_pageWidth + _pageSpacing)
                                - _pageEdges.right + _overshoot + overflow);
                
            } else {
                left = right = ((self.inner_pageWidth + _pageSpacing)
                                - _pageEdges.left + _overshoot + overflow);
            }
        }
        
    } else {
        if (_pageEdges.left > 0) {
            left = right = -_pageEdges.left;
            
        } else if (_pageEdges.right < 0) {
            left = right = -_pageEdges.right;
        }
        
        if (_pageEdges.top > 0) {
            top = bottom = -_pageEdges.top;
            
        } else if (_pageEdges.bottom < 0) {
            top = bottom = -_pageEdges.bottom;
        }
    }
    
    return UIEdgeInsetsMake(top, left, bottom, right);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)inner_pageWidth {
    if (UIInterfaceOrientationIsLandscape(_orientation)) {
        return self.height;
        
    } else {
        return self.width;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)inner_pageHeight {
    if (UIInterfaceOrientationIsLandscape(_orientation)) {
        return self.width;
        
    } else {
        return self.height;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)inner_frameOfPageAtIndex:(NSInteger)pageIndex {
    CGSize size;
    if ([_dataSource respondsToSelector:@selector(scrollView:sizeOfPageAtIndex:)]) {
        size = [_dataSource scrollView:self sizeOfPageAtIndex:pageIndex];
        if (0 == size.width || 0 == size.height) {
            size = CGSizeMake(self.inner_pageWidth, self.inner_pageHeight);
        }
        
    } else {
        size = CGSizeMake(self.inner_pageWidth, self.inner_pageHeight);
    }
    
    CGFloat width, height;
    if (UIInterfaceOrientationIsLandscape(_orientation)) {
        if (size.width / size.height > self.width / self.height) {
            height = self.height;
            width = size.height/size.width * self.height;
            
        } else {
            height = size.width/size.height * self.width;
            width = self.width;
        }
        
    } else {
        if (size.width / size.height > self.width / self.height) {
            width = self.width;
            height = size.height/size.width * self.width;
            
        } else {
            width = size.width/size.height * self.height;
            height = self.height;
        }
    }
    
    CGFloat xd = width - self.width;
    CGFloat yd = height - self.height;
    return CGRectMake(-xd/2, -yd/2, width, height);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)inner_zoomFactor {
    return self.inner_stretchedWidth / self.inner_pageWidth;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(CGFloat)inner_stretchedWidth {
    return -_pageEdges.left + self.inner_pageWidth + _pageEdges.right;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)inner_overflowForFrame:(CGRect)frame {
    if (UIInterfaceOrientationIsLandscape(_orientation)) {
        return frame.origin.y < 0 ? fabs(frame.origin.y) : 0;
        
    } else {
        return frame.origin.x < 0 ? fabs(frame.origin.x) : 0;
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)inner_flipped {
    return _orientation == UIInterfaceOrientationLandscapeLeft
    || _orientation == UIInterfaceOrientationPortraitUpsideDown;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)inner_flicked {
    if (!self.inner_flipped) {
        if (_pageEdges.left > kFlickThreshold && ![self inner_isFirstPage]) {
            return YES;
            
        } else if (_pageEdges.right < -kFlickThreshold && ![self inner_isLastPage]) {
            return YES;
            
        } else {
            return NO;
        }
        
    } else {
        if (_pageEdges.left > kFlickThreshold && ![self inner_isLastPage]) {
            return YES;
            
        } else if (_pageEdges.right < -kFlickThreshold && ![self inner_isFirstPage]) {
            return YES;
            
        } else {
            return NO;
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)inner_pinched {
    return -_pageEdges.left + _pageEdges.right < 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)inner_pulled {
    return _pageEdges.left > 0 || _pageEdges.top > 0
    || _pageEdges.right < 0 || _pageEdges.bottom < 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)inner_stopDragging:(BOOL)willDecelerate {
    if (_dragging) {
        _dragging = NO;
        
        if ([_delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
            [_delegate scrollViewDidEndDragging:self willDecelerate:willDecelerate];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)inner_canZoom {
    return _zoomEnabled && !_holding
    && (_zooming || ![_delegate respondsToSelector:@selector(scrollViewShouldZoom:)]
        || [_delegate scrollViewShouldZoom:self]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)inner_startTapTimer:(UITouch*)touch {
    _tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(tapTimer:)
                                               userInfo:touch repeats:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)inner_endHolding {
    _holding = NO;
    
    if ([_delegate respondsToSelector:@selector(scrollViewDidEndHolding:)]) {
        [_delegate scrollViewDidEndHolding:self];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITouch*)inner_removeTouch:(UITouch*)touch {
    if (touch == _touch1) {
        TT_RELEASE_SAFELY(_touch1);
        --_touchCount;
        return _touch2;
        
    } else if (touch == _touch2) {
        TT_RELEASE_SAFELY(_touch2);
        --_touchCount;
        return _touch1;
        
    } else {
        return nil;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Get the location of the touch by taking into account the orientation.
 * In landscape mode, the x and y values are flipped.
 */
- (CGPoint)inner_touchLocation:(UITouch*)touch {
    CGPoint point = [touch locationInView:self];
    if (UIInterfaceOrientationIsLandscape(_orientation)) {
        return CGPointMake(point.y, point.x);
        
    } else {
        return point;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)inner_stretchTouchEdges:(UIEdgeInsets)edges toPoint:(CGPoint)point {
    UIEdgeInsets newEdges = edges;
    if (!edges.left || point.x < edges.left) {
        newEdges.left = point.x;
    }
    if (!edges.right || point.x > edges.right) {
        newEdges.right = point.x;
    }
    if (!edges.top || point.y < edges.top) {
        newEdges.top = point.y;
    }
    if (!edges.bottom || point.y > edges.bottom) {
        newEdges.bottom = point.y;
    }
    
    return newEdges;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)inner_touchEdgesForPoint:(CGPoint)point {
    return [self inner_stretchTouchEdges:UIEdgeInsetsZero toPoint:point];
}




@end
