//
//  SNDatabase_NewsChannel.m
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase_NewsChannel.h"
#import "SNChannelManageContants.h"

@implementation SNDatabase(NewsChannel)

-(NSArray*)getSelectedSubedNewsChannelList {
	__block NSArray *newsChannelArray = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        //3.3版本的选择条件是isChannelSubed='1' and isSelected='1'
        //3.4由于频道改为订阅处理，因此用户是否sub此频道变得不再重要，用户可以通过刊物列表操作离线数据。
        FMResultSet *rs	= [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM tbNewsChannel where %@='%@'",TB_NEWSCHANNEL_CHANNEL_ISSELECTED, kDownloadSettingItemSelected]];
        if ([db hadError]) {
            SNDebugLog(@"getSelectedSubedNewsChannelList : executeQuery error:%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        newsChannelArray = [self getObjects:[NewsChannelItem class] fromResultSet:rs limitCount:kChannelMaxVolum];
        [rs close];
    }];
	
	return newsChannelArray;
}

-(NSArray*)getSubedNewsChannelList {
    
	__block NSArray *newsChannelArray = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsChannel where isChannelSubed='1'"];
        if ([db hadError]) {
            SNDebugLog(@"getSubedNewsChannelList : executeQuery error:%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        newsChannelArray = [self getObjects:[NewsChannelItem class] fromResultSet:rs limitCount:kChannelMaxVolum];
        [rs close];
    }];
	
	return newsChannelArray;
}

-(NSArray*)getUnSubedNewsChannelList {
    
	__block NSArray *newsChannelArray = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsChannel where isChannelSubed!='1'"];
        if ([db hadError]) {
            SNDebugLog(@"getUnSubedNewsChannelList : executeQuery error:%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        newsChannelArray = [self getObjects:[NewsChannelItem class] fromResultSet:rs limitCount:kChannelMaxVolum];
        [rs close];
    }];
	
	return newsChannelArray;
}


-(NSMutableArray*)getNewsChannelList
{
	__block NSMutableArray *newsChannelArray = nil;
    
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsChannel"];
        if ([db hadError]) {
            SNDebugLog(@"getNewsChannelList : executeQuery error:%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        newsChannelArray = [self getObjects:[NewsChannelItem class] fromResultSet:rs limitCount:kChannelMaxVolum];
        [rs close];
    }];
    
	return newsChannelArray;
}

-(NewsChannelItem*)getChannelById:(NSString*)aId
{
    __block NewsChannelItem* _newsChannelItem	 = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db)
     {
         FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:SN_String("SELECT * FROM %@ WHERE channelID=?"), @"tbNewsChannel"], aId];
         if ([db hadError]) {
             SNDebugLog(@"%@--%@ : ExecuteQuery error:%d, %@.", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage]);
             return;
         }
         _newsChannelItem	= [self getFirstObject:[NewsChannelItem class] fromResultSet:rs];
         [rs close];
     }];
    return _newsChannelItem;
}

