//
//  SNCheckIcon.m
//  sohunews
//
//  Created by jialei on 14-3-13.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNCommentEditorCheckIcon.h"
#import "SNCommentConfigs.h"

//static NSString *const shareAppStatusNotBind = @"1";
//static NSString *const shareAppStatusFailure = @"2";

@interface SNCommentEditorCheckIcon ()

@property (nonatomic, strong)UIImage    *checkEmptyImage;
@property (nonatomic, strong)UIImage    *checkSelectedImage;
@property (nonatomic, strong)UIImage    *sourceImage;

@end

@implementation SNCommentEditorCheckIcon

- (id)initWithItem:(ShareListItem *)item iconKey:(NSString *)key
{
    self = [super init];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.checkEmptyImage = [UIImage themeImageNamed:@"icopl_wxz_v5.png"];
        self.checkSelectedImage = [UIImage themeImageNamed:@"icopl_xz_v5.png"];
//        NSString *imageName = [NSString stringWithFormat:@"%@.png", key];
//        self.sourceImage = [UIImage themeImageNamed:imageName];
        
        self.frame = CGRectMake(0, 0,
                                self.checkEmptyImage.size.width + 12,
                                self.checkEmptyImage.size.height + 12);

        self.selected = ([SNUtility getSinaBindStatus] && [SNShareList isItemEnable:item]);
        self.key = key;
        self.item = item;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleTouched)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGPoint checkImagePoint = CGPointMake(8, 8);
//    CGPoint sourceImagePoint = CGPointMake(self.checkEmptyImage.size.width + 3, 0);
    
    
    if (self.selected) {
        [self.checkSelectedImage drawAtPoint:checkImagePoint];
//        [self.sourceImage drawAtPoint:sourceImagePoint blendMode:kCGBlendModeNormal alpha:1.0];
    }
    else {
        [self.checkEmptyImage drawAtPoint:checkImagePoint blendMode:kCGBlendModeNormal alpha:0.5];
        if ([SNUtility getSinaBindStatus]) {
//            [self.sourceImage drawAtPoint:sourceImagePoint blendMode:kCGBlendModeNormal alpha:1.0];
        } else {
//            [self.sourceImage drawAtPoint:sourceImagePoint blendMode:kCGBlendModeNormal alpha:0.5];
        }
    }
    
    [super drawRect:rect];
}

- (void)handleTouched
{
    if ([SNUtility getSinaBindStatus]) {
        self.item.status = shareAppStatusBinded;
    }
    
    if ([SNUtility getSinaBindStatus]) {
        self.selected = !self.selected;
        [self changedAppStated];
    }
    else {
        if (self.touchedLoginBlock) {
            self.touchedLoginBlock(self.key);
        }
//        [SNNotificationManager postNotificationName:SNCECheckIconDidPressed object:nil];
//        BOOL isLogin = [SNUserManager isLogin];
//        [[SNShareManager defaultManager] authrizeByAppId:self.item.appID
//                                               loginType:isLogin ? SNShareManagerAuthLoginTypeBind : SNShareManagerAuthLoginTypeLoginWithBind
//                                                delegate:self];
    }
}

- (void)changedAppStated
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SNShareList saveItemStatusToUserDefaults:self.item enable:self.selected];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
            if (self.touchedChooseBlock) {
                self.touchedChooseBlock(self.key, self.selected);
            }
        });
    });
}

- (void)loginFinished
{
    self.selected = YES;
    self.item = [[SNShareList shareInstance] itemByAppId:self.item.appID];
    self.item.status = @"0";
    [self changedAppStated];
}

- (void)dealloc
{
    // clear SNShareManager delegate
    [[SNShareManager defaultManager] setDelegate:nil];
}

@end
