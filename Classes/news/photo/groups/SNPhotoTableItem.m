//
//  SNHotTableItem.m
//  sohunews
//
//  Created by ivan on 3/7/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNPhotoTableItem.h"
#import "SNPhotoTableOneCell.h"
#import "SNPhotoTableFourCell.h"


@implementation SNPhotoTableItem

@synthesize hotPhotoNews,imagesDic,indexPath,controller,allItems;

/*-(void)fetchCellImage:(NSString *)imagePath tag:(int)tag {
    TTURLRequest* request = [TTURLRequest requestWithURL: imagePath delegate: self];
    request.cachePolicy = TTURLRequestCachePolicyDefault;
    request.userInfo = [NSString stringWithFormat:@"%d", tag];
    request.response = [[[TTURLImageResponse alloc] init] autorelease];
    [request send];
}

- (void)cacheCellImageToMemory:(UIImage *)aImg urlPath:(NSString *)aPath {
    if (!self.imagesDic) {
        self.imagesDic = [NSMutableDictionary dictionary];
    }
    [self.imagesDic setObject:aImg forKey:aPath];
}

#pragma mark -
#pragma mark TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest*)request {
    
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
    TTURLImageResponse* imageResponse = (TTURLImageResponse*)request.response;
    int imageViewTag = [request.userInfo intValue];
    id obj = [self.controller.tableView cellForRowAtIndexPath:self.indexPath];
    if (obj) {
        UIImageView *_imageView = nil;
        if ([obj isKindOfClass:[SNPhotoTableOneCell class]]) {
            SNPhotoTableOneCell *cell = (SNPhotoTableOneCell *)obj;
            _imageView = (UIImageView *)[cell.contentView viewWithTag:imageViewTag];
        } else if ([obj isKindOfClass:[SNPhotoTableFourCell class]]) {
            SNPhotoTableFourCell *cell = (SNPhotoTableFourCell *)obj;
            _imageView = (UIImageView *)[cell.contentView viewWithTag:imageViewTag];
        }
        if (_imageView) {
            UIImage* clipedImageObj = [imageResponse.image cliptoSize:CGSizeMake(CGRectGetWidth(_imageView.frame), CGRectGetHeight(_imageView.frame))];
            _imageView.image = clipedImageObj;
            [self cacheCellImageToMemory:clipedImageObj urlPath:request.urlPath];
            _imageView.alpha = 0;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.8];
            _imageView.alpha = 1;
            [UIView commitAnimations];
        }
    }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
}

-(void)freeImagesDic {
     //(imagesDic);
}*/

-(void)dealloc {
    //[[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
     //(hotPhotoNews);
     //(imagesDic);
     //(indexPath);
     //(allItems);
}

@end
