//
//  SNCellContentView.h
//  sohunews
//
//  Created by sampan li on 13-1-9.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRollingNewsTableItem.h"

#define SELF_TYPEICON_WIDTH                                                     (36/2.0f)
#define SELF_TYPEICON_HEIGHT                                                    (22/2.0f)
#define SELF_RECOMICON_WIDTH                                                    (32/2.0f)
#define SELF_TYPEICON_RECOMMEND_WIDTH                                           (32/2.0f)
#define SELF_TYPEICON_TOP                                                       (166/2)
#define SELF_TYPEICON_RIGHT                                                     (86/2)
#define TYPEICON_TOP                                                            (24/2)

@interface SNCellContentView : UIView
{
    int _picCount;                  //图片数量
    int _titleHeight;               //标题高度
    int _abstractHeight;            //摘要高度
    
    float _titleWidth;              //标题宽度
    float _abstractWidth;           //摘要宽度
    float markText_x;
    float sponsorships_x;           //冠名x坐标
    
    BOOL _videoMark;                //是否为视频
    BOOL _voteMark;                 //是否为投票
    BOOL _isRecommend;              //是否为推荐
    BOOL _hasImage;                 //是否有图片
    BOOL _hasComments;              //是否有评论
    int  _titleLineCnt;             //标题行数
    BOOL _isAppCell;                //appCell评论数显示位置不同
    BOOL _isFromSub;                //是否为频道刊物
    BOOL _isMySubscribe;            //是否为我的订阅
    BOOL _isSearch;                 //是否为搜索
    BOOL _updatedSubscribe;         //我的订阅是否更新
    BOOL _isFlash;                  //是否是快讯
    BOOL _hasMoreButton;
    
    NSMutableAttributedString *_titleAttStr;
    NSMutableAttributedString *_abstractAttStr;
    SNRollingNewsItemType _newsType;
    SNRollingNewsCellType _cellType;
    
    NSString *_title;
    NSString *_abstract;
    NSString *_commentNum;
    NSString *_time;
    NSString *_newsId;
    NSString *_recommendIconUrl;
    NSString *_recomType;
    NSString *_liveStatus;
    NSString *_local;
    NSString *_playTime;
    NSString *_subscribeCount;
    NSString *_sponsorships;
    NSString *_newsTypeString;
    NSString *_tvPlayNum;
    NSString *_playVid;
    NSString *_sourceName;
}
@property(nonatomic,strong)UIColor *markTextColor;

@property(nonatomic,strong)NSMutableAttributedString *abstractAttStr;
@property(nonatomic,strong)NSMutableAttributedString *titleAttStr;

@property(nonatomic,assign)int picCount;
@property(nonatomic,assign)int titleHeight;
@property(nonatomic,assign)int abstractHeight;

@property(nonatomic,assign)SNRollingNewsItemType newsType;
@property(nonatomic,assign)SNRollingNewsCellType cellType;

@property(nonatomic,assign)float titleWidth;
@property(nonatomic,assign)float abstractWidth;

@property(nonatomic,copy)NSString *newsId;
@property(nonatomic,copy)NSString *recommendIconUrl;
@property(nonatomic,copy)NSString *media;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *abstract;
@property(nonatomic,copy)NSString *commentNum;
@property(nonatomic,copy)NSString *time;
@property(nonatomic,copy)NSString *recomType;
@property(nonatomic,copy)NSString *liveStatus;
@property(nonatomic,copy)NSString *local;
@property(nonatomic,copy)NSString *playTime;
@property(nonatomic,copy)NSString *subscribeCount;
@property(nonatomic,copy)NSString *sponsorships;
@property(nonatomic,copy)NSString *newsTypeString;
@property(nonatomic,copy)NSString *newsTypeTextString;
@property(nonatomic,copy)NSString *tvPlayNum;
@property(nonatomic,copy)NSString *playVid;
@property(nonatomic,copy)NSString *sourceName;
@property(nonatomic,copy)NSString *advertiser;
@property(nonatomic,copy)NSString *bookAuthor;
@property(nonatomic,copy)NSString *bookType;


@property(nonatomic,assign)BOOL videoMark;
@property(nonatomic,assign)BOOL voteMark;
@property(nonatomic,assign)BOOL isRecommend;
@property(nonatomic,assign)BOOL hasImage;
@property(nonatomic,assign)BOOL hasComments;
@property(nonatomic,assign)BOOL isSearch;
@property(nonatomic,assign)BOOL isAppCell;
@property(nonatomic,assign)BOOL isFromSub;
@property(nonatomic,assign)BOOL isMySubscribe;
@property(nonatomic,assign)BOOL updatedSubscribe;
@property(nonatomic,assign)BOOL isFlash;
@property(nonatomic,assign)int  titleLineCnt;
@property(nonatomic,assign)BOOL hasMoreButton;
@property(nonatomic,assign)BOOL hasDetailLink;

@property (nonatomic, assign) BOOL isFinance;

@property (nonatomic, copy) NSString *recomReasons;
@property (nonatomic, copy) NSString *recomTime;
@property (nonatomic, assign) CGFloat mediaPointY;


-(void)drawTitleAndAbstract;
-(void)drawTypeIconWithText:(NSString*)text textColor:(UIColor*)textColor rect:(CGRect)rect backgroundColor:(UIColor*)backColor;
-(NSString*)getVoiceOverText;
+ (BOOL)hasImageCellType:(SNRollingNewsCellType) cellType hasImage:(BOOL)hasImage;
@end
