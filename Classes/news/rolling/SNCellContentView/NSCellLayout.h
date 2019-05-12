//
//  NSCellViewHelper.h
//  sohunews
//
//  Created by sampan li on 13-1-17.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNRollingBaseCell.h"

#define CELL_HEIGHT                                             ([[SNDevice sharedInstance] isPlus]?(219/3):(154/2))           //标题模版高度
#define DEFAULT_CELL_HEITHT                                     154/2           //图文模版高度
#define PHOTO_CELL_HEIGHT                                       280/2           //组图模版高度
#define PICTURE_CELL_HEIGHT                                     250             //大图模版高度
#define APP_CELL_HEIGHT                                         257             //应用模版高度
#define WEATHER_CELL_HEIGHT                                     ([[SNDevice sharedInstance] isPlus]?(206/3):(124/2))            //天气模版高度
#define FINANCE_CELL_HEIGHT                                     190/2           //财经模版高度
#define PUBLIC_CELL_HEIGHT                                      130/2           //通用模版高度
#define FOCUS_CELL_HEIGHT                                       232/2           //焦点模版高度
#define AD_BANNER_CELL_HEIGHT                                   268/2           //广告模版高度（banner）
#define MY_SUBSCRIBE_CELL_HEIGHT                                174/2           //我的订阅模版高度
#define INDIVIDUATION_CELL_HEIGHT                               190/2           //个性化模版高度

#define WEATHER_LEFT                                            14
#define WEATHER_IMAGE_LEFT                                      ([[SNDevice sharedInstance] isPlus]?(57/3):([[SNDevice sharedInstance] isPhone6]?(28/2):0))
#define WEATHER_IMAGE_TOP                                       ([[SNDevice sharedInstance] isPlus]?(20/3): 0)
#define WEATHER_TOP                                             24/2
#define WEATHER_TEMPERATURE_WIDTH                               ([[SNDevice sharedInstance] isPlus]?(320/3): 160/2)
#define WEATHER_CELL_IMAGE_WIDTH                                ([[SNDevice sharedInstance] isPlus]?(150/3):(90/2))
#define CONTENT_LEFT                                            28/2
#define TITLE_LEFT                                              (CONTENT_LEFT + CELL_IMAGE_WIDTH + CELL_IMAGE_TITLE_DISTANCE)
//by 5.9.4 wangchuanwen modify
//#define  FEED_HEADIMAGE_HIGHT                                   40
//#define CELL_IMAGE_TITLE_DISTANCE                               (24/2)
//#define IMAGE_TOP                                               (22/2)
#define  FEED_HEADIMAGE_HIGHT                                   36
#define CELL_IMAGE_TITLE_DISTANCE                               (20/2)
#define IMAGE_TOP                                               (26/2)
#define PHOTOS_SPACEVALUE                                         8
//modify end
#define CONTENT_TOP                                             (20/2)
#define CONTENT_BOTTOM                                          (28/2)
#define ABSTRACT_TOP                                            (66/2)
#define COMMENT_BOTTOM                                          (26/2)
#define COMMENT_TOP                                             (24/2)
#define FEED_SPACEVALUE                                         7
#define CELLITEM_HEIGHT                                       (13)
#define TITLE_TO_MARK_Y                                         (12/2)  //标题到评论的距离
#define MARKTEXT_HEIGHT                                         (20/2)
#define PHOTOSCELLIMAGE_GAP                                         (2.5)
#define PHOTOSCELLIMAGE_WIDTH ((kAppScreenWidth - CONTENT_LEFT*2 - PHOTOSCELLIMAGE_GAP) / 3)

#define CELL_IMAGE_WIDTH PHOTOSCELLIMAGE_WIDTH//图文cell宽
#define CELL_IMAGE_HEIGHT (PHOTOSCELLIMAGE_WIDTH*2/3.0)//图文cell高

