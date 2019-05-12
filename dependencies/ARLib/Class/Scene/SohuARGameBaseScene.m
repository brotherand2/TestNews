//
//  SohuARGameBaseScene.m
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import "SohuARGameBaseScene.h"
#include <GLKit/GLKit.h>
#include "SohuARMacro.h"
#import "SohuARSingleton.h"
#import "SohuFileManager.h"
#import "SohuReadyView.h"
#import "SohuAnimationModels.h"
#import "SohuSloganView.h"
#import "SohuVector3.h"
#import "SohuMathTool.h"

@interface SohuARGameBaseScene ()<SohuNavigationBarDelegate,SohuARAlertViewDelegate,SohuARAlertViewDelegate>

@property(nonatomic,strong) UIButton        *photographButton;
@property(nonatomic,strong) UILabel         *hudLabel;
@property(nonatomic,assign) NSInteger       clickNumber;
@property(nonatomic,assign) NSInteger       clickNumber2;
@property(nonatomic,strong) NSMutableArray  *otherNodeArray;
@property(nonatomic,strong) NSMutableArray  *allModelArray;
@property(nonatomic,strong) NSDictionary    *allModelAnimation;
@property(nonatomic,assign) NSInteger       jumpNumber;
@property(nonatomic,strong) NSMutableArray  *sloganImages;
@property(nonatomic,assign) NSInteger       sloganNumber;
@property(nonatomic,strong) NSTimer         *timer;
@property(nonatomic,strong) UILabel         *tipsLabel;
@property(nonatomic,strong) UIImageView     *arrowImageView;
@property(nonatomic,assign) BOOL            hadAdd1;
@property(nonatomic,assign) BOOL            hadAdd2;
@property(nonatomic,assign) BOOL            animationStatus;
@property(nonatomic,strong) SCNNode         *mainNode;
@property(nonatomic,assign) CGFloat         animationStart;
@property(nonatomic,assign) CGFloat         animationEnd;
@property(nonatomic,assign) NSInteger       currentNumber;
@property(nonatomic,strong) SohuReadyView   *readyView;
@property(nonatomic,strong) CAAnimationGroup *mainGroup;
@property(nonatomic,strong) dispatch_source_t time;
@property(nonatomic,assign) BOOL            hadBig;
@property(nonatomic,strong) SCNNode         *jumpNode;
@property(nonatomic,strong) NSArray         *jumperArray;
@property(nonatomic,assign) BOOL            rotaion;
@property(nonatomic,assign) BOOL            isAnimation;
@property(nonatomic,assign) BOOL            hadLoad;

@end


@implementation SohuARGameBaseScene


#pragma mark - initialization
//init
-(void)setupSceneWith3DModelPathArray:(NSArray *)modelPathArray{
    [self initializationData];
    [self.rootNode addChildNode:self.cameraNode];
    for(int i=0;i<modelPathArray.count;i++){
        NSDictionary *dic=modelPathArray[i];
        SCNNode *modelNode= [self initializationNodeWithNodeDic:dic];
        [self.rootNode addChildNode:modelNode];
        if(i>0){
            if(modelNode){
                [_otherNodeArray addObject:modelNode];
            }
        }
    }
    
    self.rootNode.paused=YES;
}

//data
-(void)initializationData{
    _allModelAnimation=[NSMutableDictionary dictionary];
    _otherNodeArray=[NSMutableArray array];
    _allModelArray=[NSMutableArray array];
}

//node
-(SCNNode *)initializationNodeWithNodeDic:(NSDictionary *)dic{
    NSString *modelPath=dic[@"modelPath"];
    NSString *name=dic[@"name"];
    CGFloat modelX=[dic[@"modelX"] floatValue];
    CGFloat modelY=[dic[@"modelY"] floatValue];
    CGFloat modelZ=[dic[@"modelZ"] floatValue];
    BOOL enAbleShow=[dic[@"enableShow"] boolValue];
    
    NSURL *url=[NSURL fileURLWithPath:[SohuFileManager loadAbsolutePathWithRelativePath:modelPath]];
    SCNSceneSource *sceneSource = [SCNSceneSource sceneSourceWithURL:url options:nil];
    if (sceneSource==nil) {
        return nil;
    }
    SCNScene *modelScene =[SCNScene sceneWithURL:url options:nil error:nil];
    SCNNode *modelNode=[SCNNode node];
    for (SCNNode *node in modelScene.rootNode.childNodes) {
        [modelNode addChildNode:node];
    }
    modelNode.name=name;
    modelNode.hidden=!enAbleShow;
    modelNode.position=SCNVector3Make(modelX, modelY, modelZ);
    if (modelNode) {
        [self.allModelArray addObject:modelNode];
    }
    if(self.mainNode==nil){
        self.mainNode=modelNode;
    }
    [self initializationAnimation:sceneSource node:modelNode info:dic];
    return modelNode;
}

-(void)initializationAnimation:(SCNSceneSource *)sceneSource
                          node:(SCNNode*)node
                          info:(NSDictionary *)dic{
    NSArray *animationIDs =  [sceneSource identifiersOfEntriesWithClass:[CAAnimation class]];
    NSUInteger animationCount = [animationIDs count];
    
    NSMutableArray *longAnimations = [[NSMutableArray alloc] initWithCapacity:animationCount];
    CFTimeInterval maxDuration = 0;
    
    for (NSInteger index = 0; index < animationCount; index++) {
        CAAnimation *animation = [sceneSource entryWithIdentifier:animationIDs[index] withClass:[CAAnimation class]];
        if (animation) {
            maxDuration = MAX(maxDuration, animation.duration);
            _maxDuration=maxDuration;
            [longAnimations addObject:animation];
        }
    }
    CAAnimationGroup *longAnimationsGroup = [[CAAnimationGroup alloc] init];
    longAnimationsGroup.animations = longAnimations;
    longAnimationsGroup.duration = _maxDuration;
    
    if (longAnimationsGroup&& [node.name length]>0) {
        [self.allModelAnimation setValue:longAnimationsGroup forKey: node.name];
    }else{
        return;
    }
    
    if (self.mainGroup==nil) {
        self.mainGroup=longAnimationsGroup;
    }
    CGFloat start=[dic[@"animationStart"] floatValue];
    CGFloat end=[dic[@"animationEnd"] floatValue];
    self.animationStart=start;
    self.animationEnd=end;
    CGFloat repeatCount=[dic[@"repeatCount"] floatValue];
    if (repeatCount==0) {
        repeatCount=MAXFLOAT;
    }
    
    BOOL enable=[dic[@"enableAnimation"] boolValue];
    if (enable) {
        [self nodeAnimationNode:node from:start to:end repeatCount:repeatCount];
        self.mainNode.paused=YES;
    }
    NSDictionary *dic2=[[SohuARSingleton sharedInstance] arConfigurations];
    BOOL enableRotate=[dic2[@"enableRotate"] boolValue];
    if(enableRotate) {
        [self rotate];
    }
}

