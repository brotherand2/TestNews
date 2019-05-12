//
//  SNLoadingOverlay.m
//  sohunews
//
//  Created by handy wang on 8/25/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNLoadingOverlay.h"
#import "SNWaitingActivityView.h"

#define kIndicatorSize 20


@implementation SNLoadingOverlay

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];

        //Loading
        _loading = [[SNWaitingActivityView alloc] init];
        
        [_loading setFrame:CGRectMake((TTScreenBounds().size.width - kIndicatorSize) / 2, 
                                      TTScreenBounds().size.height / 3 - kIndicatorSize * 2, 
                                      kIndicatorSize, 
                                      kIndicatorSize)];
        
        [self addSubview:_loading];
        
        [_loading setHidesWhenStopped:YES];
        
        //Logo
        _logo = [[UIImageView alloc] initWithFrame:CGRectMake((TTScreenBounds().size.width - kAppLogoWidth / 2) / 2, 
                                                              (TTScreenBounds().size.height - kAppLogoHeight / 2) / 3, 
                                                              kAppLogoWidth / 2, 
                                                              kAppLogoHeight / 2)];

        [_logo setImage:[UIImage imageNamed:@"app_logo.png"]];
        
        [self addSubview:_logo];
        
    }
    
    return self;
}

- (void)setHidden:(BOOL)hidden {

    [super setHidden:hidden];
    
    if (hidden) {
        
        [_loading stopAnimating];
    
    } else {
    
        [_loading startAnimating];
    
    }

}

- (void)dealloc {
    
     //(_loading);
    
     //(_logo);


}

@end
