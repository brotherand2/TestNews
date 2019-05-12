//
//  SNDatabase_Newspaper.m
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase.h"
#import "SNDatabase_Private.h"
#import "SNDatabase_Newspaper.h"
#import "SNURLDataResponse.h"


@implementation SNDatabase(Newspaper)


-(NSDictionary*)getNewspaperUpdateValuePairs:(NewspaperItem*)newspaper
{
	if (newspaper == nil) {
		SNDebugLog(@"getNewspaperUpdateValuePairs : Invalid newspaper");
		return nil;
	}
	
	NSMutableDictionary *valuePairs	= [[NSMutableDictionary alloc] init];
	if(newspaper.subId != nil){
		[valuePairs setObject:newspaper.subId forKey:TB_NEWSPAPER_SUBID];
	}
	if(newspaper.pubId != nil){
		[valuePairs setObject:newspaper.pubId forKey:TB_NEWSPAPER_PUBID];
	}

	if(newspaper.pushName != nil){
		[valuePairs setObject:newspaper.pushName forKey:TB_NEWSPAPER_TERMNAME];
	}
    else{
        if (newspaper.termName !=nil) {
            newspaper.pushName = newspaper.termName;
            [valuePairs setObject:newspaper.pushName forKey:TB_NEWSPAPER_TERMNAME];
        }
    }
    
	if(newspaper.termTitle != nil){
		[valuePairs setObject:newspaper.termTitle forKey:TB_NEWSPAPER_TERMTITLE];
	}
	if(newspaper.termLink != nil){
		[valuePairs setObject:newspaper.termLink forKey:TB_NEWSPAPER_TERMLINK];
	}
	if(newspaper.termZip != nil){
		[valuePairs setObject:newspaper.termZip forKey:TB_NEWSPAPER_TERMZIP];
	}
	if(newspaper.termTime != nil){
		[valuePairs setObject:newspaper.termTime forKey:TB_NEWSPAPER_TERMTIME];
	}
	if(newspaper.newspaperPath != nil){
		[valuePairs setObject:newspaper.newspaperPath forKey:TB_NEWSPAPER_NEWSPAPERPATH];
	}
	if(newspaper.readFlag != nil){
		[valuePairs setObject:newspaper.readFlag forKey:TB_NEWSPAPER_READFLAG];
	}
	if(newspaper.downloadFlag != nil){
		[valuePairs setObject:newspaper.downloadFlag forKey:TB_NEWSPAPER_DOWNLOADFLAG];
	}
    if(newspaper.downloadTime != nil){
		[valuePairs setObject:newspaper.downloadTime forKey:TB_NEWSPAPER_DOWNLOADTIME];
	}
    if (newspaper.publishTime != nil) {
        [valuePairs setObject:newspaper.publishTime forKey:TB_NEWSPAPER_PUBLISHTIME];
    }
	
	return  valuePairs;
}

-(NSArray*)getNewspaperListInDatebase:(FMDatabase *)db
{
	return [self getNewspaperListWithTimeOrderOption:ORDER_OPT_DEFAULT inDatabase:db];
}

-(NSArray*)getNewspaperList
{
	return [self getNewspaperListWithTimeOrderOption:ORDER_OPT_DEFAULT];
}

//ORDER BY SUBID ASC
-(NSArray*)getNewspaperListBySubId:(NSString*)subId inDatabase:(FMDatabase *)db
{
	if ([subId length] == 0) {
		SNDebugLog(@"getNewspaperListBySubId :Invalid subId");
		return nil;
	}

    FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewspaper WHERE subId=? ORDER BY termTime DESC", subId];
    if ([db hadError]) {
        SNDebugLog(@"getNewspaperListBySubId : executeQuery error :%d,%@"
                   ,[db lastErrorCode],[db lastErrorMessage]);
        return nil;
    }
    NSArray *newspaperList	= [self getObjects:[NewspaperItem class] fromResultSet:rs];
    [rs close];
	return newspaperList;
}

-(NSArray*)getNewspaperListBySubId:(NSString*)subId
{
	__block NSArray *newspaperList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        newspaperList = [self getNewspaperListBySubId:subId inDatabase:db];
    }];
	return newspaperList;
}

-(NSArray*)getNewspaperListByPubId:(NSString*)pubId
{
	if ([pubId length] == 0) {
		SNDebugLog(@"getNewspaperListByPubId :Invalid pubId");
		return nil;
	}
	__block NSArray *newspaperList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {

        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewspaper WHERE pubId=? ORDER BY termTime DESC", pubId];
        if ([db hadError]) {
            SNDebugLog(@"getNewspaperListBySubId : executeQuery error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
        newspaperList	= [self getObjects:[NewspaperItem class] fromResultSet:rs];
        [rs close];
    }];
	return newspaperList;
}

-(NSArray*)getNewspaperListWithTimeOrderOption:(ORDER_OPTION)orderOpt
{
    __block NSArray *newspaperList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        newspaperList = [self getNewspaperListWithTimeOrderOption:orderOpt inDatabase:db];
    }];
    return newspaperList;
    
}

