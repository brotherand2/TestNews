//
//  SNDatabase+NickNameObj.h
//  sohunews
//
//  Created by guoyalun on 8/10/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase.h"

@interface SNDatabase (NickNameObj)

-(NSArray *)getAllNickNames;
-(BOOL)saveOrUpdateNickName:(NickNameObj *)nick;
-(BOOL)clearAllNickNames;
@end
