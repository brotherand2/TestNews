//
//  SNSubShakingImagesViewController.m
//  sohunews
//
//  Created by Diaochunmeng on 12-11-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubShakingImagesViewController.h"
#import "SNSubShakingItemView.h"

@interface SNSubShakingImagesViewController()
-(void)customerBg;
-(void)resetStartArray;
-(void)clearCurrentItems;
-(void)createItemsByArray:(NSArray*)aArray;
-(void)createItemsWithAnimation:(NSArray*)aArray;
-(CGRect)getStartRectByRandom;
-(void)animationFinished;
@end

@implementation SNSubShakingImagesViewController
@synthesize _desRectArray,_startRectArray;
@synthesize _imagesArray;
@synthesize _subViewController;
@synthesize _animationShowingCount;


//----------------------------------------------------------------------------------------------
//------------------------------------------- 系统回调 -------------------------------------------
//----------------------------------------------------------------------------------------------


-(void)loadView
{
    [super loadView];
    
    CGFloat width = 147;
    CGFloat height = 116;
    
    self._animationShowingCount = 0;
    self._imagesArray = [NSMutableArray arrayWithCapacity:0];
    self._desRectArray = [NSMutableArray arrayWithCapacity:0];
    [_desRectArray addObject:[NSValue valueWithCGRect:CGRectMake(8.5, 30, width, height)]];
    [_desRectArray addObject:[NSValue valueWithCGRect:CGRectMake(164, 30, width, height)]];
    [_desRectArray addObject:[NSValue valueWithCGRect:CGRectMake(8.5, 154.5, width, height)]];
    [_desRectArray addObject:[NSValue valueWithCGRect:CGRectMake(164, 154.5, width, height)]];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self customerBg];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)updateTheme:(NSNotification*)notifiction
{
    [super updateTheme:notifiction];
    [self customerBg];
    
    for(SNSubShakingItemView* item in _imagesArray)
        [item updateTheme:notifiction];
}


//----------------------------------------------------------------------------------------------
//------------------------------------------- 用户接口 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(BOOL)setItemsByArray:(NSArray*)aArray
{
    if(aArray==nil || [aArray count]==0)
        return NO;
    
    [self resetStartArray];
    [self clearCurrentItems];
    //[self createItemsByArray:aArray];
    [self createItemsWithAnimation:aArray];
    return YES;
}


//----------------------------------------------------------------------------------------------
//------------------------------------------- 内部函数 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(CGRect)getStartRectByRandom
{
    if(_startRectArray==nil || [_startRectArray count]==0)
        return CGRectZero;
    else
    {
        NSInteger index = arc4random() % [_startRectArray count];
        NSValue* value = (NSValue*)[_startRectArray objectAtIndex:index];
        [_startRectArray removeObjectAtIndex:index]; //使用策略，用后删除
        return [value CGRectValue];
    }
}

-(void)clearCurrentItems
{
    for(NSInteger i=0; i<[_imagesArray count]; i++)
    {
        UIView* view = (UIView*)[_imagesArray objectAtIndex:i];
        [view removeFromSuperview];
    }
    [self._imagesArray removeAllObjects];
}

-(void)createItemsByArray:(NSArray*)aArray
{
    NSInteger max = 4;
    for(NSInteger i=0; i<[aArray count] && i<max; i++)
    {
        CGRect desRect = [[_desRectArray objectAtIndex:i] CGRectValue];
        SCSubscribeObject* object = (SCSubscribeObject*)[aArray objectAtIndex:i];
        SNSubShakingItemView* item = [[SNSubShakingItemView alloc] initWithFrame:desRect object:object];
        item._subViewController = _subViewController;
        [self.view addSubview:item];
    }
}

