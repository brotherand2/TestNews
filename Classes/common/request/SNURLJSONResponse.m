//
//  SNURLJSONResponse.m
//  sohunews
//
//  Created by kuanxi zhu on 8/18/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNURLJSONResponse.h"
#import "ASIDataDecompressor.h"

@implementation SNURLJSONResponse
@synthesize requestData;
@synthesize responceHeader = _responceHeader;

- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
               data:(id)data {
    self.requestData = data;
    
    //记录header
    self.responceHeader = [response allHeaderFields];
    
	NSString *encoding = [response.allHeaderFields objectForKey:@"Content-Encoding"];
    
	if (encoding && NSNotFound != [encoding rangeOfString:@"gzip"].location) {
		SNDebugLog(@"gzip mode");
		NSData *saveData = [ASIDataDecompressor uncompressData:data error:NULL];
		return [super request:request processResponse:response data:saveData];
	}
	else {
		return [super request:request processResponse:response data:data];
	}
}

-(void)dealloc {
     //(requestData);
     //(_responceHeader);
}

@end

