//
//  SNReWangQiTableCell.m
//  sohunews
//
//  Created by wangxiang on 4/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNHistoryTableCell.h"
#import "SNHistoryController.h"
#import "SNHistoryTableItem.h"
#import "SNHistoryModel.h"
#import "SNHistoryItem.h"
#import "UIColor+ColorUtils.h"

@interface SNHistoryTableCell()
- (void)setAlreadyReadStyle:(BOOL)isReadFlag;
- (void)showHistoryNewsTimes;
@end

@implementation SNHistoryTableCell
@synthesize strHoureAndMin;
@synthesize strMonAndDay;

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
    [UIView drawCellSeperateLine:rect];
	
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [SNNotificationManager addObserver:self selector:@selector(updateTheme)
                                                     name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)updateTheme
{
    [self setNeedsDisplay];
}

- (void)layoutSubviews 
{
	[super layoutSubviews];

    self.textLabel.frame = CGRectMake(10,
                                      self.contentView.frame.origin.y,
                                      self.contentView.frame.size.width - 50,
                                      self.contentView.frame.size.height); 
    self.textLabel.backgroundColor = [UIColor  clearColor];
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.textLabel.adjustsFontSizeToFitWidth = NO;
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *lbl = (UILabel *)[self.contentView viewWithTag:100];
    if (!lbl) 
    {
        lbl = [[UILabel alloc] init];
        lbl.textAlignment = NSTextAlignmentRight;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.font = [UIFont systemFontOfSize:7];
        lbl.frame = CGRectMake(self.bounds.size.width-10-50, 12, 50, 8);
        lbl.tag = 100;
        [self.contentView addSubview:lbl];
          lbl = nil;
        
        lbl = [[UILabel alloc] init];
        lbl.textAlignment = NSTextAlignmentRight;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.font = [UIFont systemFontOfSize:16];
        lbl.frame = CGRectMake(self.bounds.size.width-10-50, 25, 50, 18);
        
        lbl.tag = 101;
        [self.contentView addSubview:lbl];
         lbl = nil; 
    }
    
    [self showHistoryNewsTimes]; 
    
    SNHistoryTableItem *item = (SNHistoryTableItem *)_item;
    if (MANAGEMENT_MODE_WANGQI == item.historyModels.controller.historyMode || 
        MANAGEMENT_MODE_LOCAL == item.historyModels.controller.historyMode)
    { 
        if([item.historyItem.readFlag  intValue]== 1)
        {
            [self setAlreadyReadStyle:YES];
        }
        else
        {
            [self setAlreadyReadStyle:NO];
        }
    }
}

- (void)setObject:(id)object 
{
    if (object != nil) 
     {
        [super setObject:object];
         SNHistoryTableItem *item = object;
         if (MANAGEMENT_MODE_LOCAL == item.historyModels.controller.historyMode) 
         {
             NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
             formatter.dateFormat = @"MM.dd hh:mm";
             NSDate *date = [NSDate dateWithTimeIntervalSince1970:[item.historyItem.downloadTime doubleValue]];
             NSString *strTimer = [formatter stringFromDate:date];
             NSArray *aryTime =[strTimer  componentsSeparatedByString:@" "];
             self.strMonAndDay = [aryTime  objectAtIndex:0];
             self.strHoureAndMin = [aryTime objectAtIndex:1];
         }
         else
         {
             NSArray *aryTime =[item.historyItem.termTime  componentsSeparatedByString:@" "];
             self.strHoureAndMin = [aryTime objectAtIndex:[aryTime count]-1];
             NSString *strYear = [aryTime objectAtIndex:0];
             NSArray *aryYear = [strYear componentsSeparatedByString:@"-"];
             NSString *strMon = [aryYear objectAtIndex:[aryYear count]-2];
             NSString *strDay = [aryYear objectAtIndex:[aryYear count]-1];
             self.strMonAndDay = [NSString stringWithFormat:@"%@/%@",strMon,strDay];
         }
          self.textLabel.text =item.historyItem.termName;
     }
}

- (void)showHistoryNewsTimes
{
    UILabel *lbl = (UILabel *)[self.contentView viewWithTag:100];
    lbl.text = [NSString stringWithFormat:@"%@",strHoureAndMin];
    lbl = (UILabel *)[self.contentView viewWithTag:101];
    lbl.text = [NSString stringWithFormat:@"%@",strMonAndDay];
}

- (void)setAlreadyReadStyle:(BOOL)isReadFlag
{
    UILabel *lbl100 = (UILabel *)[self.contentView viewWithTag:100];
    UILabel *lbl101 = (UILabel *)[self.contentView viewWithTag:101];
    
    if (isReadFlag) 
    {
        lbl100.textColor =  [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kHistoryCellTextReadColor]];
        lbl101.textColor =  [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kHistoryCellDateReadColor]];
        self.textLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kHistoryCellTextReadColor]];
    }
    else
    {
        lbl100.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kHistoryCellTextUnreadColor]];
        lbl101.textColor =  [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kHistoryCellDateUnreadColor]];
        self.textLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kHistoryCellTextUnreadColor]];
    }
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
}

@end
