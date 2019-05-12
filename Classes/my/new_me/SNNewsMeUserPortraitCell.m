//
//  SNNewsMeUserPortraitCell.m
//  sohunews
//
//  Created by iOS_D on 2016/12/19.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNNewsMeUserPortraitCell.h"

#define HeadImageView_Height 100
#define UserPortraitCell_Height (170)
//210

@implementation SNNewsMeUserPortraitCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        CGFloat x  = 14;
        CGFloat s_width = [[UIScreen mainScreen] bounds].size.width;
       
        _userPortraitView = [[SNNewsMeUserPortraitView alloc] initWithFrame:CGRectMake(x, 0, s_width-2*x, UserPortraitCell_Height)];
        [self.contentView addSubview:_userPortraitView];
        _userPortraitView.hidden = YES;
        _openUserView = [[SNNewsMeOpenUserPortraitView alloc] initWithFrame:CGRectMake(x, 0, s_width-2*x, UserPortraitCell_Height)];
        [self.contentView addSubview:_openUserView];
        _openUserView.hidden = NO;
    }
    return self;
}

- (void)updateData:(NSDictionary *)info{
    if (self.info != info) {
        _info = info;
    }
    
    if ([SNNewsMeUserPortraitCell getUserStatus:self.info]) {//如果是老用户
        [self showUser];
    }
    else{
        [self showOpen];
    }
}

- (void)showOpen{
    _openUserView.hidden = NO;
    _userPortraitView.hidden = YES;
}

- (void)showUser{
    _userPortraitView.hidden = NO;
    _openUserView.hidden = YES;
    
    NSString* faceImage = [self.info objectForKey:@"faceImage"];
    NSString* faceTypeName = [self.info objectForKey:@"faceTypeName"];
    NSString* faceTypeTips = [self.info objectForKey:@"faceTypeTips"];
    
    [_userPortraitView updateData:faceTypeName faceTypeTips:faceTypeTips imageUrl:faceImage];
}

- (void)jumpLink{//跳转
    NSString* link = @"";
    if ([SNNewsMeUserPortraitCell getUserStatus:self.info]) {//已知兴趣偏好
        NSNumber* genderStatus = [self.info  objectForKey:@"genderStatus"];
        if (genderStatus.integerValue == 0) {//未确定 性别
            //跳性别
            [self jumpSexSet];
        }
        else if (genderStatus.integerValue == 1){
            //跳H5
            [self jumpH5];
        }
    }
    else{//开启
        [self jumpOpen];
    }
}

- (void)jumpH5{
    NSString* urlString = SNLinks_Path_FaceH5;
    [SNUtility openProtocolUrl:urlString context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:UserPortraitWebViewType], kUniversalWebViewType, nil]];
}

- (void)jumpSexSet{
    NSString* url = @"tt://userPortraitSexSet";
    NSString* gender = [self.info objectForKey:@"gender"];
    NSDictionary* dic = @{@"old":@"1",@"gender":gender};
    TTURLAction *action = [[TTURLAction actionWithURLPath:url] applyAnimated:YES];
    [action applyQuery:dic];
    [[TTNavigator navigator] openURLAction:action];
}

- (void)jumpOpen{
    NSString* url = @"tt://userPortraitSexSet";
    TTURLAction *action = [[TTURLAction actionWithURLPath:url] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:action];
}

- (void)updateTheme{
    [super updateTheme];
    [_userPortraitView updateTheme];
    [_openUserView updateTheme];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSInteger)getUserStatus:(NSDictionary*)info{
    if (info && [info isKindOfClass:[NSDictionary class]]) {
        NSNumber* faceType = [info objectForKey:@"faceType"];
        if (faceType.integerValue !=0) {//判断是否确定兴趣偏好
            return 1;
        }
    }
    
    return 0;
}

+(CGFloat)getCellHeight:(id)info{
    if ([SNNewsMeUserPortraitCell getUserStatus:info]) {
        return UserPortraitCell_Height+30;
    }
    return UserPortraitCell_Height;
}

@end


