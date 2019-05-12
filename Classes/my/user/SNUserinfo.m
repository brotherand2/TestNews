//
//  SNUserinfo.m
//  sohunews
//
//  Created by Diaochunmeng on 12-11-16.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNUserinfo.h"
#import "SNUserinfoMediaObject.h"
#import "NSDictionaryExtend.h"
#import "NSObject+YAJL.h"
#import "SNUserUtility.h"

@implementation SNUserItem
@synthesize _imageUrl,_imageUrlhl,_imageUrlNight,_imageUrlNighthl;
@synthesize _name;
@synthesize _link;


-(id)init
{
	if(self=[super init])
	{
	}
	return self;
}

-(id)copyWithZone:(NSZone*)zone
{
	SNUserItem* newObj = [[SNUserItem alloc] init];
    newObj._imageUrl = self._imageUrl;
    newObj._imageUrlhl = self._imageUrlhl;
    newObj._imageUrlNight = self._imageUrlNight;
    newObj._imageUrlNighthl = self._imageUrlNighthl;
    newObj._name = self._name;
    newObj._link = self._link;
	return newObj;
}


-(NSData*)getData
{
	return [NSKeyedArchiver archivedDataWithRootObject:self];
}

+(id)userinfoData:(NSData*)data
{
	if (data == nil)
    {
		return nil;
	}
	return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

//Saving a class in NSUserDefaults
-(void)encodeWithCoder:(NSCoder*)encoder
{
    //Encode properties, other class variables, etc
	[encoder encodeObject:self._imageUrl forKey:@"imageUrl"];
    [encoder encodeObject:self._imageUrlhl forKey:@"imageUrlhl"];
    [encoder encodeObject:self._imageUrlNight forKey:@"imageUrlNight"];
    [encoder encodeObject:self._imageUrlNighthl forKey:@"imageUrlNighthl"];
    [encoder encodeObject:self._name forKey:@"name"];
	[encoder encodeObject:self._link forKey:@"link"];
}

-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super init];
	if( self != nil )
	{
        //decode properties, other class vars
		self._imageUrl = [decoder decodeObjectForKey:@"imageUrl"];
        self._imageUrlhl = [decoder decodeObjectForKey:@"imageUrlhl"];
        self._imageUrlNight = [decoder decodeObjectForKey:@"imageUrlNight"];
        self._imageUrlNighthl = [decoder decodeObjectForKey:@"imageUrlNighthl"];
        self._name = [decoder decodeObjectForKey:@"name"];
		self._link = [decoder decodeObjectForKey:@"link"];;
	}
	return self;
}
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SNUserinfo
@synthesize uid = _uid;
@synthesize userName = _userName;
@synthesize password = _password;
@synthesize nickName = _nickName;
@synthesize headImageUrl = _headImageUrl;
@synthesize cookieName = _cookieName;
@synthesize cookieValue = _cookieValue;
@synthesize date = _date;
@synthesize itemArray = _itemArray;
@synthesize flushCodeUrl = _flushCodeUrl;
@synthesize isSelf = _isSelf;
@synthesize token = _token;
@synthesize pid = _pid;

-(void)dealloc
{
     //(_uid);
     //(_userName);
     //(_password);
     //(_nickName);
     //(_headImageUrl);
     //(_cookieName);
     //(_cookieValue);
     //(_date);
     //(_itemArray);
     //(_flushCodeUrl);
     //(_token);
     //(_pid);
}

-(id)init
{
	if(self=[super init])
	{
        self.itemArray = [NSMutableArray arrayWithCapacity:0];
	}
	return self;
}

