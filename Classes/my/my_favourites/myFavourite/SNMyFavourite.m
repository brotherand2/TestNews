//
//  SNMyFavourite.m
//  sohunews
//
//  Created by handy wang on 8/7/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNMyFavourite.h"
#import "SNDBManager.h"
#import "SNDatabase_SubscribeCenter.h"
#import "SNEncryptManager.h"

@implementation SNMyFavourite

@synthesize ID                  = _ID;
@synthesize title               = _title;
@synthesize imgURL              = _imgURL;
@synthesize myFavouriteRefer    = _myFavouriteRefer;
@synthesize contentLeveloneID   = _contentLeveloneID;
@synthesize contentLeveltwoID   = _contentLeveltwoID;
@synthesize isRead              = _isRead;
@synthesize pubDate             = _pubDate;
@synthesize isEditMode = _isEditMode;
@synthesize isSelected = _isSelected;
@synthesize userId = _userId;

- (id)init {
    
    if (self = [super init]) {
        
        _myFavouriteRefer = MYFAVOURITE_REFER_NONE;
        
        _isEditMode = NO;
        
        _isSelected = NO;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    
	SNMyFavourite *newPO = [[[self class] alloc] init];
    
	newPO.ID = self.ID;

    newPO.title = self.title;
    
    newPO.imgURL = self.imgURL;
    
    newPO.myFavouriteRefer = self.myFavouriteRefer;
    
    newPO.contentLeveloneID = self.contentLeveloneID;
    
    newPO.contentLeveltwoID = self.contentLeveltwoID;
    
    newPO.isRead = self.isRead;
    
    newPO.pubDate = self.pubDate;
    
    newPO.isEditMode = self.isEditMode;
    
    newPO.isSelected = self.isSelected;
    
    newPO.userId = self.userId;
    
    newPO.templateType = self.templateType;
    
	return newPO;
}

- (NSString *)description {
    NSMutableString *_descriptionStr = [NSMutableString string];
    
    [_descriptionStr appendFormat:@"{ID: %ld", (long)_ID];
    [_descriptionStr appendFormat:@", title: %@", _title];
    [_descriptionStr appendFormat:@", imgURL: %@", _imgURL];
    [_descriptionStr appendFormat:@", myFavouriteRefer: %d", _myFavouriteRefer];
    [_descriptionStr appendFormat:@", contentLeveloneID: %@", _contentLeveloneID];
    [_descriptionStr appendFormat:@", contentLeveltwoID: %@", _contentLeveltwoID];
    [_descriptionStr appendFormat:@", isRead: %@", _isRead];
    [_descriptionStr appendFormat:@", pubDate: %@", _pubDate];
    [_descriptionStr appendFormat:@", isEditMode: %d", _isEditMode];
    [_descriptionStr appendFormat:@", isSelected: %d}", _isSelected];
    [_descriptionStr appendFormat:@", userid: %@}", _userId];
    [_descriptionStr appendFormat:@", templateType: %@}", _templateType];
    return _descriptionStr;
}

- (void)dealloc {
    
     //(_title);
     //(_imgURL);
     //(_contentLeveloneID);
     //(_contentLeveltwoID);
     //(_isRead);
     //(_pubDate);
     //(_userId);
     //(_templateType);
}

+(NSString*)generCloudLinkEx:(MYFAVOURITE_REFER)myFavouriteRefer contentLeveloneID:(NSString*)contentLeveloneID contentLeveltwoID:(NSString*)contentLeveltwoID showType:(NSString *)showType
{
    NSMutableString* link = [NSMutableString stringWithCapacity:0];

    if(contentLeveloneID!=nil && contentLeveltwoID!=nil)
    {
        switch (myFavouriteRefer)
        {
            case MYFAVOURITE_REFER_PUB_HOME: //打开收藏的刊物
            {
                NSString* pubIdEx = [contentLeveloneID stringByReplacingOccurrencesOfString:@"," withString:@"_"]; //PubId可能携带逗号，但是与服务器的分割符冲突了
                NSArray *propertyArray = [contentLeveltwoID componentsSeparatedByString:@"#"];
                if ([propertyArray count]==2)
                {
                    link = [NSMutableString stringWithFormat:@"paper://pubId=%@&subId=%@&termId=%@",pubIdEx,propertyArray[1],propertyArray[0]];
                }
                break;
            }
                
            case MYFAVOURITE_REFER_NEWS_IN_PUB: //打开收藏的刊物中的新闻最终页
            {
                link = [NSMutableString stringWithFormat:@"news://termId=%@&newsId=%@",contentLeveloneID,contentLeveltwoID];
                break;
            }
            case MYFAVOURITE_REFER_RECOMMEND_NEWS_IN_CHANNEL:
            case MYFAVOURITE_REFER_NEWS_IN_ROLLINGNEWS: //打开频道新闻中的新闻最终页
            {
                if (showType.length > 0) {
                    link = [NSMutableString stringWithFormat:@"news://newsId=%@&showType=%@",contentLeveltwoID, showType];
                }
                else {
                    link = [NSMutableString stringWithFormat:@"news://newsId=%@",contentLeveltwoID];
                }
                break;
            }
            case MYFAVOURITE_REFER_NEWS_IN_ROLLINGNEWSJOKE: //打开频道新闻中的段子
            {
                link = [NSMutableString stringWithFormat:@"joke://newsId=%@",contentLeveltwoID];
                break;
            }
            case MYFAVOURITE_REFER_NEWS_IN_ROLLINGNEWSNEWVIDEO:
            {
                link = [NSMutableString stringWithFormat:@"%@",contentLeveltwoID];
                break;
            }
                
            case MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_PUB: //打开收藏的刊物组图列表
            {
                link = [NSMutableString stringWithFormat:@"photo://termId=%@&newsId=%@",contentLeveloneID,contentLeveltwoID];
                break;
            }
            case MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS: //打开收藏的滚动新闻组图列表
            {
                if(contentLeveloneID==nil || [contentLeveloneID isEqualToString:kCorpusNewsGidExist])
                    link = [NSMutableString stringWithFormat:@"photo://gid=%@",contentLeveltwoID];
                else
                    link = [NSMutableString stringWithFormat:@"photo://channelId=%@&newsId=%@",contentLeveloneID,contentLeveltwoID];
                break;
            }
            case MYFAVOURITE_REFER_GROUPPHOTOSLIDE_FROM_PUB_MAG_HOME: //打开收藏的画报PhotoSlideshow
            {
                if(contentLeveloneID==nil || [contentLeveloneID isEqualToString:@"0"])
                    link = [NSMutableString stringWithFormat:@"photo://gid=%@",contentLeveltwoID];
                else
                    link = [NSMutableString stringWithFormat:@"photo://termId=%@&newsId=%@",contentLeveloneID,contentLeveltwoID];
                break;
            }
                
            case MYFAVOURITE_REFER_GROUPPHOTOSLIDE_FROM_PUB_PHOTOLIST: //打开收藏的刊物组图列表下的PhotoSlideshow
            case MYFAVOURITE_REFER_GROUPPHOTOSLIDE_FROM_ROLLINGNEWS_PHOTOLIST: //打开收藏的滚动新闻组图列表下的PhotoSlideshow
            case MYFAVOURITE_REFER_GROUPPHOTOSLIDE_FROM_GROUPPHOTOTAB_CATEGORY: //打开收藏的分类组图下的PhotoSlideshow
            case MYFAVOURITE_REFER_GROUPPHOTOSLIDE_FROM_GROUPPHOTOTAB_TAG: //打开收藏的标签组图下的PhotoSlideshow
            case MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_CHANNEL://频道新闻里的组图
            {
                link = [NSMutableString stringWithFormat:@"photo://gid=%@",contentLeveltwoID];
                break;
            }
                
            case MYFAVOURITE_REFER_WEIBO_HOT: // 打开收藏的微热议 - add by jojo
            {
                link = [NSMutableString stringWithFormat:@"weibo://rootId=%@",contentLeveltwoID];
                break;
            }
#ifdef SHARE_SPECIAL_NEWS
            case MYFAVOURITE_REFER_SPECAIL: // 打开收藏专题
            {
                link = [NSString stringWithFormat:@"special://termId=%@",contentLeveltwoID];
                break;
            }
#endif
            case MYFAVOURITE_REFER_NONE:
            {
                if(contentLeveloneID==nil || [contentLeveloneID isEqualToString:@"0"])
                    link = [NSMutableString stringWithFormat:@"photo://gid=%@",contentLeveltwoID];
                break;
            }
            case MYFAVOURITE_REFER_VIDEO:
            {
                if (contentLeveloneID)
                {
                    link = [NSMutableString stringWithFormat:@"video://mid=%@",contentLeveltwoID];
                }
                break;
            }
            case MYFAVOURITE_REFER_VIDEOMEDIA:
            {
                if (contentLeveloneID && contentLeveltwoID)
                {
                    link = [NSMutableString stringWithFormat:@"videoMedia://columnId=%@&subId=%@",contentLeveloneID,contentLeveltwoID];
                }
                break;
            }
            default:
            {
                break;
            }
        }
    }
    
    return link;
}

+(SNMyFavourite*)generateMyFavFromSNCloudSave:(SNCloudSave*)aCloudSave
{
    if(aCloudSave==nil || ![aCloudSave isKindOfClass:[SNCloudSave class]])
        return nil;
    else
    {
        SNMyFavourite* myFavourite = [[SNMyFavourite alloc] init];
        myFavourite.title = aCloudSave._title;
        myFavourite.myFavouriteRefer = aCloudSave._myFavouriteRefer;
        myFavourite.contentLeveloneID = aCloudSave._contentLeveloneID;
        myFavourite.contentLeveltwoID = aCloudSave._contentLeveltwoID;
        myFavourite.pubDate = aCloudSave._collectTime;
        return myFavourite;
    }
}

-(NSString*)generCloudLink
{
    return [SNMyFavourite generCloudLinkEx:_myFavouriteRefer contentLeveloneID:_contentLeveloneID contentLeveltwoID:_contentLeveltwoID showType:_showType];
}

-(BOOL)isEqual:(id)object
{
    if(object!=nil && [object isKindOfClass:[SNMyFavourite class]])
    {
        SNMyFavourite* myFav = (SNMyFavourite*)object;
        if(self.myFavouriteRefer==myFav.myFavouriteRefer && [self.contentLeveloneID isEqualToString:myFav.contentLeveloneID] && [self.contentLeveltwoID isEqualToString:myFav.contentLeveltwoID])
            return YES;
    }
    
    //Default
    return NO;
}
@end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation SNCloudSave
@synthesize _ID,_userId = _userid;
@synthesize _title,_link,_collectTime = _collecttime;
@synthesize isEditMode = _isEditMode;
@synthesize isSelected = _isSelected;
@synthesize _contentLeveloneID,_contentLeveltwoID;
@synthesize _myFavouriteRefer;

-(id)init
{
    if(self = [super init])
    {
    }    
    return self;
}

-(id)copyWithZone:(NSZone*)zone
{
	SNCloudSave* newPO = [[[self class] alloc] init];
    newPO._ID = self._ID;
	newPO._title = self._title;
    newPO._link = self._link;
    newPO._collectTime = self._collectTime;
    newPO._userId = self._userId;
    newPO.templateType = self.templateType;
	return newPO;
}

- (NSString *)description
{
    NSMutableString *_descriptionStr = [NSMutableString string];
    [_descriptionStr appendFormat:@"{_ID: %ld", (long)_ID];
    [_descriptionStr appendFormat:@"{_title: %@", _title];
    [_descriptionStr appendFormat:@"{_link: %@", _link];
    [_descriptionStr appendFormat:@"{_collectTime: %@", _collecttime];
    [_descriptionStr appendFormat:@"{templateType: %@", _templateType];
    [_descriptionStr appendFormat:@", userId: %@}", _userid];
    return _descriptionStr;
}

-(void)dealloc
{    
     //(_title);
     //(_link);
     //(_collecttime);
     //(_userid);
     //(_contentLeveloneID);
     //(_contentLeveltwoID);
     //(_templateType);
}

-(NSString*)generCloudLink
{
    return [SNMyFavourite generCloudLinkEx:_myFavouriteRefer contentLeveloneID:_contentLeveloneID contentLeveltwoID:_contentLeveltwoID showType:_showType];
}

-(BOOL)parserLink
{    
    if(_link!=nil && [_link length]>0)
    {
        NSDictionary* dictionary = [SNEncryptManager dictionaryFromQuery:_link usingEncoding:NSASCIIStringEncoding];
        if(dictionary!=nil)
        {
            NSString* protocol = (NSString*)[dictionary objectForKey:@"_protocol_"];
            
            if(protocol==nil)
            {
                //无法解析到协议头
            }
            else if([protocol isEqualToString:@"news:"]) //news://channelId=1&newsId=5006336
            {
                NSString* channelId = [dictionary objectForKey:@"channelId"];
                NSString* termId = [dictionary objectForKey:@"termId"];
                self._contentLeveltwoID = [dictionary objectForKey:@"newsId"];

                if(termId!=nil && [termId length]>0 && self._contentLeveltwoID!=nil)
                {
                    self._contentLeveloneID = termId;
                    self._myFavouriteRefer = MYFAVOURITE_REFER_NEWS_IN_PUB;
                    return YES;
                }
                else if(channelId!=nil && [channelId length]>0 && self._contentLeveltwoID!=nil)
                {
                    self._contentLeveloneID = channelId;
                    self._myFavouriteRefer = MYFAVOURITE_REFER_NEWS_IN_ROLLINGNEWS;
                    return YES;
                }
                //纯推荐来的
                else {
                    self._contentLeveloneID = @"0";//由于云收藏不存channelId，此处占位而已，跳过nil判断
                    self._myFavouriteRefer = MYFAVOURITE_REFER_NEWS_IN_ROLLINGNEWS;
                    return YES;
                }
            }
            else if([protocol isEqualToString:@"photo:"]) //photo://termId=16152&newsId=2855510 或者 photo://gid=60361
            {
                NSString* channelId = [dictionary objectForKey:@"channelId"];
                NSString* termId = [dictionary objectForKey:@"termId"];
                NSString* newid = [dictionary objectForKey:@"newsId"];
                NSString* gid = [dictionary objectForKey:@"gid"];
                
                if(termId!=nil && [termId length]>0 && newid!=nil) //看看是不是photo://termId=16152&newsId=2855510
                {
                    self._contentLeveloneID = termId;
                    self._contentLeveltwoID = newid;
                    
                    if(self._contentLeveloneID!=nil && self._contentLeveltwoID!=nil)
                    {
                        self._myFavouriteRefer = MYFAVOURITE_REFER_GROUPPHOTOSLIDE_FROM_PUB_MAG_HOME;
                        return YES;
                    }
                }
                else if(channelId!=nil && [channelId length]>0 && newid!=nil) //看看是不是photo://channelId=16152&newsId=2855510
                {
                    self._contentLeveloneID = channelId;
                    self._contentLeveltwoID = newid;
                    
                    if(self._contentLeveloneID!=nil && self._contentLeveltwoID!=nil)
                    {
                        self._myFavouriteRefer = MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS;
                        return YES;
                    }
                }
                else if(gid!=nil) //看看是不是photo://gid=60361
                {
                    self._contentLeveltwoID = gid;
                    
                    if(self._contentLeveltwoID!=nil)
                    {
                        self._contentLeveloneID= @"0";
                        self._myFavouriteRefer = MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_CHANNEL;
                        return YES;
                    }
                }
                else if(newid != nil)//新加格式：photo://newsId=47988220
                {
                    self._contentLeveltwoID = newid;
                    if(self._contentLeveltwoID!=nil)
                    {
                        self._contentLeveloneID= @"0";
                        self._myFavouriteRefer = MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_CHANNEL;
                        return YES;
                    }
                }
            }
            else if([protocol isEqualToString:@"weibo:"]) //weibo://rootId=111
            {
                self._contentLeveltwoID = [dictionary objectForKey:@"rootId"];;
                
                if(self._contentLeveltwoID!=nil)
                {
                    self._contentLeveloneID= @"0";
                    self._myFavouriteRefer = MYFAVOURITE_REFER_WEIBO_HOT;
                    return YES;
                }
            }
#ifdef SHARE_SPECIAL_NEWS
            else if([protocol isEqualToString:@"special:"]) //weibo://rootId=111
            {
                self._contentLeveltwoID = [dictionary objectForKey:@"termId"];;
                
                if(self._contentLeveltwoID!=nil)
                {
                    self._contentLeveloneID= @"0";
                    self._myFavouriteRefer = MYFAVOURITE_REFER_SPECAIL;
                    return YES;
                }
            }
#endif
            else if([protocol isEqualToString:@"paper:"]) //paper://subId=107&pubId=1&termId=36567
            {
                self._contentLeveltwoID = [dictionary objectForKey:@"termId"];
                NSString* pubId = [dictionary objectForKey:@"pubId"];
                if(pubId!=nil)
                {
                    NSString* pubIdEx = [pubId stringByReplacingOccurrencesOfString:@"_" withString:@","]; //PubId可能携带逗号，但是与服务器的分割符冲突了
                    self._contentLeveloneID = pubIdEx;
                }
                
                if(self._contentLeveloneID!=nil && self._contentLeveltwoID!=nil)
                {
                    self._myFavouriteRefer = MYFAVOURITE_REFER_PUB_HOME;
                    return YES;
                }
            }
            else if ([protocol isEqualToString:@"videoNews:"])
            {
                self._contentLeveltwoID = _link;
                self._contentLeveloneID = @"1";
                self._myFavouriteRefer = MYFAVOURITE_REFER_NEWS_IN_ROLLINGNEWSNEWVIDEO;
                return YES;
            }
            else if ([protocol isEqualToString:@"video:"])
            {
                self._contentLeveltwoID = dictionary[@"mid"];
                self._contentLeveloneID = @"100";
                self._myFavouriteRefer = MYFAVOURITE_REFER_VIDEO;
                return YES;
            }
            else if ([protocol isEqualToString:@"videoMedia:"])
            {
                self._contentLeveloneID = dictionary[@"columnId"];
                self._contentLeveltwoID = dictionary[@"subId"];
                self._myFavouriteRefer = MYFAVOURITE_REFER_VIDEOMEDIA;
                return YES;
            }
        }
    }

    //无法识别
    self._contentLeveloneID = nil;
    self._contentLeveltwoID = nil;
    self._myFavouriteRefer = MYFAVOURITE_REFER_NONE;
    return NO;
}
@end
