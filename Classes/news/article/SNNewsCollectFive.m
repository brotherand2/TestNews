//
//  SNNewsCollectFive.m
//  sohunews
//
//  Created by wang shun on 2017/10/10.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsCollectFive.h"
#import "SNUserManager.h"

@interface SNNewsCollectFive ()
{
    int count;
}
@end

@implementation SNNewsCollectFive

-(instancetype)init{
    if (self = [super init]) {
        count = 5;
    }
    return self;
}

-(BOOL)save{
    if ([SNUserManager isLogin]) {   
        return NO;
    }
    else{
        NSNumber* n = [[NSUserDefaults standardUserDefaults] objectForKey:@"SNNewsCollectFive"];
        if (!n) {
            [self reset];
            return NO;
        }
        else{
            
            n = [NSNumber numberWithInt:n.integerValue+1];
            [[NSUserDefaults standardUserDefaults] setObject:n forKey:@"SNNewsCollectFive"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (n && n.integerValue >=count) {
                [self remove];
                return YES;
            }
            else if (n<=0){
                [self reset];
                return NO;
            }
            
            return NO;
        }
    }
    return NO;
}

- (void)reset{
    NSNumber* n = [NSNumber numberWithInt:1];
    [[NSUserDefaults standardUserDefaults] setObject:n forKey:@"SNNewsCollectFive"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)remove{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SNNewsCollectFive"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
