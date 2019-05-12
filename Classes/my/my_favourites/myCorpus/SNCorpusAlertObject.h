//
//  SNCorpusAlertObject.h
//  sohunews
//
//  Created by 李腾 on 2016/12/6.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SNClickItemOnHalfViewDelegate <NSObject>

- (void)clikItemOnHalfFloatView:(NSDictionary *)dict;

@end
@interface SNCorpusAlertObject : NSObject

@property (nonatomic, weak)id<SNClickItemOnHalfViewDelegate>delegate; //
@property (nonatomic, copy)NSString *entry;//统计用
@property (nonatomic, strong) NSArray *corpusListArray;

- (void)showCorpusAlertMenu:(BOOL)isMove;

+ (void)showEmptyCorpusAlert;

@end
