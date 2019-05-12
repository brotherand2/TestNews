//
//  SNNewsMeLoginCell.h
//  sohunews
//
//  Created by wang shun on 2017/9/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SNNewsMeLoginCellDelegate;
@interface SNNewsMeLoginCell : UITableViewCell

@property (nonatomic,weak) id <SNNewsMeLoginCellDelegate> delegate;

- (void)update;

@end

@protocol SNNewsMeLoginCellDelegate <NSObject>

- (void)loginSuccess;

- (void)refreshTable;

- (void)reloadSohuHao;

@end;
