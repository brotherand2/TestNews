//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
#define EXTJSON_SBJSON
#import "TTURLJSONResponse.h"

// extJSON
#import "TTErrorCodes.h"
#ifdef EXTJSON_SBJSON
#import "SBJson.h"
#import "NSString+SBJSON.h"
#elif defined(EXTJSON_YAJL)
#import "NSObject+YAJL.h"
#endif

// Core
#import "TTCorePreprocessorMacros.h"
 


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLJSONResponse

@synthesize rootObject  = _rootObject;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_rootObject);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTURLResponse


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
               data:(id)data {
  // This response is designed for NSData objects, so if we get anything else it's probably a
  // mistake.
  TTDASSERT([data isKindOfClass:[NSData class]]);
//  TTDASSERT(nil == _rootObject);
  NSError* err = nil;
  if ([data isKindOfClass:[NSData class]]) {
#ifdef EXTJSON_SBJSON
    NSString* json = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    // When there are newline characters in the JSON string, 
    // the error "Unescaped control character '0x9'" will be thrown. This removes those characters.
    json =  [json stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    TT_RELEASE_SAFELY(_rootObject);
    _rootObject = [[json JSONValue] retain];
    if (!_rootObject) {
      err = [NSError errorWithDomain:kTTExtJSONErrorDomain
                                code:kTTExtJSONErrorCodeInvalidJSON
                            userInfo:nil];
    }
#elif defined(EXTJSON_YAJL)
    @try {
        if (_rootObject != [data yajl_JSON]) {
            TT_RELEASE_SAFELY(_rootObject);
            _rootObject = [[data yajl_JSON] retain];
        }
    }
    @catch (NSException* exception) {
      err = [NSError errorWithDomain:kTTExtJSONErrorDomain
                                code:kTTExtJSONErrorCodeInvalidJSON
                            userInfo:[exception userInfo]];
    }
#endif
  }

  return err;
}


@end
