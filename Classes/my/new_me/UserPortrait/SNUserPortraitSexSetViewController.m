//
//  SNUserPortraitSexSetViewController.m
//  sohunews
//
//  Created by iOS_D on 2016/12/22.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNUserPortraitSexSetViewController.h"
#import "SNUserPortraitinterestView.h"
#import "SNUserPortraitIntroViewController.h"
#import "SNUserPortraitSexSelectBtn.h"
#import "SNFacePreferenceRequest.h"
#import "SNUserManager.h"
//#import "JKNotificationCenter.h"
#import <JsKitFramework/JKNotificationCenter.h>
#import "SNSubmitPreferenceRequest.h"

@interface SNUserPortraitSexSetViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,SNUserPortraitSexSelectBtnDelegate>

@property (nonatomic,strong) SNUserPortraitSexSelectBtn* boyBtn;
@property (nonatomic,strong) SNUserPortraitSexSelectBtn* grilBtn;

@property (nonatomic,strong) UIImageView* boyYes;
@property (nonatomic,strong) UIImageView* grilYes;

@property (nonatomic,strong) UILabel* grilLabel;
@property (nonatomic,strong) UILabel* boyLabel;

@property (nonatomic,strong) UILabel* selectSexLabel;

@property (nonatomic,strong) UILabel* leftTitleLabel;
@property (nonatomic,strong) UILabel* rightTitleLabel;

@property (nonatomic,strong) UIButton* nextBtn;
@property (nonatomic,strong) UIButton* finishedBtn;

@property (nonatomic,strong) UIView* sexBgView;

@property (nonatomic,strong) UICollectionView* collectionView;

@property (nonatomic,strong) NSMutableArray* selectedArray;

@property (nonatomic,strong) NSMutableArray* interestList;//genderList
@property (nonatomic,strong) NSMutableArray* genderList;
@property (nonatomic,assign) NSInteger maxNum;
@property (nonatomic,assign) BOOL isOld;
@property (nonatomic,assign) BOOL isLoadingSubmitPreference;
@property (nonatomic,strong) NSString* gender;
@property (nonatomic,strong) NSString* h5;

@end

@implementation SNUserPortraitSexSetViewController