-(id)copyWithZone:(NSZone*)zone
{
    //SNUserinfo* newObj = NSCopyObject(self, 0, zone);
    SNUserinfo* newObj = [[[self class] alloc] init];
    newObj.uid = self.uid;
    newObj.isSelf = self.isSelf;
    newObj.userName = self.userName;
    newObj.password = self.password;
    newObj.nickName = self.nickName;
    newObj.headImageUrl = self.headImageUrl;
    newObj.cookieName = self.cookieName;
    newObj.cookieValue = self.cookieValue;
    newObj.date = self.date;
    newObj.itemArray = [self.itemArray copyWithZone:zone];
    newObj.flushCodeUrl = self.flushCodeUrl;
    
    if(newObj.itemArray==nil)
        newObj.itemArray = [NSMutableArray arrayWithCapacity:10];
    else
        newObj.itemArray = [NSMutableArray arrayWithArray:newObj.itemArray];
    
    newObj.token = self.token;
    newObj.pid = self.pid;
    return newObj;
}

-(NSData*)getData
{
	return [NSKeyedArchiver archivedDataWithRootObject:self];
}

+(id)userinfo
{
    NSData* encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"SNUserinfoject"];
    SNUserinfo* obj = (SNUserinfo*)[SNUserinfo userinfoData:encodedObject];
    obj.isSelf = YES;
    return obj;
}

+(id)userinfoData:(NSData*)data
{
	if (data == nil)
    {
		return nil;
	}
	return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (BOOL)hasAlreadyLogin {
    // main passport
    SNUserinfoEx *userInfo = [SNUserinfoEx userinfoEx];
    return (userInfo && ([[userInfo getUsername] length] > 0));
}

+(NSString*)pid
{
    SNUserinfoEx *userInfo = [SNUserinfoEx userinfoEx];
    return userInfo.pid;
}

+(BOOL)saveUserinfo:(SNUserinfo*)aUserinfo
{
    if(aUserinfo==nil)
        return NO;
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kUserExpire];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SNUserinfoject"];
        [[NSUserDefaults standardUserDefaults] setObject:[aUserinfo getData] forKey:@"SNUserinfoject"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
}

//Saving a class in NSUserDefaults
-(void)encodeWithCoder:(NSCoder*)encoder
{
    //Encode properties, other class variables, etc
	[encoder encodeObject:self.uid forKey:@"uid"];
    [encoder encodeObject:self.userName forKey:@"username"];
	[encoder encodeObject:self.password forKey:@"password"];
    [encoder encodeObject:self.nickName forKey:@"nickname"];
    [encoder encodeObject:self.cookieName forKey:@"cookiename"];
    [encoder encodeObject:self.cookieValue forKey:@"cookievalue"];
	[encoder encodeObject:self.headImageUrl forKey:@"headImageUrl"];
    [encoder encodeObject:self.date forKey:@"date"];
    //[encoder encodeObject:[NSDate date] forKey:@"date"];
    [encoder encodeObject:self.itemArray forKey:@"itemArray"];
    [encoder encodeObject:self.token forKey:@"token"];
    [encoder encodeObject:self.pid forKey:@"pid"];
}

-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super init];
	if( self != nil )
	{
        //decode properties, other class vars
		self.uid = [decoder decodeObjectForKey:@"uid"];
        self.userName = [decoder decodeObjectForKey:@"username"];
		self.password = [decoder decodeObjectForKey:@"password"];
		self.nickName = [decoder decodeObjectForKey:@"nickname"];
        self.cookieName = [decoder decodeObjectForKey:@"cookiename"];
        self.cookieValue = [decoder decodeObjectForKey:@"cookievalue"];
        self.headImageUrl = [decoder decodeObjectForKey:@"headImageUrl"];
        self.date = [decoder decodeObjectForKey:@"date"];
        self.itemArray = [decoder decodeObjectForKey:@"itemArray"];
        self.token = [decoder decodeObjectForKey:@"token"];
        self.pid = [decoder decodeObjectForKey:@"pid"];
        
        if(self.itemArray==nil)
            self.itemArray = [NSMutableArray arrayWithCapacity:10];
        else
            self.itemArray = [NSMutableArray arrayWithArray:_itemArray];
	}
	return self;
}

