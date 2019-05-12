//
//  SNSmallCorpusView.h
//  sohunews
//
//  Created by Scarlett on 15/9/2.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNClickSmallCorpusDelegate;

@interface SNSmallCorpusView : UIView

- (void)setInfoWithCorpusName:(NSString *)corpusName isMove:(BOOL)isMove;

@property (nonatomic, weak)id<SNClickSmallCorpusDelegate> delegate;
@property (nonatomic, strong)NSString *entry;//统计用
@property (nonatomic, strong) NSArray *corpusListArray;

@end

@protocol SNClickSmallCorpusDelegate <NSObject>

- (void)clickSmallItemDelegate:(NSDictionary *)dict;
- (void)requestCorpusFinished;
- (void)corpusAlertDismiss;

@end
