//
//  SNHotTableCell.h
//  sohunews
//
//  Created by ivan on 3/7/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNPhotoTableItem.h"

@interface SNPhotoTableCell : TTTableViewCell<TTURLRequestDelegate> {
    SNPhotoTableItem *item;
    //UIImageView *lastImageView;
    UIImageView *lastImageView;
    
    UIImageView *_cellSelectedBg;
    
    NSString *_currentTheme;
    NSString *_currentPicMode;
}

@property(nonatomic,strong)SNPhotoTableItem *item;
//@property(nonatomic,retain)UIImageView *lastImageView;
@property(nonatomic,strong)UIImageView *lastImageView;
@property(nonatomic, strong)NSMutableArray *newsIdArray;

//- (void)addImageFile:(NSString *)imagePath toImageView:(UIImageView *)imageView;
//- (UIImage *)fetchCachedImage:(NSString *)aPath rect:(CGRect)aRect;
-(void)changeFavNumLabel:(NSString *)text;
-(BOOL)isImagesLoaded;
-(void)changeTheme;
-(void)changeMask;
-(void)updateNonePicMode;
-(void)setReadStyleByMemory;
-(void)openNews;
- (BOOL)isThemeChanged;
- (BOOL)isPicModeChanged;

@end
