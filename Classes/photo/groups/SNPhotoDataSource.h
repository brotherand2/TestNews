//
//  SNHotDataSource.h
//  sohunews
//
//  Created by ivan on 3/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNPhotoModel.h"
#import "SNPhotosTableController.h"
#import "SNNewsDataSource.h"

@interface SNPhotoDataSource : SNNewsDataSource {
    SNPhotoModel *hotPhotoModel;
}

@property(nonatomic, retain)SNPhotoModel *hotPhotoModel;
@property(nonatomic, assign)SNPhotosTableController *photosTableController;
@property(nonatomic, retain)NSMutableArray *newsIds;

-(id)initWithType:(NSString *)aType andId:(NSString *)aId 
       latestPage:(int)pageWhenViewReleased 
  lastMinTimeline:(NSString *)lastMinTimeline
       lastOffset:(NSString *)lastOffset;
-(id)initWithType:(NSString *)aType andId:(NSString *)aId;
-(void)changeFavNum:(int)favNum byNewsId:(NSString *)newsId;
-(void)changePhotoNewsReadStyle:(NSString *)newsId;

//-(void)freeCachedImages;

@end
