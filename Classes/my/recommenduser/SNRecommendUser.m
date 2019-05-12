//
//  SNRecommendUser.m
//  sohunews
//
//  Created by lhp on 6/26/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNRecommendUser.h"
#import "NSDictionaryExtend.h"

@interface SNRecommendUser ()

@end

@implementation SNRecommendUser

@synthesize headUrl = _headUrl;
@synthesize nickName = _nickName;
@synthesize pID = _pID;
@synthesize text = _text;
@synthesize gender = _gender;
@synthesize isFollowed = _isFollowed;
@synthesize signList = _signList;
- (id)initWithDictionary:(NSDictionary *) userDic{
    
    if (self = [super init]) {
        
        self.headUrl = [userDic stringValueForKey:@"headUrl" defaultValue:nil];
        self.nickName = [userDic stringValueForKey:@"nickName" defaultValue:nil];
        self.pID = [NSString stringWithFormat:@"%lld", [userDic longlongValueForKey:@"pid" defaultValue:0]];
        self.text = [userDic stringValueForKey:@"text" defaultValue:nil];
        
        NSArray* array = [userDic objectForKey:@"signList"];
        self.signList = array;
//        if(array && array.count > 0)
//        {
//            NSMutableArray* signArray = [NSMutableArray arrayWithCapacity:3];
//            for(NSDictionary* dic in array)
//            {
//                NSString* icon = [dic stringValueForKey:@"icon" defaultValue:nil];
//                if(icon.length > 0)
//                {
//                    [signArray addObject:icon];
//                }
//            }
//            self.signList = signArray;
//        }
    }
    
    return self;
}

- (void)dealloc{
    
     //(_headUrl);
     //(_nickName);
     //(_pID);
     //(_text);
     //(_signList);
}

@end
