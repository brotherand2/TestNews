//
//  SNTabBarItem.m
//  sohunews
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNTabBarItem.h"

@implementation SNTabBarItem

@synthesize cSelectedImage;  
@synthesize cUnselectedImage;

- (void) dealloc  
{  
     //(cSelectedImage);
     //(cUnselectedImage); 
}  

-(UIImage *) selectedImage  
{  
    return self.cSelectedImage;  
}  

-(UIImage *) unselectedImage  
{  
    return self.cUnselectedImage;  
}



@end
