//
//  SNNewsDrawBoard.m
//  testDrawboard
//
//  Created by wang shun on 2017/7/10.
//  Copyright © 2017年 wang shun. All rights reserved.
//

#import "SNNewsDrawBoard.h"
#import "SNNewsDrawCanvas.h"
#import "SNNewsDrawBrush.h"
#import "UIColor+ColorChange.h"

@interface SNNewsDrawBoard () {
    CGPoint pts[5];
    uint ctr;
    
    BOOL bbb;
    BOOL reEnter;
}

//背景View
@property (nonatomic, strong) UIImageView *bgImgView;
//画板View
@property (nonatomic, strong) SNNewsDrawCanvas *canvasView;
//合成View
@property (nonatomic, strong) UIImageView *composeView;
//画笔容器
@property (nonatomic, strong) NSMutableArray *brushArray;
//撤销容器
@property (nonatomic, strong) NSMutableArray *undoArray;
@property (nonatomic, strong) NSMutableArray *reundoArray;

////重做容器
//@property (nonatomic, strong) NSMutableArray *redoArray;


//wangshun
//记录脚本用
@property (nonatomic, strong) SNNewsDrawFile *dwawFile;

//每次touchsbegin的时间，后续为计算偏移量用
@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, assign) CGPoint beginPoint;
//绘制脚本用
@property (nonatomic, strong) NSMutableArray *recPackageArray;

@end

@implementation SNNewsDrawBoard

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        _brushArray  = [[NSMutableArray alloc] initWithCapacity:0];
        _undoArray   = [[NSMutableArray alloc] initWithCapacity:0];
        _reundoArray = [[NSMutableArray alloc] initWithCapacity:0];
        
//      _redoArray = [[NSMutableArray alloc]initWithCapacity:0];
        
        _bgImgView = [[UIImageView alloc] init];
        _bgImgView.frame = self.bounds;
        [self addSubview:_bgImgView];
        
        _composeView = [[UIImageView alloc] init];
        _composeView.frame = self.bounds;
//        _composeView.image = [self getAlphaImg];
        [self addSubview:_composeView];
        
        _canvasView = [[SNNewsDrawCanvas alloc] init];
        _canvasView.frame = _composeView.bounds;
        [_composeView addSubview:_canvasView];
        
        self.brushColor = [UIColor colorWithHexString:@"#ee2f10"];
        _brushWidth = LSDEF_BRUSH_WIDTH;
        _isEraser = NO;
        _shapeType = LSDEF_BRUSH_SHAPE;
        
        //wangshun
        _dwawFile = [[SNNewsDrawFile alloc] init];
        _dwawFile.packageArray = [NSMutableArray new];
        
        bbb = NO;
        reEnter = NO;
        
    }
    return self;
}

- (void)addModelToPackage:(SNNewsDrawModel*)drawModel
{
//    SNNewsDrawPackage *drawPackage = [[SNNewsDrawPackage alloc] init];
//    drawPackage.pointOrBrushArray = [[NSMutableArray alloc] initWithCapacity:0];
//    
//    [drawPackage.pointOrBrushArray addObject:drawModel];
//    [_dwawFile.packageArray addObject:drawPackage];
}


