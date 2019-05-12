//
//  SNSpecialNews.h
//  sohunews
//
//  Created by handy wang on 7/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSpecialNews : NSObject {
    int      _ID;
    NSString *_termId;
    NSString *_termName;
    NSString *_newsId;
    NSString *_newsType;
    NSString *_title;
    NSString *_pic;//可选属性
    NSArray  *_picArray;//可选属性
    NSString *_isFocusDisp;
    NSString *_abstract;//可选属性
    NSString *_link;
    NSString *_isRead;
    NSString *_form;
    NSString *_groupName;
    NSString *_hasVideo;
    NSString *_updateTime;
    NSString *_expired;
    int _type;
}

@property(nonatomic, assign)int ID;
@property(nonatomic, copy)NSString *termId;
@property(nonatomic, copy)NSString *termName;
@property(nonatomic, copy)NSString *newsId;
@property(nonatomic, copy)NSString *newsType;
@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *pic;
@property(nonatomic, strong)NSArray *picArray;
@property(nonatomic, copy)NSString *isFocusDisp;
@property(nonatomic, copy)NSString *abstract;
@property(nonatomic, copy)NSString *link;
@property(nonatomic, copy)NSString *isRead;
@property(nonatomic, copy)NSString *form;
@property(nonatomic, copy)NSString *groupName;
@property(nonatomic, copy)NSString *hasVideo;
@property(nonatomic, copy)NSString *updateTime;
@property(nonatomic, copy)NSString *expired;
@property(nonatomic, assign)NSInteger createAt;
//Transient properties
@property(nonatomic, assign)BOOL isDownloadFinished;
@property(nonatomic, assign)int type;
@end
