//
//  SNPopOverMenu.m
//  sohunews
//
//  Created by 李腾 on 2016/11/5.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNPopOverMenu.h"
#import "UIColor+StoryColor.h"
#import "UIImage+Story.h"

#define KSCREEN_WIDTH               [[UIScreen mainScreen] bounds].size.width
#define KSCREEN_HEIGHT              [[UIScreen mainScreen] bounds].size.height
#define SNDefaultBackgroundColor    [UIColor colorWithWhite:0.8 alpha:0.4]
#define SNDefaultTintColor          SNUICOLOR(kThemeBg4Color)
#define SNDefaultTextColor          SNUICOLOR(kThemeText2Color)
#define SNDefaultMenuFont           [UIFont systemFontOfSize:kThemeFontSizeD]
#define SNDefaultMenuIconSizeWidth  14.0
#define SNDefaultMenuCornerRadius   2.0
#define SNDefaultMargin             7.0
#define SNDefaultMenuLeftMargin     14.0
#define SNDefaultMenuTextMargin     12.0
#define SNDefaultMenuBorderWidth    0.8
#define SNDefaultAnimationDuration  0.25
#define SNDefaultMenuArrowHeight    10.0
#define SNDefaultMenuArrowWidth     8.0
#define SNDefaultMenuRowHeight      50.0f

#define SNPopOverMenuTableViewCellIndentifier @"SNPopOverMenuTableViewCellIndentifier"

#pragma mark - SNPopOverMenuCell

/**
 *  SNPopOverMenuArrowDirection
 */
typedef NS_ENUM(NSUInteger, SNPopOverMenuArrowDirection) {
    /**
     *  Up
     */
    SNPopOverMenuArrowDirectionUp,
    /**
     *  Down
     */
    SNPopOverMenuArrowDirectionDown,
};

@interface SNPopOverMenuCell ()

@end

@implementation SNPopOverMenuCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style
             reuseIdentifier:(NSString *)reuseIdentifier
              arrowDirection:(SNPopOverMenuArrowDirection)arrowDirection
               hideSeparator:(NSInteger)hideSeparator
                   menuWidth:(CGFloat )menuWidth
               menuRowHeight:(CGFloat )menuRowHeight
                    menuName:(NSString *)menuName
               iconImageName:(NSString *)iconImageName
                   colorType:(BOOL)isStoryColorType {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImage *iconImage = nil;
        if (iconImageName.length > 0) {
            iconImage = isStoryColorType?[UIImage imageStoryNamed:iconImageName]:[UIImage imageNamed:iconImageName];
        }
        CGFloat margin = (menuRowHeight - SNDefaultMenuIconSizeWidth)/2;
        CGRect iconImageRect = CGRectMake(SNDefaultMenuLeftMargin, margin, SNDefaultMenuIconSizeWidth, SNDefaultMenuIconSizeWidth);
        CGRect menuNameRect = CGRectMake(SNDefaultMenuTextMargin*2 + SNDefaultMenuIconSizeWidth, 0, menuWidth - SNDefaultMenuIconSizeWidth - SNDefaultMenuTextMargin*3, menuRowHeight);
        if (iconImage) {
            
            _iconImageView = [[UIImageView alloc]initWithFrame:iconImageRect];
            _iconImageView.backgroundColor = [UIColor clearColor];
            _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
            _iconImageView.tintColor = SNDefaultTextColor;
            _iconImageView.image = iconImage;
            [self.contentView addSubview:_iconImageView];
        } else {
            menuNameRect = CGRectMake(SNDefaultMenuTextMargin, 0, menuWidth - SNDefaultMenuTextMargin*2, menuRowHeight);
        }
        _menuNameLabel = [[UILabel alloc]initWithFrame:menuNameRect];
        _menuNameLabel.backgroundColor = [UIColor clearColor];
        _menuNameLabel.font = SNDefaultMenuFont;
        _menuNameLabel.textColor = isStoryColorType?[UIColor colorFromKey:@"kThemeText2Color"]:SNDefaultTextColor;
        _menuNameLabel.textAlignment = NSTextAlignmentLeft;
        _menuNameLabel.text = menuName;
        [self.contentView addSubview:_menuNameLabel];
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, menuRowHeight, menuWidth, 0.5)];
        lineView.backgroundColor = isStoryColorType?[UIColor colorFromKey:@"kThemeBg1Color"]:SNUICOLOR(kThemeBg1Color);
        [self.contentView addSubview:lineView];
        if (arrowDirection == SNPopOverMenuArrowDirectionUp) {
            // 添加分割线
            lineView.left = SNDefaultMenuLeftMargin;
            lineView.width = menuWidth - 2*SNDefaultMenuLeftMargin;
        }
        if (hideSeparator) {
            lineView.hidden = YES;
        }
    }
    return self;
}