//1. 不同节点不同动画
-(void)nodeAnimationWith:(SCNNode *)node nodeInfo:(NSDictionary *)dic{
    CGFloat animationStart=[dic[@"animationStart"] floatValue];
    CGFloat animationEnd=[dic[@"animationEnd"] floatValue];
    NSInteger repeatCount=[dic[@"repeatCount"] integerValue];
    self.animationStatus=1;
    [self nodeAnimationNode:node from:animationStart to:animationEnd repeatCount:repeatCount];
}

//2 点击次数播放动画
-(void)numberAnimationWith:(SCNNode *)node nodeInfo:(NSDictionary *)dic{
    NSArray *clickAnimationArray=dic[@"clickAnimationArray"];
    NSDictionary *dic4=clickAnimationArray[_clickNumber%clickAnimationArray.count];
    CGFloat animationStart1=[dic4[@"animationStart"] floatValue];
    CGFloat animationEnd1=[dic4[@"animationEnd"] floatValue];
    NSInteger repeatCount1=[dic4[@"repeatCount"] integerValue];
    self.animationStatus=1;
    [self nodeAnimationNode:node from:animationStart1 to:animationEnd1 repeatCount:repeatCount1];
    _clickNumber++;
}

//3. 播放声音
-(void)animationAudioWith:(SCNNode *)node nodeInfo:(NSDictionary *)dic{
    NSString *animationAudioPath=dic[@"animationAudioPath"];
    if ([animationAudioPath length]>0) {
        [node removeAllAudioPlayers];
        SCNAudioSource *audioSource=[[SCNAudioSource alloc]initWithURL:[NSURL fileURLWithPath:[SohuFileManager loadAbsolutePathWithRelativePath:animationAudioPath]]];
        SCNAction *action=[SCNAction playAudioSource:audioSource waitForCompletion:YES];
        [node runAction:action];
    }
}

//3 跳转
-(void)clickNodetoHTMLWith:(SCNNode *)node nodeInfo:(NSDictionary *)dic{
    NSString *animationUrl=dic[@"animationUrl"];
    if ([animationUrl length]>0) {
        NSDictionary *dic;
        dic=@{@"webViewUrl":animationUrl,
              };
        [[NSNotificationCenter defaultCenter] postNotificationName:kgoHTMLNotification object:dic ];
    }
}

//7. 数量加1
-(void)plusCounterWithNode:(SCNNode *)node{
    self.navigationBar.counter=self.navigationBar.counter+1;
}

//8.
-(void)jumpWithNode:(SCNNode *)node nodeInfo:(NSDictionary *)dic{
    if (self.jumpNode) {
        self.jumpNode.hidden=YES;
    }
    self.jumpNumber=self.jumpNumber+1;
    
    NSArray *array=[[SohuARSingleton sharedInstance] arConfigurations][@"randomJumpMode"];
    if(self.jumperArray.count==0){
        NSMutableArray *modelArray=[NSMutableArray array];
        for (int i=0; i<array.count; i++) {
            NSDictionary *dic11=array[i];
            NSString *jumpModelPath=dic11[@"modelPath"];
            SCNNode *node66=[self createNodeWithPath:jumpModelPath];
            node66.hidden=YES;
            [modelArray addObject:node66];
        }
        self.jumperArray=modelArray;
    }
    NSDictionary *dic11=array[_jumpNumber%(self.jumperArray.count)];
    NSInteger type=[dic11[@"jumpType"] integerValue];
    SCNNode *node66=self.jumperArray[_jumpNumber%(self.jumperArray.count)];
    NSInteger xxx=kscreenWidth/2;
    NSInteger yyy=kscreenHeight/2;
    
    CGFloat x1=arc4random()%xxx-100;
    CGFloat y1=arc4random()%yyy-100;
    
    if (x1>kscreenWidth/2) {
        x1=kscreenWidth/2;
    }
    if (y1>kscreenWidth/2) {
        y1=kscreenWidth/2;
    }
    CGFloat x=x1 * (arc4random()%2>0?-1:1);
    CGFloat y=y1* (arc4random()%2>0?-1:1);
    CGFloat z=[dic11[@"modelZ"] floatValue];
    
    node66.position=SCNVector3Make(x, y, z);
    self.jumpNode=node66;
    self.jumpNode.hidden=NO;
    [self.rootNode addChildNode:self.jumpNode];
    if (self.mainNode.hidden==NO) {
        self.mainNode.hidden=YES;
    }
    if (type==1) {
        self.navigationBar.counter=self.navigationBar.counter+1;
        [self showClickToNumber];
    }
}

//other
-(void)showMainNodeWithNode:(SCNNode *)node nodeInfo:(NSDictionary *)dic{
    //    for (SCNNode *node in _otherNodeArray) {
    //        [node removeFromParentNode];
    //    }
    //    _hadAdd1=NO;
    //    _hadAdd2=NO;
    //    [_otherNodeArray removeAllObjects];
    //    self.mainNode.hidden=NO;
}

