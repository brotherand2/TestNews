//
//  SNRecommendUser.h
//  sohunews
//
//  Created by lhp on 6/26/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNRecommendUser : NSObject{
    
    NSString *_headUrl;
    NSString *_nickName;
    NSString *_pID;
    NSString *_text;
    int _gender;
    BOOL _isFollowed;
}

@property(nonatomic,strong)  NSString *headUrl;
@property(nonatomic,strong)  NSString *nickName;
@property(nonatomic,strong)  NSString *pID;
@property(nonatomic,strong)  NSString *text;
@property(nonatomic,assign)  int gender;
@property(nonatomic,assign)  BOOL isFollowed;
@property(nonatomic,strong)  NSArray* signList;

- (id)initWithDictionary:(NSDictionary *) userDic;

@end
