//
//  SNMessageMgrConsts.h
//  sohunews
//
//  Created by chenhong on 13-12-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#ifndef sohunews_SNMessageMgrConsts_h
#define sohunews_SNMessageMgrConsts_h



// message string
#define kMagicV2        @"  V2"
#define kPI             @"PI\n"
#define kSUB            @"SUB topic news %@\n"
#define kOK             @"OK %@\n"

// last msg id
#define kMessageMgrLastMsgIdReceivedKey (@"kMessageMgrLastMsgIdReceivedKey")

#define kDevice						(@"iPhone")

// heart beat interval
#define kCheckInterval  (60*5)

#define kMaxMsgSize     (8192)

#define kDataSizeTag    1
#define kDataBodyTag    2
#define kMagicV2Tag     3
#define kSubTag         4
#define kPiTag          5
#define kMsgOKTag       6

// enum
typedef enum {
    FRAMETYPERESPONSE = 0,
    FRAMETYPEERROR = 1,
    FRAMETYPEMESSAGE = 2
}FrameType;


#endif