-(void)addModelOfImageWithNode:(SCNNode *)node nodeInfo:(NSDictionary *)dic{
    if (_hadAdd1==NO) {
        _hadAdd1=YES;
        NSArray *array2=dic[@"addModel"];
        for (NSDictionary *dic5 in array2) {
            CGFloat x=[dic5[@"modelX"] floatValue];
            CGFloat y=[dic5[@"modelY"] floatValue];
            CGFloat z=[dic5[@"modelZ"] floatValue];
            CGFloat width=[dic5[@"width"] floatValue];
            CGFloat height=[dic5[@"height"] floatValue];
            CGFloat displayTime=[dic5[@"displayTime"] floatValue];
            CGFloat hiddenMainModel=[dic5[@"hiddenMainModel"] boolValue];
            NSString *imagePath=dic5[@"modelImagePath"];
            UIImage *image=[SohuFileManager readImageFromCachesWithRelativePath:imagePath];
            NSString *name=dic5[@"name"];
            self.modelNode.hidden=hiddenMainModel;
            SCNNode *node=[SCNNode nodeWithGeometry:[SCNPlane planeWithWidth:width height:height]];
            node.name=name;
            node.position=SCNVector3Make(x, y, z);
            node.geometry.firstMaterial.diffuse.contents = image;
            node.geometry.firstMaterial.diffuse.wrapS = SCNWrapModeRepeat;
            [self.rootNode addChildNode:node];
            [_otherNodeArray addObject:node];
            if (displayTime>0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(displayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_otherNodeArray removeObject:node];
                    [node removeFromParentNode];
                    self.modelNode.hidden=NO;
                    _hadAdd1=NO;
                });
            }
        }
    }
}

//5 add MOdel
-(void)addModelWithNode:(SCNNode *)node nodeInfo:(NSDictionary *)dic{
    if (_hadAdd2==NO) {
        _hadAdd2=YES;
        NSArray *array2=dic[@"addModel"];
        for (NSDictionary *dic5 in array2) {
            CGFloat x=[dic5[@"modelX"] floatValue];
            CGFloat y=[dic5[@"modelY"] floatValue];
            CGFloat z=[dic5[@"modelZ"] floatValue];
            CGFloat displayTime=[dic5[@"displayTime"] floatValue];
            CGFloat hiddenMainModel=[dic5[@"hiddenMainModel"] boolValue];
            NSString *name=dic5[@"name"];
            NSString *path=dic5[@"modelPath"];
            self.modelNode.hidden=hiddenMainModel;
            NSURL *url=[NSURL fileURLWithPath:[SohuFileManager loadAbsolutePathWithRelativePath:path]];
            SCNSceneSource *sceneSource = [SCNSceneSource sceneSourceWithURL:url options:nil];
            SCNScene *modelScene = [sceneSource sceneWithOptions:nil error:nil];
            SCNNode *modelNode=modelScene.rootNode;
            modelNode.name=name;
            modelNode.position=SCNVector3Make(x, y, z);
            [self.rootNode addChildNode:modelNode];
            [_otherNodeArray addObject:modelNode];
            if (displayTime>0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(displayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_otherNodeArray removeObject:modelNode];
                    [modelNode removeFromParentNode];
                    self.modelNode.hidden=NO;
                    _hadAdd2=NO;
                });
            }
        }
    }
}

-(void)showNodeWithNode:(SCNNode *)node nodeInfo:(NSDictionary *)dic{
    for (SCNNode *node1 in self.allModelArray) {
        if([node1.name isEqualToString:node.name] ){
            node1.hidden=NO;
        }else{
            node1.hidden=YES;
        }
    }
}

-(void)showBigNodeWithNode:(SCNNode *)node nodeInfo:(NSDictionary *)dic{
    _hadAdd1=YES;
    _hadAdd2=YES;
    for (SCNNode *node1 in _otherNodeArray) {
        if ([node1.name isEqualToString:node.name]) {
            node1.position=SCNVector3Make(0, 0, node1.position.z+50);
            node1.hidden=NO;
        }else{
            node1.hidden=YES;;
        }
    }
    [self.mainNode setHidden:YES];
}

-(void)clickNode:(SCNNode *)node{
    
    if (self.isAnimation==YES) {
        return;
    }
    
    NSString *nodeName=[node name];
    if(node){
        self.rotaion=NO;
        NSDictionary *dic=[[SohuARSingleton sharedInstance]arConfigurations];
        NSDictionary *dic1=dic[@"animationModels"];
        NSDictionary *dic2=dic1[nodeName];
        NSArray *array=dic2[@"ModelArray"];
        for (int i=0; i<array.count; i++) {
            NSDictionary *dic3=array[i];
            NSInteger animationType=[dic3[@"animationType"] integerValue];
            if (animationType==0) {
                self.animationStatus=1;
                [self nodeAnimationWith:node nodeInfo:dic3];
            }else if(animationType==1){
                [self numberAnimationWith:node nodeInfo:dic3];
            }else if(animationType==2){
                [self animationAudioWith:node nodeInfo:dic3];
            }else if(animationType==3){
                [self clickNodetoHTMLWith:node nodeInfo:dic3];
            }else if(animationType==4){
                [self addModelOfImageWithNode:node nodeInfo:dic3];
            }else if(animationType==5){
                [self addModelWithNode:node nodeInfo:dic3];
            }else if(animationType==6){
                [self showNodeWithNode:node nodeInfo:dic];
            }else if (animationType==7){
                [self plusCounterWithNode:node];
            }else if (animationType==8){
                [self jumpWithNode:node nodeInfo:dic3];
            }else if (animationType==9){
                
            }else if (animationType==11){
                [self showBigNodeWithNode:node nodeInfo:dic3];
            }
        }
    }else{
        [self showMainNodeWithNode:nil nodeInfo:nil];
    }
}

-(void)setupData{
    
}