#pragma mark - Touch Event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    BOOL y =  [self pointCondition:touches];
    if (y==NO) {
        return;
    }
    //NSLog(@"board touchesBegan");
    CGPoint point = [[touches anyObject] locationInView:self];
    self.beginPoint = point;
    bbb = NO;

}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    BOOL y =  [self pointCondition:touches];
    if (y==NO) {
        return;
    }
    
    //NSLog(@"board touchesMoved");
    CGPoint point = [[touches anyObject] locationInView:self];
    //NSLog(@"%@",NSStringFromCGPoint(point));
    if (CGPointEqualToPoint(point,self.beginPoint) && bbb == NO) {
        
#ifdef __IPHONE_9_0
        NSArray *arrayTouch = [touches allObjects];
        UITouch *touch = (UITouch *)[arrayTouch lastObject];
        if (touch.force<1.0) {//3DTouch
            return;
        }
#endif
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(drawBoardClick:)]) {
            [self.delegate drawBoardClick:nil];
        }
        return;
    }
    else{
        
        if (bbb== NO) {
            SNNewsDrawBrush *brush = [SNNewsDrawBrush new];
            brush.brushColor = self.brushColor;
            brush.brushWidth = _brushWidth;
            brush.isEraser = _isEraser;
            brush.shapeType = _shapeType;
            brush.beginPoint = point;
            
            brush.bezierPath = [UIBezierPath new];
            [brush.bezierPath moveToPoint:point];
            
            
            [_brushArray addObject:brush];
            
            ctr = 0;
            pts[0] = point;
            
            if ([self.delegate respondsToSelector:@selector(drawBoardStartDraw:)]) {
                [self.delegate drawBoardStartDraw:nil];
            }
        }

        bbb = YES;
    }
    
    
    SNNewsDrawBrush *brush = [_brushArray lastObject];
    //wangshun
    
    if (_isEraser)
    {
        [brush.bezierPath addLineToPoint:point];
        [self setEraserMode:brush];
    }
    else
    {
        switch (_shapeType)
        {
            case SNNewsDrawShapeCurve:
                //                [brush.bezierPath addLineToPoint:point];
                
                ctr++;
                pts[ctr] = point;
                if (ctr == 4)
                {
                    pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0);
                    
                    [brush.bezierPath moveToPoint:pts[0]];
                    [brush.bezierPath addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
                    pts[0] = pts[3];
                    pts[1] = pts[4];
                    ctr = 1;
                }
                
                break;
                
            case SNNewsDrawShapeLine:
                [brush.bezierPath removeAllPoints];
                [brush.bezierPath moveToPoint:brush.beginPoint];
                [brush.bezierPath addLineToPoint:point];
                break;
                
            case SNNewsDrawShapeEllipse:
                brush.bezierPath = [UIBezierPath bezierPathWithOvalInRect:[self getRectWithStartPoint:brush.beginPoint endPoint:point]];
                break;
                
            case SNNewsDrawShapeRect:
                
                brush.bezierPath = [UIBezierPath bezierPathWithRect:[self getRectWithStartPoint:brush.beginPoint endPoint:point]];
                break;
                
            default:
                break;
        }
    }
    
    //在画布上画线
    [_canvasView setBrush:brush];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    BOOL y =  [self pointCondition:touches];
    if (y==NO) {
        return;
    }
    
    //NSLog(@"board touchesEnded");
    CGPoint point = [[touches anyObject] locationInView:self];
    
    if (CGPointEqualToPoint(point,self.beginPoint)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(drawBoardClick:)]) {
            [self.delegate drawBoardClick:nil];
        }
        return;
    }
    
    //画布view与合成view 合成为一张图（使用融合卡）
    UIImage *img = [self composeBrushToImage];
    //清空画布
    [_canvasView setBrush:nil];
    //保存到存储，撤销用。
    [self saveTempPic:img];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"board touchesCancelled");
    [self touchesEnded:touches withEvent:event];
}

- (BOOL)pointCondition:(NSSet*)touches{
//    if (self.isShowMenu == YES) {
//        CGPoint point = [[touches anyObject] locationInView:self];
//        if (point.y<(47) || point.y>(self.bounds.size.height-61)) {
//            return NO;
//        }
//    }

    return YES;
}

- (CGRect)getRectWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    CGFloat x = startPoint.x <= endPoint.x ? startPoint.x: endPoint.x;
    CGFloat y = startPoint.y <= endPoint.y ? startPoint.y : endPoint.y;
    CGFloat width = fabs(startPoint.x - endPoint.x);
    CGFloat height = fabs(startPoint.y - endPoint.y);
    
    return CGRectMake(x , y , width, height);
}

- (UIImage *)composeBrushToImage
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_composeView.layer renderInContext:context];
    
    UIImage *getImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _composeView.image = getImage;
    
    return getImage;
    
}

- (void)save
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.layer renderInContext:context];
    
    UIImage *getImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIImageWriteToSavedPhotosAlbum(getImage, nil, nil, nil);
    UIGraphicsEndImageContext();
    
    //wangshun
    SNNewsDrawActionModel *actionModel = [SNNewsDrawActionModel new];
    actionModel.ActionType = SNNewsDrawActionSave;
    
    //[self addModelToPackage:actionModel];
    //wangshun
}


- (void)clean
{
    _composeView.image = nil;
    
    [_brushArray removeAllObjects];
    
    //删除存储的文件
    [self cleanUndoArray];
//    [self cleanRedoArray];
    
    
    //wangshun
//    SNNewsDrawActionModel *actionModel = [SNNewsDrawActionModel new];
//    actionModel.ActionType = SNNewsDrawActionClean;
    
    //[self addModelToPackage:actionModel];
    //wangshun
}