/*
-(SNUserItem*)getUserItemWithName:(NSString*)aName
{
    if(aName==nil || _itemArray==nil || [_itemArray count]==0)
        return nil;
    else
    {
        for(NSInteger i=0; i<[_itemArray count]; i++)
        {
            SNUserItem* item = (SNUserItem*)[_itemArray objectAtIndex:i];
            if(item._name!=nil && [item._name isEqualToString:aName])
                return item;
        }
        //None
        return nil;
    }
}

-(SNUserItem*)getUserItemWithImageUrl:(NSString*)aImageUrl
{
    if(aImageUrl==nil || _itemArray==nil || [_itemArray count]==0)
        return nil;
    else
    {
        for(NSInteger i=0; i<[_itemArray count]; i++)
        {
            SNUserItem* item = (SNUserItem*)[_itemArray objectAtIndex:i];
            if(item._imageUrl!=nil && [item._imageUrl isEqualToString:aImageUrl])
                return item;
        }
        //None
        return nil;
    }
}*/

-(NSString*)getUsername
{
    if(_userName!=nil)
        return _userName;
    else if(_uid!=nil)
        return _uid;
    else
        return nil;
}

-(NSString*)getNickname
{
    if(_nickName.length>0)
        return _nickName;
    else if(_userName.length>0)
        return _userName;
    else if(_uid.length>0)
        return _uid;
    else
        return @"";
}

-(BOOL)isValidateDate
{
	if(_date && [_date isKindOfClass:[NSDate class]])
    {
        NSTimeInterval start = [_date timeIntervalSince1970];
        NSTimeInterval end   = [[NSDate date] timeIntervalSince1970];
        if((end - start) > 0 && (end - start) < LoginTimeout)
            return YES;
    }
    
    return NO;
}