-(NSTimer *)timer{
    if (_timer==nil) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:self.sloganInterval
                                                target:self
                                              selector:@selector(timerAction)
                                              userInfo:nil
                                               repeats:YES];
    }
    return _timer;
}


-(void)setupView{
    //1. 手势
    [self setupGestureRecognizer];
    //2. Start View
    [self setupStartView];
    //3. tool Bar
    [self setupToolBar];
    //4. Nacigation
    [self setupNavigation];
    //5. Photograph
    [self setupPhotograph];
    //6.Slogan
    [self setupSlogan];
    //7.set path
    [self setupPath];
    //8. set Arrow
    [self setupArrow];
    //9. addObsercer
    //[self addObserver];
}

-(void)setupModelPath{
    if (_actionArray.count>0) {
        SCNAction *queueAction=[SCNAction sequence:self.actionArray];
        [self.mainNode runAction:queueAction completionHandler:^{
            [self setupModelPath];
        }];
    }
}

#pragma mark  update Motio
-(void)deviceMotionUpdatesWithDeviceMotion:(CMDeviceMotion *)motion{
    [self updataCameraNodeWithDeviceMotion:motion];
    [self updataArrowWithDeviceMotion:motion];
    
}

-(void)updataCameraNodeWithDeviceMotion:(CMDeviceMotion *)motion{
    if ([ [[SohuARSingleton sharedInstance] arConfigurations][@"enableMotion"]  boolValue]) {
        SCNAction *action=[SCNAction rotateToX:motion.attitude.pitch*0.3 y:motion.attitude.yaw*0.3 z:motion.attitude.yaw*0.1 duration:0.4f];
        [self.cameraNode runAction:action];
    }
}

-(void)updataArrowWithDeviceMotion:(CMDeviceMotion *)motion{
    
    SCNNode *ddNode=self.mainNode;
    if ([[[SohuARSingleton sharedInstance] arConfigurations][@"arrowInfo"][@"enableArrow"] boolValue]) {
        CGFloat left=(atan(motion.attitude.yaw)*ddNode.position.z-ddNode.position.x)<-kscreenWidth/2;
        CGFloat right=(ddNode.position.x)+atan(motion.attitude.yaw)*ddNode.position.z<-kscreenWidth/2;
        if (right) {
            self.arrowImageView.transform=CGAffineTransformMakeRotation(-M_PI_2);
            self.arrowImageView.frame=CGRectMake(0, kscreenHeight/2-35, 33, 70);
            self.arrowImageView.hidden=NO;
        }
        
        if (left) {
            self.arrowImageView.transform=CGAffineTransformMakeRotation(M_PI_2);
            self.arrowImageView.frame=CGRectMake(kscreenWidth-33, kscreenHeight/2-35, 33, 70);
            self.arrowImageView.hidden=NO;
        }
        
        if (right==0&&left==0) {
            self.arrowImageView.hidden=YES;
        }
    }
}

#pragma mark - Life Method
-(void)sceneDidAppear{
    [_navigationBar resumeTimer];
    [_timer setFireDate:[NSDate date]];
    [self.rootNode setPaused:NO];
}

-(void)sceneDealloc{
    [_navigationBar stopTimer];
    [_timer invalidate];
    _timer=nil;
}

-(void)sceneDidDisappear{
    [self.navigationBar pauseTimer];
    [_timer setFireDate:[NSDate distantFuture]];
    
    [_timer invalidate];
    _timer=nil;
    [self.rootNode setPaused:YES];
    [_alertView removeFromSuperview];
    _alertView=nil;
    [_readyView removeFromSuperview];
    _readyView=nil;
    self.superview=nil;
}


#pragma mark - delegate
-(void)nodeAnimationNode:(SCNNode *)node
                    from:(CGFloat)from
                      to:(CGFloat)to
             repeatCount:(CGFloat )repeatCount
{
    
    [self.mainNode removeAllAnimations];
    [self.rootNode removeAllAnimations];
    self.isAnimation=YES;
    if (to-_maxDuration>0.0) {
        to=_maxDuration;
    }
    self.rootNode.paused=NO;
    CAAnimationGroup *animationGroup=[self.mainGroup copy];
    CAAnimationGroup *idleAnimationGroup = animationGroup;
    idleAnimationGroup.timeOffset = from;
    if (idleAnimationGroup) {
        CAAnimationGroup *lastAnimationGroup;
        lastAnimationGroup = [CAAnimationGroup animation];
        lastAnimationGroup.animations = @[idleAnimationGroup];
        lastAnimationGroup.duration = to-from;
        lastAnimationGroup.repeatCount = repeatCount;
        lastAnimationGroup.autoreverses = YES;
        [self.mainNode addAnimation:lastAnimationGroup forKey:@"animation"];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((to-from)*repeatCount )* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.rootNode.paused=YES;
        self.animationStatus=0;
        self.isAnimation=NO;
        if(!node){
            [self showSloganAlertWith:self.mainNode];
            return ;
        }
        [self showSloganAlertWith:node];
    });
}

-(SCNNode *)createNodeWithPath:(NSString *)path{
    NSURL *url=[NSURL fileURLWithPath:[SohuFileManager loadAbsolutePathWithRelativePath:path]];
    SCNScene *modelScene =[SCNScene sceneWithURL:url options:nil error:nil];
    SCNNode *modelNode=[SCNNode node];
    for (SCNNode *node in modelScene.rootNode.childNodes) {
        [modelNode addChildNode:node];
    }
    return modelNode;
}

-(void)rotate{
    SCNAction *rotation = [SCNAction rotateByX:0 y:2 z:0 duration:4];
    SCNAction *repeat = [SCNAction repeatActionForever:rotation];
    [ self.mainNode runAction:repeat];
}
-(void)modelMoveToPoint:(CGPoint)point{
    
}