-(id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
    if (self = [super initWithNavigatorURL:URL query:query]) {
        NSString* old = [query objectForKey:@"old"];
        //if ([old isEqualToString:@"0"]) { 原来是这样的
        if ([old isEqualToString:@"0"]) {
            self.isOld = YES;
            //只有老用户未确定才需要选择性别
            NSString* sex = [query objectForKey:@"gender"];
            if (sex && sex.length>0) {
                self.gender = sex;
            }
            //@"from":@"h5"
        }
        else{
            self.isOld = NO;
        }

        //原来是这样的
        NSString* h5 = [query objectForKey:@"from"];
        if ([h5 isEqualToString:@"h5"]) {
            self.h5 = @"1";
            self.isOld = NO;
            NSString* sex = [query objectForKey:@"gender"];
            if (sex && sex.length>0) {
                self.gender = sex;
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _selectedArray = [[NSMutableArray alloc] initWithCapacity:0];
    _interestList = [[NSMutableArray alloc] initWithCapacity:0];
    _genderList = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self createTitleView];//titleView
    
    [self createSexSetView];//性别选择

    [self addToolbar];//返回
    
    [self getpreferenceData];
}

//点击头像
- (void)click:(SNUserPortraitSexSelectBtn*)b{
    if (b.selected == YES) {
        return;
    }
    
    b.selected = !b.selected;
    if (b == self.boyBtn) {
        [self selectedBoyAndGril:@"m"];
    }
    else if(b == self.grilBtn){
         [self selectedBoyAndGril:@"f"];
    }
    
    if (self.isOld == YES) {
        return;
    }
    
    [self openInterest];//打开兴趣选择
}

- (void)selectedBoyAndGril:(NSString*)g{
    if ([g isEqualToString:@"m"]) {
        self.boyYes.hidden = NO;
        self.grilYes.hidden = YES;
        self.grilBtn.selected = NO;
        self.boyBtn.selected = YES;
        
        self.boyLabel.textColor = SNUICOLOR(kThemeRed1Color);
        self.grilLabel.textColor = SNUICOLOR(kThemeText3Color);
    }
    else if ([g isEqualToString:@"f"]){
        self.grilYes.hidden = NO;
        self.boyYes.hidden = YES;
        self.boyBtn.selected = NO;
        self.grilBtn.selected = YES;
        
        self.grilLabel.textColor = SNUICOLOR(kThemeRed1Color);
        self.boyLabel.textColor = SNUICOLOR(kThemeText3Color);
    }
}

- (void)changeTitleStatus{
    if (self.selectSexLabel == self.leftTitleLabel) {
        self.selectSexLabel = self.rightTitleLabel;
        self.rightTitleLabel.textColor = SNUICOLOR(kThemeText2Color);
        self.leftTitleLabel.textColor = SNUICOLOR(kThemeText3Color);
    }
    else{
        self.selectSexLabel = self.rightTitleLabel;
        self.rightTitleLabel.textColor = SNUICOLOR(kThemeText2Color);
        self.leftTitleLabel.textColor = SNUICOLOR(kThemeText3Color);
    }
}

- (void)openInterest{
    CGFloat y = CGRectGetMaxY(self.selectSexLabel.frame)+10;
    if (self.sexBgView.frame.origin.y != y) {
        
        _nextBtn.hidden = YES;
        
        CGFloat man_width = 63;
        CGFloat middle_width = 55;
        CGFloat x = (self.view.bounds.size.width-(man_width*2+middle_width))/2;
        
        CGFloat b_width = kThemeFontSizeC+3;
        CGFloat b_x = (man_width-b_width)/2;
        CGFloat b_y = CGRectGetMaxY(CGRectMake(x, 0, man_width, man_width));
        
        CGFloat b_yes_f = man_width/119.0;
        CGFloat b_yes_w = b_yes_f * 23;
        CGFloat b_yes_x = b_yes_f * 85;
        CGFloat b_yes_y = b_yes_f * 96;
        
        CGFloat bgView_h = 180* b_yes_f;
        
        [UIView animateWithDuration:0.25 animations:^{
            
            self.sexBgView.frame = CGRectMake(0, y, self.view.bounds.size.width, bgView_h);
            self.boyBtn.frame = CGRectMake(x, 0, man_width, man_width);
            self.boyYes.frame = CGRectMake(b_yes_x+CGRectGetMinX(self.boyBtn.frame), b_yes_y, b_yes_w, b_yes_w);
         
            self.grilBtn.frame = CGRectMake(CGRectGetMaxX(self.boyBtn.frame)+middle_width, 0, man_width, man_width);
            self.grilYes.frame = CGRectMake(b_yes_x+CGRectGetMinX(self.grilBtn.frame), b_yes_y, b_yes_w, b_yes_w);
            
            self.boyLabel.frame = CGRectMake(b_x+CGRectGetMinX(self.boyBtn.frame), b_y+3, b_width, b_width);
            self.grilLabel.frame = CGRectMake(b_x+CGRectGetMinX(self.grilBtn.frame), b_y+3, b_width, b_width);
            
            self.boyLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
            self.grilLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
            
//            self.collectionView.frame = CGRectMake(0, y+bgView_h, self.view.bounds.size.width, self.view.bounds.size.height-CGRectGetMaxY(self.selectSexLabel.frame)-100);
            
        } completion:^(BOOL finished) {
            
            [self createCollectionView];
            
            [self changeTitleStatus];
            
            [self createFinishedBtn];
        }];
    }
}

- (void)jumpClick:(UIButton*)b{
    //http://jira.sohuno.com/browse/NEWSCLIENT-16951?filter=-1 wangshun 改bug
    [(SNNavigationController *)self.flipboardNavigationController setOnlyAnimation:YES];
    
    NSString* urlString = SNLinks_Path_FaceH5;
    [SNUtility openProtocolUrl:urlString context:@{kUniversalWebViewType:[NSNumber numberWithInteger:UserPortraitWebViewType]}];
}

- (void)nextStep:(UIButton*)btn{
    if ([self.h5 isEqualToString:@"1"]) {
        [self openInterest];
        return;
    }
    //如果老用户 不确定性别走这里
    [self submitPreference:nil WithBlock:^(BOOL b){
 
        if (b ==YES) {
            [self openUserIntro];
        }
    }];
}

- (void)finishedClick:(UIButton*)btn{
    
    if (_selectedArray.count>0) {
        if ([self.h5 isEqualToString:@"1"]) {
            [self submitPreference:nil WithBlock:^(BOOL b){
                [self jumpClick:nil];
            }];
        }
        else{
            [self submitPreference:nil WithBlock:^(BOOL b){
                [self openUserIntro];
            }];//submitPreference
        }
    }
    else{
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"选择兴趣标签后开启" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
}

- (void)openUserIntro{
    NSDictionary* dic = @{@"maxNum":[NSNumber numberWithInteger:self.maxNum]};
    TTURLAction *action = [[TTURLAction actionWithURLPath:@"tt://userPortraitIntro"] applyAnimated:YES];
    [action applyQuery:dic];
    [[TTNavigator navigator] openURLAction:action];
}

- (void)createFinishedBtn{
    
    CGFloat y = CGRectGetMinY(_toolbarView.frame)-55;
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.bounds.size.width, 55)];
    [v setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:v];
    
    UIView* bgv = [[UIView alloc] initWithFrame:v.bounds];
    bgv.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kBackgroundColor];
    bgv.alpha = 1;
    [v addSubview:bgv];
    
    _finishedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_finishedBtn setBackgroundColor:[UIColor clearColor]];
    _finishedBtn.layer.cornerRadius = 3;
    _finishedBtn.layer.borderColor = SNUICOLOR(kThemeText2Color).CGColor;
    _finishedBtn.layer.borderWidth = 1;
    _finishedBtn.frame = CGRectMake((v.bounds.size.width-140)/2, (56-34)/2, 140, 34);
    //finishBtn.frame = CGRectMake(0, 0, 140, 34);
    //finishBtn.center = v.center;
    [_finishedBtn setTitle:@"完成" forState:UIControlStateNormal];
    [_finishedBtn setTitleColor:SNUICOLOR(kThemeText2Color) forState:UIControlStateNormal];
    [_finishedBtn addTarget:self action:@selector(finishedClick:) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:_finishedBtn];
}

