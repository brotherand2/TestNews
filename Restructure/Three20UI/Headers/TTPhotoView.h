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

// UI
#import "TTImageView.h"
#import "TTPhotoVersion.h"
#import "TTImageViewDelegate.h"

@protocol TTPhoto;
@class TTLabel;

//add by ivan
@protocol TTPhotoViewDelegate <NSObject>
@optional
- (void)didLoadImage4ImageView:(UIView *)view;
@end

@interface TTPhotoView : TTImageView <TTImageViewDelegate> {
  id <TTPhoto>              _photo;
  UIActivityIndicatorView*  _statusSpinner;

  TTLabel* _statusLabel;
  TTLabel* _captionLabel;
//  TTStyle* _captionStyle;

  TTPhotoVersion _photoVersion;

  BOOL _hidesExtras;
  BOOL _hidesCaption;
  //add by ivan
  id <TTPhotoViewDelegate>  _photoDelegate;
  NSInteger _index;
    BOOL isError;
}

@property (nonatomic, retain) id<TTPhoto> photo;
//@property (nonatomic, retain) TTStyle*    captionStyle;
@property (nonatomic)         BOOL        hidesExtras;
@property (nonatomic)         BOOL        hidesCaption;
//add by ivan
@property (nonatomic, assign) id <TTPhotoViewDelegate>  photoDelegate;
@property (nonatomic)         NSInteger  index;
@property (nonatomic)         BOOL        isError;

- (BOOL)loadPreview:(BOOL)fromNetwork;
- (void)loadImage;

- (void)showProgress:(CGFloat)progress;
- (void)showStatus:(NSString*)text;

@end
