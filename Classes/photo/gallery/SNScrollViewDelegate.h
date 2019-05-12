//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SNScrollView;

@protocol SNScrollViewDelegate <NSObject>

@required

- (void)scrollView:(SNScrollView*)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex;

@optional

- (void)scrollViewWillRotate: (SNScrollView*)scrollView
               toOrientation: (UIInterfaceOrientation)orientation;

- (void)scrollViewDidRotate:(SNScrollView*)scrollView;

- (void)scrollViewWillBeginDragging:(SNScrollView*)scrollView;

- (void)scrollViewDidEndDragging:(SNScrollView*)scrollView willDecelerate:(BOOL)willDecelerate;

- (void)scrollViewWillBeginDecelerating:(SNScrollView*)scrollView;

- (void)scrollViewDidEndDecelerating:(SNScrollView*)scrollView;

- (BOOL)scrollViewShouldZoom:(SNScrollView*)scrollView;

- (void)scrollViewDidBeginZooming:(SNScrollView*)scrollView;

- (void)scrollViewDidEndZooming:(SNScrollView*)scrollView;

- (void)scrollView:(SNScrollView*)scrollView touchedDown:(UITouch*)touch;

- (void)scrollView:(SNScrollView*)scrollView touchedUpInside:(UITouch*)touch;

- (void)scrollView:(SNScrollView*)scrollView tapped:(UITouch*)touch;

- (void)scrollViewDidBeginHolding:(SNScrollView*)scrollView;

- (void)scrollViewDidEndHolding:(SNScrollView*)scrollView;

- (BOOL)scrollView:(SNScrollView*)scrollView
  shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;

- (void)scrollView:(SNScrollView*)scrollView doubleTapped:(UITouch*)touch;

@end
