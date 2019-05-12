//
//  SNNovelShelfCell.m
//  sohunews
//
//  Created by qz on 16/04/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNNovelShelfCell.h"
#import "SNBookCover.h"
#import "SNNovelUtilities.h"
#import "SNStoryPageViewController.h"
#import "SNNovelShelfController.h"
#import "SNStoryUtility.h"

#define ImageY     (13)
#define leftX      (11)
#define padding (47.0/2)
#define imageRadio (252.0/204)
 
@interface SNNovelShelfCell (){
    CGFloat _imageWidth;
    CGFloat _midX;
    CGFloat _rightX;
    CGFloat _cellHeight;
}

@property (nonatomic,strong) SNBookCover *leftBookView;
@property (nonatomic,strong) SNBookCover *midBookView;
@property (nonatomic,strong) SNBookCover *rightBookView;

@end

@implementation SNNovelShelfCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imageWidth = [SNNovelUtilities shelfImageWidth];
        _midX = leftX + _imageWidth + padding;
        _rightX = _midX + _imageWidth + padding;
        _cellHeight = [SNNovelUtilities shelfCellHeight];
        [self initViews];
    }
    return self;
}

-(void)initViews{
    self.leftBookView = [[SNBookCover alloc] initWithFrame:CGRectMake(leftX, 0, _imageWidth, _cellHeight)];
    self.midBookView = [[SNBookCover alloc] initWithFrame:CGRectMake(_midX, 0, _imageWidth,_cellHeight )];
    self.rightBookView = [[SNBookCover alloc] initWithFrame:CGRectMake(_rightX, 0, _imageWidth, _cellHeight)];
    
    [self.contentView addSubview:_leftBookView];
    [self.contentView addSubview:_midBookView];
    [self.contentView addSubview:_rightBookView];
}

-(void)setSourceController:(id)sourceController{
    if (_sourceController != sourceController) {
        _sourceController = sourceController;
        
        if (_sourceController) {
            _leftBookView.sourceController = _sourceController;
            _midBookView.sourceController = _sourceController;
            _rightBookView.sourceController = _sourceController;
        }
    }
}

-(void)updateView:(NSArray *)array isEdit:(BOOL)isEditing indexPath:(NSIndexPath *)indexPath{
    
    NSArray *data = array[indexPath.row];
    
    if (data.count == 1) {
        self.leftBookView.hidden = NO;
        self.midBookView.hidden =
        self.rightBookView.hidden = YES;
        [_leftBookView updateBook:data[0] isEdit:isEditing];
    }else if (data.count == 2) {
        self.leftBookView.hidden =
        self.midBookView.hidden = NO;
        self.rightBookView.hidden = YES;
        [_leftBookView updateBook:data[0] isEdit:isEditing];
        [_midBookView updateBook:data[1] isEdit:isEditing];
    }else if (data.count == 3) {
        self.leftBookView.hidden =
        self.midBookView.hidden =
        self.rightBookView.hidden = NO;
        [_leftBookView updateBook:data[0] isEdit:isEditing];
        [_midBookView updateBook:data[1] isEdit:isEditing];
        [_rightBookView updateBook:data[2] isEdit:isEditing];
    }
    
    //书架动画frame判断(返回书架，总是在首位关闭),无网络，不修改动画
    if ([SNStoryUtility currentReachabilityStatusForStory] != StoryNetworkReachabilityStatusNotReachable) {
        if (indexPath.row == 0) {
            
            SNNovelShelfController *novelShelfController= (SNNovelShelfController *)_sourceController;
            novelShelfController.pageViewController.rectInBookshelf = [self.leftBookView.bookCover convertRect:self.leftBookView.bookCover.bounds toView:novelShelfController.view];
        }
    }

}

@end