@end



#pragma mark - SNPopOverMenuView

@interface SNPopOverMenuView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *menuTableView;
@property (nonatomic, strong) NSArray<NSString *> *menuStringArray;
@property (nonatomic, strong) NSArray<NSString *> *menuIconNameArray;
@property (nonatomic, assign) SNPopOverMenuArrowDirection arrowDirection;
@property (nonatomic, strong) SNPopOverMenuDoneBlock doneBlock;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, assign) BOOL haveunabled;
@property (nonatomic, assign) NSInteger unableIndex;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) CGFloat menuWidth;
@property (nonatomic, assign) CGFloat menuRowHeight;
@property (nonatomic, assign) BOOL isStoryColorType;
@end

@implementation SNPopOverMenuView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 设置阴影效果
        self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowRadius = 5.0;
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
    }
    return self;
}

-(UITableView *)menuTableView {
    if (!_menuTableView) {
        
        _menuTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        _menuTableView.backgroundColor = self.isStoryColorType?[UIColor colorFromKey:@"kThemeBg4Color"]:SNUICOLOR(kThemeBg4Color);
        _menuTableView.layer.cornerRadius = SNDefaultMenuCornerRadius;
        _menuTableView.scrollEnabled = NO;
        _menuTableView.clipsToBounds = YES;
        _menuTableView.delegate = self;
        _menuTableView.dataSource = self;
        [self addSubview:_menuTableView];
        _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return _menuTableView;
}


-(void)showWithAnglePoint:(CGPoint)anglePoint
            withNameArray:(NSArray<NSString*> *)nameArray
           imageNameArray:(NSArray<NSString*> *)imageNameArray
           arrowDirection:(SNPopOverMenuArrowDirection )arrowDirection
         shouldAutoScroll:(BOOL)shouldAutoScroll
                doneBlock:(SNPopOverMenuDoneBlock)doneBlock {
    _menuStringArray = nameArray;
    _menuIconNameArray = imageNameArray;
    _arrowDirection = arrowDirection;
    self.doneBlock = doneBlock;
    self.menuTableView.scrollEnabled = shouldAutoScroll;
    
    CGRect menuRect = CGRectZero;
    if (_arrowDirection == SNPopOverMenuArrowDirectionDown) {
        menuRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - SNDefaultMenuArrowHeight);
    } else if (_arrowDirection == SNPopOverMenuArrowDirectionUp) {
        menuRect = CGRectMake(0, SNDefaultMenuArrowHeight, self.frame.size.width, _menuRowHeight * nameArray.count);
    }
    
    [self.menuTableView setFrame:menuRect];
    [self.menuTableView reloadData];
    
    [self drawBackgroundLayerWithAnglePoint:anglePoint];
}


