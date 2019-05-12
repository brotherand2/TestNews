//
//  SNSubShakingItemView.m
//  sohunews
//
//  Created by Diaochunmeng on 12-11-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubShakingItemView.h"
#import "UIColor+ColorUtils.h"

@implementation SNSubShakingItemView
@synthesize _checked;
@synthesize _dataObject;
@synthesize _subViewController;


//----------------------------------------------------------------------------------------------
//------------------------------------------- 系统回调 -------------------------------------------
//----------------------------------------------------------------------------------------------


-(id)initWithFrame:(CGRect)frame object:(SCSubscribeObject*)aObject
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self._checked = YES;
        self._dataObject = aObject;
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
        [self addGestureRecognizer:tap];
        
        if(aObject!=nil)
        {
            UIColor* titleLabelColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kShakingTitleLabelColor]];
            UIColor* itemLabelColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kShakingItemLabelColor]];
            
            //bg image
            UIImage* bg = [UIImage imageNamed:@"shaking_item_bg.png"];
            CGRect baseRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            UIImageView* bgView = [[UIImageView alloc] initWithFrame:baseRect];
            bgView.tag = 101;
            bgView.image = bg;
            [self addSubview:bgView];
            
            //name
            CGRect subRect = CGRectMake(14, 15, 105, 23);
            UILabel* titleLabel = [[UILabel alloc] initWithFrame:subRect];
            titleLabel.adjustsFontSizeToFitWidth = YES;
            titleLabel.font = [UIFont systemFontOfSize:16];
            titleLabel.textColor = titleLabelColor;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.userInteractionEnabled = YES;
            titleLabel.text = _dataObject.subName;
            titleLabel.tag = 102;
            [self addSubview:titleLabel];
            
            //image
            subRect = CGRectMake(14, 54, 42, 42);
            UIImage* defaultImage = [UIImage imageNamed:@"shaking_item_default.png"];
            SNWebImageView* itemImage = [[SNWebImageView alloc] initWithFrame:subRect];
            itemImage.defaultImage = defaultImage;
            itemImage.tag = 103;
            [itemImage loadUrlPath:_dataObject.subIcon];
            [self addSubview:itemImage];
            
            //rate
            UIImage* imageStar = [UIImage imageNamed:@"shaking_star.png"];
            UIImage* imageEmptyStar = [UIImage imageNamed:@"shaking_star_empty.png"];
            
            CGFloat star = 0.0f;
            if(_dataObject.starGrade!=nil)
                star = [_dataObject.starGrade floatValue];
            
            subRect = CGRectMake(61, 62, 11, 11);
            for(NSInteger i=0; i<5; i++)
            {
                UIImageView* imageView = [[UIImageView alloc] initWithFrame:subRect];
                if(star>i)
                    imageView.image = imageStar;
                else
                    imageView.image = imageEmptyStar;
                imageView.tag = 301+i;
                [self addSubview:imageView];
                
                //adjuct pos
                subRect.origin.x += 13;
            }
            
            //sub count
            NSInteger subCount = 0;
            subRect = CGRectMake(63, 80, 72, 20);
            
            if(_dataObject.subPersonCount!=nil)
                subCount = [_dataObject.subPersonCount intValue];
            NSString* userCount = [NSString stringWithFormat:NSLocalizedString(@"shaking_subCount", nil), subCount];
            
            UILabel* subCountLabel = [[UILabel alloc] initWithFrame:subRect];
            subCountLabel.font = [UIFont systemFontOfSize:8];
            subCountLabel.textColor = itemLabelColor;
            subCountLabel.backgroundColor = [UIColor clearColor];
            subCountLabel.userInteractionEnabled = NO;
            subCountLabel.text = userCount;
            subCountLabel.tag = 104;
            [self addSubview:subCountLabel];
            
            //checkbox
            subRect = CGRectMake(118, 0, 29, 29);
            UIImage* checkboxItemImage = [UIImage imageNamed:@"shaking_sel.png"];
            UIImage* checkboxItemImagehl = [UIImage imageNamed:@"shaking_sel_hl.png"];
            UIButton* checkboxView = [[UIButton alloc] initWithFrame:subRect];
            checkboxView.tag = 204;
            checkboxView.selected = self._checked;
            [checkboxView setBackgroundImage:checkboxItemImage forState:UIControlStateNormal];
            [checkboxView setBackgroundImage:checkboxItemImagehl forState:UIControlStateSelected];
            [self addSubview:checkboxView];
            
            tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkboxTaped:)];
            [checkboxView addGestureRecognizer:tap];
        }
    }
    return self;
}

-(void)viewTaped:(id)sender
{
    if(_dataObject!=nil)
    {
        if (_dataObject && ![_dataObject open]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
            [dic setObject:_dataObject forKey:@"subObj"];
            TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://subDetail"] applyAnimated:YES] applyQuery:dic];
            [[TTNavigator navigator] openURLAction:action];
        }
    }
}

-(void)checkboxTaped:(id)sender
{
    self._checked = !self._checked;
    
    UIButton* checkBox = (UIButton*)[self viewWithTag:204];
    checkBox.selected = !checkBox.selected;
}

-(void)updateTheme:(NSNotification*)notifiction
{
    UIColor* titleLabelColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kShakingTitleLabelColor]];
    UIColor* itemLabelColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kShakingItemLabelColor]];
    
    //bg image
    UIImage* bg = [UIImage imageNamed:@"shaking_item_bg.png"];
    UIImageView* bgView = (UIImageView*)[self viewWithTag:101];
    bgView.image = bg;
    
    //name
    UILabel* titleLabel = (UILabel*)[self viewWithTag:102];
    titleLabel.textColor = titleLabelColor;
    titleLabel.backgroundColor = [UIColor clearColor];
    
    //rate
    UIImage* imageStar = [UIImage imageNamed:@"shaking_star.png"];
    UIImage* imageEmptyStar = [UIImage imageNamed:@"shaking_star_empty.png"];
    
    CGFloat star = 0.0f;
    if(_dataObject.starGrade!=nil)
        star = [_dataObject.starGrade floatValue];
    
    for(NSInteger i=0; i<5; i++)
    {
        UIImageView* imageView = (UIImageView*)[self viewWithTag:301+i];
        if(star>i)
            imageView.image = imageStar;
        else
            imageView.image = imageEmptyStar;
    }
    
    //sub count    
    UILabel* subCountLabel = (UILabel*)[self viewWithTag:104];
    subCountLabel.textColor = itemLabelColor;
    subCountLabel.backgroundColor = [UIColor clearColor];
    
    //checkbox
    UIImage* checkboxItemImage = [UIImage imageNamed:@"shaking_sel.png"];
    UIImage* checkboxItemImagehl = [UIImage imageNamed:@"shaking_sel_hl.png"];
    UIButton* checkboxView = (UIButton*)[self viewWithTag:204];
    [checkboxView setBackgroundImage:checkboxItemImage forState:UIControlStateNormal];
    [checkboxView setBackgroundImage:checkboxItemImagehl forState:UIControlStateSelected];
}
@end
