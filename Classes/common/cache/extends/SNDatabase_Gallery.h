//
//  SNDatabase_Gallery.h
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "CacheObjects.h"
#import "SNDatabase.h"

@interface SNDatabase(Gallery)

-(GalleryItem*)getGalleryByTermId:(NSString*)termId newsId:(NSString*)newsId;
-(BOOL)addSingleGalleryOrUpdate:(GalleryItem*)gallery;
-(BOOL)addSingleGalleryIfNotExist:(GalleryItem*)gallery;
-(BOOL)addSingleGallery:(GalleryItem*)gallery updateIfExist:(BOOL)bUpdateIfExist;
-(BOOL)deleteGalleryByTermId:(NSString*)termId newsId:(NSString*)newsId;
-(BOOL)clearGalleryList;

-(BOOL)updateGalleryAsLikeByTermId:(NSString*)termId newsId:(NSString*)newsId likeCount:(NSString *)count;
- (BOOL)updateGalleryCmtReadByTermId:(NSString*)termId newsId:(NSString*)newsId hasRead:(BOOL)hasRead;

@end
