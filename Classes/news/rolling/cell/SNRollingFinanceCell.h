//
//  SNRollingFinanceCell.h
//  sohunews
//
//  Created by lhp on 5/8/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRollingBaseCell.h"
#import "SNRollingNewsTableItem.h"

@class SNFinanceContentView;
@class SNFinanceMarkView;

@interface SNRollingFinanceCell : SNRollingBaseCell {
    SNFinanceMarkView *markView;
    SNFinanceContentView *leftContentView;
    SNFinanceContentView *rightContentView;
    SNFinanceContentView *financeEntryContentView;
}

@end
