//
//  SNTagButton.m
//  sohunews
//
//  Created by  on 12-3-15.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNCategoryButton.h"

@implementation SNCategoryButton

@synthesize category;

-(void)dealloc {
    TT_RELEASE_SAFELY(category);
    [super dealloc];
}

@end
