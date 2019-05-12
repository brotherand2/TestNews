//
//  SNPhotoFavModel.h
//  sohunews
//
//  Created by qi pei on 3/30/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNURLRequest.h"

@protocol SNPhotoFavModelDelegate <NSObject>

-(void)favRequestWillStart;

//statusCode-- 1:成功 2:重复提交 3:失败 4:离线-提交失败
-(void)favRequestFinished:(int)statusCode;

@end

@interface SNPhotoFavModel : NSObject {
    SNURLRequest *_favRequest;
    id<SNPhotoFavModelDelegate> delegate;
}
@property(nonatomic, assign)id<SNPhotoFavModelDelegate> delegate;

-(id)initWithDelegate:(id)aDelegate;
-(void)favoriteCurrentNews:(NSString *)newsId termId:(NSString *)termId;
-(void)cancelRequest;

@end
