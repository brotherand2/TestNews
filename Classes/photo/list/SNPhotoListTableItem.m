//
//  SNPhotoListTableItem.m
//  sohunews
//
//  Created by 雪 李 on 11-12-14.
//  Copyright (c) 2011年 Sohu.com Inc. All rights reserved.
//

#import "SNPhotoListTableItem.h"
#import "SNDBManager.h"
#import "SNPhotoListTableCell.h"
#import "SNUtility.h"
#import "SNThemeManager.h"
#import "SNLabel.h"

@implementation SNPhotoListTableItem
@synthesize index = _index;
@synthesize photo = _photo;
@synthesize cellHeight = _cellHeight;
@synthesize textHeight = _textHeight;
@synthesize image = _image;
@synthesize indexPath   = _indexPath;

- (void)heightForPhotoListItem
{
    if (self.cellHeight == 0) {
        NSString *abstract = [SNUtility stringTrimming:self.photo.abstract];
    
        if (_photo.height == 0 || _photo.width == 0)
        {
            self.imageHeight = kImageSizeHeight;
        }
        else
        {
            self.imageHeight = kImageSizeWidth/_photo.width * _photo.height;
        }
        if([abstract length] <= 0) {
            self.cellHeight =  self.imageHeight + kTextBottomOffset;
        } else {
            NSString *text = [NSString stringWithFormat:@"%@%@",kAbstractPrefix,abstract];
            CGPoint fontsize = [SNUtility getNewsFontSizePoint];
            CGFloat textHeight = [SNLabel heightForContent:text maxWidth:kImageSizeWidth font:fontsize.x lineHeight:fontsize.y];
            self.textHeight = textHeight;
            self.cellHeight = self.imageHeight + kImageBottomMargin + textHeight + kTextBottomOffset +8;
        }
    }
}

- (id)initWithItem:(PhotoItem *)item
{
    id obj = [super init];
    if (obj) {
        self.photo = item;
        self.cellHeight = 0;
        [self heightForPhotoListItem];
    }
    return obj;
}

-(void)dealloc
{
    TT_RELEASE_SAFELY(_photo);
    TT_RELEASE_SAFELY(_indexPath);
    [super dealloc];
}

@end
