//
//  NSObject+COMPExtension.h
//  Compass
//
//  Created by 李耀忠 on 26/09/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (COMPExtension)

+ (void)comp_swizzleSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector;

#ifdef DEBUG
- (NSDictionary *)comp_getProperties;
#endif

@end