-(void)drawBackgroundLayerWithAnglePoint:(CGPoint)anglePoint {
    if (_backgroundLayer) {
        [_backgroundLayer removeFromSuperlayer];
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    switch (_arrowDirection) {
        case SNPopOverMenuArrowDirectionUp:{
            
            [path moveToPoint:anglePoint];
            [path addLineToPoint:CGPointMake(anglePoint.x - SNDefaultMenuArrowWidth, SNDefaultMenuArrowHeight)];
            [path addLineToPoint:CGPointMake(SNDefaultMenuCornerRadius, SNDefaultMenuArrowHeight)];
            [path addArcWithCenter:CGPointMake(SNDefaultMenuCornerRadius, SNDefaultMenuArrowHeight + SNDefaultMenuCornerRadius) radius:SNDefaultMenuCornerRadius startAngle:-M_PI_2 endAngle:-M_PI clockwise:NO];
            [path addLineToPoint:CGPointMake( 0, self.bounds.size.height - SNDefaultMenuCornerRadius)];
            [path addArcWithCenter:CGPointMake(SNDefaultMenuCornerRadius, self.bounds.size.height - SNDefaultMenuCornerRadius) radius:SNDefaultMenuCornerRadius startAngle:M_PI endAngle:M_PI_2 clockwise:NO];
            [path addLineToPoint:CGPointMake( self.bounds.size.width - SNDefaultMenuCornerRadius, self.bounds.size.height)];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - SNDefaultMenuCornerRadius, self.bounds.size.height - SNDefaultMenuCornerRadius) radius:SNDefaultMenuCornerRadius startAngle:M_PI_2 endAngle:0 clockwise:NO];
            [path addLineToPoint:CGPointMake(self.bounds.size.width , SNDefaultMenuCornerRadius + SNDefaultMenuArrowHeight)];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - SNDefaultMenuCornerRadius, SNDefaultMenuCornerRadius + SNDefaultMenuArrowHeight) radius:SNDefaultMenuCornerRadius startAngle:0 endAngle:-M_PI_2 clockwise:NO];
            [path addLineToPoint:CGPointMake(anglePoint.x + SNDefaultMenuArrowWidth, SNDefaultMenuArrowHeight)];
            [path closePath];
            break;
        }
        case SNPopOverMenuArrowDirectionDown:{
            [path moveToPoint:anglePoint];
            [path addLineToPoint:CGPointMake( anglePoint.x - SNDefaultMenuArrowWidth, anglePoint.y - SNDefaultMenuArrowHeight)];
            [path addLineToPoint:CGPointMake( SNDefaultMenuCornerRadius, anglePoint.y - SNDefaultMenuArrowHeight)];
            [path addArcWithCenter:CGPointMake(SNDefaultMenuCornerRadius, anglePoint.y - SNDefaultMenuArrowHeight - SNDefaultMenuCornerRadius) radius:SNDefaultMenuCornerRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
            [path addLineToPoint:CGPointMake( 0, SNDefaultMenuCornerRadius)];
            [path addArcWithCenter:CGPointMake(SNDefaultMenuCornerRadius, SNDefaultMenuCornerRadius) radius:SNDefaultMenuCornerRadius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
            [path addLineToPoint:CGPointMake( self.bounds.size.width - SNDefaultMenuCornerRadius, 0)];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - SNDefaultMenuCornerRadius, SNDefaultMenuCornerRadius) radius:SNDefaultMenuCornerRadius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
            [path addLineToPoint:CGPointMake(self.bounds.size.width , anglePoint.y - (SNDefaultMenuCornerRadius + SNDefaultMenuArrowHeight))];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - SNDefaultMenuCornerRadius, anglePoint.y - (SNDefaultMenuCornerRadius + SNDefaultMenuArrowHeight)) radius:SNDefaultMenuCornerRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
            [path addLineToPoint:CGPointMake(anglePoint.x + SNDefaultMenuArrowWidth, anglePoint.y - SNDefaultMenuArrowHeight)];
            [path closePath];
        }
    }
    
    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.path = path.CGPath;
    _backgroundLayer.lineWidth = SNDefaultMenuBorderWidth;
    _backgroundLayer.fillColor = self.isStoryColorType?[UIColor colorFromKey:@"kThemeBg4Color"].CGColor:SNDefaultTintColor.CGColor;
    _backgroundLayer.strokeColor = self.isStoryColorType?[UIColor colorFromKey:@"kThemeBg1Color"].CGColor:SNUICOLOR(kThemeBg1Color).CGColor;
    [self.layer insertSublayer:_backgroundLayer atIndex:0];
}


#pragma mark - UITableViewDelegate,UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _menuRowHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _menuStringArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *imageName = [NSString string];
    if (_menuIconNameArray.count - 1 >= indexPath.row) {
        imageName = _menuIconNameArray[indexPath.row];
    }
    SNPopOverMenuCell *menuCell = [[SNPopOverMenuCell alloc]initWithStyle:
                                   UITableViewCellStyleDefault
                                                          reuseIdentifier:SNPopOverMenuTableViewCellIndentifier
                                                           arrowDirection:_arrowDirection
                                                            hideSeparator:(indexPath.row == _menuStringArray.count -1)?YES:NO
                                                                menuWidth:_menuWidth
                                                            menuRowHeight:_menuRowHeight
                                                                 menuName:_menuStringArray[indexPath.row]
                                                            iconImageName:imageName
                                                                colorType:self.isStoryColorType];
    
    if (self.haveunabled && indexPath.row == self.unableIndex) {
        menuCell.menuNameLabel.textColor = SNUICOLOR(kThemeBg1Color);
    }
    
    return menuCell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.unableIndex && self.haveunabled) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.doneBlock) {
        self.doneBlock(indexPath.row);
    }
}

