//
//  SNUserPortrait.m
//  sohunews
//
//  Created by wang shun on 2017/1/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNUserPortrait.h"
#import "SNFaceInfoRequest.h"
#import "SNNewsMeUserPortraitCell.h"
#import "SNUserManager.h"
#import "SNUserPortraitWindow.h"

static UIView* temp = nil;

@implementation SNUserPortrait

-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)getUserPortraitLocalInfoData{
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userPortraitInfo.plist"];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:path];
        self.faceInfo = dic;
    }
}
- (void)saveUserPortraitLocalInfoData:(NSDictionary*)info{
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userPortraitInfo.plist"];
    [info writeToFile:path atomically:YES];
}

- (void)getUserPortraitFaceInfoCompletionBlock:(void(^)(void))method{
    //    api/face/faceInfo.go
    
    [[[SNFaceInfoRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSString* statusCode = [responseObject objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"30130000"]) {
                NSDictionary* data = [responseObject objectForKey:@"data"];
                if (data && [data isKindOfClass:[NSDictionary class]]) {
                    NSDictionary* face_Info =[data objectForKey:@"faceInfo"];
                    
                    if (self.faceInfo && [self.faceInfo isKindOfClass:[NSDictionary class]]) {
                        NSInteger n = [SNNewsMeUserPortraitCell getUserStatus:self.faceInfo];
                        if (n==0) {
                            NSInteger m = [SNNewsMeUserPortraitCell getUserStatus:face_Info];
                            if (m!=0) {//已解锁新的专属身份
                                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"已解锁新的专属身份" toUrl:nil mode:SNCenterToastModeError];
                            }
                        }
                    }
                    self.faceInfo = face_Info;
                    [self saveUserPortraitLocalInfoData:self.faceInfo];
                }
            }
            if (method) {
                method();
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }];
}

- (NSMutableArray*)addUserPortraitInitData:(NSMutableArray*)sectionArr{
    NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray* p_arr = [sectionArr objectAtIndex:0];
    
    //需求：去掉用户画像 wyy
//    NSArray* u_arr = [self getUserHeadInitData];
//    [arr addObjectsFromArray:u_arr];
    
    [arr addObjectsFromArray:p_arr];
    NSMutableArray* m_arr = [NSMutableArray arrayWithCapacity:0];
    [m_arr addObject:arr];
    
    self.isOpenFaceInfo = YES;
    [self getUserPortraitLocalInfoData];
    
    return m_arr;
}

+ (BOOL)isFirstOpen{//是否第一次开启
    BOOL b = NO;
   
    NSString* userPortrait_Open =  [[NSUserDefaults standardUserDefaults] objectForKey:@"SNUserPortrait_Open"];
    
    if (userPortrait_Open && [userPortrait_Open isEqualToString:@"1"]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"SNUserPortrait_Open"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        b = YES;
    }
    return b;
}

+ (UIView*)OpenWindow:(UIView*)view{
    //来这里解锁专属形象 开启属于您的个性化阅读之旅吧
    //发现您的专属形象 速来这里查看吧
    
    NSString* str = @"来这里解锁专属形象 开启属于您的个性化阅读之旅吧";
    if (![SNUserPortrait isFirstOpen]) {
        str = @"发现您的专属形象 速来这里查看吧~";
    }
    CGFloat w = 160;
    CGRect str_rect = [str boundingRectWithSize:CGSizeMake(w, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[SNUserPortrait windowFont]} context:nil];
    CGFloat h = 31;
    if (str_rect.size.height>21) {
        h = str_rect.size.height+10;
    }
    
    CGFloat x = view.bounds.size.width-w-5;
    CGFloat y = view.bounds.size.height-h-30-49;//30是距离tabBar高度 49是tabbar高度

    SNUserPortraitWindow * v = [[SNUserPortraitWindow alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [view addSubview:v];
    [v setContentText:str];
    temp = v;
    return v;
}

+ (void)closeUserWindow{
    if (temp) {
        [temp removeFromSuperview];
    }
}

+ (UIFont*)windowFont{
    return [UIFont systemFontOfSize:kThemeFontSizeC];
}

+ (void)getCurrentFaceInfoData{
    
}

- (NSArray*)getUserHeadInitData{
    NSDictionary* dic = @{@"title":@"UserPortrait",@"selector":@"meOpenUrl:",@"openUrl":@"userportrait://"};
    NSDictionary* nulldic = @{@"title":@"space",@"selector":@"meOpenUrl:"};
    NSArray* arr = @[dic,nulldic];
    return arr;
}

@end