-(void)createItemsWithAnimation:(NSArray*)aArray
{
    NSInteger max = 4;
    for(NSInteger i=0; i<[aArray count] && i<max; i++)
    {
        CGRect startRect = [self getStartRectByRandom];
        //CGPoint startCenter = CGPointMake(startRect.origin.x+startRect.size.width/2,startRect.origin.y+startRect.size.height/2);
        CGRect desRect = [[_desRectArray objectAtIndex:i] CGRectValue];
        CGPoint desCenter = CGPointMake(desRect.origin.x+desRect.size.width/2,desRect.origin.y+desRect.size.height/2);
        //CGPoint exCenter = [self getExCenterPt:startCenter desPt:desCenter];
        
        SCSubscribeObject* object = (SCSubscribeObject*)[aArray objectAtIndex:i];
        SNSubShakingItemView* item = [[SNSubShakingItemView alloc] initWithFrame:startRect object:object];
        item._subViewController = _subViewController;
        [self._imagesArray addObject:item];
        [self.view addSubview:item];
        
        /*
        CAKeyframeAnimation* positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
		positionAnimation.duration = 1.0f;
        positionAnimation.calculationMode = kCAAnimationDiscrete;
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, startCenter.x, startCenter.y);
        //CGPathAddLineToPoint(path, NULL, exCenter.x, exCenter.y);
        CGPathAddLineToPoint(path, NULL, desCenter.x, desCenter.y);
		positionAnimation.path = path;
		CGPathRelease(path);

        //Add pos animation
		[item.layer addAnimation:positionAnimation forKey:nil];
        item.center = desCenter;
        
        //Add alpha animation
        CABasicAnimation *fadeAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeAnimation.fromValue= [NSNumber numberWithFloat:0.0];
        fadeAnimation.toValue= [NSNumber numberWithFloat:1.0];
        fadeAnimation.duration= 1.0f;
        [item.layer addAnimation:fadeAnimation forKey:@"fadeInOut"];
        item.alpha = 1.0f;*/
        
        item.alpha = 0.0f;
        self._animationShowingCount++;
        
        [UIView beginAnimations:@"pos-alpha" context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDidStopSelector:@selector(animationFinished)];
        [item setAlpha:1.0f];
        [item setCenter:desCenter];
        [UIView commitAnimations];
    }
}

-(void)resetStartArray
{
    CGFloat width = 146.5;
    CGFloat height = 115.5;
    CGFloat selfRight = self.view.frame.origin.x + self.view.frame.size.width;
    CGFloat selfButtom = self.view.frame.origin.y + self.view.frame.size.height;
    
    self._startRectArray = [NSMutableArray arrayWithCapacity:0];
    [_startRectArray addObject:[NSValue valueWithCGRect:CGRectMake(-width, 22, width, height)]];
    
    //top left
    [_startRectArray addObject:[NSValue valueWithCGRect:CGRectMake(-width, -height, width, height)]];
    //top line
    [_startRectArray addObject:[NSValue valueWithCGRect:CGRectMake(8.5, -height, width, height)]];
    [_startRectArray addObject:[NSValue valueWithCGRect:CGRectMake(164, -height, width, height)]];
    //top right
    [_startRectArray addObject:[NSValue valueWithCGRect:CGRectMake(selfRight, -height, width, height)]];
    //right line
    [_startRectArray addObject:[NSValue valueWithCGRect:CGRectMake(selfRight, 22, width, height)]];
    [_startRectArray addObject:[NSValue valueWithCGRect:CGRectMake(selfRight, 147, width, height)]];
    //buttom right
    [_startRectArray addObject:[NSValue valueWithCGRect:CGRectMake(selfRight, selfButtom, width, height)]];
    //buttom line
    [_startRectArray addObject:[NSValue valueWithCGRect:CGRectMake(164, selfButtom, width, height)]];
    [_startRectArray addObject:[NSValue valueWithCGRect:CGRectMake(22, selfButtom, width, height)]];
    //buttom left
    [_startRectArray addObject:[NSValue valueWithCGRect:CGRectMake(-width, selfButtom, width, height)]];
    //left line
    [_startRectArray addObject:[NSValue valueWithCGRect:CGRectMake(-width, 147, width, height)]];
    [_startRectArray addObject:[NSValue valueWithCGRect:CGRectMake(width, 22, width, height)]];
}

-(void)customerBg
{
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

-(void)animationFinished
{
    self._animationShowingCount--;
}

/*
-(CGFloat)distanceBetweenPointA:(CGPoint)a andB:(CGPoint)b
{
    CGFloat deltaX = b.x - a.x;
    CGFloat deltaY = b.y - a.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY );
}

-(CGPoint)getExCenterPt:(CGPoint)aStart desPt:(CGPoint)aDesPt
{
    CGFloat exTotal = 5.0f;
    CGFloat distance = [self distanceBetweenPointA:aStart andB:aDesPt];
    CGFloat exDetalx = (aDesPt.x-aStart.x)*exTotal/distance;
    CGFloat exDetaly = (aDesPt.y-aStart.y)*exTotal/distance;
    return CGPointMake(aDesPt.x+exDetalx, aDesPt.y+exDetaly);
}*/
@end
