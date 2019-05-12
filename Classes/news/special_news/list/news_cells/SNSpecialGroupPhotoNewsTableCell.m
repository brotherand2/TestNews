//
//  SNSpecialGroupPhotoNewsTableCell.m
//  sohunews
//
//  Created by handy wang on 7/7/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNSpecialGroupPhotoNewsTableCell.h"
#import "UIColor+ColorUtils.h"
#import "SNSpecialNewsTableItem.h"

#define kRowHeight                      (106/2)

@implementation SNSpecialGroupPhotoNewsTableCell

#pragma mark - Lifecycle methods

- (void)dealloc {
     //(_arrowView);
    
}

#pragma mark - Public methods implementation

#pragma mark - Override

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
	return kRowHeight;
}

- (void)setObject:(id)object {
    isNewItem = _item != object;
    
	if (isNewItem) {
        
		_item = object;
        
        if (_item) {
            SNSpecialNewsTableItem *snItem = (SNSpecialNewsTableItem *)_item;
            SNDebugLog(SN_String("INFO: %@--%@, item is %@"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), [snItem description]);
            
            snItem.delegate = self;
            snItem.selector = NSSelectorFromString(@"openNews");
            
            if (snItem.text && ![@"" isEqualToString:snItem.text]) {
                self.textLabel.text = snItem.text;
            }
            
            self.detailTextLabel.text = nil;
            self.backView.hidden = YES;
            
            [self setNeedsDisplay];
        }
	}
}

- (void)layoutSubviews {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat width = self.contentView.width - kTableCellHPadding * 4 - 10;
    CGFloat left = kTableCellHPadding;
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.font = [UIFont systemFontOfSize:17];
    self.textLabel.frame = CGRectMake(left, 0, width, kRowHeight);
    if	(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
        self.textLabel.left = 0;
    }
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.textLabel.adjustsFontSizeToFitWidth = NO;
    
    //CGSize _textSize = [self.textLabel.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(width, kRowHeight) lineBreakMode:UILineBreakModeTailTruncation];
    if (![[SNDevice sharedInstance] isPhone6] && ![[SNDevice sharedInstance] isPlus]) {
        CGRect _textLabelFrame = self.textLabel.frame;
        _textLabelFrame.size.width = 230;
        self.textLabel.frame = _textLabelFrame;
    }
   
    self.detailTextLabel.text = nil;
    
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] init];
        CGFloat xvalue = self.contentView.width - kTableCellHPadding  - 15/2.0;
        _arrowView.frame = CGRectMake(xvalue, 42/2, 15/2.0, 24/2);
        [self addSubview:_arrowView];
    }
    
    if (!_typeIcon) {
        _typeIcon = [[UILabel alloc] init];
        
        CGFloat xvalue = self.contentView.width - kTableCellHPadding - 56/2.0;
        _typeIcon.frame = CGRectMake(xvalue, CGRectGetMidY(self.textLabel.frame) - 28/2/2, 56/2.0, 28/2);
        _typeIcon.textAlignment = NSTextAlignmentCenter;
        _typeIcon.layer.cornerRadius = 2;
        _typeIcon.font = [UIFont systemFontOfSize:10];
        
        [self addSubview:_typeIcon];
    }
    
    _typeIcon.text = NSLocalizedString(@"GroupPhotoNews", nil);
    _typeIcon.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsTypeLiveColor]];
    _typeIcon.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsTypeTextColor]];
    
    if ([self needsUpdateTheme]) {
        [self updateTheme];
    }
    
    [self setReadStyleByMemory];
}

-(void)updateTheme {

    [super updateTheme];
    _typeIcon.text = NSLocalizedString(@"GroupPhotoNews", nil);
    _typeIcon.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsTypeLiveColor]];
    _typeIcon.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsTypeTextColor]];
}

- (void)setAlreadyReadStyle {
    [super setAlreadyReadStyle];

    _arrowView.image = [UIImage imageNamed:@"arrow_hl.png"];
    
}

- (void)setUnReadStyle {
    [super setUnReadStyle];

    _arrowView.image = [UIImage imageNamed:@"arrow.png"];
    
}

@end