-(BOOL)setNewsChannelList:(NSArray*)newsChannelList updateTopTime:(BOOL)update
{	
	if ([newsChannelList count] == 0) {
		SNDebugLog(@"setNewsChannelList : Invalid newsChannelList");
		return NO;
	}
	__block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        //备份之前下载设置中频道的选中状态=============
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from %@ ", TB_NEWSCHANNEL]];
        if ([db hadError]) {//这个备份失败不应该影响频道数据的保存，所以没有return、rollback以及设置result=NO;
            SNDebugLog(@"===Failed to backup selected channels with error:%d , %@",[db lastErrorCode],[db lastErrorMessage]);
        }
        NSArray *_selectedNewsChannelArray = [self getObjects:[NewsChannelItem class] fromResultSet:rs];
        [rs close];
        //========================================
        
        result = [db executeUpdate:@"DELETE FROM tbNewsChannel"];
        if ([db hadError])
        {
            SNDebugLog(@"setNewsChannelList: executeUpdate clear current news channel list error %d : %@",[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
        NSInteger index = 0;
        for (NewsChannelItem *item in  newsChannelList) {
            if (update) {
                NSString *currentDateString = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
                result = [db executeUpdate:@"INSERT INTO tbNewsChannel (name,channelID,channelIcon,channelType,isChannelSubed,channelPosition,channelTop,channelTopTime,lastModify,currPosition,localType,isRecom,tips,tipsInterval,link,gbcode,serverVersion,channelCategoryName,channelCategoryID,channelIconFlag,channelShowType,isMixStream) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",item.channelName,item.channelId,item.channelIcon,item.channelType,item.isChannelSubed == nil?@"0":item.isChannelSubed,item.channelPosition,item.channelTop,currentDateString,item.lastModify,item.currPosition,item.localType,item.isRecom,item.tips,@(item.tipsInterval),item.link,item.gbcode,item.serverVersion,item.channelCategoryName,item.channelCategoryID, item.channelIconFlag,item.channelShowType, @(item.isMixStream)];
            } else {
                result = [db executeUpdate:@"INSERT INTO tbNewsChannel (name,channelID,channelIcon,channelType,isChannelSubed,channelPosition,channelTop,currPosition,localType,isRecom,tips,tipsInterval,link,gbcode,serverVersion,channelCategoryName,channelCategoryID,channelIconFlag,channelShowType,isMixStream) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",item.channelName,item.channelId,item.channelIcon,item.channelType,item.isChannelSubed == nil?@"0":item.isChannelSubed,item.channelPosition,item.channelTop,item.currPosition,item.localType,item.isRecom,item.tips,@(item.tipsInterval),item.link,item.gbcode,item.serverVersion,item.channelCategoryName,item.channelCategoryID, item.channelIconFlag,item.channelShowType,@(item.isMixStream)];
            }
            
            if ([db hadError]) {
                SNDebugLog(@"setNewsChannelList: executeUpdate error %d , %@,item:%@",[db lastErrorCode],[db lastErrorMessage],item);
                *rollback = YES;
                return;
            }
            if (++index >= kChannelMaxVolum) {
                break ;
            }
        }
        
        //恢复之前下载设置中频道的选中状态====
        for (NewsChannelItem *_selectedNewsChannelItem in _selectedNewsChannelArray) {
            if (!update) {
                //update == NO 的时候要把恢复topTime 和 lastModify 回退回去
                result = [db executeUpdate:[NSString stringWithFormat:@"update %@ set %@=?,%@ =?,%@=? where %@=?",
                                            TB_NEWSCHANNEL, TB_NEWSCHANNEL_CHANNEL_ISSELECTED,TB_NEWSCHANNEL_CHANNELTOPTIME,TB_NEWSCHANNEL_CHANNEL_LAST_MODIFY,TB_NEWSCHANNEL_CHANNELID ],_selectedNewsChannelItem.isSelected,_selectedNewsChannelItem.channelTopTime,_selectedNewsChannelItem.lastModify,
                                             _selectedNewsChannelItem.channelId];
            } else {
                result = [db executeUpdate:[NSString stringWithFormat:@"update %@ set %@=? where %@=?",
                                            TB_NEWSCHANNEL, TB_NEWSCHANNEL_CHANNEL_ISSELECTED,TB_NEWSCHANNEL_CHANNELID], _selectedNewsChannelItem.isSelected,
                                             _selectedNewsChannelItem.channelId];
            }
            if ([db hadError]) {//这个恢复失败也不应该影响频道数据的保存，所以没有return、rollback以及设置result=NO;
                SNDebugLog(@"Failed to recover selected channels with error: %d , %@",[db lastErrorCode],[db lastErrorMessage]);
                result = NO;
                break;
            }
        }
        //========================================
        
        if (update) {
            [SNUserDefaults setBool:YES forKey:kChannelEdit];
        }
    }];
	return result;
}

- (void)addOrDeleteNewsChannnelToDataBase:(NewsChannelItem *)item editMode:(BOOL)editMode {
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *currentDateString = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        if (editMode) {
            [db executeUpdate:@"DELETE FROM tbNewsChannel WHERE channelID=?", item.channelId];//避免重复数据
            [db executeUpdate:@"INSERT INTO tbNewsChannel (name,channelID,channelIcon,channelType,isChannelSubed,channelPosition,channelTop,channelTopTime,lastModify,currPosition,localType,isRecom,tips,tipsInterval,link,gbcode,channelCategoryName,channelCategoryID,channelIconFlag,channelShowType) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",item.channelName,item.channelId,item.channelIcon,item.channelType,item.isChannelSubed == nil?@"0":item.isChannelSubed,item.channelPosition,item.channelTop,currentDateString,item.lastModify,item.currPosition,item.localType,item.isRecom,item.tips,@(item.tipsInterval),item.link,item.gbcode,item.channelCategoryName,item.channelCategoryID, item.channelIconFlag,item.channelShowType];
        }
        else {
            [db executeUpdate:@"DELETE FROM tbNewsChannel WHERE channelID=?", item.channelId];
        }
        if ([db hadError]) {
            SNDebugLog(@"database error");
        }
    }];
}

-(BOOL)clearNewsChannelList
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbNewsChannel"];
        if ([db hadError])
        {
            SNDebugLog(@"clearNewsChannelList: executeUpdate error %d : %@",[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
	return result;
}

-(BOOL)updateNewsChannelIsSelected:(NSString *)isSelected channelID:(NSString *)channelID {
    __block BOOL result = NO;
    [[SNDatabase writeQueue] inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:[NSString stringWithFormat:@"update %@ set %@=? where %@=?",
                                    TB_NEWSCHANNEL, TB_NEWSCHANNEL_CHANNEL_ISSELECTED, TB_NEWSCHANNEL_CHANNELID], isSelected, channelID];
    }];
    return result;
}

@end
