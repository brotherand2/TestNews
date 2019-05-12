//
//  SNSubShakingImagesViewController.h
//  sohunews
//
//  Created by Diaochunmeng on 12-11-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//



@class SNSubShakingCenterViewController;
@interface SNSubShakingImagesViewController : SNBaseViewController
{
    NSMutableArray* _desRectArray;
    NSMutableArray* _startRectArray;
    NSMutableArray* _imagesArray;
    SNSubShakingCenterViewController* __weak _subViewController;
    NSInteger _animationShowingCount;
}

@property(nonatomic,strong) NSMutableArray* _desRectArray;
@property(nonatomic,strong) NSMutableArray* _startRectArray;
@property(nonatomic,strong) NSMutableArray* _imagesArray;
@property(nonatomic,weak) SNSubShakingCenterViewController* _subViewController;
@property(nonatomic,assign) NSInteger _animationShowingCount;

-(BOOL)setItemsByArray:(NSArray*)aArray;
@end
