//
//  SNPushSettingDataSource.m
//  sohunews
//
//  Created by 李 雪 on 11-7-1.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNPushSettingDataSource.h"
#import "SNPushSettingModel.h"
#import "SNPushSettingItem.h"
#import "SNPushSettingSectionInfo.h"
#import "SNPushSettingTableItem.h"
#import "SNPushSettingTableCell.h"
#import "SNPushSettingController.h"
#import "SNDBManager.h"

@implementation SNPushSettingDataSource
@synthesize strNewsTitle = _strNewsTitle;
@synthesize pushViewController=_pushViewController;

-(SNPushSettingDataSource*)init{
	if (self = [super init]) {
        [[SNPushSettingModel instance].settingSections  removeAllObjects];
        [[SNPushSettingModel instance].requestAryForChangePushSetting  removeAllObjects];
    }
	return self;
}

- (id<TTModel>)model {
    return [SNPushSettingModel instance];
}

- (void)dealloc {
    [SNPushSettingModel instance].controller = nil;
}

#pragma mark -
#pragma mark TTTableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return [[SNPushSettingModel instance].settingSections count];
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section 
{
   if (section >= [[SNPushSettingModel instance].settingSections count]) {
		return 0;
	}
	
    SNPushSettingSectionInfo *sectionInfo = [[SNPushSettingModel instance].settingSections objectAtIndex:section];
    NSInteger numStoriesInSection = [sectionInfo.settingItems count];
    return numStoriesInSection;
}

- (void)tableViewDidLoadModel:(UITableView*)tableView {
	self.items		 = [NSMutableArray array];
	self.sections	 = [NSMutableArray array];
    
    for (SNPushSettingSectionInfo *settingSection in [SNPushSettingModel instance].settingSections) {
        
        [self.sections addObject:((settingSection.name == nil) ? @"" : settingSection.name)];
        NSMutableArray *itemsPerSection	= [NSMutableArray array];
        if (PushSettingSwith) {
            for (NSObject *objItem in settingSection.settingItems) {
                if ([objItem isKindOfClass:[SNPushSettingItem class]]) {
                    SNPushSettingTableItem *item = [[SNPushSettingTableItem alloc]init];
                    item.pushSettingController=self.pushViewController;
                    item.pushSettingItem=(SNPushSettingItem *)objItem;
                    item.nType	= 1;
                    if (item) {
                        [itemsPerSection addObject:item];
                    }
                }
                else{
                    [itemsPerSection addObject:objItem];
                }
            }
        }
        else{
            for (SNPushSettingItem *settingItem in settingSection.settingItems) {
                SNPushSettingTableItem *item = [[SNPushSettingTableItem alloc]init];
                item.pushSettingController=self.pushViewController;
                item.pushSettingItem=settingItem;
                item.nType	= 1;
                if (item) {
                    [itemsPerSection addObject:item];
                }
            }
        }
        [self.items addObject:itemsPerSection];
	}
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
	if ([object isKindOfClass:[SNPushSettingTableItem class]]) {
		return [SNPushSettingTableCell class];
	} 
	return [super tableView:tableView cellClassForObject:object];		
}

- (NSString*)titleForLoading:(BOOL)reloading {
	return NSLocalizedString(@"Loading data",@"");
}

- (NSString*)titleForError:(NSError*)error {
	return NSLocalizedString(@"Load data failed",@"");
}

- (NSString*)subtitleForError:(NSError*)error {
	return NSLocalizedString(@"Retry later",@"");
}

- (NSString*)titleForEmpty
{
	return NSLocalizedString(@"No Subscribe info",@"");
}

@end

