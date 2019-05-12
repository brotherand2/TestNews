//
//  SNNewsPPLoginSyncUserInfoRequest.h
//  sohunews
//
//  Created by wang shun on 2017/11/9.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"
//本接口 跟我们服务端同步信息
// 
@interface SNNewsPPLoginSyncUserInfoRequest : SNDefaultParamsRequest

@end



/*
 * @apiSampleRequest https://api.k.sohu.com/api/usercenter/passport/login.go
 * @apiParam {String} gid gid
 * @apiParam {String} passport passport
 * @apiParam {String} ppAppId 应用ID
 * @apiParam {String} ppAppVs 应用版本号
 * @apiParam {String} ppToken passport返回的token
 * @apiParam {String} p1 p1
 * @apiParam {String} u 产品id
 * @apiParam {String} loginType 登录类型 1.手机 2.第三方 3.账号登录
 * @apiParam {String} ua ua
 * @apiParam {String} openId 第三方应用openId loginType=2 时上传
 * @apiParam {String} appId 第三方应用标识1:sina;6:qq;8:wechat;9:meizu;10:taobao;11:huawei;12:xiaomi;13:aliyunos loginType=2 时上传
 * @apiParam {String} from 登录类型 loginType=2 时上传 login:登录 bind:绑定  loginWithBind:登录并绑定
 * @apiParam {String} mainPassport 绑定时主passport(当前登录的passport) loginType=2 ,from=bind 时上传
 * @apiParam {String} macAaddress 同步网安数据
 * @apiParam {String} innerIp 同步网安数据
 * @apiParam {String} longitude 同步网安数据
 * @apiParam {String} latitude 同步网安数据
 * @apiParam {String} stationId 同步网安数据
 * @apiParam {String} osType 同步网安数据
 * @apiSuccess {String} statusCode 状态码 -1:参数异常 10000000:成功 10000002:token校验失败 10000004:失败
 * @apiSuccess {String} statusMsg 状态码描述
 * @apiSuccess {String} pid pid
 * @apiSuccess {String} nick 昵称
 * @apiSuccess {String} avator 头像
 * @apiSuccessExample Success-Response:
 * {
 *      statusCode: "10000000",
 *      statusMsg: "success",
 *      data: {
 *          pid: "6163181245703827517",
 *          avator: "http://photo.pic.sohu.com/images/oldblog/person/11111.gif",
 *          nick: "狐狐网友"
 *      }
 * }
 */