-(NSArray*)getNewspaperListWithTimeOrderOption:(ORDER_OPTION)orderOpt inDatabase:(FMDatabase *)db
{
    FMResultSet *rs	= nil;
    switch (orderOpt) {
        case ORDER_OPT_ASC:
            rs = [db executeQuery:@"SELECT * FROM tbNewspaper ORDER BY termTime ASC"];
            break;
        case ORDER_OPT_DESC:
            rs = [db executeQuery:@"SELECT * FROM tbNewspaper ORDER BY termTime DESC"];
            break;
        case ORDER_OPT_DEFAULT:
        default:
            rs = [db executeQuery:@"SELECT * FROM tbNewspaper"];
            break;
    }
    
    if ([db hadError]) {
        SNDebugLog(@"getNewspaperListWithTimeOrderOption : executeQuery error :%d,%@"
                   ,[db lastErrorCode],[db lastErrorMessage]);
        return nil;
    }
    
    NSArray *newspaperList	= [self getObjects:[NewspaperItem class] fromResultSet:rs];
    [rs close];
	return newspaperList;
}

-(NSArray*)getNewspaperDownloadedList
{
	return [self getNewspaperDownloadedListWithTimeOrderOption:ORDER_OPT_DEFAULT];
}

-(NSArray*)getNewspaperDownloadedListWithTimeOrderOption:(ORDER_OPTION)orderOpt
{
    __block NSArray *newspaperList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= nil;
        switch (orderOpt) {
            case ORDER_OPT_ASC:
                rs = [db executeQuery:@"SELECT * FROM tbNewspaper WHERE downloadFlag='1' ORDER BY termTime ASC"];
                break;
            case ORDER_OPT_DESC:
                rs = [db executeQuery:@"SELECT * FROM tbNewspaper WHERE downloadFlag='1' ORDER BY termTime DESC"];
                break;
            case ORDER_OPT_DEFAULT:
            default:
                rs = [db executeQuery:@"SELECT * FROM tbNewspaper WHERE downloadFlag='1' ORDER BY downloadTime DESC"];
                break;
        }
        
        if ([db hadError]) {
            SNDebugLog(@"getNewspaperDownloadedListWithTimeOrderOption : executeQuery error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
        newspaperList	= [self getObjects:[NewspaperItem class] fromResultSet:rs];
        [rs close];
	    
    }];
	
	return newspaperList;
}

-(NSArray*)getNewspaperDownloadedListByPubId:(NSString*)pubId
{
    if ([pubId length] == 0) {
        SNDebugLog(@"getNewspaperDownloadedListByPubId:Invalid pubId");
		return nil;
    }
    __block NSArray *newspaperList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewspaper WHERE pubId=? AND downloadFlag='1' ORDER BY termId DESC",pubId];
        
        if ([db hadError]) {
            SNDebugLog(@"getNewspaperDownloadedListByPubId : executeQuery error :%d,%@,pubId=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],pubId);
            return;
        }
        newspaperList	= [self getObjects:[NewspaperItem class] fromResultSet:rs];
        [rs close];
	}];
	return newspaperList;
}

-(NSArray*)getNewspaperDownloadedListBySubId:(NSString*)subId
{
	return [self getNewspaperDownloadedListBySubId:subId withTimeOrderOption:ORDER_OPT_DEFAULT];
}

-(NSArray*)getNewspaperDownloadedListBySubId:(NSString*)subId withTimeOrderOption:(ORDER_OPTION)orderOpt
{
	if ([subId length] == 0) {
		SNDebugLog(@"getNewspaperDownloadedListBySubId:Invalid subId");
		return nil;
	}
    __block NSArray *newspaperList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= nil;
        switch (orderOpt) {
            case ORDER_OPT_ASC:
                rs = [db executeQuery:@"SELECT * FROM tbNewspaper WHERE subId=? AND downloadFlag='1' ORDER BY termTime ASC",subId];
                break;
            case ORDER_OPT_DESC:
                rs = [db executeQuery:@"SELECT * FROM tbNewspaper WHERE subId=? AND downloadFlag='1' ORDER BY termTime DESC",subId];
                break;
            case ORDER_OPT_DEFAULT:
            default:
                rs = [db executeQuery:@"SELECT * FROM tbNewspaper WHERE subId=? AND downloadFlag='1' ORDER BY termId DESC",subId];
                break;
        }
        
        if ([db hadError]) {
            SNDebugLog(@"getNewspaperDownloadedListBySubId : executeQuery error :%d,%@,subId=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],subId);
            return;
        }
        
        newspaperList	= [self getObjects:[NewspaperItem class] fromResultSet:rs];
        [rs close];
    }];
	return newspaperList;
}

