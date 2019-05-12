//
//  COMPRequestError.m
//  Compass
//
//  Created by 李耀忠 on 21/10/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import "COMPRequestError.h"

@implementation COMPRequestError

+ (COMPSocketErrorCode)socketErrorCodeFromURLSessionErrorCode:(NSInteger)errorCode {
    //用户取消
    if (errorCode == NSURLErrorCancelled ||
        errorCode == NSURLErrorUserCancelledAuthentication) {
        return COMPUserCancelErrorType;
    }

    //DNS错误
    if (errorCode == NSURLErrorCannotFindHost ||
        errorCode == NSURLErrorDNSLookupFailed) {
        return COMPDNSErrorType;
    }

    //连接错误
    if (errorCode == NSURLErrorTimedOut ||
        errorCode == NSURLErrorHTTPTooManyRedirects ||
        errorCode == NSURLErrorCannotConnectToHost ||
        errorCode == NSURLErrorNotConnectedToInternet ||
        errorCode == NSURLErrorRedirectToNonExistentLocation ||
        errorCode == NSURLErrorUserAuthenticationRequired ||
        errorCode == NSURLErrorInternationalRoamingOff ||
        errorCode == NSURLErrorCallIsActive ||
        errorCode == NSURLErrorDataNotAllowed ||
        errorCode == NSURLErrorRequestBodyStreamExhausted) {
        return COMPSocketConnectErrorType;
    }

    //读写流错误
    if (errorCode == NSURLErrorDataLengthExceedsMaximum ||
        errorCode == NSURLErrorNetworkConnectionLost ||
        errorCode == NSURLErrorResourceUnavailable ||
        errorCode == NSURLErrorBadServerResponse ||
        errorCode == NSURLErrorZeroByteResource ||
        errorCode == NSURLErrorCannotDecodeRawData ||
        errorCode == NSURLErrorCannotDecodeContentData ||
        errorCode == NSURLErrorCannotParseResponse ||
        errorCode == NSURLErrorFileDoesNotExist ||
        errorCode == NSURLErrorRequestBodyStreamExhausted ||
        errorCode == NSURLErrorFileIsDirectory ||
        errorCode == NSURLErrorNoPermissionsToReadFile ||
        errorCode == NSURLErrorCannotLoadFromNetwork ||
        errorCode == NSURLErrorCannotCreateFile ||
        errorCode == NSURLErrorCannotOpenFile ||
        errorCode == NSURLErrorCannotCloseFile ||
        errorCode == NSURLErrorCannotWriteToFile ||
        errorCode == NSURLErrorCannotRemoveFile ||
        errorCode == NSURLErrorCannotMoveFile ||
        errorCode == NSURLErrorDownloadDecodingFailedMidStream ||
        errorCode == NSURLErrorDownloadDecodingFailedToComplete) {
        return COMPRWStreamError;
    }

    //SSL错误
    if (errorCode == NSURLErrorSecureConnectionFailed ||
        errorCode == NSURLErrorServerCertificateHasBadDate ||
        errorCode == NSURLErrorServerCertificateUntrusted ||
        errorCode == NSURLErrorServerCertificateHasUnknownRoot ||
        errorCode == NSURLErrorServerCertificateNotYetValid ||
        errorCode == NSURLErrorClientCertificateRejected ||
        errorCode == NSURLErrorClientCertificateRequired ||
        errorCode == NSURLErrorAppTransportSecurityRequiresSecureConnection) {
        return COMPSocketSSLErrorType;
    }

    return COMPUndefinedSocketType;
}

@end
