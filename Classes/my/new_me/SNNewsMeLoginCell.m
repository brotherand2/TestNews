//
//  SNNewsMeLoginCell.m
//  sohunews
//
//  Created by wang shun on 2017/9/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsMeLoginCell.h"
#import "SNNewsMeLoginView.h"
#import "SNNewsMeUserInfoView.h"
#import "SNUserManager.h"
@interface SNNewsMeLoginCell ()<SNNewsMeLoginViewDelegate>

@property (nonatomic,strong)SNNewsMeUserInfoView* loginedView;//已登录
@property (nonatomic,strong)SNNewsMeLoginView* loginView;//未登录
@end

@implementation SNNewsMeLoginCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        [self createLoginedUI];
        [self createUI];
        
        [self loginSuccess];
    }
    return self;
}

-(void)update{
    [self loginSuccess];
}

- (void)createLoginedUI{
    SNNewsMeUserInfoView* view = [[SNNewsMeUserInfoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
    [self.contentView addSubview:view];
    self.loginedView = view;
}

//未登录UI
- (void)createUI{//
    SNNewsMeLoginView* view = [[SNNewsMeLoginView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 138)];
    view.delegate = self;
    [self.contentView addSubview:view];
    self.loginView = view;
}

- (void)loginSuccess{
    if ([SNUserManager isLogin]) {
        self.loginView.hidden = YES;
        self.loginedView.hidden = NO;
    }
    else{
        self.loginView.hidden = NO;
        self.loginedView.hidden = YES;
    }
    
    [self.loginedView update:nil];
}

-(void)refreshTable{
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadSohuHao)]) {
        [self.delegate reloadSohuHao];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshTable)]) {
        [self.delegate refreshTable];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