@end


#pragma mark - SNPopOverMenu

@interface SNPopOverMenu () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView * backgroundView;
@property (nonatomic, strong) SNPopOverMenuView *popMenuView;
@property (nonatomic, copy) SNPopOverMenuDoneBlock doneBlock;
@property (nonatomic, copy) SNPopOverMenuDismissBlock dismissBlock;
@property (nonatomic, assign) CGFloat menuWidth;
@property (nonatomic, assign) CGFloat menuRowHeight;
@property (nonatomic, strong) UIView *sender;
@property (nonatomic, assign) CGRect senderFrame;
@property (nonatomic, strong) NSArray<NSString*> *menuArray;
@property (nonatomic, strong) NSArray<NSString*> *menuImageArray;
@property (nonatomic, assign) BOOL isCurrentlyOnScreen;
@property (nonatomic, strong) UIView *superCoverView;
@property (nonatomic, assign) BOOL isStoryColorType;

@end

@implementation SNPopOverMenu

static SNPopOverMenu *shared;
+ (SNPopOverMenu *)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[SNPopOverMenu alloc] init];
    });
    return shared;
}

+ (void)showForSender:(UIView *)sender senderFrame:(CGRect)senderFrame withMenu:(NSArray<NSString *> *)menuArray imageNameArray:(NSArray<NSString *> *)imageNameArray doneBlock:(SNPopOverMenuDoneBlock)doneBlock dismissBlock:(SNPopOverMenuDismissBlock)dismissBlock {
    [self sharedInstance].popMenuView.haveunabled = NO;
    [self sharedInstance].popMenuView.isStoryColorType = NO;
    [self sharedInstance].isStoryColorType = NO;
    [[self sharedInstance] showForSender:sender senderFrame:senderFrame withMenu:menuArray imageNameArray:imageNameArray doneBlock:doneBlock dismissBlock:dismissBlock];
}


+ (void)showForSender:(UIView *)sender
          haveUnabled:(BOOL)haveUnabled
         unabledIndex:(NSInteger)unabledIndex
          senderFrame:(CGRect )senderFrame
             withMenu:(NSArray<NSString*> *)menuArray
       imageNameArray:(NSArray<NSString*> *)imageNameArray
            doneBlock:(SNPopOverMenuDoneBlock)doneBlock
         dismissBlock:(SNPopOverMenuDismissBlock)dismissBlock {
    [self sharedInstance].popMenuView.haveunabled = haveUnabled;
    [self sharedInstance].popMenuView.unableIndex = unabledIndex;
    [self sharedInstance].popMenuView.isStoryColorType = NO;
    [self sharedInstance].isStoryColorType = NO;
    [[self sharedInstance] showForSender:sender senderFrame:senderFrame withMenu:menuArray imageNameArray:imageNameArray doneBlock:doneBlock dismissBlock:dismissBlock];
}

+ (void)dismiss {
    [[self sharedInstance] dismiss];
}

#pragma mark - 为小说添加方法，因为小说模块日夜间模式与主线不一致
+ (void)showForStorySender:(UIView *)sender
               senderFrame:(CGRect )senderFrame
                 superView:(UIView *)superView
                  withMenu:(NSArray<NSString*> *)menuArray
            imageNameArray:(NSArray<NSString*> *)imageNameArray
                 doneBlock:(SNPopOverMenuDoneBlock)doneBlock
              dismissBlock:(SNPopOverMenuDismissBlock)dismissBlock {
    [self sharedInstance].popMenuView.haveunabled = NO;
    [self sharedInstance].popMenuView.isStoryColorType = YES;
    [self sharedInstance].isStoryColorType = YES;
    [self sharedInstance].superCoverView = superView;
    [[self sharedInstance] showForSender:sender senderFrame:senderFrame withMenu:menuArray imageNameArray:imageNameArray doneBlock:doneBlock dismissBlock:dismissBlock];
}

#pragma mark - Private Methods

