//
//  SNDatabase+newsAudio.h
//  sohunews
//
//  Created by guoyalun on 5/6/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNDatabase.h"
#import "SNNewsAudio.h"

@interface SNDatabase (newsAudio)

-(NSArray*)getNewsAudioList;
-(NSArray*)getNewsAudioByTermId:(NSString*)termId newsId:(NSString*)newsId;
-(NSArray*)getNewsAudioByTermId:(NSString*)termId newsId:(NSString*)newsId inDatabase:(FMDatabase *)db;
-(SNNewsAudio *)getNewsAudioByUrl:(NSString*)url;

-(BOOL)addSingleNewsAudio:(SNNewsAudio*)newsAudio;
-(BOOL)addSingleNewsAudio:(SNNewsAudio*)newsAudio inDatabase:(FMDatabase *)db;
-(BOOL)addMultiNewsAudio:(NSArray*)newsAudioList;
-(BOOL)addMultiNewsAudio:(NSArray*)newsAudioList inDatabase:(FMDatabase *)db;

-(BOOL)deleteNewsAudioByUrl:(NSString*)url;
-(BOOL)deleteNewsAudioByNewsId:(NSString*)newsId;
-(BOOL)deleteNewsAudioByTermId:(NSString*)termId newsId:(NSString*)newsId inDatabase:(FMDatabase *)db;

@end
