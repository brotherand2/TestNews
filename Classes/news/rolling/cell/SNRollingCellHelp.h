//
//  SNRollingCellHelper.h
//  sohunews
//
//  Created by lhp on 5/6/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingBaseCell.h"
#import "SNRollingNewsTitleCell.h"
#import "SNRollingNewsAbstractCell.h"
#import "SNRollingNewsTableCell.h"
#import "SNRollingWeatherCell.h"
#import "SNRollingNewsOnePicHeadlineCell.h"
#import "SNRollingNewsFocusCell.h"
#import "SNRollingWeatherPhotoCell.h"
#import "SNRollingPhotoNewsTableCell.h"
#import "SNRollingNewsPictureCell.h"
#import "SNRollingVideoCell.h"
#import "SNRollingMatchCell.h"
#import "SNRollingFinanceCell.h"
#import "SNRollingPublicCell.h"
#import "SNRollingNewsAdBannerCell.h"
#import "SNRollingMySubscribeCell.h"
#import "SNRollingNewsAppArrayCell.h"
#import "SNRollingIndividuationCell.h"
#import "SNRollingLoadMoreCell.h"
#import "SNRollingNewsTopicCell.h"
#import "SNRollingAdAppCell.h"
#import "SNRollingLocalFocusCell.h"
#import "SNRollingHouseFocusCell.h"

