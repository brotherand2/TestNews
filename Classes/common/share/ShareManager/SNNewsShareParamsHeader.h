//
//  SNNewsShareParamsHeader.h
//  sohunews
//
//  Created by wang shun on 2017/1/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#ifndef SNNewsShareParamsHeader_h
#define SNNewsShareParamsHeader_h
/**************************************************************************/
/*
    分享流程
    
    从外部拿到分享数据 
 
    1.点击图标
    2.访问shareon.go
    3.分享至第三方平台(用shareon结果)
    4.upload同步至我的分享
 
 */
/**************************************************************************/

#define kShareIconImgWidth 45.0///2*[UIScreen mainScreen].scale
#define kShareIconImage  @"iconImage"
#define kShareIconTitle  @"title"


//必须参数
#define SNNewsShare_title        @"title"
#define SNNewsShare_content      @"content"
#define SNNewsShare_shareContent @"shareContent"

#define SNNewsShare_shareComment @"shareComment"//评论分享

#define SNNewsShare_Url          @"url"     //upload 同步我的分享  //单图分享不用传 url
#define SNNewsShare_webUrl       @"webUrl"
#define SNNewsShare_link         @"link"    //
////


#define SNNewsShare_MediaUrl     @"mediaUrl"//视频对应的url
#define SNNewsShare_ImageUrl     @"imageUrl" //


#define SNNewsShare_ShareOn_contentType   @"contentType" //shareOn接口
#define SNNewsShare_ShareOn_referString   @"referString" //shareOn接口 upload
#define SNNewsShare_V4Upload_sourceType   @"sourceType"  //upload接口

#define SNNewsShare_LOG_type     @"shareLogType"  //埋点

#define SNNewsShare_isQianfan    @"isQianfanShare"   //千帆
#define SNNewsShare_isVideo      @"isVideoShare"     //视频

//UI图标显示
//disableIons String 想要 不显示谁 就写谁 逗号分隔
//朋友圈,微信好友，狐友，微博，QQ空间，QQ，支付宝，支付宝生活圈,复制链接
//disableIcons = @"moments,weChat,sohu,sina,qqZone,qq,alipay,lifeCircle,copyLink";
#define SNNewsShare_disableIcons @"disableIcons" //隐藏图标
#define SNNewsShare_addIcons @"addIcons" //添加图标

#define SNNewsShare_ShareViewTitle @"shareviewtitle" //分享到 title

#define SNShare_Platform_Image_CompressionQuality 1 //图片压缩比

#define SNNewsShare_Icons_Timeline @"moments" //微信朋友圈
#define SNNewsShare_Icons_WeChat @"weChat" //微信好友
#define SNNewsShare_Icons_Sohu @"sohu" //狐友
#define SNNewsShare_Icons_Sina @"sina" //新浪微博
#define SNNewsShare_Icons_QQ @"qq" //QQ
#define SNNewsShare_Icons_QQZone @"qqZone" //QQ空间
#define SNNewsShare_Icons_Alipay @"alipay" //支付宝好友
#define SNNewsShare_Icons_LifeCircle @"lifeCircle" //生活圈
#define SNNewsShare_Icons_ScreenShot @"screenshot" //截屏分享
#define SNNewsShare_Icons_CopyLink @"copyLink" //复制链接
//
#endif /* SNNewsShareParamsHeader_h */