-(void)willStartGame{
    if ( [[[SohuARSingleton sharedInstance] arConfigurations][@"readyInfo"][@"enableReady"] boolValue]){
        UIWindow *window=[[UIApplication sharedApplication] keyWindow];
        [window addSubview:self.readyView];
        window.userInteractionEnabled=NO;
        [self.readyView setupReadyViewWithAnimation];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_readyView removeFromSuperview];
            [self startGame];
            window.userInteractionEnabled=YES;
            
        });
    }else{
        [self startGame];
    }
}
-(void)startGame{
    // 开始动画
    [self.rootNode setPaused:NO];
    //1. 开始计时
    [_navigationBar startDownCount];
    //2. 安路径跑
    [self setupModelPath];
    //3. 开始solp
    [self startSlogan];
    //4. 开始动画
    [self startAnimation];
}

-(void)startAnimation{
    NSDictionary *dic=[[SohuARSingleton sharedInstance] arConfigurations][@"startAlert"];
    CGFloat start= [dic[@"animationStart"] floatValue];
    CGFloat end=[dic[@"animationEnd"] floatValue];
    CGFloat count=[dic[@"repeatCount"] floatValue];
    CGFloat modelX=[dic[@"modelX"] floatValue];
    CGFloat modelY=[dic[@"modelY"] floatValue];
    CGFloat modelZ=[dic[@"modelZ"] floatValue];
    CGFloat duration=[dic[@"duration"] floatValue];
    if (count==0) {
        count=MAXFLOAT;
    }
    if (_actionArray.count<=0) {
        if (duration-0.0>0) {
            SCNAction *action1=[SCNAction moveTo:SCNVector3Make(modelX, modelY, modelZ) duration:duration];
            [self.mainNode runAction:action1];
        }
    }
    [self nodeAnimationNode:nil from:start to:end repeatCount:count];
    self.animationStart=start;
    self.animationEnd=end;
   }

-(void)setupPath{
    NSDictionary *dic=[[SohuARSingleton sharedInstance] arConfigurations][@"motionPathInfo"];
    if ([dic[@"enableMoveByPath"] boolValue]) {
        NSArray* modelPaths=dic[@"motionPath"];
        _modelPathArray=modelPaths;
        _actionArray=[NSMutableArray array];
        for (int i=0; i<_modelPathArray.count; i++) {
            NSDictionary *dic0=_modelPathArray[i];
            SohuVector3 *sv3=[SohuVector3 vector3x:[dic0[@"modelX"] floatValue] y:[dic0[@"modelY"] floatValue]  z:[dic0[@"modelZ"] floatValue] ];
            SCNVector3 v3=SCNVector3Make(sv3.vector3x, sv3.vector3y, sv3.vector3z);
            CGFloat ff;
            CGFloat temp=250;
            CGFloat yyy;
            if (i==0) {
                ff=[SohuMathTool distanceBetween3DPointsFirst:self.mainNode.position second:SCNVector3Make(sv3.vector3x, sv3.vector3y, sv3.vector3z)]/temp;
                yyy= [SohuMathTool angleYForStartPoint:CGPointMake(self.mainNode.position.x, self.mainNode.position.y) EndPoint:CGPointMake(sv3.vector3x, sv3.vector3y) ];
            }else{
                NSDictionary *dic2=_modelPathArray[i-1];
                SohuVector3 *sv32=[SohuVector3 vector3x:[dic2[@"modelX"] floatValue] y:[dic2[@"modelY"] floatValue]  z:[dic2[@"modelZ"] floatValue] ];
                ff=[SohuMathTool distanceBetween3DPointsFirst:SCNVector3Make(sv3.vector3x, sv3.vector3y, sv3.vector3z)
                                                       second:SCNVector3Make(sv32.vector3x, sv32.vector3y, sv32.vector3z)]/temp;
                yyy= [SohuMathTool angleYForStartPoint:CGPointMake(sv32.vector3x, sv32.vector3y) EndPoint:CGPointMake(sv3.vector3x, sv3.vector3y) ];
            }
            SCNAction *action1=[SCNAction rotateToX:self.mainNode.rotation.x y:yyy z:self.mainNode.rotation.z duration:0.2];
            SCNAction *action=[SCNAction moveTo:v3 duration:ff*2];
            SCNAction *groupAction=[SCNAction group:@[action1,action]];
            [_actionArray addObject:groupAction];
        }
    }
}


#pragma mark - Navigation Bar Delegate
-(void)sohuNavigationBar:(SohuNavigationBar *)sohuNavigationBar countdownCount:(NSInteger)countdownCount{
    NSDictionary *navigationInfo=[[SohuARSingleton sharedInstance] arConfigurations][@"navigationInfo"];
    NSInteger counter1=[navigationInfo[@"standardQuantity"] integerValue];
    if(countdownCount==0){
        [self.rootNode setPaused:YES];
        if(_navigationBar.counter<counter1){
            [self showGameFailView];
        }else if(self.navigationBar.counter>=counter1){
            [self showGameSuccessView];
        }
    }
}

-(void)rePlay{
    NSDictionary *startDic=[[SohuARSingleton sharedInstance] arConfigurations][@"navigationInfo"];
    NSInteger count=[startDic[@"countdown"] integerValue];
    [_navigationBar setupCounterWithCountdownCount:count];
    _navigationBar.counter=0;
    [self willStartGame];
}

-(void)gameSuccess{
    NSDictionary *dic=[[SohuARSingleton sharedInstance] arConfigurations][@"endAlert"];
    NSString *urlString=dic[@"successUrl"];
    _currentNumber=self.navigationBar.counter;
    self.navigationBar.counter=0;
    [self.rootNode setPaused:NO];
    NSDictionary *dic2=@{};
    if (urlString) {
        dic2=@{@"clickNumber":[NSString stringWithFormat:@"%ld",_currentNumber],
               @"webViewUrl":urlString
               };
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kgoHTMLNotification object:dic2 ];
}

