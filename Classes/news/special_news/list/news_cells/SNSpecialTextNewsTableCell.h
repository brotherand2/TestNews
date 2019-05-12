//
//  SNSpecialTextNewsTableCell.h
//  sohunews
//
//  Created by handy wang on 7/7/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNSpecialNewsTableCell.h"

@interface SNSpecialTextNewsTableCell : SNSpecialNewsTableCell {
    UIImageView *_arrowView;
    UIImageView *_videoView;
    UILabel     *_typeIcon;
}

-(void)setBgRed;
-(void)setBgBlue;
-(void)updateTheme;
@end