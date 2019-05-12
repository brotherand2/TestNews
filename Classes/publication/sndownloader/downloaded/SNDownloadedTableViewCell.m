//
//  SNReWangQiTableCell.m
//  sohunews
//
//  Created by wangjiangshan on 6/30/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadedTableViewCell.h"
#import "SNHistoryController.h"
#import "SNHistoryTableItem.h"
#import "SNHistoryModel.h"
#import "SNHistoryItem.h"
#import "UIColor+ColorUtils.h"

#define SELF_ROW_HEIGHT                                                                     (110.0 / 2)

#define SELF_DOWNLOADED_DATE_LABEL_TAG                                                      (100)
#define SELF_DOWNLOADED_TIME_LABEL_TAG                                                      (101)
#define SELF_DOWNLOADED_SELECT_BTN_TAG                                                      (102)

#define SELF_MOVE_TO_LEFT_INEDITMODE                                                        (30)

#define SELF_SELECT_BTN_WIDTH                                                               (60/2.0f)
#define SELF_SELECT_BTN_HEIGHT                                                              (60/2.0f)

@interface SNDownloadedTableViewCell()

- (void)setAlreadyReadStyle:(BOOL)isReadFlag;

- (void)tap:(UIButton *)btn;

@end


@implementation SNDownloadedTableViewCell

@synthesize newspaperItem = _newspaperItem;
@synthesize tableViewCellDelegate = _tableViewCellDelegate;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}
- (void)updateTheme
{
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
    [UIView drawCellSeperateLine:rect];
	
}

- (void)layoutSubviews  {
	[super layoutSubviews];

    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //Term name
    CGFloat _textLabelWidth = self.frame.size.width - 70;
    if (_newspaperItem.isEditMode) {
        _textLabelWidth = self.frame.size.width - 70- SELF_MOVE_TO_LEFT_INEDITMODE;
    }
    self.textLabel.font = [UIFont systemFontOfSize:17];
//    self.textLabel.textColor = TTSTYLEVAR(textColor);
//    self.textLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
    self.textLabel.textAlignment = NSTextAlignmentLeft;
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.textLabel.frame = CGRectMake(10,
                                      0,
                                      _textLabelWidth,
                                      self.frame.size.height); 
    self.textLabel.backgroundColor = [UIColor  clearColor];
    self.textLabel.adjustsFontSizeToFitWidth = NO;
    self.textLabel.text =_newspaperItem.termName;
    
    //Parse date and time
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd hh:mm";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[_newspaperItem.downloadTime doubleValue]];
    NSString *strTimer = [formatter stringFromDate:date];
    NSArray *aryTime =[strTimer  componentsSeparatedByString:@" "];
    NSString *_downloadedDateStr = [aryTime  objectAtIndex:0];
    NSString *_downloadedTimeStr = [aryTime objectAtIndex:1];
    
    //Downlod time
    CGFloat _timeLabelLeft = self.bounds.size.width-40-10;
    if (_newspaperItem.isEditMode) {
        _timeLabelLeft = self.bounds.size.width-40-10 - SELF_MOVE_TO_LEFT_INEDITMODE;
    }
    UILabel *_downloadedTimeLabel = (UILabel *)[self viewWithTag:SELF_DOWNLOADED_TIME_LABEL_TAG];
    if (!_downloadedTimeLabel) {
        _downloadedTimeLabel = [[UILabel alloc] init];
        _downloadedTimeLabel.textAlignment = NSTextAlignmentRight;
        _downloadedTimeLabel.backgroundColor = [UIColor clearColor];
        _downloadedTimeLabel.font = [UIFont systemFontOfSize:7];
        _downloadedTimeLabel.frame = CGRectMake(_timeLabelLeft,12,40,8 );
        _downloadedTimeLabel.tag = SELF_DOWNLOADED_TIME_LABEL_TAG;
        [self addSubview:_downloadedTimeLabel];
        //_downloadedTimeLabel = nil;
    }
    _downloadedTimeLabel.text = _downloadedTimeStr;
    CGRect _timeLabelFrame = _downloadedTimeLabel.frame;
    _timeLabelFrame.origin.x = _timeLabelLeft;
    _downloadedTimeLabel.frame = _timeLabelFrame;
    
    //Downlod date
    CGFloat _dateLabelLeft = self.bounds.size.width-60-10;
    if (_newspaperItem.isEditMode) {
        _dateLabelLeft = self.bounds.size.width-60-10 - SELF_MOVE_TO_LEFT_INEDITMODE;
    }
    UILabel *_downloadedDateLabel = (UILabel *)[self viewWithTag:SELF_DOWNLOADED_DATE_LABEL_TAG];
    if (!_downloadedDateLabel)  {
        _downloadedDateLabel = [[UILabel alloc] init];
        _downloadedDateLabel.textAlignment = NSTextAlignmentRight;
        _downloadedDateLabel.backgroundColor = [UIColor clearColor];
        _downloadedDateLabel.font = [UIFont systemFontOfSize:16];
        _downloadedDateLabel.frame = CGRectMake(_dateLabelLeft,25,60,18);
        _downloadedDateLabel.tag = SELF_DOWNLOADED_DATE_LABEL_TAG;
        [self addSubview:_downloadedDateLabel];
        //_downloadedDateLabel = nil;
    }
    _downloadedDateLabel.text = _downloadedDateStr;
    CGRect _dateLabelFrame = _downloadedDateLabel.frame;
    _dateLabelFrame.origin.x = _dateLabelLeft;
    _downloadedDateLabel.frame = _dateLabelFrame;
    if([_newspaperItem.readFlag intValue]== 1) {
        [self setAlreadyReadStyle:YES];
    }
    else {
        [self setAlreadyReadStyle:NO];
    }
    
    //Select btn
    UIButton *_selectBtn = (UIButton *)[self viewWithTag:SELF_DOWNLOADED_SELECT_BTN_TAG];
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectBtn.selected = NO;
        [_selectBtn addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        _selectBtn.tag = SELF_DOWNLOADED_SELECT_BTN_TAG;
        [self addSubview:_selectBtn];
    }
    if (_newspaperItem.isEditMode) {
        CGRect _frame = CGRectMake(self.bounds.size.width-SELF_SELECT_BTN_WIDTH-5, 
                                   (SELF_ROW_HEIGHT - SELF_SELECT_BTN_HEIGHT)/2.0f, 
                                   SELF_SELECT_BTN_WIDTH, 
                                   SELF_SELECT_BTN_HEIGHT);
        [_selectBtn setFrame:_frame];
        if (_newspaperItem.isSelected) {
            NSString *_selectedImageName = @"selected.png";
            [_selectBtn setBackgroundImage:[UIImage imageNamed:_selectedImageName] forState:UIControlStateNormal];
            _selectBtn.selected = YES;
        } else {
            NSString *_deselectedImageName = @"deselected.png";
            [_selectBtn setBackgroundImage:[UIImage imageNamed:_deselectedImageName] forState:UIControlStateNormal];
            _selectBtn.selected = NO;
        }
    } else {
        CGRect _frame = CGRectMake(self.bounds.size.width, 
                                   (SELF_ROW_HEIGHT - SELF_SELECT_BTN_HEIGHT)/2.0f, 
                                   SELF_SELECT_BTN_WIDTH, 
                                   SELF_SELECT_BTN_HEIGHT);
        [_selectBtn setFrame:_frame];
        NSString *_deselectedImageName = @"deselected.png";
        [_selectBtn setBackgroundImage:[UIImage imageNamed:_deselectedImageName] forState:UIControlStateNormal];
        _selectBtn.selected = NO;
    }
}