- (void)createCollectionView{
    
    CGFloat height = CGRectGetMinY(_toolbarView.frame)-CGRectGetMaxY(self.sexBgView.frame);
    CGRect rect = CGRectMake(0, CGRectGetMaxY(self.sexBgView.frame), self.view.bounds.size.width, height);
    
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.sexBgView.frame)-1, self.view.bounds.size.width, 1)];
    [line setBackgroundColor:SNUICOLOR(kThemeRed1Color)];
    [line setAlpha:0.1];
    [self.view addSubview:line];
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.footerReferenceSize = CGSizeMake(self.view.bounds.size.width, 55);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.alwaysBounceVertical =YES;
    [self.view addSubview:_collectionView];
    
    NSString* cellId = @"cellId";
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellId];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    [self.collectionView reloadData];

}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.interestList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* cellId = @"cellId";
    UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    CGFloat s_width = [UIScreen mainScreen].bounds.size.width;
    CGFloat i_width = s_width/3.0;
    CGFloat v_width = s_width*(130/720.0);
    
    SNUserPortraitinterestView* view = (SNUserPortraitinterestView*)[cell viewWithTag:12306];
    if (view == nil) {
        view = [[SNUserPortraitinterestView alloc] initWithFrame:CGRectMake((i_width-v_width)/2, (i_width-v_width)/2, v_width, v_width)];
        view.tag = 12306;
        [cell addSubview:view];
    }
    
    NSDictionary* each_cell = [self.interestList objectAtIndex:indexPath.row];
    view.info = each_cell;
    BOOL b = [self isSelectedCellData:each_cell];
    view.isSelected = b;
    
    return cell;
}

