//
//  SNEmoticonTabView.m
//  sohunews
//
//  Created by jialei on 14-5-12.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNEmoticonTabView.h"
#import "SNEmoticonStaticScrollView.h"


@interface SNEmoticonTabView()
{
    int _tabCount;
    int _tabSelectIndex;
    int _tabLastIndex;
    SNEmoticonType _type;
    
    NSMutableArray *_emoticonConfigArray;
    NSMutableArray *_tabButtonArray;
    NSMutableArray *_scrollViewArray;
    
    UIImageView *_bgView;
    UIImage *_tabSelectImage;
}

@end

#define EMOTICON_TAB_BUTTON_WIDTH   (120 / 2)
#define EMOTICON_TAB_BUTTON_HEIGHT  (72 / 2)
#define EMOTICON_SCROLL_VIEW_TAG    100

@implementation SNEmoticonTabView

- (id)initWithType:(SNEmoticonConfigType)type frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSString *plistName = [NSString stringWithFormat:@"emoticonConfig_%lu", type];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plistName
                                                                                                       ofType:@"plist"]];
        NSArray *emoticonConfigArray = [dic arrayValueForKey:@"emoticonConfig" defaultValue:nil];
        NSInteger count = [emoticonConfigArray count];
        _emoticonConfigArray = [[NSMutableArray alloc] initWithCapacity:count];
        _tabButtonArray = [[NSMutableArray alloc] initWithCapacity:count];
        _scrollViewArray = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (NSInteger i = 0; i < count; i++) {
            NSDictionary *configDic = emoticonConfigArray[i];
            
            if (configDic && [configDic isKindOfClass:[NSDictionary class]]) {
                SNEmoticonConfig *config = [[SNEmoticonConfig alloc] init];
                config.emoticonPlistName = [configDic stringValueForKey:@"plist" defaultValue:nil];
                config.emoticonClassName = [configDic stringValueForKey:@"class" defaultValue:nil];
                config.emoticonType = [configDic stringValueForKey:@"type" defaultValue:nil];
                
                [_emoticonConfigArray addObject:config];
            }
        }
        
        _type = type;
        _tabCount = (int)count;
        _tabSelectIndex = 0;
        _tabLastIndex = 0;
        _tabSelectImage = [UIImage themeImageNamed:@"emoticon_tab_select.png"];
        
        [self createView];
    }
    return self;
}

- (void)dealloc
{
     //(_bgView);
     //(_emoticonConfigArray);
     //(_tabButtonArray);
     //(_scrollViewArray);
     //(_tabSelectImage);
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark- createView
- (void)createView
{
    UIImage *backgroundImage = [UIImage themeImageNamed:@"comment_input_background.png"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.frame = self.bounds;
    [self addSubview:backgroundImageView];
    
    [self createTabBar];
    
    int index = 0;
    for (SNEmoticonConfig *config in _emoticonConfigArray) {
        
        NSArray* emoticonObjects = [[SNEmoticonManager sharedManager] emoticonObjectsFromPlist:config.emoticonPlistName];
        
        if (emoticonObjects.count > 0 && config.emoticonClassName.length > 0) {
            //tabButton
            NSString *btnImageName = [NSString stringWithFormat:@"emoticon_tab_button_%@.png", config.emoticonType];
            UIImage *btnImage = [UIImage themeImageNamed:btnImageName];
            UIButton *tabButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            tabButton.size = CGSizeMake(EMOTICON_TAB_BUTTON_WIDTH, EMOTICON_TAB_BUTTON_HEIGHT);
            tabButton.left = index * EMOTICON_TAB_BUTTON_WIDTH;
            tabButton.top = _bgView.top;
            tabButton.tag = index;
            [tabButton setImage:btnImage forState:UIControlStateNormal];
            tabButton.alpha = themeImageAlphaValue();
            if (index==0) {
                [tabButton setBackgroundImage:_tabSelectImage forState:UIControlStateNormal];
                _currentType = SNEmoticonStatic;
            }
            
            //分割线
            UIImage *image = [UIImage themeImageNamed:@"emoticon_tab_sep.png"];
            UIImageView *sepView = [[UIImageView alloc] initWithImage:image];
            sepView.size = sepView.size;
            sepView.top = 0;
            sepView.left = tabButton.width - sepView.width;
            
            [tabButton addSubview:sepView];
            
            [tabButton addTarget:self action:@selector(tabBarSelect:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:tabButton];
            [_tabButtonArray addObject:tabButton];
            
            //scrollView
            Class viewClass = NSClassFromString(config.emoticonClassName);
            SNEmoticonStaticScrollView *emoticonScrollView = [[viewClass alloc] initWithObjects:emoticonObjects
                                                                                          frame:CGRectMake(0, 0,
                                                                                                self.size.width,
                                                                                                self.height - _bgView.height)];
            emoticonScrollView.scrollsToTop = NO;
            emoticonScrollView.tag = index + EMOTICON_SCROLL_VIEW_TAG;
            emoticonScrollView.emoticonDelegate = self;

            if (index==0) {
                emoticonScrollView.hidden = NO;
            }
            else {
                emoticonScrollView.hidden = YES;
            }
            
            [self addSubview:emoticonScrollView];
            [_scrollViewArray addObject:emoticonScrollView];
            
            index++;
        }
    }
}

- (void)createTabBar
{
    UIImage *bgImage = [UIImage themeImageNamed:@"emoticon_tab_bg.png"];
    _bgView = [[UIImageView alloc] initWithImage:bgImage];
    _bgView.size = CGSizeMake(self.width, bgImage.size.height);
    _bgView.left = 0;
    _bgView.bottom = self.size.height;

    [self addSubview:_bgView];
}

#pragma mark- action
- (void)tabBarSelect:(id)sender
{
    UIButton *button = (UIButton *)sender;

    if (_tabLastIndex < _tabButtonArray.count) {
        UIButton *lastButton = _tabButtonArray[_tabLastIndex];
        [lastButton setBackgroundImage:nil forState:UIControlStateNormal];
    }
    [button setBackgroundImage:_tabSelectImage forState:UIControlStateNormal];
    
    if (_tabLastIndex < _tabButtonArray.count) {
        SNEmoticonStaticScrollView *lastScrollView = _scrollViewArray[_tabLastIndex];
        SNEmoticonStaticScrollView *selectScrollView = _scrollViewArray[button.tag];
        lastScrollView.hidden = YES;
        selectScrollView.hidden = NO;
        _currentType = selectScrollView.type;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(emoticonTabSelect:)]) {
            [self.delegate emoticonTabSelect:_currentType];
        }
    }
    
    _tabSelectIndex = (int)button.tag;
    _tabLastIndex = _tabSelectIndex;
    
}

#pragma mark -emoticonScrollDelegate
- (void)emoticonDidSelect:(SNEmoticonObject *)emoticon
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(emoticonDidSelect:)]) {
        [self.delegate emoticonDidSelect:emoticon];
    }
}

- (void)emoticonDidDelete
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(emoticonDidDelete)]) {
        [self.delegate emoticonDidDelete];
    }
}

@end
