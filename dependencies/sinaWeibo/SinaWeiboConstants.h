//
//  SinaWeiboConstants.h
//  sinaweibo_ios_sdk
//
//  Created by Wade Cheng on 4/22/12.
//  Copyright (c) 2012 SINA. All rights reserved.
//

#ifndef sinaweibo_ios_sdk_SinaWeiboConstants_h
#define sinaweibo_ios_sdk_SinaWeiboConstants_h

#define SinaWeiboSdkVersion                @"2.0"

#define kSinaWeiboSDKErrorDomain           @"SinaWeiboSDKErrorDomain"
#define kSinaWeiboSDKErrorCodeKey          @"SinaWeiboSDKErrorCodeKey"

#define kSinaWeiboAppAuthURL_iPhone        @"sinaweibosso://login"
#define kSinaWeiboAppAuthURL_iPad          @"sinaweibohdsso://login"

typedef enum
{
	kSinaWeiboSDKErrorCodeParseError       = 200,
	kSinaWeiboSDKErrorCodeSSOParamsError   = 202,
} SinaWeiboSDKErrorCode;

#endif
