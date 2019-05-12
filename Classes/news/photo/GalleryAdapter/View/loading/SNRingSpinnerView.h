//
//  SNRingSpinnerView.h
//  SNNewGallery
//
//  Created by H.Ekko on 03/01/2017.
//  Copyright © 2017 Huang Zhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNRingSpinnerView : UIView

@property (nonatomic, readonly) BOOL isAnimating;
@property (nonatomic) CGFloat lineWidth;

- (void)startAnimating;
- (void)stopAnimating;

@end