@implementation SNNewsMeUserPortraitView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView{
    CGFloat y = 34;
//    750分辨率：460*230px 1242分辨率：690*345px  @3x
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-2*HeadImageView_Height)/2, y, HeadImageView_Height*2, HeadImageView_Height)];
    _headImageView.image = [UIImage themeImageNamed:@"icoset_jzsb_v5.png"];
    [self addSubview:_headImageView];
    
    _nightheadView = [[UIView alloc] initWithFrame:_headImageView.bounds];
    [_nightheadView setBackgroundColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg1Color]];
    [_headImageView addSubview:_nightheadView];
    _nightheadView.alpha = 0.7;
    _nightheadView.hidden = YES;
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headImageView.frame)+3, self.frame.size.width, 21)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_titleLabel setText:@"极客族"];
    
    _titleLabel.textColor = SNUICOLOR(kThemeText1Color);
    _titleLabel.font = [UIFont boldSystemFontOfSize:kThemeFontSizeE];
    
    [self addSubview:_titleLabel];
    
    NSString* str = @"发现您的专属形象，速来这里查看吧";//@"开启个性化阅读，解锁专属形象";//发现您的专属形象，速来这里查看吧
    CGFloat f = kThemeFontSizeD;
    UIDevicePlatform t = [[UIDevice currentDevice] platformTypeForScreen];
    if (t == UIDevice5SiPhone || t == UIDevice4SiPhone) {
        f = kThemeFontSizeC;
    }
   
    CGRect rect = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, 21) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:f]} context:nil];
    CGFloat w = rect.size.width;
    CGFloat arrowsWidth = 12/2;
    CGFloat arrowsHigh  = 22/2;
    CGFloat img_width = w+14+14+14+(arrowsWidth);
    CGFloat img_height = 28;
    _subImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-img_width)/2, CGRectGetMaxY(_titleLabel.frame)+8, img_width, img_height)];
    _subImageView.backgroundColor = SNUICOLOR(kThemeBg2Color);
    _subImageView.layer.cornerRadius = img_height/2;
    [self addSubview:_subImageView];
    
    _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_subImageView.frame)+14, CGRectGetMaxY(_titleLabel.frame)+8+4, w, 21)];
    _subTitleLabel.textAlignment = NSTextAlignmentCenter;
    [_subTitleLabel setText:str];
    [_subTitleLabel setFont:[UIFont systemFontOfSize:f]];
    _subTitleLabel.textColor = SNUICOLOR(kThemeText2Color);
    _subTitleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_subTitleLabel];

    _arrow = [[UIImageView alloc] init];
    _arrow.frame = CGRectMake(CGRectGetMaxX(_subTitleLabel.frame)+14, CGRectGetMinY(_subImageView.frame)+8.5, arrowsWidth, arrowsHigh);
    _arrow.image = [UIImage themeImageNamed:@"icofiction_jtt_v5.png"];
    [self addSubview:_arrow];

}

- (void)updateData:(NSString*)name faceTypeTips:(NSString*)tips imageUrl:(NSString*)url{
    _titleLabel.text = name;
    _subTitleLabel.text = tips;
    
    NSString* str = _subTitleLabel.text;
    CGFloat f = kThemeFontSizeD;
    UIDevicePlatform t = [[UIDevice currentDevice] platformTypeForScreen];
    if (t == UIDevice5SiPhone || t == UIDevice4SiPhone) {
        f = kThemeFontSizeC;
    }
    
    CGRect rect = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, 21) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:f]} context:nil];
    CGFloat w = rect.size.width;
    CGFloat arrowsWidth = 12/2;
    CGFloat arrowsHigh  = 22/2;
    
    CGFloat img_width = w+14+14+14+(arrowsWidth);
    CGFloat img_height = 28;
    _subImageView.frame = CGRectMake((self.frame.size.width-img_width)/2, CGRectGetMaxY(_titleLabel.frame)+8, img_width, img_height);
    _subTitleLabel.frame = CGRectMake(CGRectGetMinX(_subImageView.frame)+14, CGRectGetMaxY(_titleLabel.frame)+8+4, w, 21);

    _arrow.frame = CGRectMake(CGRectGetMaxX(_subTitleLabel.frame)+14, CGRectGetMinY(_subImageView.frame)+8.5, arrowsWidth, arrowsHigh);
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage themeImageNamed:@"icoset_jzsb_v5.png"]];
    [self updateTheme];
}

- (void)updateTheme{
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        _subTitleLabel.textColor = SNUICOLOR(kThemeText3Color);
        _titleLabel.textColor = SNUICOLOR(kThemeText3Color);
        _nightheadView.hidden = NO;
    }
    else{
        _subTitleLabel.textColor = SNUICOLOR(kThemeText2Color);
        _titleLabel.textColor = SNUICOLOR(kThemeText1Color);
        _nightheadView.hidden = YES;
    }
    [_nightheadView setBackgroundColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kBackgroundColor]];
    _subImageView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg1Color];
    _arrow.image = [UIImage themeImageNamed:@"icofiction_jtt_v5.png"];
}

@end

@implementation SNNewsMeOpenUserPortraitView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configView];
    }
    return self;
}

- (void)configView{
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat width = 74;
    _openImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-width)/2, 40, width, width)];
    _openImageView.layer.cornerRadius = width/2;
    _openImageView.backgroundColor = [UIColor clearColor];
    _openImageView.layer.borderWidth  = 1;
    _openImageView.layer.borderColor  = SNUICOLOR(kThemeRed1Color).CGColor;
    _openImageView.layer.cornerRadius = width/2;
    [self addSubview:_openImageView];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (kThemeFontSizeE+3.5)*2, (kThemeFontSizeE+3.5)*2)];
    label.textColor = SNUICOLOR(kThemeRed1Color);
    label.font = [UIFont systemFontOfSize:kThemeFontSizeE];
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"立即开启";
    label.center = _openImageView.center;
    [self addSubview:label];
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_openImageView.frame)+25, self.frame.size.width, kThemeFontSizeD+3)];
    [self addSubview:_contentLabel];
    
    _contentLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    _contentLabel.textColor = SNUICOLOR(kThemeText2Color);
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    _contentLabel.text = @"开启个性化阅读，解锁专属形象";//来这里解锁专属形象，开启属于您的个性化阅读之旅吧
}

- (void)updateData:(NSString*)title{
    _contentLabel.text = title;
    [self updateTheme];
}

- (void)updateTheme{
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        _contentLabel.textColor = SNUICOLOR(kThemeText3Color);
    }
    else{
        _contentLabel.textColor = SNUICOLOR(kThemeText2Color);
    }
}

@end



