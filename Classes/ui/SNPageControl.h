//
//  SNPageControl.h
//  sohunews
//
//  Created by Dan on 7/18/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNPageControlDelegate;

@interface SNPageControl : UIView 
{
@private
    NSInteger _currentPage;
    NSInteger _numberOfPages;
    UIColor *dotColorCurrentPage;
    UIColor *dotColorOtherPage;
    BOOL hidesForSinglePage;
    
    NSObject<SNPageControlDelegate> *__weak delegate;
}

// Set these to control the PageControl.
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger numberOfPages;

// Customize these as well as the backgroundColor property.
@property (nonatomic, strong) UIColor *dotColorCurrentPage;
@property (nonatomic, strong) UIColor *dotColorOtherPage;
@property (nonatomic, strong) UIImage *dotImageCurrentPage;

@property (nonatomic, assign) BOOL hidesForSinglePage;

// Optional delegate for callbacks when user taps a page dot.
@property (nonatomic, weak) NSObject<SNPageControlDelegate> *delegate;

@property (nonatomic, assign) NSTextAlignment dotsAlignment;

@end

@protocol SNPageControlDelegate<NSObject>
@optional
- (void)pageControlPageDidChange:(SNPageControl *)pageControl;
@end
