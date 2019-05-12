//
//  SNTableMoreButton.h
//  sohunews
//
//  Created by kuanxi zhu on 8/24/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SNTableMoreButton : TTTableMoreButton {
	NSString *_title;
    BOOL animating;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readwrite)BOOL animating;
@end