- (void)beginEditMode {
    if (_newspaperItem.isEditMode) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        
        //text label
        CGFloat _textLabelWidth = self.frame.size.width - 70 - SELF_MOVE_TO_LEFT_INEDITMODE;
        CGRect _textLabelFrame = self.textLabel.frame;
        _textLabelFrame.size.width = _textLabelWidth;
        self.textLabel.frame = _textLabelFrame;
        
        //Downlod time
        UILabel *_downloadedTimeLabel = (UILabel *)[self viewWithTag:SELF_DOWNLOADED_TIME_LABEL_TAG];
        CGFloat _timeLabelLeft = self.bounds.size.width-40-10 - SELF_MOVE_TO_LEFT_INEDITMODE;
        CGRect _timeLabelFrame = _downloadedTimeLabel.frame;
        _timeLabelFrame.origin.x = _timeLabelLeft;
        _downloadedTimeLabel.frame = _timeLabelFrame;

        //Downlod date
        CGFloat _dateLabelLeft = self.bounds.size.width-60-10 - SELF_MOVE_TO_LEFT_INEDITMODE;
        UILabel *_downloadedDateLabel = (UILabel *)[self viewWithTag:SELF_DOWNLOADED_DATE_LABEL_TAG];
        CGRect _dateLabelFrame = _downloadedDateLabel.frame;
        _dateLabelFrame.origin.x = _dateLabelLeft;
        _downloadedDateLabel.frame = _dateLabelFrame;
        
        //Select btn
        CGRect _frame = CGRectMake(self.bounds.size.width-SELF_SELECT_BTN_WIDTH-5, 
                                   (SELF_ROW_HEIGHT - SELF_SELECT_BTN_HEIGHT)/2.0f, 
                                   SELF_SELECT_BTN_WIDTH, 
                                   SELF_SELECT_BTN_HEIGHT);
        UIButton *_selectBtn = (UIButton *)[self viewWithTag:SELF_DOWNLOADED_SELECT_BTN_TAG];
        [_selectBtn setFrame:_frame];
        NSString *_deselectedImageName = @"deselected.png";
        [_selectBtn setBackgroundImage:[UIImage imageNamed:_deselectedImageName] forState:UIControlStateNormal];

        
        [UIView commitAnimations];
    }
}

