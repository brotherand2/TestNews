//
//  SNDatabase_NewsChannel.h
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase.h"
@interface SNDatabase(NewsChannel) 

-(NSArray*)getSelectedSubedNewsChannelList;
-(NSArray*)getSubedNewsChannelList;
-(NSArray*)getUnSubedNewsChannelList;
-(NSMutableArray*)getNewsChannelList;
-(NewsChannelItem*)getChannelById:(NSString*)aId;
-(BOOL)setNewsChannelList:(NSArray*)newsChannelList updateTopTime:(BOOL)update;
-(BOOL)clearNewsChannelList;
-(BOOL)updateNewsChannelIsSelected:(NSString *)isSelected channelID:(NSString *)channelID;
- (void)addOrDeleteNewsChannnelToDataBase:(NewsChannelItem *)item editMode:(BOOL)editMode;

@end
