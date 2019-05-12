//
//  SNChannelManageObject.h
//  sohunews
//
//  Created by jojo on 13-10-15.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SNChannelManageObjTypeChannel,
    SNChannelManageObjTypeCategory,
    SNChannelManageObjTypeWeibo,
    SNChannelManageObjTypeVideo,
}
SNChannelManageObjType;

@interface SNChannelManageObject : NSObject

@property(nonatomic, copy) NSString *channelCategoryName;
@property(nonatomic, copy) NSString *channelCategoryID;
@property(nonatomic, copy) NSString *channelIconFlag;
@property(nonatomic, copy) NSString *ID;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *isSubed;
@property(nonatomic, copy) NSString *localType;
@property(nonatomic, copy) NSString *channelType;
@property(nonatomic, copy) NSString *channelViewClassString;

@property(nonatomic, assign) SNChannelManageObjType objType;
@property(nonatomic, strong) id orignalObj;
@property(nonatomic, strong) NSString *channelTop;
@property(nonatomic, assign) BOOL addNew;
@property(nonatomic, copy) NSString *serverVersion;
@property(nonatomic, copy) NSString *channelShowType;
@property(nonatomic, assign) int isMixStream;

- (id)initWithObj:(id)obj type:(SNChannelManageObjType)type;

@end