-(BOOL)isSelfUser
{
    SNUserinfo* obj = [SNUserinfo userinfo];
    
    if(self.userName!=nil && [self.userName isEqualToString:obj.userName])
        return YES;
    else if(self.uid!=nil && [self.uid isEqualToString:obj.uid])
        return YES;
    else if(self.pid!=nil && [self.pid isEqualToString:obj.pid])
        return YES;
    else
        return NO;
}
-(void)resetUserinfo
{
    self.uid = nil;
    self.userName = nil;
    self.password = nil;
    self.nickName = nil;
    self.headImageUrl = nil;
    self.cookieName = nil;
    self.cookieValue = nil;
    self.date = nil;
    [self.itemArray removeAllObjects];
    self.flushCodeUrl = nil;
    self.pid = nil;
    self.token = nil;
}
+(void)clearUserinfoFromUserDefaults
{
    [[SNUserinfoEx userinfo] resetUserinfo];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SNUserinfoject"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserCenterLoginAppId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////i
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//版本3.3做字段扩展
//2012 12 18 by diaochunmeng
@implementation SNUserinfoEx
@synthesize gender = _gender;
@synthesize birthday = _birthday;
@synthesize province = _province;
@synthesize city = _city;
@synthesize education = _education;
@synthesize mobile = _mobile;
@synthesize lastCommentId = _lastCommentId;
@synthesize description = _description;
@synthesize actionCount = _actionCount;
@synthesize followingCount = _followingCount;
@synthesize followedCount = _followedCount;
@synthesize relation = _relation;
@synthesize userBindList = _userBindList;
@synthesize thirdPartyId = _thirdPartyId;
@synthesize thirdPartyName =  _thirdPartyName;
@synthesize thirdPartyUrl = _thirdPartyUrl;
@synthesize icon = _icon;
@synthesize backImg = _backImg;
@synthesize tempHeader =_tempHeader;
@synthesize from = _from;
@synthesize personMediaArray = _personMediaArray;
@synthesize isRegcms = _isRegcms;
@synthesize cmsRegUrl = _cmsRegUrl;
@synthesize signList =_signList;
@synthesize isShowManage = _isShowManage;
@synthesize audugcAuth = _audugcAuth;
-(void)dealloc
{
     //(_gender);
     //(_birthday);
     //(_province);
     //(_city);
     //(_education);
     //(_lastCommentId);
     //(_tempHeader);
     //(_mobile);
     //(_description);
     //(_actionCount);
     //(_followingCount);
     //(_followedCount);
     //(_relation);
     //(_userBindList);
     //(_thirdPartyId);
     //(_thirdPartyName);
     //(_thirdPartyUrl);
     //(_icon);
     //(_backImg);
     //(_from);
     //(_personMediaArray);
     //(_cmsRegUrl);
     //(_signList);
}

-(id)init
{
	if(self=[super init])
	{
	}
	return self;
}

-(id)initWithSNUserinfo:(SNUserinfo*)aSNUserinfo
{
    if(self=[super init])
	{
        if(aSNUserinfo!=nil && [aSNUserinfo isKindOfClass:[SNUserinfo class]])
        {
            self.uid = aSNUserinfo.uid;
            self.isSelf = aSNUserinfo.isSelf;
            self.userName = aSNUserinfo.userName;
            self.password = aSNUserinfo.password;
            self.nickName = aSNUserinfo.nickName;
            self.headImageUrl = aSNUserinfo.headImageUrl;
            self.cookieName = aSNUserinfo.cookieName;
            self.cookieValue = aSNUserinfo.cookieValue;
            self.date = aSNUserinfo.date;
            self.itemArray = [aSNUserinfo.itemArray mutableCopy];
            self.flushCodeUrl = aSNUserinfo.flushCodeUrl;
        }
	}
	return self;
}

-(id)copyWithZone:(NSZone*)zone
{
	SNUserinfoEx* newObj = [super copyWithZone:zone];
    newObj.gender = self.gender;
    newObj.birthday = self.birthday;
    newObj.province = self.province;
    newObj.city = self.city;
    newObj.education = self.education;
    newObj.mobile = self.mobile;
    newObj.lastCommentId = self.lastCommentId;
    newObj.tempHeader = self.tempHeader;
    
    newObj.description = self.description;
    newObj.actionCount = self.actionCount;
    newObj.followingCount = self.followingCount;
    newObj.followedCount = self.followedCount;
    newObj.relation = self.relation;
    newObj.userBindList = self.userBindList;
    newObj.thirdPartyId = self.thirdPartyId;
    newObj.thirdPartyName = self.thirdPartyName;
    newObj.thirdPartyUrl = self.thirdPartyUrl;
    newObj.icon = self.icon;
    newObj.backImg = self.backImg;
    newObj.tempHeader = self.tempHeader;
    newObj.from = self.from;
    newObj.personMediaArray = self.personMediaArray;
    newObj.isRealName = self.isRealName;

	return newObj;
}

+(id)userinfoExData:(NSData*)data
{
	if (data == nil)
    {
		return nil;
	}
	id userinfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if([userinfo isKindOfClass:[SNUserinfoEx class]])
        return userinfo;
    else
        return [[SNUserinfoEx alloc] initWithSNUserinfo:userinfo];
}

+(id)userinfo
{
    NSData* encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"SNUserinfoject"];
    SNUserinfoEx* obj = (SNUserinfoEx*)[SNUserinfoEx userinfoExData:encodedObject];
    obj.isSelf = YES;
    return obj;
}

+(BOOL)isLogin
{
    SNUserinfoEx* obj = (SNUserinfoEx*)[SNUserinfoEx userinfoEx];
    if (obj!=nil && obj.pid.length>0)
        return YES;
    else
        return NO;
}

