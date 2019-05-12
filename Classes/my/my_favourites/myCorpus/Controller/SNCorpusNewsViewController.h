//
//  SNCorpusNewsViewController.h
//  sohunews
//
//  Created by Scarlett on 15/8/28.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//


#import "SNTripletsLoadingView.h"
#import "SNLoadingImageAnimationView.h"

@interface SNCorpusNewsViewController : SNBaseViewController

@property (nonatomic, weak)UITableView *corpusNewsTableView;
@property (nonatomic, copy)NSString *corpusName;
@property (nonatomic, copy)NSString *corpusID;
@property (nonatomic, assign) NSInteger pageNum;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, weak)SNTripletsLoadingView *loadingView;
@property (nonatomic, strong)SNLoadingImageAnimationView *animationImageView;
@property (nonatomic, weak) UIView *backView;
@property (nonatomic, assign) BOOL notAutoPlay;
- (instancetype)initWithCustomFrame:(CGRect)frame;
- (void)getCorpusNewsList;
+ (void)clearData;

@end
