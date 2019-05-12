//
//  SNFavoriteCollectionViewCell.h
//  sohunews
//
//  Created by 李腾 on 2016/11/5.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNCorpusNewsViewController.h"

@interface SNFavoriteCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) SNCorpusNewsViewController *corpusVC;

- (void)setFavoriteWithCorpusName:(NSString *)corpusName andCorpusId:(NSString *)corpusId;

@end
