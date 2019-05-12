//
//  SNPhotoListTableItem.h
//  sohunews
//
//  Created by 雪 李 on 11-12-14.
//  Copyright (c) 2011年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kImageSizeWidth                 (600.0/2)
#define kImageSizeHeight                (450.0/2)
#define kTextBottomOffset               (5.0)
#define kAbstractPrefix                 (@"      ")
#define kDefaultFontIndex 3
#define kInfoBottomMargin               (8)
#define kImageBottomMargin              (29.0/2)

//@class SNPhotoListController;
@class PhotoItem;
@protocol TTURLRequestDelegate;
@interface SNPhotoListTableItem : TTTableItem<TTURLRequestDelegate>
{
    int     _index;
    float   _cellHeight;
    float   _textHeight;
    PhotoItem *_photo;
    
    //内部使用
    UIImage  *_image;
    NSIndexPath *_indexPath;
}

@property(nonatomic,assign)int          index;
@property(nonatomic,assign)float        cellHeight;
@property(nonatomic,assign)float imageHeight;
@property(nonatomic,assign)float        textHeight;
@property(nonatomic,retain)PhotoItem    *photo;

//内部使用
@property(nonatomic,assign)UIImage      *image;
@property(nonatomic,retain)NSIndexPath  *indexPath;

- (id)initWithItem:(PhotoItem *)item;
- (void)heightForPhotoListItem;

@end
