//
//  COMPRequestError.h
//  Compass
//
//  Created by 李耀忠 on 21/10/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Recorditem.pb.h"

@interface COMPRequestError : NSObject

+ (COMPSocketErrorCode)socketErrorCodeFromURLSessionErrorCode:(NSInteger)errorCode;

@end