#define TOP_CELL_IMAGE_HEIGHT                                   ([[SNDevice sharedInstance] isPlus]? 150/3 : 100/2)
#define TOP_CELL_IMAGE_WIDTH                                    ([[SNDevice sharedInstance] isPlus]? 225/3 : 150/2)

#define CELL_IMAGE_HEIGHT_AD                                    ([[SNDevice sharedInstance] isPlus]? 238.f/3 : 136/2)
#define CELL_BOOK_IMAGE_WIDTH                                   ((NSInteger)([[SNDevice sharedInstance] isPlus]?(227.5/3):(130/2)))
#define CELL_BOOK_IMAGE_HEIGHT                                  ((NSInteger)([[SNDevice sharedInstance] isPlus]?(280.f/3):(160/2)))

#define PHOTOCELL_IMAGE_WIDTH                                   (194/2)
#define PHOTOCELL_IMAGE_HEIGHT                                  (126/2)
#define FOCUS_IMAGE_WIDTH                                       ([UIScreen mainScreen].bounds.size.width - (CONTENT_LEFT * 2))
#define FOCUS_IMAGE_HEIGHT                                      (316/2)
#define PICTURE_IMAGE_HEIGHT                                    185
#define CONTENT_IMAGE_TOP                                       ([[SNDevice sharedInstance] isPlus]?(117/3 -4):(70/2))
#define VIDEO_CONTENT_TOP                                       (30)
#define TYPEICON_TO_IMAGE_Y                                     ([[SNDevice sharedInstance] isPlus] ? 0 : -4) //类型图标与图片间距
#define FEED_CONTENT_IMAGE_TOP                                  IMAGE_TOP + FEED_HEADIMAGE_HIGHT + FEED_SPACEVALUE
#define FEED_TITLE_LINE_SPACE                                   2

#define ROLLINGNEWS_ABSTRACT_FONT                               (24/2)
#define NEWS_SECTION_HEIGHT                                     28

#define ABSTRACT_LINEHEIGHT                                     (34/2)
#define ABSTRACT_LINESPACE                                      (20/2)

#define ICON_WIDTH                                              11
#define ICON_HEIGHT                                             11
#define LABLETEXT_WIDTH                                         (200/2)
#define LABLETEXT_HEIGHT                                        10

#define VIDEO_ICON_WIDTH                                        (36/2)

#define HEIGHT_VALUE                                            [[SNDevice sharedInstance] isPlus]?(201/3):(126/2)

#define VIDEO_CELL_PLAYERHEIGHT                                 (CGFloat)((kAppScreenWidth - 14 * 2) * 370.0 / 656.0)
#define VIDEO_CELL_HEIGHT                                       (CGFloat)(VIDEO_CELL_PLAYERHEIGHT + CONTENT_IMAGE_TOP + kMoreButtonHeight)//246             //视频模版高度


typedef enum {
    CELL_READ_STYLE_NONE,
    CELL_READ_STYLE_READ,
    CELL_READ_STYLE_UNREAD
}CELL_READ_STYLE_TYPE;

@interface NSCellLayout : NSObject
{
    
}
+(float)titleTextWidthHasPic:(BOOL)ifHasPic ifHasTypeIcon:(BOOL)ifHasTypeIcon targetWidth:(float)width;
+(float)abstractTextWidthHasPic:(BOOL)ifHasPic targetWidth:(float)width;

+(float)defaultNewsCellHeight;
+(float)defaultExpressNewsHeight;
+(float)defaultGroupPhotoCellHeight;

+(float)getTitleHeight:(NSString*)title font:(UIFont*)font textWidth:(float)width  isMultiLine:(BOOL)isMultiLine;
+(float)getAbstractHeight:(NSAttributedString*)attributeStr  textWidth:(float)width;
+(float)heightWithTitle: (NSString*)title titleWidth:(float)titleWidth abstract:(NSString*)atstract abstractWidth:(float)abstractWidth ifMultiTitle:(BOOL)ifMutiTitle;
+(NSMutableAttributedString*)getAttributedString:(NSString*)abstractText;
@end
