//
//  SohuLoadingView.m
//  SohuAR
//
//  Created by sun on 2016/11/30.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import "SohuLoadingView.h"

@interface SohuLoadingView ()

@end

@implementation SohuLoadingView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

-(void)setupView{
    [self addSubview:self.loadingLabel];
}

#pragma mark - getter
-(UILabel *)loadingLabel{
    if (_loadingLabel==nil) {
        _loadingLabel=[[UILabel alloc]init];
        _loadingLabel.text=@"正在加载资源";
        _loadingLabel.backgroundColor=[UIColor blackColor];
        _loadingLabel.alpha=0.6;
        _loadingLabel.textColor=[UIColor whiteColor];
        _loadingLabel.font=[UIFont systemFontOfSize:12.0];
        _loadingLabel.textAlignment=NSTextAlignmentCenter;
        _loadingLabel.frame=CGRectMake(0, 0, 100, 40);
        _loadingLabel.center=self.center;
        _loadingLabel.layer.masksToBounds=YES;
        _loadingLabel.layer.cornerRadius=3;
    }
    return _loadingLabel;
}

-(void)setDownloadProgress:(CGFloat)downloadProgress{
    self.loadingLabel.text=[NSString stringWithFormat:@"%0.0f%@",downloadProgress*100,@"%"];
}

@end