-(void)showClickToNumber{
    NSDictionary *dic=[[SohuARSingleton sharedInstance] arConfigurations][@"navigationInfo"];
    if (self.navigationBar.counter==[dic[@"standardQuantity"] integerValue]) {
        [self.alertView removeFromSuperview];
        self.alertView=nil;
        NSDictionary *startDic=[[SohuARSingleton sharedInstance] arConfigurations][@"endAlert"];
        UIImage *image=[SohuFileManager readImageFromCachesWithRelativePath:startDic[@"successImagePath"]];
        self.alertView.alertImage=image;
        self.alertView.tag=3;
        self.alertView.frame=self.superview.frame;
        [self.rootNode setPaused:YES];
    }
}


#pragma mark - alerView Delgate
-(void)sohuARAlertView:(SohuARAlertView *)sohuARAlertView
      didClickItemType:(ARAlertViewItemType)arARAlertViewItemType
             parameter:(NSDictionary *)parameter{
    //0 开始 1 失败 2成功 3 点击到一定次数
    if (sohuARAlertView.tag==0) {
        [self willStartGame];
    }else if (sohuARAlertView.tag==1){
        [self rePlay];
    }else if (sohuARAlertView.tag==2){
        [self gameSuccess];
    }else if (sohuARAlertView.tag==3){
        [self gameSuccess];
    }
}

-(void)showGameFailView{
    [self.alertView removeFromSuperview];
    self.alertView=nil;
    NSDictionary *startDic=[[SohuARSingleton sharedInstance] arConfigurations][@"endAlert"];
    UIImage *image=[SohuFileManager readImageFromCachesWithRelativePath:startDic[@"failImagePath"]];
    if(image){
        self.alertView.alertImage=image;
        self.alertView.tag=1;
        self.alertView.frame=self.superview.frame;
    }
}

-(void)showGameSuccessView{
    [self.alertView removeFromSuperview];
    self.alertView=nil;
    NSDictionary *startDic=[[SohuARSingleton sharedInstance] arConfigurations][@"endAlert"];
    UIImage *image=[SohuFileManager readImageFromCachesWithRelativePath:startDic[@"successImagePath"]];
    if(image){
        self.alertView.alertImage=image;
        self.alertView.tag=2;
        self.alertView.frame=self.superview.frame;
    }
}

#pragma Mark - setup Recognizer
-(void)setupPinchGestureRecognizer{
    UIPinchGestureRecognizer *pinch=[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    [self.superview addGestureRecognizer:pinch];
}

-(void)setupSwipeGestureRecognizer{
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(handleSwipes:)];
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleSwipes:)];
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [self.superview addGestureRecognizer:left];
    [self.superview addGestureRecognizer:right];
}

-(void)setupPanGestureRecognizer{
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self.superview addGestureRecognizer:pan];
}

-(void)setupTapGestureRecognizer{
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
    [tap setNumberOfTapsRequired:2];
    [self.superview addGestureRecognizer:tap];
}

-(void)setupRotationGestureRecognizer{
//    UIRotationGestureRecognizer *rotation=[[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotation:)];
//    [self.superview addGestureRecognizer:rotation];
}

#pragma mark - some Action
-(void)toolBarButtonAction{
    if ([_delegate respondsToSelector:@selector(sohuARGameBaseScene:didClick:)]) {
        [_delegate sohuARGameBaseScene:self didClick:0];
    }
}

-(void)rotation:(UIRotationGestureRecognizer *)rotation{
    if (rotation.state == UIGestureRecognizerStateChanged ){
        SCNAction *rotation1 = [SCNAction rotateByX:0 y:rotation.rotation*0.1 z:0 duration:0.5];
        [ self.mainNode  runAction:rotation1];
    }
}
-(void)handlePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer  {
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateChanged ) {
        self.mainNode.position=SCNVector3Make(self.mainNode.position.x, self.mainNode.position.y, (self.mainNode.position.z-(pinchGestureRecognizer.scale>1?-10:10))>0?0: (self.mainNode.position.z-(pinchGestureRecognizer.scale>1?-10:15)));
    }
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        SCNAction *rotation1 = [SCNAction rotateByX:0 y:M_PI_2 z:0 duration:0.5];
        [ self.mainNode  runAction:rotation1];
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        SCNAction *rotation1 = [SCNAction rotateByX:0 y:-M_PI_2 z:0 duration:0.5];
        [ self.mainNode  runAction:rotation1];
    }
}

-(void)handlePan:(UIPanGestureRecognizer *)panGestureRecognize{
    if (self.rotaion==NO) {
        if (panGestureRecognize.state == UIGestureRecognizerStateChanged ){
            CGPoint point = [panGestureRecognize translationInView:self.superview];
            CGFloat xx=self.mainNode.position.x+point.x*0.025;
            CGFloat yy=self.mainNode.position.y-point.y*0.025;
            SCNVector3 vector3=SCNVector3Make(xx, yy, self.mainNode.position.z);
            self.mainNode.position=vector3;
        }
    }else{
         CGPoint point = [panGestureRecognize translationInView:self.superview];
         SCNAction *rotation1 = [SCNAction rotateByX:0 y:point.x*0.00025 z:0 duration:0.01];
         [ self.mainNode  runAction:rotation1];
    }
    if (panGestureRecognize.state == UIGestureRecognizerStateEnded){
        self.rotaion=YES;
    }
}

-(void)tap{
    self.mainNode.position=SCNVector3Make(0, 0, -600);
    self.mainNode.position=SCNVector3Make(0, 0, 0);
}

-(void)setupGestureRecognizer{
    if ([[[SohuARSingleton sharedInstance] arConfigurations][@"enableGesture"] boolValue]) {
        [self setupPanGestureRecognizer];
        [self setupPinchGestureRecognizer];
        [self setupRotationGestureRecognizer];
        [self setupSwipeGestureRecognizer];
    }
}

