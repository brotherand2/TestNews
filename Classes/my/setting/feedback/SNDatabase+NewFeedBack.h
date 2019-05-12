//
//  SNDatabase+NewFeedBack.h
//  sohunews
//
//  Created by 李腾 on 2016/10/20.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNDatabase.h"
#import "SNFeedBackModel.h"


@interface SNDatabase (NewFeedBack)

-(BOOL)saveFeedBacksToDB:(NSMutableArray *)fbs;

-(NSMutableArray *)loadAllFeedBacks;

-(BOOL)addFeedBack:(SNFeedBackModel *)fb;

-(int)selectMaxRid;

-(int)lastInsertRowId;

-(void)updateFeedbackSendStatus:(int)status byId:(int)aId;

-(SNFeedBackModel *)queryFeedbackById:(int)fId;

-(BOOL)deleteFeedbackById:(int)fId;

-(BOOL)changeMyRecordUserName:(NSString *)newName;

- (BOOL)deleteAllFeedBacks;

@end
