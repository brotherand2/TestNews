//
//  SNThirdPartRequestManager.h
//  sohunews
//
//  Created by lhp on 12/25/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNThirdPartRequestManager : NSObject {
    NSArray *urlArray;
    NSMutableArray *connectionArray;
}
@property(nonatomic,strong)NSArray *urlArray;

+ (SNThirdPartRequestManager *)sharedInstance;
- (void)sendRequestWithUrl:(NSString *) url;
- (void)sendAllRequest;

@end
