//
//  SNNewsMeLoginView.m
//  sohunews
//
//  Created by wang shun on 2017/9/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsMeLoginView.h"
#import "SNNewsMeLoginItemCell.h"
#import "WXApi.h"
#import "SNNewsMeLoginModel.h"
#import "SNUserManager.h"
#import "SNNewsLoginManager.h"
#import "SNThirdLoginViewModel.h"
#import "SNNewsLoginSuccess.h"
#import "SNSLib.h"

@interface SNNewsMeLoginView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UILabel* titleLabel;

@property (nonatomic,strong) UICollectionView* collectionView;

@property (nonatomic,strong) SNNewsMeLoginModel* loginIconModel;//显示icon

@property (nonatomic,strong) SNThirdLoginViewModel* thirdLoginModel;//第三方登录

@end

@implementation SNNewsMeLoginView

- (void)dealloc{
    [SNNotificationManager removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = SNUICOLOR(kThemeMeLoginHeaderColor);
        self.loginIconModel = [[SNNewsMeLoginModel alloc] initData:nil];
        self.thirdLoginModel = [[SNThirdLoginViewModel alloc] init];
        
        [self createTitleLabel];
        [self createCollectView];
        
        //切换夜间模式 wangshun
        [SNNotificationManager addObserver:self selector:@selector(update:) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)update:(NSNotification*)noti{
    self.backgroundColor = SNUICOLOR(kThemeMeLoginHeaderColor);
}

- (void)createTitleLabel{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, self.bounds.size.width, 20)];
    [self addSubview:_titleLabel];
    
    self.titleLabel.text = @"一键登录，即可点评收藏文章";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    self.titleLabel.textColor = SNUICOLOR(kThemeText2Color);
}

- (void)createCollectView{
    CGFloat y = CGRectGetMaxY(self.titleLabel.frame)+18;
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
     layout.minimumLineSpacing = 21; // 水平方向的间距
    
    CGFloat w = 55;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, y, self.bounds.size.width, w) collectionViewLayout:layout];
    [self addSubview:_collectionView];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    [_collectionView registerClass:[SNNewsMeLoginItemCell class] forCellWithReuseIdentifier:@"SNNewsMeLoginItemCell"];
    
    _collectionView.alwaysBounceHorizontal = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    
}

#pragma mark -- UICollectionViewDataSource
/** 每组cell的个数*/
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.loginIconModel.dataArr.count;
}

/** cell的内容*/
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SNNewsMeLoginItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SNNewsMeLoginItemCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary* info = [self.loginIconModel.dataArr objectAtIndex:indexPath.row];
    [cell setInfo:info];
    return cell;
}

/** 总共多少组*/
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark -- UICollectionViewDelegateFlowLayout
/** 每个cell的尺寸*/
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(55, 55);
}

/** section的margin*/
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    //这逻辑谁能看懂 UI需求 wangshun
    CGFloat space = 23;//间隔23
    if ([[SNDevice sharedInstance] isPlus]) {
        space = space*1.1;
    }

    if (self.loginIconModel.dataArr.count ==4) {
        space = 30;
        if ([[SNDevice sharedInstance] isPlus]) {
            space = 30*1.1;
        }
    }
//
    CGFloat f_w = 19*2+55*self.loginIconModel.dataArr.count+space*(self.loginIconModel.dataArr.count-1);
    SNDebugLog(@"ddd:%f",f_w);
    SNDebugLog(@"sss:%f",[UIScreen mainScreen].bounds.size.width);
    
    if (f_w>[UIScreen mainScreen].bounds.size.width) {//放不下
        return UIEdgeInsetsMake(0, 19, 0, 19);
    }
    else{//能放下  则居中

        CGFloat left = ([UIScreen mainScreen].bounds.size.width-f_w)/2.0;
        return UIEdgeInsetsMake(0, left+19, 0, left+19);
    }

    //return UIEdgeInsetsMake(0, 19, 0, 19);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    if (self.loginIconModel.dataArr.count ==4) {
        if ([[SNDevice sharedInstance] isPlus]) {
            return 30*1.1;
        }
        return 30;
    }
    
    if ([[SNDevice sharedInstance] isPlus]) {
        return 23*1.1;
    }
    return 23;
}

#pragma mark -- UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {    
    if (![SNUserManager isLogin]) {
        SNNewsMeLoginItemCell* cell = (SNNewsMeLoginItemCell*)[collectionView cellForItemAtIndexPath:indexPath];
        NSDictionary* data = cell.dic;
        NSString* title = [data objectForKey:SNNewsMeLoginTitle];
        SNDebugLog(@"title:%@",title);
        if ([title isEqualToString:@"mobile"]) {//手机号
            [SNNewsLoginManager loginData:@{@"loginFrom":@"100039",@"entrance":@"8"} Successed:^(NSDictionary *info) {//111我的页面一键登录手机号登录
                if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccess)]) {
                    [self.delegate loginSuccess];
                }
            } Failed:nil];
        }
        else{
            NSString* sourceChannelID = @"100039";
            if (sourceChannelID && ![sourceChannelID isEqualToString:@"-1"]) {
                NSDictionary* dic = @{@"loginSuccess":@"0",@"cid":[SNUserManager getP1],@"screen":@"0"};
                SNDebugLog(@"sourceID:%@,dic:%@",sourceChannelID,dic);
                [SNSLib addCountForSohuNewsLoginEventWithKey:sourceChannelID bodyDic:dic];
            }
            
            
            NSString* agif = [NSString stringWithFormat:@"_act=pv&page=49&entrance=8"];
            [SNNewsReport reportADotGif:agif];
            SNDebugLog(@"me tab login agif:%@",agif);
            
            SNNewsLoginSuccess* loginSuccess = [[SNNewsLoginSuccess alloc] initWithParams:nil];
            loginSuccess.sourceChannelID = sourceChannelID?:@"";
            loginSuccess.loginSuccess = ^(NSDictionary *resultDic) {
                SNDebugLog(@"plat success:%@",title);
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccess)]) {
                    [self.delegate loginSuccess];
                }
                
                [self performSelector:@selector(refreshTable) withObject:nil afterDelay:0.25];
                
            };
            
            loginSuccess.loginCancel = ^(NSDictionary *resultDic) {
                
            };
        
            NSMutableDictionary* queryDic = [[NSMutableDictionary alloc] initWithCapacity:0];
            [queryDic setObject:loginSuccess forKey:@"loginSuccess"];
            [queryDic setObject:@"8" forKey:@"entrance"];
            [queryDic setObject:sourceChannelID forKey:@"loginFrom"];
            
            [self.thirdLoginModel thirdLoginWithName:title WithParams:queryDic Success:^(NSDictionary *resultDic) {
                if ([[resultDic objectForKey:@"success"] isEqualToString:@"1"]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (loginSuccess) {
                            [loginSuccess loginSucessed:nil];
                        }
                    });
                    
                }
                else{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (loginSuccess) {
                            [loginSuccess loginCancel:nil];
                        }
                    });
                }
            }];
        }
    }
}

- (void)refreshTable{
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshTable)]) {
        [self.delegate refreshTable];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
