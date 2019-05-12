//
//  SohuNavigationBar.m
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import "SohuNavigationBar.h"
#import "SohuARSingleton.h"

@interface SohuNavigationBar ()


@property(nonatomic,strong) UILabel *timerLabel;
@property(nonatomic,strong) UILabel *gameCounterLabel;
@property(nonatomic,strong) UIImageView *gameCounterImageView;
@property(nonatomic,strong) UIView *backgroundView;

@end

@implementation SohuNavigationBar

-(instancetype)init{
    self=[super init];
    if (self) {
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backgroundView];
    }
    return self;
}

#pragma mark - publick method
-(void)stopTimer{
    [_gameTimer invalidate];
    _gameTimer=nil;
}

-(void)pauseTimer{
    [_gameTimer setFireDate:[NSDate distantFuture]];
    
}
-(void)resumeTimer{
     [_gameTimer setFireDate:[NSDate date]];
    [_gameTimer invalidate];
    _gameTimer=nil;

}

-(void)resettingTimer{

}

#pragma mark - some Action
-(void)gameTimerAction{
    _countdownCount=_countdownCount-1;
    if(_countdownCount==0){
        [_gameTimer invalidate];
        _gameTimer=nil;
    }
    if (_countdownCount>=0) {
        _timerLabel.text = [NSString stringWithFormat:@"00:%02ld", (long)_countdownCount];
        if ([_barDelegate respondsToSelector:@selector(sohuNavigationBar:countdownCount:)]) {
            [_barDelegate sohuNavigationBar:self countdownCount:_countdownCount];
        }
    }
}

-(void)startDownCount{
    self.timerLabel.text = @"00:00";
    [self.gameTimer fire];
}

-(void)setCounter:(NSInteger)counter{
    _counter=counter;
    self.gameCounterLabel.text=[NSString stringWithFormat:@"X%ld",(long)_counter];
}


#pragma mark - setter

-(void)setCounterImage:(UIImage *)counterImage{
    _counterImage=counterImage;
    self.gameCounterImageView.image=counterImage;
    [self addSubview:_gameCounterImageView];
}


-(void)setupCounterWithCounter:(NSInteger)counter{
    [self addSubview:self.gameCounterLabel];
     self.gameCounterLabel.text=[NSString stringWithFormat:@"X%ld",(long)_counter];
    _counter=counter;
}

-(void)setupCounterWithCountdownCount:(NSInteger)downCount{
    _countdownCount=downCount;
    [self addSubview:self.timerLabel];
    self.timerLabel.text = [NSString stringWithFormat:@"00:%02ld", (long)downCount];
}

#pragma mark - getter
-(UILabel *)timerLabel{
    if (_timerLabel==nil) {
        _timerLabel=[[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width-100-15, 5,100, 25)];
        _timerLabel.textAlignment=NSTextAlignmentRight;
        _timerLabel.textColor=[UIColor redColor];
    }
    return _timerLabel;
}

-(UILabel *)gameCounterLabel{
    if (_gameCounterLabel==nil) {
        _gameCounterLabel=[[UILabel alloc]initWithFrame:CGRectMake(45, 5, 100, 25)];
        _gameCounterLabel.textColor=[UIColor redColor];
        _gameCounterLabel.textAlignment=NSTextAlignmentLeft;
    }
    return _gameCounterLabel;
}

-(UIImageView *)gameCounterImageView{
    if (_gameCounterImageView==nil) {
        _gameCounterImageView=[[UIImageView alloc]init];
        _gameCounterImageView.backgroundColor=[UIColor clearColor];
        _gameCounterImageView.contentMode=UIViewContentModeScaleAspectFit;
        _gameCounterImageView.frame=CGRectMake(15, 5, 25, 25);
    }
    return _gameCounterImageView;
}

-(UIView *)backgroundView{
    if (_backgroundView==nil) {
        _backgroundView=[[UIView alloc]initWithFrame:self.frame];
        _backgroundView.backgroundColor=[UIColor blackColor];
        _backgroundView.alpha=0.4;
    }
    return _backgroundView;
}

-(NSTimer *)gameTimer{
    if(_gameTimer==nil){
        _gameTimer=[NSTimer scheduledTimerWithTimeInterval:1
                                                    target:self
                                                  selector:@selector(gameTimerAction)
                                                  userInfo:nil
                                                   repeats:YES];
    }
    return _gameTimer;
    
}
@end
