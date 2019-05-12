//
//  SNRollingNewsDownloadManagerFinishType.h
//  sohunews
//
//  Created by handy wang on 1/9/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//
typedef enum {
    SNRNDMFinishTypeUnknown = -1,           //未知结束下载方式
    SNRNDMFinishTypeNetworkUnreachable = 0, //网络不可用导致下载结束
    SNRNDMFinishTypeChannelsIsEmpty = 1,    //将要进行下载的频道数为0导致下载结束
    SNRNDMFinishTypeDownloadAll = 2,        //完全下载完所有频道而下载结束
    SNRNDMFinishTypeCancleDownload = 3      //下载过程中全部频道被取消下载而下载结束
} SNRollingNewsDownloadManagerFinishType;