+(BOOL)isSelfUser:(NSString*)pid
{
    SNUserinfoEx* obj = (SNUserinfoEx*)[SNUserinfoEx userinfoEx];
    if(!obj)
        return NO;
    if(!obj.pid)
        return NO;
    if([obj.pid isEqualToString:pid])
        return YES;
    return NO;
        
}
+(SNUserinfoEx*)userinfoEx
{
    static SNUserinfoEx* sharedUserinfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSData* encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"SNUserinfoject"];
        if(encodedObject)
        {
            sharedUserinfo = (SNUserinfoEx*)[SNUserinfoEx userinfoExData:encodedObject];
            sharedUserinfo.isSelf = YES;
        }
        else
        {
            sharedUserinfo = [[SNUserinfoEx alloc] init];
        }
    });
    NSString *pid = [[[NSUserDefaults alloc] initWithSuiteName:kTodaynewswidgetGroup] objectForKey:kTodaynewswidgetPid];
    if (![sharedUserinfo.pid isEqualToString:pid] && sharedUserinfo.pid.length > 0) {
        [[[NSUserDefaults alloc] initWithSuiteName:kTodaynewswidgetGroup] setObject:sharedUserinfo.pid forKey:kTodaynewswidgetPid];
    }
    return sharedUserinfo;
//    NSData* encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"SNUserinfoject"];
//    SNUserinfoEx* obj = (SNUserinfoEx*)[SNUserinfoEx userinfoExData:encodedObject];
//    obj._isSelf = YES;
//    return obj;
}

//+(BOOL)saveUserinfoEx:(SNUserinfoEx*)aUserinfo
//{
//    if(aUserinfo==nil)
//        return NO;
//    else
//    {
//        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kUserExpire];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SNUserinfoject"];
//        [[NSUserDefaults standardUserDefaults] setObject:[aUserinfo getData] forKey:@"SNUserinfoject"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        return YES;
//    }
//}

+(NSString *)passport
{
    SNUserinfoEx *userinfo = [SNUserinfoEx userinfoEx];
    return userinfo.userName;
}

-(NSString*)getGender
{
    if([@"1" isEqualToString:_gender])
        return @"男";
    else if([@"2" isEqualToString:_gender])
        return @"女";
    else
        return @"女";
}
-(NSString*)getTerm
{
    if([@"1" isEqualToString:_gender])
        return @"他";
    else if([@"2" isEqualToString:_gender])
        return @"她";
    else
        return @"他";
}
-(NSString*)getPlace
{
    NSMutableString* str = [NSMutableString stringWithCapacity:0];
    if(_province.length>0)
    {
        if(![@"北京" isEqualToString:_province] && ![@"上海" isEqualToString:_province] && ![@"天津" isEqualToString:_province] && ![@"重庆" isEqualToString:_province] && ![@"香港" isEqualToString:_province]&& ![@"澳门" isEqualToString:_province])
            [str appendString:_province];
    }
    
    if(_city.length>0 && [str length]>0)
        return [NSString stringWithFormat:@"%@ %@",str, _city];
    else if(_city.length>0 && [str length]==0)
        return _city;
    else
        return @"";
}

- (NSString *)getMobileNum {
    if(_mobile.length>0)
        return _mobile;
    else
        return @"未绑定";
}

//Saving a class in NSUserDefaults
-(void)encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    
    //Encode properties, other class variables, etc
	[encoder encodeObject:self.gender forKey:@"gender"];
    [encoder encodeObject:self.birthday forKey:@"birthday"];
    [encoder encodeObject:self.province forKey:@"province"];
    [encoder encodeObject:self.city forKey:@"city"];
    [encoder encodeObject:self.education forKey:@"education"];
    [encoder encodeObject:self.mobile forKey:@"mobile"];
    [encoder encodeObject:self.lastCommentId forKey:@"lastCommentId"];
    [encoder encodeObject:self.tempHeader forKey:@"tempHeader"];
    
    [encoder encodeObject:self.description forKey:@"description"];
    [encoder encodeObject:self.actionCount forKey:@"actionCount"];
    [encoder encodeObject:self.followingCount forKey:@"followingCount"];
    [encoder encodeObject:self.followedCount forKey:@"followedCount"];
    [encoder encodeObject:self.relation forKey:@"relation"];
    [encoder encodeObject:self.userBindList forKey:@"userBindList"];
    [encoder encodeObject:self.thirdPartyId forKey:@"thirdPartyId"];
    [encoder encodeObject:self.thirdPartyName forKey:@"thirdPartyName"];
    [encoder encodeObject:self.thirdPartyUrl forKey:@"thirdPartyUrl"];
    [encoder encodeObject:self.icon forKey:@"icon"];
    [encoder encodeObject:self.backImg forKey:@"backImg"];
    [encoder encodeObject:self.from forKey:@"from"];
    [encoder encodeObject:self.personMediaArray forKey:@"personMediaArray"];
    [encoder encodeBool:self.isRegcms forKey:@"isRegcms"];
    [encoder encodeObject:self.cmsRegUrl  forKey:@"cmsRegUrl"];
    [encoder encodeObject:self.signList forKey:@"signList"];
    [encoder encodeBool:self.isShowManage forKey:@"isShowManage"];
    [encoder encodeBool:self.audugcAuth forKey:@"audugcAuth"];
    [encoder encodeBool:self.isRealName forKey:@"isRealName"];
    [encoder encodeObject:self.passport forKey:@"passport"];
    [encoder encodeObject:self.ppLoginFlag forKey:@"ppLoginFlag"];
    
}

