//
//  SNFavoriteCollectionViewCell.m
//  sohunews
//
//  Created by 李腾 on 2016/11/5.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNFavoriteCollectionViewCell.h"

@implementation SNFavoriteCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.corpusVC = [[SNCorpusNewsViewController alloc] initWithCustomFrame:self.contentView.bounds];
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_corpusVC.view];
        
    }
    return self;
}

- (void)setFavoriteWithCorpusName:(NSString *)corpusName andCorpusId:(NSString *)corpusId {
    self.corpusVC.animationImageView.status = SNImageLoadingStatusLoading;
    self.corpusVC.loadingView.hidden = YES;
    self.corpusVC.backView.hidden = NO;
    if (self.corpusVC.emptyView) {
        [self.corpusVC.emptyView removeFromSuperview];
        self.corpusVC.emptyView = nil;
    }
    self.corpusVC.pageNum = 1;
    self.corpusVC.corpusName = corpusName;
    self.corpusVC.corpusID = corpusId;
   
}

- (void)dealloc {
    self.corpusVC = nil;
}


@end
