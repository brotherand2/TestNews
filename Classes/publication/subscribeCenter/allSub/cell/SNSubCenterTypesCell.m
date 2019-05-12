//
//  SNSubCenterTypesCell.m
//  sohunews
//
//  Created by wang yanchen on 12-11-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubCenterTypesCell.h"
#import "UIColor+ColorUtils.h"
#import "CacheObjects.h"

#define kTypeCellWidth                      (168 / 2)
#define kTypeCellHeight                     (120 / 2)

#define kTypeNameFont                       (28 / 2)

#define kTypeNameTopMargin                  (32 / 2)
#define kTypeNameLeftMargin                 (20 / 2)

@implementation SNSubCenterTypesCell
@synthesize typeObj = _typeObj;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _typeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kTypeNameTopMargin, kTypeCellWidth, kThemeFontSizeD + 1)];
        _typeNameLabel.backgroundColor = [UIColor clearColor];
        _typeNameLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        _typeNameLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText1Color]];
        _typeNameLabel.centerY = self.frame.size.height / 2; //kTypeCellHeight / 2;
        _typeNameLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_typeNameLabel];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
//     //(_selectBackImageView);
     //(_typeObj);
     //(_typeNameLabel);
}

- (void)setTypeObj:(SCSubscribeTypeObject *)typeObj {
    if (_typeObj != typeObj) {
         //(_typeObj);
        _typeObj = typeObj;
    }
    
    _typeNameLabel.text = _typeObj.typeName;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    if (highlighted) {
        self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSubTypeCellHilightBgColor]];
    }
    else{
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
//    _selectBackImageView.hidden = !selected;
    _typeNameLabel.textColor = self.selected ? [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeRed1Color]] : [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText1Color]];
}

- (void)updateTheme {
    _typeNameLabel.textColor = self.selected ? [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeRed1Color]] : [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText1Color]];
//    _selectBackImageView.image = [UIImage themeImageNamed:@"subcenter_allsub_type_cell_bgn.png"];
//    [self setSelected:!_selectBackImageView.isHidden animated:NO];
}

@end
