//
//  SNRollingNewsBookShelfCell.h
//  sohunews
//
//  Created by H on 2016/11/7.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

@class SNBook;

@interface SNBookCover : UIView

@property (nonatomic, strong) UIImageView * bookCover;
@property (nonatomic, weak) id sourceController;

@property (nonatomic, strong) SNBook * book;

- (void)setHasRead:(BOOL)hasRead;

- (void)updateBook:(id)bookItem isEdit:(BOOL)isEditing;
@end
