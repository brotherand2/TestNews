//
//  SNUpgrade.h
//  sohunews
//
//  Created by 李 雪 on 11-9-5.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SNUpgradeInfo;
@protocol SNUpgradeDelegate;

@interface SNUpgrade : NSObject {
	SNUpgradeInfo	*_upgradeInfo;
	NSString		*_curElementName;
    NSMutableString *_curElementValue;
}

@property(nonatomic, weak)id<SNUpgradeDelegate> delegate;
@property(nonatomic, strong) SNURLRequest *currentRequest;

//同步方法
//-(SNUpgradeInfo*)getUpgradeInfo;
- (void)getUpgradeInfoWithCompletionHandle:(void(^)(SNUpgradeInfo *upgradeInfo))completionHandle;
//异步方法（暂未实现）
-(void)getUpgradeInfoAsyncly:(id)delegate;

@end

@protocol SNUpgradeDelegate <NSObject>

- (void)receiveUpgradeInfo:(SNUpgradeInfo*)upgradeInfo;

@end


