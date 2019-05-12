//
//  SNPromotion.h
//  sohunews
//
//  Created by yanchen wang on 12-7-6.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 
 promotions =     (
 {
 abstracts = "21 DAYS FROM THE OPENING OF THE LONDON 2012 OF OLYMPIC GAMES";
 "bg_pic" = "";
 "click_link" = "http://api.k.sohu.com/api/paper/lastTermLink.go?subId=308";
 "left_icon" = "http://cache.k.sohu.com/img8/wb/iospicon/2012/07/05/1341476965445.png";
 title = "\U8ddd\U79bb2012\U4f26\U6566\U5965\U8fd0\U4f1a\U5f00\U5e55\U8fd8\U670921\U5929";
 }
 );
 
 */
@interface SNPromotion : NSObject

@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *abstracts;
@property(nonatomic, copy)NSString *bgPicUrl;
@property(nonatomic, copy)NSString *leftIconUrl;
@property(nonatomic, copy)NSString *linkUrl;

@end
