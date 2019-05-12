//
//  SNNewsDrawModel.h
//  testDrawboard
//
//  Created by wang shun on 2017/7/10.
//  Copyright © 2017年 wang shun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SNNewsDrawModel : NSObject

//-(void)encodeWithCoder:(NSCoder *)aCoder;
//
//-(id)initWithCoder:(NSCoder *)aDecoder;
//
//-(id)copyWithZone:(NSZone *)zone;
//
//-(NSUInteger)hash;
//
//-(BOOL)isEqual:(id)object;

@property (nonatomic, assign) NSInteger modelType;

@end


@interface SNNewsDrawPointModel : SNNewsDrawModel

@property (nonatomic, assign) CGFloat xPoint;

@property (nonatomic, assign) CGFloat yPoint;

@end


@interface SNNewsDrawBrushModel : SNNewsDrawModel

@property (nonatomic, copy) UIColor *brushColor;

@property (nonatomic, assign) CGFloat brushWidth;

@property (nonatomic, assign) NSInteger shapeType;

@property (nonatomic, assign) BOOL isEraser;

@property (nonatomic, strong) SNNewsDrawPointModel *beginPoint;

@property (nonatomic, strong) SNNewsDrawPointModel *endPoint;

@end

typedef NS_ENUM(NSInteger, SNNewsDrawAction)
{
    SNNewsDrawActionUnKnown = 1,
    SNNewsDrawActionUndo,
    SNNewsDrawActionRedo,
    SNNewsDrawActionSave,
    SNNewsDrawActionClean,
    SNNewsDrawActionOther,
};

@interface SNNewsDrawActionModel : SNNewsDrawModel

@property (nonatomic, assign) SNNewsDrawAction ActionType;

@end




@interface SNNewsDrawPackage : SNNewsDrawModel

@property (nonatomic, strong) NSMutableArray<SNNewsDrawModel*> *pointOrBrushArray;

@end


@interface SNNewsDrawFile : SNNewsDrawModel

@property (nonatomic, strong) NSMutableArray<SNNewsDrawPackage*> *packageArray;

@end