- (instancetype)init {
    self = [super init];
    if (self) {
        [SNNotificationManager addObserver:self
                                  selector:@selector(onChangeStatusBarOrientationNotification:)
                                      name:UIApplicationDidChangeStatusBarOrientationNotification
                                    object:nil];
        
        [SNNotificationManager addObserver:self
                                  selector:@selector(dismiss)
                                      name:kNotifyDidReceive
                                    object:nil];
    }
    return self;
}

-(UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc ]initWithFrame:[UIScreen mainScreen].bounds];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackgroundViewTapped:)];
        tap.delegate = self;
        [_backgroundView addGestureRecognizer:tap];
        _backgroundView.backgroundColor = [UIColor clearColor];
    }
    return _backgroundView;
}

-(SNPopOverMenuView *)popMenuView {
    if (!_popMenuView) {
        _popMenuView = [[SNPopOverMenuView alloc] init];
        _popMenuView.alpha = 0;
    }
    return _popMenuView;
}


-(void)onChangeStatusBarOrientationNotification:(NSNotification *)notification {
    if (self.isCurrentlyOnScreen) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self adjustPopOverMenu];
        });
    }
}

- (void)showForSender:(UIView *)sender
          senderFrame:(CGRect )senderFrame
             withMenu:(NSArray<NSString*> *)menuArray
       imageNameArray:(NSArray<NSString*> *)imageNameArray
            doneBlock:(SNPopOverMenuDoneBlock)doneBlock
         dismissBlock:(SNPopOverMenuDismissBlock)dismissBlock {
    [[SNSkinMaskWindow sharedInstance] resignAppActive];
    [self.backgroundView addSubview:self.popMenuView];
    if (self.isStoryColorType) {
        [self.superCoverView addSubview:self.backgroundView];
    } else {
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.backgroundView];
    }
    self.sender         = sender;
    self.senderFrame    = senderFrame;
    self.menuArray      = menuArray;
    self.menuImageArray = imageNameArray;
    self.doneBlock      = doneBlock;
    self.dismissBlock   = dismissBlock;
    
    [self adjustPopOverMenu];
}


-(void)adjustPopOverMenu {
    
    [self.backgroundView setFrame:CGRectMake(0, 0, KSCREEN_WIDTH, KSCREEN_HEIGHT)];
    
    CGRect senderRect;
    
    if (self.sender) {
        senderRect = [self.sender.superview convertRect:self.sender.frame toView:self.backgroundView];
    } else {
        senderRect = self.senderFrame;
    }
    if (senderRect.origin.y > KSCREEN_HEIGHT) {
        senderRect.origin.y = KSCREEN_HEIGHT;
    }
    
    CGPoint menuArrowPoint = CGPointMake(senderRect.origin.x + (senderRect.size.width)/2 , 0);
    CGFloat menuX = 0;
    _menuWidth = [self calcuMenuWidthWithTitleArray:_menuArray] + 2 *SNDefaultMenuLeftMargin + SNDefaultMenuIconSizeWidth + SNDefaultMenuTextMargin;
    _menuRowHeight = SNDefaultMenuRowHeight;
    CGRect menuRect = CGRectZero;
    BOOL shouldAutoScroll = NO;
    SNPopOverMenuArrowDirection arrowDirection;
    if (senderRect.origin.y + senderRect.size.height/2  < KSCREEN_HEIGHT/2) {
        arrowDirection = SNPopOverMenuArrowDirectionUp;
        menuArrowPoint.y = 0;
        
    } else {
        arrowDirection = SNPopOverMenuArrowDirectionDown;
        menuArrowPoint.y = _menuRowHeight * self.menuArray.count + SNDefaultMenuArrowHeight;
    }
    
    CGFloat menuHeight = _menuRowHeight * self.menuArray.count + SNDefaultMenuArrowHeight;
    self.popMenuView.menuWidth = _menuWidth;
    self.popMenuView.menuRowHeight = _menuRowHeight;
    if (menuArrowPoint.x + _menuWidth/2 + SNDefaultMargin > KSCREEN_WIDTH) {
        menuArrowPoint.x = MIN(menuArrowPoint.x - (KSCREEN_WIDTH - _menuWidth - SNDefaultMargin), _menuWidth - SNDefaultMenuArrowWidth - SNDefaultMargin);
        menuX = KSCREEN_WIDTH - _menuWidth - SNDefaultMargin;
    } else if ( menuArrowPoint.x - _menuWidth/2 - SNDefaultMargin < 0){
        menuArrowPoint.x = MAX( SNDefaultMenuCornerRadius + SNDefaultMenuArrowWidth, menuArrowPoint.x - SNDefaultMargin);
        menuX = SNDefaultMargin;
    } else {
        menuArrowPoint.x = _menuWidth/2;
        menuX = senderRect.origin.x + (senderRect.size.width)/2 - _menuWidth/2;
    }
    if (arrowDirection == SNPopOverMenuArrowDirectionDown) {
        senderRect.origin.y += 15;
        menuRect = CGRectMake(menuX, (senderRect.origin.y - menuHeight), _menuWidth, menuHeight);
        if (menuRect.origin.y  < 0) {
            menuRect = CGRectMake(menuX, SNDefaultMargin, _menuWidth, senderRect.origin.y - SNDefaultMargin);
            menuArrowPoint.y = senderRect.origin.y;
            shouldAutoScroll = YES;
        }
        
    } else {
        menuRect = CGRectMake(menuX, (senderRect.origin.y + senderRect.size.height), _menuWidth, menuHeight);
        // if too long and is out of screen
        if (menuRect.origin.y + menuRect.size.height > KSCREEN_HEIGHT) {
            menuRect = CGRectMake(menuX, (senderRect.origin.y + senderRect.size.height), _menuWidth, KSCREEN_HEIGHT - menuRect.origin.y - SNDefaultMargin);
            shouldAutoScroll = YES;
        }
    }
    /*修改锚点,从锚点位置弹出和消失 */
    _popMenuView.layer.anchorPoint = CGPointMake(menuArrowPoint.x/menuRect.size.width, arrowDirection == SNPopOverMenuArrowDirectionUp?0:1);
    
    _popMenuView.frame = menuRect;
    
    __weak typeof(self)weakself = self;
    [_popMenuView showWithAnglePoint:menuArrowPoint
                       withNameArray:self.menuArray
                      imageNameArray:self.menuImageArray
                      arrowDirection:arrowDirection
                    shouldAutoScroll:shouldAutoScroll
                           doneBlock:^(NSInteger selectedIndex) {
                               [weakself doneActionWithSelectedIndex:selectedIndex];
                           }];
    [self show];
}