-(NewspaperItem*)getNewspaperByTermId:(NSString*)termId inDatabase:(FMDatabase *)db
{
	if ([termId length] == 0) {
		SNDebugLog(@"getNewspaperByTermId : Invalid termId");
		return nil;
	}
    FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewspaper WHERE termId=?",termId];
    if ([db hadError]) {
        SNDebugLog(@"getNewspaperByTermId : executeQuery error :%d,%@,termId=%@"
                   ,[db lastErrorCode],[db lastErrorMessage],termId);
        return nil;
    }
    NewspaperItem *newspaper	= [self getFirstObject:[NewspaperItem class] fromResultSet:rs];
    [rs close];
    
	return newspaper;
}

-(NewspaperItem*)getNewspaperByTermId:(NSString*)termId
{
	
    __block NewspaperItem *newspaper = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        newspaper = [self getNewspaperByTermId:termId inDatabase:db];
    }];
	return newspaper;
}

-(BOOL)setNewspaperList:(NSArray*)newspaperList
{	
	if ([newspaperList count] == 0) {
		SNDebugLog(@"setNewspaperList : Invalid newspaperList");
		return NO;
	}
	
    __block BOOL result = YES;
    __block NSArray *curNewspaperList = nil;
	//当前报纸列表为空，直接执行增加操作
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        curNewspaperList	= [self getNewspaperListInDatebase:db];
        if ([curNewspaperList count] == 0) {
            result  = [self addMultiNewspaper:newspaperList inDatabase:db];
            if (!result) {
                *rollback = YES;
            }
        }
    }];
    if ([curNewspaperList count] == 0 && result) {
        return result;
    }
	//对比新旧报纸列表，删除该删除的，增加该新增的
	NSMutableArray *addNewspaperList	= [[NSMutableArray alloc] init];
	NSMutableArray *delNewspaperList	= [[NSMutableArray alloc] initWithArray:curNewspaperList];
	
	for (NewspaperItem *newspaper in newspaperList) {
		BOOL bExist	= NO;
		for (NewspaperItem *delNewspaper in delNewspaperList) {
			if ([newspaper.termId isEqualToString:delNewspaper.termId]) {
				[delNewspaperList removeObject:delNewspaper];
				bExist	= YES;
				break;
			}
		}
		
		if (!bExist) {
			[addNewspaperList addObject:newspaper];
		}
	}
	
	if ([addNewspaperList count] == 0 && [delNewspaperList count] == 0) {
		return YES;
	}
	
	//准备插入和删除操作，采用事务
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //首先执行删除操作
        for (NewspaperItem *item in delNewspaperList) {
            result = [db executeUpdate:@"DELETE FROM tbNewspaper WHERE termId=?",item.termId];
            if ([db hadError]) {
                SNDebugLog(@"setNewspaperList: delete current newspaper error:%d,%@,item.termId=%@"
                           ,[db lastErrorCode],[db lastErrorMessage],item.termId);
                *rollback =  YES;
                return;
            }
        }
         //再执行插入操作
        for (NewspaperItem *newspaper in addNewspaperList) {
            if (newspaper.pushName == nil) {
                newspaper.pushName = newspaper.termName;
            }
            result = [db executeUpdate:@"INSERT INTO tbNewspaper (ID,subId,pubId,termId,termName,termTitle,termLink,termZip \
             ,termTime,newspaperPath,readFlag,downloadFlag,publishTime) VALUES (NULL,?,?,?,?,?,?,?,?,?,?,?,?)"
             ,newspaper.subId,newspaper.pubId,newspaper.termId,newspaper.pushName,newspaper.termTitle
             ,newspaper.termLink,newspaper.termZip,newspaper.termTime,newspaper.newspaperPath
             ,newspaper.readFlag,newspaper.downloadFlag,newspaper.publishTime];
            
            if ([db hadError]) {
                SNDebugLog(@"setNewspaperList: insert newspaper item error: %d,%@,item:%@"
                           ,[db lastErrorCode],[db lastErrorMessage],newspaper);
                *rollback =  YES;
                return;
            }
        }
    }];
    
		
	//相应的删除对应的文件
    if (result) {
        BOOL bSucceed	= NO;
        NSError *error	= nil;
        NSFileManager *fm	= [NSFileManager defaultManager];
        for (NewspaperItem *newspaper in delNewspaperList){
            NSString *realpath = [newspaper realNewspaperPath];
            if (![fm fileExistsAtPath:realpath]) {
                continue;
            }
            
            NSString *newspaperFolderPath	= [self getNewspaperFolderPathByHomePagePath:realpath];
            if (newspaperFolderPath == nil) {
                continue;
            }
            
            bSucceed	= [fm removeItemAtPath:newspaperFolderPath error:&error];
            if (!bSucceed) {
                SNDebugLog(@"setNewspaperList: remove newspaper failed:%d,%@,path=%@"
                           ,[error code],[error localizedDescription],newspaperFolderPath);
            }
        }
    }
	
	return result;
}