-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super init];
	if( self != nil )
	{
        if (!(self = [super initWithCoder:decoder])) return nil;
        
        //decode properties, other class vars
		self.gender = [decoder decodeObjectForKey:@"gender"];
        self.birthday = [decoder decodeObjectForKey:@"birthday"];
        self.province = [decoder decodeObjectForKey:@"province"];
        self.city = [decoder decodeObjectForKey:@"city"];
        self.education = [decoder decodeObjectForKey:@"education"];
        self.mobile = [decoder decodeObjectForKey:@"mobile"];
        self.lastCommentId = [decoder decodeObjectForKey:@"lastCommentId"];
        self.tempHeader = [decoder decodeObjectForKey:@"tempHeader"];
        
        self.description = [decoder decodeObjectForKey:@"description"];
        self.actionCount = [decoder decodeObjectForKey:@"actionCount"];
        self.followingCount = [decoder decodeObjectForKey:@"followingCount"];
        self.followedCount = [decoder decodeObjectForKey:@"followedCount"];
        self.relation = [decoder decodeObjectForKey:@"relation"];
        self.userBindList = [decoder decodeObjectForKey:@"userBindList"];
        self.thirdPartyId = [decoder decodeObjectForKey:@"thirdPartyId"];
        self.thirdPartyName = [decoder decodeObjectForKey:@"thirdPartyName"];
        self.thirdPartyUrl = [decoder decodeObjectForKey:@"thirdPartyUrl"];
        self.icon = [decoder decodeObjectForKey:@"icon"];
        self.backImg = [decoder decodeObjectForKey:@"backImg"];
        self.from = [decoder decodeObjectForKey:@"from"];
        self.personMediaArray = [decoder decodeObjectForKey:@"personMediaArray"];
        self.isRegcms = [decoder decodeBoolForKey:@"isRegcms"];
        self.cmsRegUrl = [decoder decodeObjectForKey:@"cmsRegUrl"];
        self.signList = [decoder decodeObjectForKey:@"signList"];
        self.isShowManage = [decoder decodeBoolForKey:@"isShowManage"];
        self.audugcAuth = [decoder decodeBoolForKey:@"audugcAuth"];
        self.isRealName = [decoder decodeBoolForKey:@"isRealName"];
        self.passport = [decoder decodeObjectForKey:@"passport"];
        self.ppLoginFlag = [decoder decodeObjectForKey:@"ppLoginFlag"];
	}
	return self;
}
-(void)resetUserinfo
{
    [super resetUserinfo];
    self.gender = nil;
    self.birthday = nil;
    self.province = nil;
    self.city = nil;
    self.education = nil;
    self.mobile = nil;
    self.lastCommentId = nil;
    self.tempHeader = nil;
    
    self.description = nil;
    self.actionCount = nil;
    self.followingCount = nil;
    self.followedCount = nil;
    self.relation = nil;
    self.userBindList = nil;
    self.thirdPartyId = nil;
    self.thirdPartyName = nil;
    self.thirdPartyUrl = nil;
    self.icon = nil;
    self.backImg = nil;
    self.from = nil;
    self.personMediaArray = nil;
    self.cmsRegUrl = nil;
    self.isRegcms = NO;
    self.signList = nil;
    self.audugcAuth = NO;
    self.isRealName = NO;
}
-(BOOL)hasPersonMedia
{
    if(![SNUserinfoEx isLogin])
        return NO;
    if(self.personMediaArray == nil)
        return NO;
    return self.personMediaArray.count > 0;
}