-(void)setupStartView{
    NSDictionary *startDic=[[SohuARSingleton sharedInstance] arConfigurations][@"startAlert"];
    if ([startDic[@"enableShow"] boolValue]) {
        NSDictionary *startDic=[[SohuARSingleton sharedInstance] arConfigurations][@"startAlert"];
        UIImage *image=[SohuFileManager readImageFromCachesWithRelativePath:startDic[@"imagePath"]];
        
        if (image==nil) {
            return;
        }
        self.alertView.alertImage=image;
        self.alertView.tag=0;
        self.alertView.alertImageView.bounds=CGRectMake(0, 0, [startDic[@"imageWidth"] floatValue], [startDic[@"imageHeight"] floatValue]);
        self.alertView.alertImageView.center=self.superview.center;
    }
}

-(void)setupToolBar{
    [self.superview addSubview:self.toolBar];
    [self.toolBar.backButton setImage:[UIImage imageNamed:@"ic_back.png"] forState:UIControlStateNormal];
}

-(void)setupNavigation{
    if ([[[SohuARSingleton sharedInstance] arConfigurations][@"enbleNavigation"] boolValue]) {
        NSDictionary *navigationDic=[[SohuARSingleton sharedInstance] arConfigurations][@"navigationInfo"];
        if ([navigationDic[@"enableCounter"] boolValue]) {
            UIImage *image=[SohuFileManager readImageFromCachesWithRelativePath:navigationDic[@"ImagePath"]];
            self.navigationBar.counterImage=image;
            [self.navigationBar setupCounterWithCounter:0];
        }
        if([navigationDic[@"enableTimer"] boolValue]) {
            NSDictionary *startDic=[[SohuARSingleton sharedInstance] arConfigurations][@"navigationInfo"];
            NSInteger count=[startDic[@"countdown"] integerValue];
            [self.navigationBar setupCounterWithCountdownCount:count];
        }
        [self.superview addSubview:self.navigationBar];
    }
}

-(void)setupPhotograph{
    if ([[[SohuARSingleton sharedInstance] arConfigurations][@"enablePhotograph"] boolValue]) {
        [self.superview addSubview:self.photographButton];
    }
}

-(void)setupArrow{
    NSDictionary *dic=[[SohuARSingleton sharedInstance] arConfigurations][@"arrowInfo"];
    if ( [dic[@"enableArrow"] boolValue]) {
        NSString *startDic=dic[@"arrowImage"];
        UIImage *image=[SohuFileManager readImageFromCachesWithRelativePath:startDic];
        _arrowImageView.image=image;
        [self.superview addSubview:self.arrowImageView];
        [self.superview addSubview:self.tipsLabel];
    }
}

-(void)startSlogan{
    [_timer setFireDate:[NSDate date]];
}

-(void)setupSlogan{
    NSDictionary *dic=[[SohuARSingleton sharedInstance] arConfigurations][@"sloganInfo"];
    if ([dic[@"enableSolgan"] boolValue]) {
        self.sloganImages=dic[@"sloganImages"];
        self.sloganInterval=[dic[@"sloganInterval"] integerValue];
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

-(void)showSloganAlertWith:(SCNNode *)node{
    
    NSMutableDictionary *dic=[[SohuARSingleton sharedInstance] arConfigurations][@"sloganInfoAlert"];
    if ([node.name length]>0) {
        NSMutableDictionary *dic1=dic[node.name];
        if (self.hadLoad==NO) {
            UIImage *image=[SohuFileManager readImageFromCachesWithRelativePath:dic1[@"sloganImagesPath"]];
            CGFloat h=[dic1[@"imageHeight"] floatValue];
            CGFloat w=[dic1[@"imageWidth"] floatValue];
            [SohuSloganView showToView1:self.superview
                            sloganImage:image
                                   size:CGSizeMake(w, h)
                      sloganinformation:dic1];
            self.hadLoad=YES;
        }
    }
}

-(void)setupTimer{
}


-(void)setSuperview:(UIView *)superview{
    _superview=superview;
    [self setupView];
}

-(void)timerAction{
    self.sloganNumber++;
    NSInteger index=self.sloganNumber % (self.sloganImages.count);
    self.sloganNumber++;
    NSDictionary *dicss=self.sloganImages[index];
    UIImage *image=[SohuFileManager readImageFromCachesWithRelativePath:dicss[@"sloganImagesPath"]];
    CGFloat h=[dicss[@"imageHeight"] floatValue];
    CGFloat w=[dicss[@"imageWidth"] floatValue];
    [SohuSloganView showToView:self.superview
                   sloganImage:image
                          size:CGSizeMake(w, h)
             sloganinformation:nil];
}

-(void)playTimer{
    [_timer fire];
}

-(void)pauseTimer{
    [_timer invalidate];
    _timer=nil;
}
-(void)resumeTimer{
    [_timer setFireDate:[NSDate date]];
}


-(void)setSloganInterval:(NSInteger)sloganInterval{
    _sloganInterval=sloganInterval;
}

-(void)setEnbleStar:(BOOL)enbleStar{
    
}

-(void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sloganDidClick:)
                                                 name:@"sohuSloganView"
                                               object:nil];

}

-(void)sloganDidClick:(NSNotification *)notification{
    NSDictionary *dic=notification.object;
    CGFloat start=[dic[@"animationStart"] floatValue];
    CGFloat end=[dic[@"animationEnd"] floatValue];
    NSInteger count=[dic[@"repeatCount"] integerValue];
    [self nodeAnimationNode:nil from:start to:end repeatCount:count];
}

-(void)button:(UIButton *)button{
    KWS(weakSelf);
    if ([_delegate respondsToSelector:@selector(sohuARGameBaseScene:didClick:)]) {
        self.hudLabel.text=@"已保存";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.4 animations:^{
                weakSelf.hudLabel.alpha=0;
            } completion:^(BOOL finished) {
                [weakSelf.hudLabel removeFromSuperview];
                weakSelf.hudLabel=nil;
            }];
        });
        
        [_delegate sohuARGameBaseScene:self didClick:1];
    }
}

