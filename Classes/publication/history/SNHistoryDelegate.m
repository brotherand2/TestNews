//
//  SNCgWangQiDelegate.m
//  sohunews
//
//  Created by wangxiang on 4/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNHistoryDelegate.h"
#import "SNDBManager.h"
#import "SNHistoryController.h"
#import "SNHistoryTableCell.h"
#import "SNPaperHistoryItem.h"
#import "SNHistoryModel.h"
#import "SNHistoryItem.h"
#import "SNSubItem.h"

#define ROW_HEIGHT	 (110.0 / 2)

@implementation SNHistoryDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    id curCell = [tableView cellForRowAtIndexPath:indexPath];
	if ([curCell isKindOfClass:[SNHistoryTableCell class]]) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		SNHistoryItem *item = [((SNHistoryModel *)_model).wangqiArray objectAtIndex:indexPath.row];
		if (0 == [item.readFlag intValue]) {
			item.readFlag = [NSString stringWithFormat:@"%d", 1];
			NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
			[tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
			
			NSMutableDictionary *changeInfo = [NSMutableDictionary dictionary];
			[changeInfo setObject:item.readFlag forKey:@"readFlag"];
			[[SNDBManager currentDataBase] updateNewspaperByTermId:item.termId withValuePairs:changeInfo];
		}
		
		if (item) {
            NSMutableDictionary *userInfo = nil;
			NSString *linkType = ((SNHistoryController *)_controller).linkType;
            if (MANAGEMENT_MODE_LOCAL == ((SNHistoryController *)_controller).historyMode) {
                linkType    = @"LOCAL";
                userInfo = [NSMutableDictionary dictionary];
                [userInfo setObject:item forKey:@"subitem"];
            }
			else if ([linkType isEqualToString:@"SUBLIST"]) {
				SNSubItem *newItem = [[SNSubItem alloc] init];
				newItem.subId = item.subId;
                newItem.termId = item.termId;
				newItem.pubId = item.pubId;
				newItem.pubName = item.termName;
				newItem.lastTermLink = item.termLink;
                newItem.termTime = item.termTime;
				SNDebugLog(@"0000000%@", newItem.lastTermLink);
                
                SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:item.subId];
                if (subObj && subObj.subName) {
                    newItem.pubName = subObj.subName;
                }
				userInfo = [NSMutableDictionary dictionary];
				[userInfo setObject:newItem forKey:@"subitem"];
               
                 //(newItem);
			}
            else if ([linkType isEqualToString:@"HISTORYLIST"]) {
                SNPaperHistoryItem *paperHistoryItem = [[SNPaperHistoryItem alloc] init];
                paperHistoryItem.subId = item.subId;
                paperHistoryItem.pubId = item.pubId;
                paperHistoryItem.termName = item.termName;
                paperHistoryItem.link = item.termLink;
                paperHistoryItem.termId = item.termId;
                SNDebugLog(@"SNPaperHomeItem--%@", item.termLink);
                userInfo = [NSMutableDictionary dictionary];
                [userInfo setObject:paperHistoryItem forKey:@"subitem"];
                 //(paperHistoryItem);
            }
            if (userInfo) {
                SNDebugLog(SN_String("INFO: link type is %@"), linkType);
                if ([linkType isEqualToString:@"HISTORYLIST"]) {
                    [userInfo setObject:@"0" forKey:@"navigateFromWangqi"];
                }
                else if ([linkType isEqualToString:@"LOCAL"]) {
                    [userInfo setObject:@"0" forKey:@"navigateFromWangqi"];
                }
                else{
                    [userInfo setObject:@"1" forKey:@"navigateFromWangqi"];
                }
                [userInfo setObject:linkType forKey:@"linkType"];
                
                TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://paperBrowser"] applyAnimated:YES] applyQuery:userInfo];
				[[TTNavigator navigator] openURLAction:urlAction];
			}
		}
	}
	else {
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return ROW_HEIGHT;
}

@end