-(BOOL)addSingleNewspaper:(NewspaperItem*)newspaper
{
	return [self addSingleNewspaper:newspaper updateIfExist:YES];
}

-(BOOL)addMultiNewspaper:(NSArray*)newspaperList inDatabase:(FMDatabase *)db
{
    return [self addMultiNewspaper:newspaperList updateIfExist:YES inDatebase:db];
}
     
-(BOOL)addMultiNewspaper:(NSArray*)newspaperList
{
	return [self addMultiNewspaper:newspaperList updateIfExist:YES];
}

-(BOOL)addSingleNewspaper:(NewspaperItem*)newspaper updateIfExist:(BOOL)bUpdateIfExist
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addSingleNewspaper:newspaper updateIfExist:bUpdateIfExist inDatabase:db];
        if ([db hadError]) {
            *rollback = YES;
        }
    }];
    return result;
}

-(BOOL)addSingleNewspaper:(NewspaperItem*)newspaper updateIfExist:(BOOL)bUpdateIfExist inDatabase:(FMDatabase *)db
{
	if (newspaper == nil) {
		SNDebugLog(@"addSingleNewspaper : Invalid newspaper");
		return NO;
	}
    if (bUpdateIfExist) {
        [db executeUpdate:@"REPLACE INTO tbNewspaper (subId,pubId,termId,termName,termTitle,termLink,termZip \
         ,termTime,newspaperPath,readFlag,downloadFlag,downloadTime,normalLogo,nightLogo,publishTime) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
         ,newspaper.subId,newspaper.pubId,newspaper.termId,newspaper.termName,newspaper.termTitle
         ,newspaper.termLink,newspaper.termZip,newspaper.termTime,newspaper.newspaperPath
         ,newspaper.readFlag,newspaper.downloadFlag,newspaper.downloadTime,newspaper.normalLogo,newspaper.nightLogo,newspaper.publishTime];
        if ([db hadError]) {
            return NO;
        }
        return YES;
    } else {
        NSInteger count = [db intForQuery:@"SELECT COUNT(*) FROM tbNewspaper WHERE termId=?",newspaper.termId];
        if (count==0) {
            if (newspaper.pushName == nil) {
                newspaper.pushName = newspaper.termName;
            }
            [db executeUpdate:@"INSERT INTO tbNewspaper (subId,pubId,termId,termName,termTitle,termLink,termZip \
             ,termTime,newspaperPath,readFlag,downloadFlag,downloadTime,normalLogo,nightLogo,publishTime) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
             ,newspaper.subId,newspaper.pubId,newspaper.termId,newspaper.pushName,newspaper.termTitle
             ,newspaper.termLink,newspaper.termZip,newspaper.termTime,newspaper.newspaperPath
             ,newspaper.readFlag,newspaper.downloadFlag,newspaper.downloadTime,newspaper.normalLogo,newspaper.nightLogo,newspaper.publishTime];
            
            if ([db hadError]) {
                SNDebugLog(@"addSingleNewspaper: insert newspaper error: %d,%@,newspaper:%@"
                           ,[db lastErrorCode],[db lastErrorMessage],newspaper);
                return NO;
            }
        }
    }
    return YES;
}

-(BOOL)addMultiNewspaper:(NSArray*)newspaperList updateIfExist:(BOOL)bUpdateIfExist inDatebase:(FMDatabase *)db
{
    if ([newspaperList count] == 0) {
        SNDebugLog(@"addMultiNewspaper : Invalid newspaper list");
        return NO;
    }
    for (NewspaperItem *newspaper in newspaperList) {
        if (![self addSingleNewspaper:newspaper updateIfExist:bUpdateIfExist inDatabase:db]) {
            SNDebugLog(@"addMultiNewspaper : Add a newspaper item failed item:%@",newspaper);
            return NO;
        }
    }
    return YES;
}

     
-(BOOL)addMultiNewspaper:(NSArray*)newspaperList updateIfExist:(BOOL)bUpdateIfExist
{
	__block BOOL bSucceed	= YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        bSucceed = [self addMultiNewspaper:newspaperList updateIfExist:bUpdateIfExist inDatebase:db ];
        if (!bSucceed) {
            *rollback = YES;
        }
    }];
	return bSucceed;
}
     

-(BOOL)updateNewspaperByTermId:(NSString*)termId withValuePairs:(NSDictionary*)valuePairs InDatabase:(FMDatabase *)db
{
	return [self updateNewspaperByTermId:termId withValuePairs:valuePairs addIfNotExist:NO inDatabase:db];
}