/******************************************新闻频道各种Cell模板介绍********************************************
 
 
一、各种Cell功能

1、只显示标题Cell
SNRollingNewsTitleCell

2、显示标题和摘要的Cell
SNRollingNewsAbstractCell

3、显示标题、摘要、图片的Cell
SNRollingNewsTableCell

4、显示天气的Cell
SNRollingWeatherCell

5、显示焦点图的Cell
SNRollingNewsFocusCell

6、焦点图显示天气、切换城市的Cell(天气版)
SNRollingWeatherPhotoCell

7、显示我的订阅Cell(5.0版本已停用)
SNRollingMySubscribeCell

8、显示组图的Cell
SNRollingPhotoNewsTableCell

9、显示大图模式新闻的Cell(5.0版本已停用)
SNRollingNewsPictureCell

10、显示app的Cell(5.0版本已停用)
SNRollingAppCell

11、显示视频的Cell
SNRollingVideoCell

12、显示刊物的Cell
SNSearchResultSubscribeCell

13、显示比赛的Cell
SNRollingMatchCell

14、财经股票的Cell
SNRollingFinanceCell
 
15、通用模板的Cell (例如:彩票入口)
 SNRollingPublicCell

16、4.3版本之前默认的Cell (已删除)
SNRollingNewsDefaultCell
 
17、广告banner的Cell
SNRollingNewsAdBannerCell
 
18、添加订阅Cell
SNRollingAddSubscribeCell
 
19、功能模版Cell （替换之前的SNRollingPublicCell）
SNRollingIndividuationCell
 
20、应用推广Cell （替代之前的SNRollingAppCell）
SNRollingNewsAppArrayCell
 
21、频道流加载更多Cell
SNRollingLoadMoreCell
 
22、批量应用下载换量Cell
SNRollingNewsAppArrayCell
 
 
23、视频广告 lijian 2014.12.29
SNRollingVideoAdCell
 
24、我的订阅Cell(5.2.2版本)
SNRollingNewsMySubscribeCell

 
**********切换本地频道用到的Cell*************
 
30、显示城市频道信息的Cell(非频道新闻Cell)
SNChannelListCell

31、显示用户本地频道信息的Cell(非频道新闻Cell)
SNLocalChannelCell
 
******************************************


二、部分Cell继承关系 （频道列表中的cell都继承自SNRollingBaseCell）

 
                                     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓
                                     ┃                          ┃
                                     ┃   SNRollingWeatherCell   ┃
                                     ┃                          ┃
                                     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
                                     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓
                                     ┃                          ┃
                                     ┃   SNRollingPublicCell    ┃
                                     ┃                          ┃
                                     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
                                     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓
                                     ┃                          ┃
                                     ┃   SNRollingFinanceCell   ┃
                                     ┃                          ┃
                                     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
                                     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓
                                     ┃                          ┃
                                     ┃  SNRollingNewsFocusCell  ┃
                                     ┃                          ┃
                                     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
                                     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓
                                     ┃                          ┃
                                     ┃SNRollingIndividuationCell┃
                                     ┃                          ┃
                                     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
    ┏━━━━━━━━━━━━━━━━━━━━┓           ┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓           ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓          ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                    ┃           ┃                          ┃           ┃                             ┃          ┃                           ┃
    ┃  SNRollingBaseCell ┃  ◀━━━━━   ┃  SNRollingNewsTitleCell  ┃  ◀━━━━━━  ┃ SNRollingNewsAbstractCell   ┃  ◀━━━━━  ┃  SNRollingNewsTableCell   ┃
    ┃                    ┃           ┃                          ┃           ┃                             ┃          ┃                           ┃
    ┗━━━━━━━━━━━━━━━━━━━━┛           ┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛           ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛          ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

                                     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓           ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓          ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
                                     ┃                          ┃           ┃                             ┃          ┃                           ┃
                                     ┃  SNRollingNewsTitleCell  ┃  ◀━━━━━━  ┃  SNRollingNewsPictureCell   ┃  ◀━━━━━  ┃     SNRollingAppCell      ┃
                                     ┃                          ┃           ┃                             ┃          ┃                           ┃
                                     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛           ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛          ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
                                     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓           ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓          ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
                                     ┃                          ┃           ┃                             ┃          ┃                           ┃
                                     ┃  SNRollingNewsTitleCell  ┃  ◀━━━━━━  ┃  SNRollingNewsPictureCell   ┃  ◀━━━━━  ┃    SNRollingVideoCell     ┃
                                     ┃                          ┃           ┃                             ┃          ┃                           ┃
                                     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛           ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛          ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
                                     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓           ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓          ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
                                     ┃                          ┃           ┃                             ┃          ┃                           ┃
                                     ┃  SNRollingNewsTitleCell  ┃  ◀━━━━━━  ┃  SNRollingNewsPictureCell   ┃  ◀━━━━━  ┃ SNRollingNewsAdBannerCell ┃
                                     ┃                          ┃           ┃                             ┃          ┃                           ┃
                                     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛           ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛          ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

                                     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓           ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
                                     ┃                          ┃           ┃                             ┃
                                     ┃  SNRollingNewsTitleCell  ┃  ◀━━━━━━  ┃ SNRollingPhotoNewsTableCell ┃
                                     ┃                          ┃           ┃                             ┃
                                     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛           ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

                                     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓           ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
                                     ┃                          ┃           ┃                             ┃
                                     ┃  SNRollingNewsTitleCell  ┃  ◀━━━━━━  ┃      SNRollingMatchCell     ┃
                                     ┃                          ┃           ┃                             ┃
                                     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛           ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

                                     ┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓           ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
                                     ┃                          ┃           ┃                             ┃
                                     ┃  SNRollingNewsTitleCell  ┃  ◀━━━━━━  ┃  SNRollingNewsAppArrayCell  ┃
                                     ┃                          ┃           ┃                             ┃
                                     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛           ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛          

 
 
 

三、cell模版对应的枚举值type  (templateType对应模版 http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=7471346 ）

                Cell                                        Type                                             TemplateType
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃  SNRollingNewsTitleCell    ┃  ◀━━━━━━━▶  ┃   SNRollingNewsCellTypeTitle     ┃    ◀━━━━━━━▶    ┃            1 | 12            ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃ SNRollingNewsAbstractCell  ┃  ◀━━━━━━━▶  ┃  SNRollingNewsCellTypeAbstrac    ┃    ◀━━━━━━━▶    ┃            1 | 12            ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃  SNRollingNewsTableCell    ┃  ◀━━━━━━━▶  ┃  SNRollingNewsCellTypeDefault    ┃    ◀━━━━━━━▶    ┃            1 | 12            ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃SNRollingPhotoNewsTableCell ┃  ◀━━━━━━━▶  ┃  SNRollingNewsCellTypePhotos     ┃    ◀━━━━━━━▶    ┃              2               ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃   SNRollingNewsFocusCell   ┃  ◀━━━━━━━▶  ┃   SNRollingNewsCellTypeFocus     ┃    ◀━━━━━━━▶    ┃              3               ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃   SNRollingWeatherCell     ┃  ◀━━━━━━━▶  ┃  SNRollingNewsCellTypeWeather    ┃    ◀━━━━━━━▶    ┃              4               ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃  SNRollingWeatherPhotoCell ┃  ◀━━━━━━━▶  ┃SNRollingNewsCellTypeFocusWeather ┃    ◀━━━━━━━▶    ┃              5               ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃     SNRollingVideoCell     ┃  ◀━━━━━━━▶  ┃   SNRollingNewsCellTypeVideo     ┃    ◀━━━━━━━▶    ┃              6               ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃      SNRollingMatchCell    ┃  ◀━━━━━━━▶  ┃   SNRollingNewsCellTypeMatch     ┃    ◀━━━━━━━▶    ┃              7               ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃    SNRollingPublicCell     ┃  ◀━━━━━━━▶  ┃  SNRollingNewsCellTypeCommon     ┃    ◀━━━━━━━▶    ┃              8               ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃  SNRollingNewsPictureCell  ┃  ◀━━━━━━━▶  ┃  SNRollingNewsCellTypePicture    ┃    ◀━━━━━━━▶    ┃            9 | 14            ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃    SNRollingFinanceCell    ┃  ◀━━━━━━━▶  ┃  SNRollingNewsCellTypeFinance    ┃    ◀━━━━━━━▶    ┃             10               ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃       SNRollingAppCell     ┃  ◀━━━━━━━▶  ┃     SNRollingNewsCellTypeApp     ┃    ◀━━━━━━━▶    ┃             11               ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃ SNRollingNewsAdBannerCell  ┃  ◀━━━━━━━▶  ┃  SNRollingNewsCellTypeAdBanner   ┃    ◀━━━━━━━▶    ┃             13               ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃SNSearchResultSubscribeCell ┃  ◀━━━━━━━▶  ┃ SNRollingNewsCellTypeSubscribe   ┃    ◀━━━━━━━▶    ┃             15               ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃  SNRollingMySubscribeCell  ┃  ◀━━━━━━━▶  ┃SNRollingNewsCellTypeMySubscribe  ┃    ◀━━━━━━━▶    ┃             16               ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃ SNRollingNewsAppArrayCell  ┃  ◀━━━━━━━▶  ┃   SNRollingNewsCellTypeAppArray  ┃    ◀━━━━━━━▶    ┃             17               ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃ SNRollingIndividuationCell ┃  ◀━━━━━━━▶  ┃SNRollingNewsCellTypeIndividuation┃    ◀━━━━━━━▶    ┃             19               ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┃   SNRollingLoadMoreCell    ┃  ◀━━━━━━━▶  ┃   SNRollingNewsCellTypeLoadMore  ┃    ◀━━━━━━━▶    ┃             20               ┃
    ┃                            ┃             ┃                                  ┃                 ┃                              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
 
    说明： 图文模版本地进行了进一步区分， 有图片时使用SNRollingNewsTableCell，无图片时使用 SNRollingNewsAbstractCell
          广告TemplateType为12为图文模板，14为大图模版
 
 
 
    专题展开模版说明： 其它模版都是一个SNNews对应一个NewsTableItem,专题展开News包含多个News信息，会根据当前展开数量生成对应的NewsTableItem，开始和结尾还包含
                    groupNewsHeadItem和groupNewsFootItem。
 
 
 
 
 *********************************************************************************************************/