// 设置headerView和footerView的
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        reusableView = header;
    }
    reusableView.backgroundColor = [UIColor clearColor];
    if (kind == UICollectionElementKindSectionFooter)
    {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        footerview.backgroundColor = [UIColor clearColor];
        reusableView = footerview;
    }
    return reusableView;
}

#pragma mark - didSelectItemAtIndexPath

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIView* v = [cell viewWithTag:12306];
    if ([v isKindOfClass:[SNUserPortraitinterestView class]]) {
        SNUserPortraitinterestView* view = (SNUserPortraitinterestView*)v;
        view.isSelected = !view.isSelected;
        NSString* tagId = [NSString stringWithFormat:@"%@",[view.info objectForKey:@"tagId"]];
        if (view.isSelected == YES) {
            [_selectedArray addObject:tagId];
        }
        else{
            if (_selectedArray.count>0) {
                NSMutableIndexSet* set = [[NSMutableIndexSet alloc] init];
                for (int i=0;i< _selectedArray.count;i++) {
                    NSString* str = [_selectedArray objectAtIndex:i];
                    if([str isEqualToString:tagId]){
                        [set addIndex:i];
                    }
                }
                [_selectedArray removeObjectsAtIndexes:set];
            }
        }
        
        if (_selectedArray.count>0) {
            self.finishedBtn.layer.borderColor = SNUICOLOR(kThemeRed1Color).CGColor;
            [self.finishedBtn setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
        }
        else{
            self.finishedBtn.layer.borderColor = SNUICOLOR(kThemeText2Color).CGColor;
            [self.finishedBtn setTitleColor:SNUICOLOR(kThemeText2Color) forState:UIControlStateNormal];
        }
    }
}

#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat s_width = [UIScreen mainScreen].bounds.size.width;
    CGFloat i_width = s_width/3;
    return (CGSize){i_width,i_width};
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return (CGSize){self.view.bounds.size.width,0};
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return (CGSize){self.view.bounds.size.width,55};
}