-(BOOL)updateNewspaperByTermId:(NSString*)termId withValuePairs:(NSDictionary*)valuePairs
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self updateNewspaperByTermId:termId withValuePairs:valuePairs addIfNotExist:NO inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
	return result;
}

-(BOOL)updateNewspaperByTermId:(NSString*)termId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self updateNewspaperByTermId:termId withValuePairs:valuePairs addIfNotExist:bAddIfNotExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

-(BOOL)updateNewspaperByTermId:(NSString*)termId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist inDatabase:(FMDatabase *)db;
{	
	if ([termId length] == 0) {
		SNDebugLog(@"updateNewspaperByTermId : Invalid termId");
		return NO;
	}
	
	if ([valuePairs count] == 0) {
		SNDebugLog(@"updateNewspaperByTermId : Invalid valuePairs");
		return NO;
	}
	
	//查询此前是否已经存在
	FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewspaper WHERE termId=?",termId];
	if ([db hadError]) {
		SNDebugLog(@"updateNewspaperByTermId : executeQuery for exist one error :%d,%@,termId=%@"
				   ,[db lastErrorCode],[db lastErrorMessage],termId);
		return NO;
	}
	
	NSArray *newspaperInfo	= [self getObjects:[NewspaperItem class] fromResultSet:rs];
	[rs close];
	
	//不存在，
	if([newspaperInfo count] == 0)
	{
		if (!bAddIfNotExist) {
			SNDebugLog(@"updateNewspaperByTermId : newspaper item with termId=%@ doesn't exist",termId);
			return NO;
		}
		//新增
		else {
			[db executeUpdate:@"INSERT INTO tbNewspaper (ID,subId,pubId,termId,termName,termTitle,termLink,termZip \
			 ,termTime,newspaperPath,readFlag,downloadFlag,downloadTime,publishTime) VALUES (NULL,?,?,?,?,?,?,?,?,?,?,?,?,?)"
			 ,[valuePairs objectForKey:TB_NEWSPAPER_SUBID],[valuePairs objectForKey:TB_NEWSPAPER_PUBID],termId
			 ,[valuePairs objectForKey:TB_NEWSPAPER_TERMNAME],[valuePairs objectForKey:TB_NEWSPAPER_TERMTITLE]
			 ,[valuePairs objectForKey:TB_NEWSPAPER_TERMLINK],[valuePairs objectForKey:TB_NEWSPAPER_TERMZIP]
			 ,[valuePairs objectForKey:TB_NEWSPAPER_TERMTIME],[valuePairs objectForKey:TB_NEWSPAPER_NEWSPAPERPATH]
			 ,[valuePairs objectForKey:TB_NEWSPAPER_READFLAG],[valuePairs objectForKey:TB_NEWSPAPER_DOWNLOADFLAG]
             ,[valuePairs objectForKey:TB_NEWSPAPER_DOWNLOADTIME],[valuePairs objectForKey:TB_NEWSPAPER_PUBLISHTIME]];
			
			if ([db hadError]) {
				SNDebugLog(@"updateNewspaperByTermId: insert newspaper error: %d,%@,termId=%@,valuePairs:%@"
						   ,[db lastErrorCode],[db lastErrorMessage],termId,valuePairs);
				return NO;
			}
			
			SNDebugLog(@"updateNewspaperByTermId: insert newspaper,termId=%@,valuePairs:%@",termId,valuePairs);
			return YES;
		}
	}
	
	//如果该项存在，则执行更新操作
	NSDictionary *updateSetStatementsInfo = [self formatUpdateSetStatementsInfoFromValuePairs:valuePairs ignoreNilValue:NO];
	if ([updateSetStatementsInfo count] == 0) {
		return NO;
	}
	
	NSString *setStatement			= [updateSetStatementsInfo objectForKey:UPDATE_SETSTATEMNT];
	NSMutableArray *valueArguments	= [updateSetStatementsInfo objectForKey:UPDATE_SETARGUMENTS];
	NSString *updateStatements		= [NSString stringWithFormat:@"UPDATE %@ %@ WHERE %@=?"
									   ,TB_NEWSPAPER,setStatement,TB_NEWSPAPER_TERMID];
	[valueArguments addObject:termId];
	
	[db executeUpdate:updateStatements withArgumentsInArray:valueArguments];
	if ([db hadError]) {
		SNDebugLog(@"updateNewspaperByTermId : executeUpdate error :%d,%@,updateStatements=%@,valueArguments:%@"
				   ,[db lastErrorCode],[db lastErrorMessage],updateStatements,valueArguments);
		return NO;
	}
	
	return YES;
}

-(BOOL)updateNewspaperBySubId:(NSString*)subId withValuePairs:(NSDictionary*)valuePairs inDatabase:(FMDatabase *)db
{
	return [self updateNewspaperBySubId:subId withValuePairs:valuePairs addIfNotExist:NO inDatabase:db];
}