-(NSArray*)getPersonMediaObjects
{
    if(self.personMediaArray.count > 0)
    {
        NSMutableArray* array = [NSMutableArray arrayWithCapacity:5];
        for(NSDictionary* dic in _personMediaArray)
        {
            SNUserinfoMediaObject* mediaObject = [[SNUserinfoMediaObject alloc] init];
//            mediaObject.count = [dic objectForKey:@"subCount"];
            mediaObject.count = [dic objectForKey:@"countShowText"];//5.1修改为累计阅读数
            mediaObject.name = [dic objectForKey:@"subName"];
            mediaObject.iconUrl = [dic objectForKey:@"subIcon"];
            mediaObject.link = [dic objectForKey:@"subLink"];
            mediaObject.mediaLink = [dic objectForKey:@"mediaLink"];
            mediaObject.subId = [dic stringValueForKey:@"subId" defaultValue:@""];
            //mediaObject.subTypeIcon = [dic arrayValueForKey:@"subTypeIcon" defaultValue:nil];
            NSString* signStr = [dic objectForKey:@"subTypeIcon"];
            mediaObject.subTypeIcon = [signStr yajl_JSON];
            [array addObject:mediaObject];
        }
        return array;
    }
    else
        return nil;
}

-(void)saveUserinfoToUserDefault
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kUserExpire];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SNUserinfoject"];
    [[NSUserDefaults standardUserDefaults] setObject:[self getData] forKey:@"SNUserinfoject"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)parseUserinfoFromDictionary:(NSDictionary*)dic
{
    [SNUserUtility parseUserinfo:self fromDictionary:dic];
}

- (void)ppSaveUserInfo:(NSDictionary*)dic{
    
    self.pid = [dic stringValueForKey:@"pid" defaultValue:nil];
    [[[NSUserDefaults alloc] initWithSuiteName:kTodaynewswidgetGroup] setObject:(self.pid ?:@"-1") forKey:kTodaynewswidgetPid];
    
    NSString* token = [dic stringValueForKey:@"token" defaultValue:nil];
    NSString* nick = [dic stringValueForKey:@"nick" defaultValue:nil];
    NSString* passport = [dic stringValueForKey:@"passport" defaultValue:nil];
    NSString* avator = [dic stringValueForKey:@"avator" defaultValue:nil];

    self.token = token;
    self.nickName = nick;
    self.headImageUrl = avator;
    self.passport = passport;
    self.userName = passport;
    self.uid = passport;
    
    self.ppLoginFlag = @"1";
    
    [self saveUserinfoToUserDefault];
}

-(void)copyEditUserinfo:(SNUserinfoEx*)aUserinfo
{
    if(!aUserinfo)
        return;
    if(aUserinfo.nickName)
        self.nickName = aUserinfo.nickName;
    if(aUserinfo.headImageUrl)
        self.headImageUrl = aUserinfo.headImageUrl;
    if(aUserinfo.gender)
        self.gender = aUserinfo.gender;
    if(aUserinfo.province)
        self.province = aUserinfo.province;
    if(aUserinfo.city)
        self.city = aUserinfo.city;
}

-(SNUserType)getUserType
{
    if(self.personMediaArray.count > 0)
    {
        if(self.isShowManage)
        {
            return SNUserTypeMedia;
        }
        else
        {
            return SNUserTypeOrganization;
        }
    }
    else
        return SNUserTypePeople;
        
}
@end
