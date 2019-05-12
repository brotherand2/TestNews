//
//  SNRedPacketFallView.m
//  sohunews
//
//  Created by wangyy on 16/3/8.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRedPacketFallView.h"

@interface SNRedPacketFallView ()

@property(nonatomic,strong)NSArray *imageNameArray;

@end

@implementation SNRedPacketFallView

@synthesize imageNameArray = _imageNameArray;
- (void)dealloc{
     //(_imageNameArray);
}

- (id)init
{
    self = [self initWithImageName:@"jinbi.png"];
    if (self) {
        [self initializeValue];
    }
    return self;
}

- (id)initWithImageName:(NSString *)imageName{
    return [self initWithImageNameArray:[NSArray arrayWithObject:imageName]];
}

- (id)initWithImageNameArray:(NSArray *)imageNameArray{
    self = [super init];
    if (self) {
        self.imageNameArray = imageNameArray;
    }
    return self;
}

-(void)initializeValue{
    // Configure the particle emitter to the top edge of the screen
    CAEmitterLayer *parentLayer = self;
    parentLayer.emitterPosition = CGPointMake(kAppScreenWidth / 2.0, -30);
    parentLayer.emitterSize		= CGSizeMake(kAppScreenWidth - 200.0, 0);
    
    // Spawn points for the flakes are within on the outline of the line
    parentLayer.emitterMode		= kCAEmitterLayerOutline;
    parentLayer.emitterShape	= kCAEmitterLayerLine;

//    parentLayer.shadowOpacity = 1.0;
//    parentLayer.shadowRadius  = 0.0;
//    parentLayer.shadowOffset  = CGSizeMake(0.0, 1.0);
//    parentLayer.shadowColor   = [[UIColor whiteColor] CGColor];
//    parentLayer.seed = (arc4random()%100)+1;
    
    CAEmitterCell* containerLayer = [self createSubLayerContainer];
    NSMutableArray *subLayerArray = [NSMutableArray array];
    NSArray *contentArray = [self getContentsByArray:self.imageNameArray];
    for (UIImage *image in contentArray) {
        [subLayerArray addObject:[self createSubLayer:image]];
    }
    
    if (containerLayer) {
        containerLayer.emitterCells = subLayerArray;
        parentLayer.emitterCells = [NSArray arrayWithObject:containerLayer];
    }else{
        parentLayer.emitterCells = subLayerArray;
    }
}

-(NSArray *)getContentsByArray:(NSArray *)imageNameArray{
    NSMutableArray *retArray = [NSMutableArray array];
    
    for (NSString *imageName in imageNameArray) {
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            [retArray addObject:image];
        }
    }
    return retArray;
}

-(CAEmitterCell*)createSubLayerContainer{
    CAEmitterCell* containerLayer = [CAEmitterCell emitterCell];
    containerLayer.birthRate			= 4.0;
    containerLayer.velocity			= 0;
    containerLayer.lifetime			= 0.35;
    containerLayer.name = @"emitter";
    return containerLayer;
}

-(CAEmitterCell *)createSubLayer:(UIImage *)image{
    CAEmitterCell *cellLayer = [CAEmitterCell emitterCell];
    
    cellLayer.birthRate		= 15;
    cellLayer.lifetime		= 20;
    
    cellLayer.velocity		= 150;
    cellLayer.velocityRange = 0.25 * M_PI;
    cellLayer.yAcceleration = 700;
//    cellLayer.xAcceleration = 20;
    cellLayer.emissionRange = 0.5 * M_PI;		// some variation in angle
    //    cellLayer.spinRange		= 0.25 * M_PI;		// slow spin
    cellLayer.scale = 0.5;
    cellLayer.contents		= (id)[image CGImage];
    
    cellLayer.color			= [[UIColor whiteColor] CGColor];
    
    return cellLayer;
}

-(void)stopRedPacketFall
{
    //turn on/off the emitting of particles
    [self setValue:@0 forKeyPath:@"emitterCells.emitter.birthRate"];
}

@end