-(BOOL)updateNewspaperBySubId:(NSString*)subId withValuePairs:(NSDictionary*)valuePairs
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self updateNewspaperBySubId:subId withValuePairs:valuePairs addIfNotExist:NO inDatabase:db];
        if (!result) {
            *rollback  = YES;
        }
    }];
	return result;
}

-(BOOL)updateNewspaperBySubId:(NSString*)subId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self updateNewspaperBySubId:subId withValuePairs:valuePairs addIfNotExist:bAddIfNotExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

-(BOOL)updateNewspaperBySubId:(NSString*)subId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist inDatabase:(FMDatabase *)db
{
	if ([subId length] == 0) {
		SNDebugLog(@"updateNewspaperBySubId : Invalid subId");
		return NO;
	}
	
	if ([valuePairs count] == 0) {
		SNDebugLog(@"updateNewspaperBySubId : Invalid valuePairs");
		return NO;
	}
	
	//查询此前是否已经存在
	FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewspaper WHERE subId=?",subId];
	if ([db hadError]) {
		SNDebugLog(@"updateNewspaperBySubId : executeQuery for exist one error :%d,%@,subId=%@"
				   ,[db lastErrorCode],[db lastErrorMessage],subId);
		return NO;
	}
	
	NSArray *newspaperInfo	= [self getObjects:[NewspaperItem class] fromResultSet:rs];
	[rs close];
	
	//不存在，
	if([newspaperInfo count] == 0)
	{
		if (!bAddIfNotExist) {
			SNDebugLog(@"updateNewspaperBySubId : newspaper item with subId=%@ doesn't exist",subId);
			return NO;
		}
		//新增
		else {
			[db executeUpdate:@"INSERT INTO tbNewspaper (ID,subId,pubId,termId,termName,termTitle,termLink,termZip \
			 ,termTime,newspaperPath,readFlag,downloadFlag,downloadTime,publishTime) VALUES (NULL,?,?,?,?,?,?,?,?,?,?,?,?,?)"
			 ,subId,[valuePairs objectForKey:TB_NEWSPAPER_PUBID],[valuePairs objectForKey:TB_NEWSPAPER_TERMID]
			 ,[valuePairs objectForKey:TB_NEWSPAPER_TERMNAME],[valuePairs objectForKey:TB_NEWSPAPER_TERMTITLE]
			 ,[valuePairs objectForKey:TB_NEWSPAPER_TERMLINK],[valuePairs objectForKey:TB_NEWSPAPER_TERMZIP]
			 ,[valuePairs objectForKey:TB_NEWSPAPER_TERMTIME],[valuePairs objectForKey:TB_NEWSPAPER_NEWSPAPERPATH]
			 ,[valuePairs objectForKey:TB_NEWSPAPER_READFLAG],[valuePairs objectForKey:TB_NEWSPAPER_DOWNLOADFLAG]
             ,[valuePairs objectForKey:TB_NEWSPAPER_DOWNLOADTIME],[valuePairs objectForKey:TB_NEWSPAPER_PUBLISHTIME]];
			
			if ([db hadError]) {
				SNDebugLog(@"updateNewspaperBySubId: insert newspaper error: %d,%@,subId=%@,valuePairs:%@"
						   ,[db lastErrorCode],[db lastErrorMessage],subId,valuePairs);
				return NO;
			}
			
			SNDebugLog(@"updateNewspaperBySubId: insert newspaper,subId=%@,valuePairs:%@",subId,valuePairs);
			return YES;
		}
	}
	
	//如果该项存在，则执行更新操作
	NSDictionary *updateSetStatementsInfo = [self formatUpdateSetStatementsInfoFromValuePairs:valuePairs ignoreNilValue:NO];
	if ([updateSetStatementsInfo count] == 0) {
		return NO;
	}
	
	NSString *setStatement			= [updateSetStatementsInfo objectForKey:UPDATE_SETSTATEMNT];
	NSMutableArray *valueArguments	= [updateSetStatementsInfo objectForKey:UPDATE_SETARGUMENTS];
	NSString *updateStatements		= [NSString stringWithFormat:@"UPDATE %@ %@ WHERE %@=?"
									   ,TB_NEWSPAPER,setStatement,TB_NEWSPAPER_SUBID];
	[valueArguments addObject:subId];
	
	[db executeUpdate:updateStatements withArgumentsInArray:valueArguments];
	if ([db hadError]) {
		SNDebugLog(@"updateNewspaperBySubId : executeUpdate error :%d,%@,updateStatements=%@,valueArguments:%@"
				   ,[db lastErrorCode],[db lastErrorMessage],updateStatements,valueArguments);
		return NO;
	}
	
	return YES;
}

-(BOOL)deleteNewspaperByTermId:(NSString*)termId
{
	return [self deleteNewspaperByTermId:termId deleteFromTable:NO];
}