- (void)createSexSetView{
    CGFloat bb = (self.view.bounds.size.width/750.0);//UI给的设计比例
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxX(self.selectSexLabel.frame), self.view.bounds.size.width, self.view.bounds.size.height-CGRectGetMaxX(self.selectSexLabel.frame)-49)];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:view];
    self.sexBgView = view;
    
    CGFloat man_width = 119*2*bb;
    CGFloat middle_width = 120*bb;
    CGFloat x = (self.view.bounds.size.width-(man_width*2+middle_width))/2;
    
    SNUserPortraitSexSelectBtn* _boy = [[SNUserPortraitSexSelectBtn alloc] initWithFrame:CGRectMake(x, 0, man_width, man_width) WithImage:@"icofiction_boy_v5.png"];
    _boy.delegate = self;
    [view addSubview:_boy];
    self.boyBtn = _boy;
    
    CGFloat b_yes_f = man_width/119.0;
    CGFloat b_yes_w = b_yes_f * 23;
    CGFloat b_yes_x = b_yes_f * 85;
    CGFloat b_yes_y = b_yes_f * 96;
    
    UIImageView* _boy_yes = [[UIImageView alloc] initWithFrame:CGRectMake(b_yes_x+CGRectGetMinX(_boy.frame), b_yes_y, b_yes_w, b_yes_w)];
    [_boy_yes setImage:[UIImage themeImageNamed:@"icofiction_xz_v5.png"]];
    _boy_yes.hidden = YES;
    [view addSubview:_boy_yes];
    self.boyYes = _boy_yes;
    
    CGFloat b_width = 30+3;
    CGFloat b_x = (man_width-b_width)/2;
    CGFloat b_y = CGRectGetMaxY(_boy.frame);
    
    UILabel* _boylabel = [[UILabel alloc] initWithFrame:CGRectMake(b_x+CGRectGetMinX(_boy.frame), b_y+25, b_width, b_width)];
    _boylabel.text = @"男";
    _boylabel.font = [UIFont systemFontOfSize:b_width];
    [view addSubview:_boylabel];
    self.boyLabel = _boylabel;
    
    /*
     [_boy setImage:[UIImage themeImageNamed:@"icofiction_boy_v5.png"] forState:UIControlStateNormal];
     [_boy setImage:[UIImage themeImageNamed:@"icofiction_boypress_v5.png"] forState:UIControlStateHighlighted];
     [_boy setImage:[UIImage themeImageNamed:@"icofiction_boypress_v5.png"] forState:UIControlStateSelected];
     */
    
    SNUserPortraitSexSelectBtn* _girl = [[SNUserPortraitSexSelectBtn alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_boy.frame)+middle_width, 0, man_width, man_width) WithImage:@"icofiction_girl_v5.png"];
    _girl.delegate = self;
    [view addSubview:_girl];
    self.grilBtn = _girl;
    
    UIImageView* _girl_yes = [[UIImageView alloc] initWithFrame:CGRectMake(b_yes_x+CGRectGetMinX(_girl.frame), b_yes_y, b_yes_w, b_yes_w)];
    [_girl_yes setImage:[UIImage themeImageNamed:@"icofiction_xz_v5.png"]];
    _girl_yes.hidden = YES;
    [view addSubview:_girl_yes];
    self.grilYes = _girl_yes;
    
    UILabel* _grilabel = [[UILabel alloc] initWithFrame:CGRectMake(b_x+CGRectGetMinX(_girl.frame), b_y+25, b_width, b_width)];
    _grilabel.text = @"女";
    _grilabel.font = [UIFont systemFontOfSize:b_width];
    [view addSubview:_grilabel];
    self.grilLabel = _grilabel;
    
    self.boyLabel.textColor = SNUICOLOR(kThemeText3Color);
    self.grilLabel.textColor = SNUICOLOR(kThemeText3Color);
    
    
    CGFloat b = (self.view.bounds.size.height/1280.0);
    CGFloat b_w = (self.view.bounds.size.width/720.0);
    CGFloat y = 134*b;
    CGFloat w = 277*b_w;
    CGFloat x_b = (self.view.bounds.size.width-w)/2;
    CGFloat h = b*76;
    
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    _nextBtn.frame = CGRectMake(x_b, CGRectGetMaxY(_boylabel.frame) +y, w, h);
    [_nextBtn setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
    _nextBtn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeE];
    _nextBtn.layer.borderColor = SNUICOLOR(kThemeRed1Color).CGColor;
    _nextBtn.layer.borderWidth = 1;
    _nextBtn.layer.cornerRadius = 3;
    [_nextBtn addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_nextBtn];
    
    if (self.isOld == YES) {//默认
        [self selectedBoyAndGril:self.gender];
    }
    else{
        _nextBtn.hidden = NO;
    }
    
    if ([self.h5 isEqualToString:@"1"]) {
        [self selectedBoyAndGril:self.gender];
    }
}

- (void)createTitleView{
    
    CGFloat originY = 27;
    CGFloat originY1 = 54;
    if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
        originY += 24;
        originY1 += 24;
    }
    UIButton* jumpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    jumpBtn.frame = CGRectMake(self.view.bounds.size.width-50-14, originY, 50, 21);
    jumpBtn.backgroundColor = [UIColor clearColor];
    [jumpBtn setTitle:@"跳过" forState:UIControlStateNormal];
    [jumpBtn setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
    jumpBtn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    [jumpBtn addTarget:self action:@selector(jumpClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:jumpBtn];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, originY1, self.view.bounds.size.width-48, 30)];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:30]];
    [titleLabel setText:@"选择阅读偏好"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = SNUICOLOR(kThemeText1Color);
    [self.view addSubview:titleLabel];
    
    UIDevicePlatform t = [[UIDevice currentDevice] platformTypeForScreen];
    CGFloat f = kThemeFontSizeE;
    if (t == UIDevice5SiPhone || t == UIDevice4SiPhone) {
        f = kThemeFontSizeD;
    }
    
    CGFloat width = (self.view.bounds.size.width-48)/2;
    _leftTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(titleLabel.frame)+10, width, kThemeFontSizeE+3)];
    _leftTitleLabel.font = [UIFont systemFontOfSize:f];
    _leftTitleLabel.textColor = SNUICOLOR(kThemeText2Color);
    _leftTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_leftTitleLabel];
    _leftTitleLabel.text = @"第一步：选择性别";
    self.selectSexLabel = _leftTitleLabel;
    
    _rightTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_leftTitleLabel.frame), CGRectGetMaxY(titleLabel.frame)+10, width, kThemeFontSizeE+3)];
    _rightTitleLabel.font = [UIFont systemFontOfSize:f];
    _rightTitleLabel.textColor = SNUICOLOR(kThemeText3Color);
    _rightTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_rightTitleLabel];
    _rightTitleLabel.text = @"第二步：选择兴趣";
}