// calculate the title MaxWidth
- (CGFloat)calcuMenuWidthWithTitleArray:(NSArray <NSString *>*)titleArray {
    CGFloat width = 0;
    for (NSString *title in titleArray) {
        CGFloat newWidth = [title textSizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeD]].width;
        width = newWidth > width ? newWidth:width;
    }
    return width;
}

#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:_popMenuView];
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }else if (CGRectContainsPoint(CGRectMake(0, 0, _menuWidth, _menuRowHeight), point)) {
        [self doneActionWithSelectedIndex:0];
        return NO;
    }
    return YES;
}

#pragma mark - onBackgroundViewTapped

-(void)onBackgroundViewTapped:(UIGestureRecognizer *)gesture {
    [self dismiss];
}

#pragma mark - show animation

- (void)show {
    self.isCurrentlyOnScreen = YES;
    _popMenuView.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    [UIView animateWithDuration:SNDefaultAnimationDuration
                     animations:^{
                         _popMenuView.transform = CGAffineTransformIdentity;
                         _popMenuView.alpha = 1;
                     }];
}

#pragma mark - dismiss animation

- (void)dismiss {
    self.isCurrentlyOnScreen = NO;
    [self doneActionWithSelectedIndex:-1];
    [[SNSkinMaskWindow sharedInstance] becameAppActive];
}

#pragma mark - doneActionWithSelectedIndex

-(void)doneActionWithSelectedIndex:(NSInteger)selectedIndex {
    [UIView animateWithDuration:SNDefaultAnimationDuration
                     animations:^{
                         _popMenuView.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
                         _popMenuView.alpha = 0;
                         _backgroundView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self.popMenuView removeFromSuperview];
                             [self.backgroundView removeFromSuperview];
                             self.popMenuView = nil;    // 单例,必须置为nil
                             self.backgroundView = nil;
                             
                             if (selectedIndex < 0) {
                                 if (self.dismissBlock) {
                                     self.dismissBlock();
                                 }
                             } else {
                                 if (self.doneBlock) {
                                     self.doneBlock(selectedIndex);
                                 }
                             }
                         }
                     }];
}
@end