-(BOOL)deleteNewspaperByTermId:(NSString *)termId deleteFromTable:(BOOL)bDelFromTable;
{
	if ([termId length] == 0) {
		SNDebugLog(@"deleteNewspaperByTermId : Invalid termId");
		return NO;
	}
	
    __block BOOL result = YES;
    __block NewspaperItem *newspaper = nil;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        newspaper = [self getNewspaperByTermId:termId inDatabase:db];
        if (newspaper == nil) {
            SNDebugLog(@"deleteNewspaperByTermId : newspaper with termId=%@ doesn't exist",termId);
            return;
        }
        
        if (bDelFromTable) {
            [db executeUpdate:@"DELETE FROM tbNewspaper WHERE termId=?",termId];
            if ([db hadError]) {
                SNDebugLog(@"deleteNewspaperByTermId : executeUpdate error :%d,%@,termId=%@"
                           ,[db lastErrorCode],[db lastErrorMessage],termId);
                *rollback = YES;
                return;
            }
        }
        else {
            //更新字段
            NSDictionary *valuePairs	= [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"",TB_NEWSPAPER_NEWSPAPERPATH
                                           ,@"0",TB_NEWSPAPER_DOWNLOADFLAG
                                           ,nil];
            
            result	= [self updateNewspaperByTermId:termId withValuePairs:valuePairs addIfNotExist:NO inDatabase:db];
            if (!result) {
                SNDebugLog(@"deleteNewspaperByTermId : Update newspaper zip flag failed, termId=%@",termId);
                *rollback = YES;
                return;
            }
        }

    }];
    
		
	//删除报纸zip包
    if (result) {
        NSError *error		= nil;
        NSFileManager *fm	= [NSFileManager defaultManager];
        NSString *realpath = [newspaper realNewspaperPath];
        NSString *newspaperFolderPath	= [self getSingleNewspaperFolderPath:realpath];
        if ([newspaperFolderPath length] == 0) {
            SNDebugLog(@"deleteNewspaperByTermId: Cann't get newspaper folder path,newspaperPath=%@",realpath);
        }
        else {
            if (![fm removeItemAtPath:newspaperFolderPath error:&error]) {
                SNDebugLog(@"deleteNewspaperByTermId: remove newspaper failed:%d,%@,path=%@"
                           ,[error code],[error localizedDescription],newspaperFolderPath);
            }
        }
    }

	return result;
}

-(BOOL)deleteNewspaperBySubId:(NSString*)subId
{
	return [self deleteNewspaperBySubId:subId deleteFromTable:NO];
}


-(BOOL)deleteNewspaperBySubId:(NSString *)subId deleteFromTable:(BOOL)bDelFromTable
{
	if ([subId length] == 0) {
		SNDebugLog(@"deleteNewspaperBySubId : Invalid subId");
		return NO;
	}
	__block BOOL result = YES;
    __block NSArray *newspaperList = nil;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        newspaperList = [self getNewspaperListBySubId:subId inDatabase:db];
        if ([newspaperList count] == 0) {
            SNDebugLog(@"deleteNewspaperBySubId : newspaper with subId=%@ doesn't exist",subId);
            result = NO;
            return;
        }
        
        if (bDelFromTable) {
            result = [db executeUpdate:@"DELETE FROM tbNewspaper WHERE subId=?",subId];
            if ([db hadError]) {
                SNDebugLog(@"deleteNewspaperBySubId : executeUpdate error :%d,%@,subId=%@"
                           ,[db lastErrorCode],[db lastErrorMessage],subId);
                *rollback = YES;
                return;
            }
        }
        else {
            //更新字段
            NSDictionary *valuePairs	= [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"",TB_NEWSPAPER_NEWSPAPERPATH
                                           ,@"0",TB_NEWSPAPER_DOWNLOADFLAG
                                           ,nil];
            
            result = [self updateNewspaperBySubId:subId withValuePairs:valuePairs addIfNotExist:NO inDatabase:db];
            if (!result) {
                SNDebugLog(@"deleteNewspaperBySubId : Update newspaper zip flag failed, subId=%@",subId);
                *rollback = YES;
                return;
            }
        }
    }];
	
	
	//删除报纸zip包
    if (result) {
        NSError *error		= nil;
        NSFileManager *fm	= [NSFileManager defaultManager];
        for (NewspaperItem *newspaper in newspaperList) {
            NSString *realpath = [newspaper realNewspaperPath];
            if (![fm fileExistsAtPath:realpath]) {
                continue;
            }
            
            NSString *newspaperFolderPath	= [self getNewspaperFolderPathByHomePagePath:realpath];
            if ([newspaperFolderPath length] == 0) {
                continue;
            }
            
            BOOL bSucceed	= [fm removeItemAtPath:newspaperFolderPath error:&error];
            if (!bSucceed) {
                SNDebugLog(@"deleteNewspaperBySubId: remove newspaper failed:%d,%@,path=%@"
                           ,[error code],[error localizedDescription],newspaperFolderPath);
            }
        }
    }
	
	return result;
}

