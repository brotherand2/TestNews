//
//  SNBaseFavouriteObject.m
//  sohunews
//
//  Created by Gao Yongyue on 13-12-6.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBaseFavouriteObject.h"
#import "SNMyFavourite.h"
#import "SNDBManager.h"
#import "SNUserManager.h"

@implementation SNBaseFavouriteObject

- (id)initWithMyFavourite:(SNMyFavourite *)myFavourite
{
    if (self = [super init])
    {
        self.title = myFavourite.title;
        self.contentLevelFirstID = myFavourite.contentLeveloneID;
        self.contentLevelSecondID = myFavourite.contentLeveltwoID;
        self.imageUrl = myFavourite.imgURL;
        self.publicationDate = myFavourite.pubDate;
        self.type = myFavourite.myFavouriteRefer;
    }
    return self;
}

- (id)initWithCloudSave:(SNCloudSave *)cloudSave
{
    if (self = [super init])
    {
        self.title = cloudSave._title;
        self.contentLevelFirstID = cloudSave._contentLeveloneID;
        self.contentLevelSecondID = cloudSave._contentLeveltwoID;
//        self.imageUrl = cloudSave._imgURL;
        self.publicationDate = cloudSave._collectTime;
        self.type = cloudSave._myFavouriteRefer;
        self.link2 = cloudSave._link;
    }
    return self;
}

- (NSMutableDictionary *)localProperties
{
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    if (_title)
    {
        properties[kContentTitle] = _title;
    }
    if (_contentLevelFirstID)
    {
        properties[kContentLevelFirstID] = _contentLevelFirstID;
    }
    if (_contentLevelSecondID)
    {
        properties[kContentLevelSecondID] = _contentLevelSecondID;
    }
    if (_publicationDate)
    {
        properties[kPublicationDate] = _publicationDate;
    }
    if (_imageUrl)
    {
        properties[kContentImageUrl] = _imageUrl;
    }
    if (_link2)
    {
        properties[kContentLink2] = _link2;
    }
    if (_templateType) {
        properties[kContentTemplateType] = _templateType;
    }
    
    properties[kContentType] = @(_type);
    
    return properties;
}

- (SNCloudSave *)cloudSaveObjectConvertedByMyFavouriteObject:(SNMyFavourite *)myFavourite
{
    if (myFavourite != nil && [myFavourite isKindOfClass:[SNMyFavourite class]])
    {
        SNCloudSave *cloudSave = [[SNCloudSave alloc] init];
        cloudSave._title = myFavourite.title;
        cloudSave._myFavouriteRefer = myFavourite.myFavouriteRefer;
        cloudSave._contentLeveloneID = myFavourite.contentLeveloneID;
        cloudSave._contentLeveltwoID = myFavourite.contentLeveltwoID;
        cloudSave._collectTime = myFavourite.pubDate;
        cloudSave._link = [self schemeFromProperties];
        cloudSave.templateType = myFavourite.templateType;
        cloudSave.showType = self.showType;
        if (myFavourite.userId)
        {
            cloudSave._userId = myFavourite.userId;
        }
        else
        {
            cloudSave._userId = [SNUserManager getUserId];
        }
        if (!myFavourite.pubDate)
        {
            NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
            cloudSave._collectTime = [NSString stringWithFormat:@"%lf", interval*1000];
        }
        return cloudSave;
    }
    else
        return nil;
}

- (SNMyFavourite *)myFavouriteObjectConvertedByCloudSaveObject:(SNCloudSave *)cloudSave
{
    if (cloudSave != nil && [cloudSave isKindOfClass:[SNCloudSave class]])
    {
        SNMyFavourite *myFavourite = [[SNMyFavourite alloc] init];
        myFavourite.title = cloudSave._title;
        myFavourite.myFavouriteRefer = cloudSave._myFavouriteRefer;
        myFavourite.contentLeveloneID = cloudSave._contentLeveloneID;
        myFavourite.contentLeveltwoID = cloudSave._contentLeveltwoID;
        myFavourite.pubDate = cloudSave._collectTime;
        myFavourite.userId = [SNUserManager getUserId];
        return myFavourite;
    }
    else
        return nil;
}

- (SNMyFavourite *)myFavouriteObjectConvertedByBaseFavouriteObject
{
    SNMyFavourite *myFavourite = [[SNMyFavourite alloc] init];
    NSMutableDictionary *propertyDict = [self localProperties];
    if (propertyDict[kContentTitle])
    {
        myFavourite.title = propertyDict[kContentTitle];
    }
    if (propertyDict[kContentLevelFirstID])
    {
        myFavourite.contentLeveloneID = propertyDict[kContentLevelFirstID];
    }
    if (propertyDict[kContentLevelSecondID])
    {
        myFavourite.contentLeveltwoID = propertyDict[kContentLevelSecondID];
    }
    if (propertyDict[kPublicationDate])
    {
        myFavourite.pubDate = propertyDict[kPublicationDate];
    }
    if (propertyDict[kContentImageUrl])
    {
        myFavourite.imgURL = propertyDict[kContentImageUrl];
    }
    if (propertyDict[kContentTemplateType]) {
        myFavourite.templateType = propertyDict[kContentTemplateType];
    }
    myFavourite.userId = [SNUserManager getUserId];
    myFavourite.myFavouriteRefer = [propertyDict[kContentType] intValue];
    return myFavourite;
}

- (SNCloudSave *)cloudSaveObjectConvertedByBaseFavouriteObject
{
    return [self cloudSaveObjectConvertedByMyFavouriteObject:[self myFavouriteObjectConvertedByBaseFavouriteObject]];
}

- (NSString *)schemeFromProperties
{
    if (_link2 && [_link2 length])
    {
        return _link2;
    }
    else
        return nil;
}

- (void)dealloc
{
    _title = nil;
    _contentLevelFirstID = nil;
    _contentLevelSecondID = nil;
    _publicationDate = nil;
    _imageUrl = nil;
}

@end