- (void)cleanUndoArray
{
    for(NSString *picPath in _undoArray)
    {
        [self deleteTempPic:picPath];
    }
    
    [_undoArray removeAllObjects];
}

//- (void)cleanRedoArray
//{
//    for(NSString *picPath in _redoArray)
//    {
//        [self deleteTempPic:picPath];
//    }
//    
//    [_redoArray removeAllObjects];
//}


- (void)deleteTempPic:(NSString *)picPath
{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    [fileManager removeItemAtPath:picPath error:nil];
}

- (void)layoutSubviews
{
    _bgImgView.frame = self.bounds;
    _composeView.frame = self.bounds;
    _canvasView.frame = self.bounds;
}

- (void)setEraserMode:(SNNewsDrawBrush*)brush
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0);
    
    [_composeView.image drawInRect:self.bounds];
    
    [[UIColor clearColor] set];
    
    brush.bezierPath.lineWidth = _brushWidth;
    [brush.bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
    
    [brush.bezierPath stroke];
    
    _composeView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}

- (void)saveTempPic:(UIImage*)img
{
    if (img)
    {
        //这里切换线程处理
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSDate *date = [NSDate date];
            NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"HHmmssSSS"];
            NSString *now = [dateformatter stringFromDate:date];
            
            NSString *picPath = [NSString stringWithFormat:@"%@%@",[NSHomeDirectory() stringByAppendingFormat:@"/tmp/"], now];
            //NSLog(@"存贮于   = %@",picPath);
            
            BOOL bSucc = NO;
            NSData *imgData = UIImagePNGRepresentation(img);
            
            
            if (imgData)
            {
                bSucc = [imgData writeToFile:picPath atomically:YES];
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (bSucc)
                {
                    //NSLog(@"wangshun picPath:::%@",picPath);
                    [_undoArray addObject:picPath];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(drawBoardCanUnDo:)]) {
                        [self.delegate drawBoardCanUnDo:YES];
                    }
                }
                
            });
        });
    }
    
}

- (UIImage *)getLastBrush{
    if (_undoArray.count>0) {
        NSString *lastPath = [_undoArray lastObject];
        NSData *imgData = [NSData dataWithContentsOfFile:lastPath];
        
        UIImage* img = [UIImage imageWithData:imgData];
        return img;
    }
    return nil;
}

#pragma mark -

#pragma mark - 撤销

- (void)unDo
{
    if (_undoArray.count > 0)
    {
        NSString *lastPath = [_undoArray lastObject];
        
        //NSLog(@"wangshun remove picPath:::%@",lastPath);
        
        [_undoArray removeLastObject];
        
        if (_undoArray.count == 0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(drawBoardCanUnDo:)]) {
                [self.delegate drawBoardCanUnDo:NO];
            }
        }
        
        //[_redoArray addObject:lastPath];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            UIImage *unDoImage = nil;
            if (_undoArray.count > 0)
            {
                NSString *unDoPicStr = [_undoArray lastObject];
                NSData *imgData = [NSData dataWithContentsOfFile:unDoPicStr];
                if (imgData)
                {
                    unDoImage = [UIImage imageWithData:imgData];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                _composeView.image = unDoImage;
                
                if (reEnter == YES) {
                    
                }
                else{
                    NSFileManager* fmanager = [NSFileManager defaultManager];
                    if ([fmanager fileExistsAtPath:lastPath]) {
                        [fmanager removeItemAtPath:lastPath error:nil];
                    }
                }
            });
        });
        
    }
}

-(void)reEnterSelf{
    reEnter = YES;
    
    //保留当前状态
    [_reundoArray removeAllObjects];
    [_reundoArray addObjectsFromArray:_undoArray];
}

- (void)canelClick{
    if (reEnter == YES) {
        if (_reundoArray.count>0) {
            [_undoArray removeAllObjects];
            [_undoArray addObjectsFromArray:_reundoArray];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *unDoImage = nil;
                if (_undoArray.count > 0) {
                    NSString *unDoPicStr = [_undoArray lastObject];
                    NSData *imgData = [NSData dataWithContentsOfFile:unDoPicStr];
                    if (imgData) {
                        unDoImage = [UIImage imageWithData:imgData];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _composeView.image = unDoImage;
                });
            });
        }
        else {
            _composeView.image = nil;
            [_undoArray removeAllObjects];
        }
    }
    else {
        _composeView.image = nil;
        [_undoArray removeAllObjects];
    }
}

-(void)dealloc{
    [self clean];
}


- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    if (backgroundImage)
    {
        _bgImgView.image = backgroundImage;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