#pragma mark - getter
-(UIButton *)photographButton{
    if (_photographButton==nil) {
        _photographButton=[UIButton buttonWithType:UIButtonTypeCustom];
        _photographButton.frame=CGRectMake(self.toolBar.frame.size.width/2-20, kscreenHeight-40-70,40 , 40);
        _photographButton.backgroundColor=[UIColor clearColor];
        NSString *startDic=[[SohuARSingleton sharedInstance] arConfigurations][@"photographImage"];
        UIImage *image=[SohuFileManager readImageFromCachesWithRelativePath:startDic];
        [self.photographButton setImage:image forState:UIControlStateNormal];
        [_photographButton addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photographButton;
}


-(UILabel *)hudLabel{
    if (_hudLabel==nil) {
        _hudLabel=[[UILabel alloc]initWithFrame:CGRectMake(self.superview.frame.size.width/2-50, self.superview.frame.size.height/2-20, 100, 40)];
        _hudLabel.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        _hudLabel.textColor=[UIColor whiteColor];
        _hudLabel.font=[UIFont systemFontOfSize:14.0f];
        _hudLabel.layer.cornerRadius=3;
        _hudLabel.layer.masksToBounds=YES;
        _hudLabel.textAlignment=NSTextAlignmentCenter;
        [self.superview addSubview:self.hudLabel];
    }
    return _hudLabel;
}

-(SCNNode *)cameraNode{
    if (_cameraNode==nil) {
        _cameraNode = [SCNNode node];
        _cameraNode.camera = [SCNCamera camera];
        _cameraNode.camera.zFar = 10000;
        _cameraNode.name=@"cameraNode";
        _cameraNode.position=SCNVector3Make(0, 0, 0);
        [self.rootNode addChildNode:_cameraNode];
    }
    return _cameraNode;
}

-(SohuNavigationBar *)navigationBar{
    if (_navigationBar==nil) {
        _navigationBar=[[SohuNavigationBar alloc]initWithFrame:CGRectMake(0,0, self.superview.frame.size.width,35)];
        _navigationBar.counter=0;
        _navigationBar.countdownCount=0;
        _navigationBar.barDelegate=self;
        _navigationBar.backgroundColor=[UIColor clearColor];
    }
    return _navigationBar;
}

-(SohuARAlertView *)alertView{
    if(_alertView==nil){
        _alertView=[[SohuARAlertView alloc]initWithFrame:self.superview.frame];
        _alertView.delegate=self;
        [self.superview addSubview:_alertView];
    }
    return _alertView;
}

-(SohuToolbar *)toolBar{
    if (_toolBar==nil) {
        _toolBar=[[SohuToolbar alloc] initWithFrame:CGRectMake(0, self.superview.frame.size.height - 50,self.superview.frame.size.width, 50)];
        NSDictionary *startDic=[[SohuARSingleton sharedInstance] arConfigurations][@"toolBarInfo"];
        UIImage *image=[SohuFileManager readImageFromCachesWithRelativePath:startDic[@"backImage"]];
        [self.toolBar.backButton setImage:image forState:UIControlStateNormal];
        [_toolBar.backButton addTarget:self action:@selector(toolBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _toolBar;
}

-(UIImageView *)arrowImageView{
    if (_arrowImageView==nil) {
        if ([[[SohuARSingleton sharedInstance] arConfigurations][@"arrowInfo"][@"enableArrow"] boolValue]) {
            _arrowImageView=[[UIImageView alloc]init];
            _arrowImageView.contentMode=UIViewContentModeScaleAspectFit;
            _arrowImageView.transform=CGAffineTransformMakeRotation(M_PI/2);
            _arrowImageView.hidden=YES;
            NSDictionary *startDic=[[SohuARSingleton sharedInstance] arConfigurations][@"arrowInfo"];
            UIImage *image=[SohuFileManager readImageFromCachesWithRelativePath:startDic[@"arrowImage"]];
            _arrowImageView.image=image;
            [self.superview addSubview:_arrowImageView];
        }
    }
    return _arrowImageView;
}

-(void)setClickNumber2:(NSInteger)clickNumber2{
    _clickNumber2=clickNumber2;
    _currentNumber=_clickNumber;
    self.navigationBar.counter=_clickNumber2;
    
    NSDictionary *dic=[[SohuARSingleton sharedInstance] arConfigurations][@"navigationInfo"];
    if (_clickNumber2==[dic[@"standardQuantity"] integerValue]) {
        [self.alertView removeFromSuperview];
        self.alertView=nil;
        NSDictionary *startDic=[[SohuARSingleton sharedInstance] arConfigurations][@"endAlert"];
        UIImage *image=[SohuFileManager readImageFromCachesWithRelativePath:startDic[@"successImagePath"]];
        self.alertView.alertImage=image;
        self.alertView.tag=2;
        self.alertView.frame=self.superview.frame;
    }
}

-(UILabel *)tipsLabel{
    if (_tipsLabel==nil) {
        _tipsLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, kscreenHeight-50-20, kscreenWidth, 20)];
        _tipsLabel.font=[UIFont systemFontOfSize:12.0f];
        _tipsLabel.textColor=[UIColor whiteColor];
        _tipsLabel.text=@"提示：按箭头方向转动手机，寻找物体";
        _tipsLabel.textAlignment=NSTextAlignmentCenter;
        _tipsLabel.backgroundColor=[UIColor clearColor];
    }
    return _tipsLabel;
}

-(SohuReadyView *)readyView{
    if (_readyView==nil) {
        _readyView=[[SohuReadyView alloc]initWithFrame:self.superview.frame];
        NSDictionary *dic=[[SohuARSingleton sharedInstance] arConfigurations][@"readyInfo"];
        UIImage *readyImage=[SohuFileManager readImageFromCachesWithRelativePath:dic[@"readyImage"]];
        UIImage *goImage=[SohuFileManager readImageFromCachesWithRelativePath:dic[@"goImage"]];
        _readyView.readyView.image=readyImage;
        _readyView.goView.image=goImage;
        _readyView.userInteractionEnabled=NO;
    }
    return _readyView;
}
@end
