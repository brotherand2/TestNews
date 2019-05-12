//
//  SNSubCenterTypesHelper.h
//  sohunews
//
//  Created by wang yanchen on 12-11-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubCenterTableHelper.h"

@interface SNSubCenterTypesHelper : SNSubCenterTableHelper {
    NSMutableArray *_typesArray;
    NSInteger _selectIndex;
    
    BOOL bInitFirstSelection;
}

@property (nonatomic, strong) NSMutableArray *typesArray;
@property (nonatomic, assign) BOOL isLoading;

- (void)refreshDataWithCheckExpired:(BOOL)bCheck;

@end

@protocol SNSubCenterTypesHelperDelegate <NSObject>

@optional
- (void)didSelectTypeWithTypeId:(NSString *)typeId;
- (void)didFinishLoadHomeDataWithTypeId:(NSString *)typeId;
- (void)didFailLoadHomeData; // for home data with empty sub list

- (void)typesTableDidScroll:(UIScrollView *)scroll;
- (void)typesStartToLoad;
- (void)typesFindNoDataToLoad;

@end
