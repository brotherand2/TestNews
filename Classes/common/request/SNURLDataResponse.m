//
//  SNURLDataResponse.m
//  sohunews
//
//  Created by kuanxi zhu on 8/18/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNURLDataResponse.h"
#import "ASIDataDecompressor.h"

@implementation SNURLDataResponse
@synthesize data = _data;
@synthesize responceHeader = _responceHeader;

- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
			   data:(id)data {
	// This response is designed for NSData objects, so if we get anything else it's probably a
	// mistake.

//	NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//	NSString *zipPath = [docPath stringByAppendingPathComponent:@"test.gz"];
//	NSString *dataPath = [docPath stringByAppendingPathComponent:@"test"];
//	NSData *zipData = [NSData dataWithContentsOfFile:zipPath];
//	_data = [ASIDataDecompressor uncompressData:zipData error:NULL];
//	[data writeToFile:dataPath atomically:NO];
	
//	TTDASSERT([data isKindOfClass:[NSData class]] || [data isKindOfClass:[UIImage class]]);
//	TTDASSERT(nil == _data);
    
    //记录header
    self.responceHeader = [response allHeaderFields];
    
	//SNDebugLog(@"processResponse--%@", response.allHeaderFields);
	NSString *encoding = [response.allHeaderFields objectForKey:@"Content-Encoding"];
	if (encoding && NSNotFound != [encoding rangeOfString:@"gzip"].location) {
		//SNDebugLog(@"gzip mode--%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
		_data = [ASIDataDecompressor uncompressData:data error:NULL];
	}
	else {
		_data = data;
	}
	return nil;
}

- (void)dealloc {
	 //(_data);
     //(_responceHeader);
}

@end
