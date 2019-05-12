//
//  ZipArchive.h
//  
//
//  Created by aish on 08-9-11.
//  acsolu@gmail.com
//  Copyright 2008  Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "minizip/zip.h"
#include "minizip/unzip.h"

@class ZipArchive;

@protocol ZipArchiveDelegate <NSObject>
@optional
-(void) ErrorMessage:(NSString*) msg;
-(BOOL) OverWriteOperation:(NSString*) file;
//解压完成一个文件
-(void) FileUnzipped:(NSString*)filePath fromZipArchive:(ZipArchive*)zip;

@end


@interface ZipArchive : NSObject {
@private
	zipFile		_zipFile;
	unzFile		_unzFile;
	
	id			_delegate;
	BOOL		_needUnzipProcessNotify;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, assign) BOOL needUnzipProcessNotify;

-(BOOL) CreateZipFile2:(NSString*) zipFile;
-(BOOL) addFileToZip:(NSString*) file newname:(NSString*) newname;
-(BOOL) CloseZipFile2;

-(BOOL) UnzipOpenFile:(NSString*) zipFile;
-(BOOL) UnzipFileTo:(NSString*) path overWrite:(BOOL) overwrite;
-(BOOL) UnzipCloseFile;
@end