-(BOOL)clearNewspaperlist
{
	return [self clearNewspaperlist:NO];
}

-(BOOL)clearNewspaperlist:(BOOL)bDelFromTable;
{
    __block BOOL result = YES;
    __block NSArray *newspaperList = nil;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewspaper"];
        if ([db hadError]) {
            SNDebugLog(@"clearNewspaperlist : executeQuery error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            result = NO;
            return;
        }
        
        newspaperList	= [self getObjects:[NewspaperItem class] fromResultSet:rs];
        [rs close];
        
        if ([newspaperList count] == 0) {
            SNDebugLog(@"clearNewspaperlist : Empty newspaper list");
            return;
        }
        
        if (bDelFromTable) {
            result =  [db executeUpdate:@"DELETE FROM tbNewspaper"];
            if ([db hadError]) {
                SNDebugLog(@"clearNewspaperlist : executeUpdate error :%d,%@"
                           ,[db lastErrorCode],[db lastErrorMessage]);
                *rollback = YES;
                return;
            }
        }
        else {
            //更新字段
            result = [db executeUpdate:@"UPDATE tbNewspaper SET newspaperPath=\'\',downloadFlag=\'0\'"];
            if ([db hadError]) {
                SNDebugLog(@"clearNewspaperlist : Update newspaper zip flag failed");
                *rollback = YES;
                return;
            }
        }
    }];
	
	if (result) {
        NSError *error	= nil;
        NSFileManager *fm	= [NSFileManager defaultManager];
        for (NewspaperItem *newspaper in newspaperList){
            NSString *realpath = [newspaper realNewspaperPath];
            if (![fm fileExistsAtPath:realpath]) {
                continue;
            }
            
            NSString *newspaperFolderPath	= [self getNewspaperFolderPathByHomePagePath:realpath];
            if ([newspaperFolderPath length] == 0) {
                continue;
            }
            
            BOOL bSucceed	= [fm removeItemAtPath:newspaperFolderPath error:&error];
            if (!bSucceed) {
                SNDebugLog(@"clearNewspaperlist: remove newspaper failed:%d,%@,path=%@"
                           ,[error code],[error localizedDescription],newspaperFolderPath);
            }
        }

    }
		
	return result;
}


-(BOOL)downloadNewspaperZip:(NewspaperItem*)newspaper delegate:(id)delegate
{
	if (newspaper == nil) {
		return NO;
	}
	
	if (newspaper.termZip == nil || [newspaper.termZip length] == 0) {
		return NO;
	}
	
	NewspaperZipRequestItem *newspaperZipRequest	= (NewspaperZipRequestItem *)([NewspaperZipRequestItem requestWithURL:newspaper.termZip delegate:self]);
	newspaperZipRequest.url		= newspaper.termZip;
	newspaperZipRequest.path	= [self generateCachePathByUrl:newspaper.termZip basePath:[self getNewspaperCachePath]];
	newspaperZipRequest.urlRequestDelegate	= delegate;
	newspaperZipRequest.newspaperInfo	= newspaper;
	newspaperZipRequest.cachePolicy		= TTURLRequestCachePolicyNone;
	newspaperZipRequest.response	= [[SNURLDataResponse alloc] init];
	newspaperZipRequest.nRetryCount	= 0;
	newspaperZipRequest.isAllowResume = YES;
    
	[_UrlRequestAry addObject:newspaperZipRequest];
	[newspaperZipRequest send];
	
	return YES;
}

-(BOOL)downloadNewspaperZipById:(NSString *)newspaperId delegate:(id)delegate
{
	NewspaperItem *newspaper		= [self getNewspaperByTermId:newspaperId];
	if (newspaper == nil) {
		return NO;
	}
	
	return [self downloadNewspaperZip:newspaper delegate:delegate];
}

-(NSString*)getNewsPaperFolderByTermId:(NSString*)tId
{
	NewspaperItem *newspaper	= [self getNewspaperByTermId:tId];
	if (newspaper == nil||[newspaper.newspaperPath length] == 0) {
		return nil;
	}
	
	NSFileManager *fm	= [NSFileManager defaultManager];
    NSString *realpath = [newspaper realNewspaperPath];
	if (![fm fileExistsAtPath:realpath]) {
		return nil;
	}
	
	NSRange rangeLastPath	= [realpath rangeOfString:@"/" options: NSBackwardsSearch];
	if (rangeLastPath.location == NSNotFound) {
		return nil;
	}
	
	NSString *newsFolder	= [realpath substringToIndex:rangeLastPath.location];
	if ([newsFolder length] == 0) {
		return nil;
	}
	
	return newsFolder;
}

@end