- (void)addToolbar
{
    _toolbarView = [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - [SNToolbar toolbarHeight], kAppScreenWidth, [SNToolbar toolbarHeight])];
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setAccessibilityLabel:@"返回"];
    [_toolbarView setLeftButton:leftButton];
    
    [self.view addSubview:_toolbarView];
}


#pragma mark - didReceiveMemoryWarning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getpreferenceData{
    //    api/face/preference.go
    
    [[[SNFacePreferenceRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"getpreferenceData result:%@",responseObject);
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSString* statusCode = [responseObject objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"30130000"]) {
                NSDictionary* data = [responseObject objectForKey:@"data"];
                if (data && [data isKindOfClass:[NSDictionary class]]) {
                    NSArray* arr = [data objectForKey:@"tagList"];
                    if (arr && arr.count>0) {
                        [self.interestList removeAllObjects];
                        [self.interestList addObjectsFromArray:arr];
                    }
                    arr = [data objectForKey:@"genderList"];
                    if (arr && arr.count>0) {
                        [self.genderList removeAllObjects];
                        [self.genderList addObjectsFromArray:arr];
                    }
                    
                    NSNumber* num = [data objectForKey:@"maxNum"];

                    if (num && num.integerValue>0) {

                        self.maxNum = num.integerValue;
                    }
                }
            }
        }
        [self.collectionView reloadData];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error);
    }];
}

- (void)submitPreference:(NSDictionary*)dic WithBlock:(void (^)(BOOL b)) method{
//    /api/face/submitPreference.go
    if (self.isLoadingSubmitPreference == YES) {
        return;
    }
    
    NSString* m = @"";
    //
    //    gender 可选	String
    //    gender 性别 m=男,f=女
    if (self.boyBtn.selected == YES) {
        m = @"m";
    }
    else if (self.grilBtn.selected == YES){
        m = @"f";
    }
    
//    tagIds	String	
//    兴趣标签id 字符串,多个 id 以英文逗号隔开
    NSString* tagIds = @"";
    if (self.selectedArray.count>0) {
        tagIds = [self.selectedArray componentsJoinedByString:@","];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:m forKey:@"gender"];
    [params setValue:tagIds forKey:@"tagIds"];
    
    [[[SNSubmitPreferenceRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        self.isLoadingSubmitPreference = NO;
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSString* statusCode = [responseObject objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"30130000"]) {
                
                if ([self.h5 isEqualToString:@"1"]) {//成功要唤起h5一下
                    [[JKNotificationCenter defaultCenter] dispatchNotification:@"com.sohu.newssdk.action.changedPreference" withObject:nil];
                }
                if (method) {
                    method(YES);
                }
            } else {
                NSString* statusMsg = [responseObject objectForKey:@"statusMsg"];
                [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
            }
        } else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"接口异常" toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        self.isLoadingSubmitPreference = NO;
        if (method) {
            method(NO);
        }
    }];
    
    self.isLoadingSubmitPreference = YES;
}

- (BOOL)isSelectedCellData:(NSDictionary*)info{
    NSString* tagId = [NSString stringWithFormat:@"%@",[info objectForKey:@"tagId"]];
    for (NSString* str in _selectedArray) {
        if ([str isEqualToString:tagId]) {
            return YES;
        }
    }
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
