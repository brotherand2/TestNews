//
//  SNUpgrade.m
//  sohunews
//
//  Created by 李 雪 on 11-9-5.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNUpgrade.h"
#import "TBXML.h"
#import "SNUpgradeRequest.h"
#import "SNUpgradeInfo.h"

@implementation SNUpgrade

@synthesize delegate = _delegate;
@synthesize currentRequest = _currentRequest;

- (void)getUpgradeInfoWithCompletionHandle:(void(^)(SNUpgradeInfo *upgradeInfo))completionHandle {
    
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
    }
    
    [[[SNUpgradeRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        [self parseResponseWithResponseData:responseObject];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @try {
                if (completionHandle) {
                    completionHandle(_upgradeInfo);
                }
            } @catch (NSException *exception) {
                SNDebugLog(@"SNUpgradeRequest exception reason--%@", exception.reason);
            } @finally {
                
            }
        });
    } failure:^(SNBaseRequest *request, NSError *error) {
        _upgradeInfo.networkError	= error;
        SNDebugLog(@"SNUpgrade-request:didFailLoadWithError %d,%@",[error code],[error localizedDescription]);
        if (_delegate != nil && [_delegate respondsToSelector:@selector(receiveUpgradeInfo:)]) {
            [_delegate receiveUpgradeInfo:nil];
        }
    }];
}

//异步方法
-(void)getUpgradeInfoAsyncly:(id)delegate {
	_delegate	= delegate;
    [self getUpgradeInfoWithCompletionHandle:nil];
}

- (void)parseResponseWithResponseData:(NSData *)data {
    @synchronized (self) {
        if (data == nil || ![data isKindOfClass:[NSData class]]) {
            return;
        }
        
        if (_upgradeInfo == nil) {
            _upgradeInfo = [[SNUpgradeInfo alloc] init];
        }
        TBXML *tbxml = [TBXML tbxmlWithXMLData:data];
        
        TBXMLElement *root = tbxml.rootXMLElement;
        TBXMLElement *updateElem = [TBXML childElementNamed:@"update" parentElement:root];
        
        if (updateElem) {
            NSString *needUpgrade = [TBXML textForElement:[TBXML childElementNamed:@"a" parentElement:updateElem]];
            
            _upgradeInfo.bNeedUpgrade = [needUpgrade isEqualToString:@"1"];
            
            _upgradeInfo.upgradeType = [[TBXML textForElement:[TBXML childElementNamed:@"b" parentElement:updateElem]] intValue];
            
            _upgradeInfo.description = [TBXML textForElement:[TBXML childElementNamed:@"c" parentElement:updateElem]];
            
            _upgradeInfo.packageSize = [[TBXML textForElement:[TBXML childElementNamed:@"d" parentElement:updateElem]] intValue];
            
            _upgradeInfo.downloadUrl = [TBXML textForElement:[TBXML childElementNamed:@"e" parentElement:updateElem]];
            
            _upgradeInfo.latestVer = [TBXML textForElement:[TBXML childElementNamed:@"f" parentElement:updateElem]];
        } else {
            _upgradeInfo.serverRtnError = @"upgrade serverRtnError";
        }
        
        if (_delegate != nil &&
            [_delegate respondsToSelector:@selector(receiveUpgradeInfo:)]) {
            [_delegate receiveUpgradeInfo:_upgradeInfo];
        }
    }
}

-(void)dealloc
{
    if (_currentRequest) {
        [_currentRequest.delegates removeObject:self];
        [_currentRequest cancel];
         //(_currentRequest);
    }
     //(_upgradeInfo);
    _delegate = nil;
}

@end