- (void)endEditMode {
    if (!_newspaperItem.isEditMode) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        
        //text label
        CGFloat _textLabelWidth = self.frame.size.width - 70;
        CGRect _textLabelFrame = self.textLabel.frame;
        _textLabelFrame.size.width = _textLabelWidth;
        self.textLabel.frame = _textLabelFrame;
        
        //Downlod time
        UILabel *_downloadedTimeLabel = (UILabel *)[self viewWithTag:SELF_DOWNLOADED_TIME_LABEL_TAG];
        CGFloat _timeLabelLeft = self.bounds.size.width-40-10;
        CGRect _timeLabelFrame = _downloadedTimeLabel.frame;
        _timeLabelFrame.origin.x = _timeLabelLeft;
        _downloadedTimeLabel.frame = _timeLabelFrame;
        
        //Downlod date
        CGFloat _dateLabelLeft = self.bounds.size.width-60-10;
        UILabel *_downloadedDateLabel = (UILabel *)[self viewWithTag:SELF_DOWNLOADED_DATE_LABEL_TAG];
        CGRect _dateLabelFrame = _downloadedDateLabel.frame;
        _dateLabelFrame.origin.x = _dateLabelLeft;
        _downloadedDateLabel.frame = _dateLabelFrame;
        
        //Select btn
        CGRect _frame = CGRectMake(self.bounds.size.width, 
                                   (SELF_ROW_HEIGHT - SELF_SELECT_BTN_HEIGHT)/2.0f, 
                                   SELF_SELECT_BTN_WIDTH, 
                                   SELF_SELECT_BTN_HEIGHT);
        UIButton *_selectBtn = (UIButton *)[self viewWithTag:SELF_DOWNLOADED_SELECT_BTN_TAG];
        [_selectBtn setFrame:_frame];
        
        [UIView commitAnimations];
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

#pragma mark - Private methods implementation

- (void)setAlreadyReadStyle:(BOOL)isReadFlag {
    UILabel *_downloadedDateLabel = (UILabel *)[self viewWithTag:SELF_DOWNLOADED_DATE_LABEL_TAG];
    UILabel *_downloadedTimeLabel = (UILabel *)[self viewWithTag:SELF_DOWNLOADED_TIME_LABEL_TAG];
    
    if (isReadFlag) {
        _downloadedDateLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kHistoryCellDateReadColor]];
        _downloadedTimeLabel.textColor =  [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kHistoryCellTextReadColor]];
        self.textLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kHistoryCellTextReadColor]];
    }
    else {
        _downloadedDateLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kHistoryCellDateUnreadColor]];
        _downloadedTimeLabel.textColor =  [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kHistoryCellTextUnreadColor]];
        self.textLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kHistoryCellTextUnreadColor]];
    }
}

- (void)tap:(UIButton *)btn {
    SNDebugLog(SN_String("INFO: %@--%@, Before tap btn.selected is [%d]"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), btn.selected);
    btn.selected = !(btn.selected);
    SNDebugLog(SN_String("INFO: %@--%@, After tap btn.selected is [%d]"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), btn.selected);
    
    UIButton *_selectBtn = (UIButton *)[self viewWithTag:SELF_DOWNLOADED_SELECT_BTN_TAG];
    if (btn.selected) {
        _newspaperItem.isSelected = YES;
        NSString *_selectedImageName = @"selected.png";
        [_selectBtn setBackgroundImage:[UIImage imageNamed:_selectedImageName] forState:UIControlStateNormal];
    } else {
        _newspaperItem.isSelected = NO;
        NSString *_deselectedImageName = @"deselected.png";
        [_selectBtn setBackgroundImage:[UIImage imageNamed:_deselectedImageName] forState:UIControlStateNormal];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if([_tableViewCellDelegate canPerformAction:@selector(cellDidTap:) withSender:self])
    {
        [_tableViewCellDelegate performSelector:@selector(cellDidTap:) withObject:self];
    }
#pragma clang diagnostic pop
}

- (void)selectIt {
    UIButton *_selectBtn = (UIButton *)[self viewWithTag:SELF_DOWNLOADED_SELECT_BTN_TAG];
    _selectBtn.selected = YES;
    _newspaperItem.isSelected = YES;
    NSString *_selectedImageName = @"selected.png";
    [_selectBtn setBackgroundImage:[UIImage imageNamed:_selectedImageName] forState:UIControlStateNormal];
}

- (void)deselectIt {
    UIButton *_selectBtn = (UIButton *)[self viewWithTag:SELF_DOWNLOADED_SELECT_BTN_TAG];
    _selectBtn.selected = NO;
    _newspaperItem.isSelected = NO;
    NSString *_deselectedImageName = @"deselected.png";
    [_selectBtn setBackgroundImage:[UIImage imageNamed:_deselectedImageName] forState:UIControlStateNormal];
}

@end
