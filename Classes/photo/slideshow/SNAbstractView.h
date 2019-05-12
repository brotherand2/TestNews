//
//  SNAbstractView.h
//  sohunews
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNPhoto.h"

#define TITLE_SECTION_HEIGHT                (35)
#define ABSTRACT_VIEW_HEIGHT                (83)
#define ABSTRACT_VIEW_ORIGIN_Y              (TTApplicationFrame().size.height-TITLE_SECTION_HEIGHT-35)
#define ABSTRACT_VIEW_EXPAND_ORIGIN_Y       (ABSTRACT_VIEW_ORIGIN_Y - ABSTRACT_VIEW_HEIGHT + TITLE_SECTION_HEIGHT)
#define kAbstractStatusKey                  (@"kAbstractStatusKey")
#define ARROW_IMAGE_W                       (18)
#define ARROW_IMAGE_H                       (11)
#define INDEX_VIEW_WIDTH                    (40)
#define INDEX_VIEW_HEIGHT                   (14)
#define CONTENT_FONT_SIZE                   (13)
#define CONTENT_MARGIN                      (10)
#define TITLE_LABEL_HEIGHT                  (18)

@interface SNAbstractView : UIView {
    SNPhoto *photo;
    UILabel *titleLabel;
    UILabel *indexLabel;
    UIImageView *arrowImageView;
    UIScrollView *scrollView;
    UILabel *contentLabel;
    
    BOOL isMoving;
    
    CGPoint lastOrigin;
}
@property(nonatomic,retain)SNPhoto *photo;
@property(nonatomic,readonly)CGPoint lastOrigin;

-(void)animationAbstractView;

@end
