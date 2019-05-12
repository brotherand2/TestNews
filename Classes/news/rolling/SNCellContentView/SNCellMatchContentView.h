//
//  SNCellMatchContentView.h
//  sohunews
//
//  Created by lhp on 5/8/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNImageView.h"


@interface SNCellMatchContentView : UIView
{
    SNImageView *hostTeamIcon;
    SNImageView *visitorTeamIcon;
    
    NSString *hostTeamName;
    NSString *visitorTeamName;
    NSString *hostTotal;
    NSString *visitorTotal;
    NSString *matchName;
    NSString *liveStatus;
}
@property(nonatomic,strong)NSString *hostTeamName;
@property(nonatomic,strong)NSString *visitorTeamName;
@property(nonatomic,strong)NSString *matchName;
@property(nonatomic,strong)NSString *liveStatus;
@property(nonatomic,strong)NSString *hostTotal;
@property(nonatomic,strong)NSString *visitorTotal;

- (void)updateWithHostTeamUrl:(NSString *) leftUrl visitorTeamUrl:(NSString *) rightUrl;
- (void)updateTheme;

@end
