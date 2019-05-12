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

#import "TTURLImageResponse.h"

// Network
#import "TTErrorCodes.h"
#import "TTURLRequest.h"
#import "TTURLCache.h"

// Core
 


@implementation UIImage (TTCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Creates a new image by resizing the receiver to the desired size, and rotating it if receiver's
 * imageOrientation shows it to be necessary (and the rotate argument is YES).
 */
- (UIImage*)transformWidth:(CGFloat)width height:(CGFloat)height rotate:(BOOL)rotate {
    CGFloat destW = width;
    CGFloat destH = height;
    CGFloat sourceW = width;
    CGFloat sourceH = height;
    if (rotate) {
        if (self.imageOrientation == UIImageOrientationRight
            || self.imageOrientation == UIImageOrientationLeft) {
            sourceW = height;
            sourceH = width;
        }
    }
    
    CGImageRef imageRef = self.CGImage;
    int bytesPerRow = destW * (CGImageGetBitsPerPixel(imageRef) >> 3);
    CGContextRef bitmap = CGBitmapContextCreate(NULL, destW, destH,
                                                CGImageGetBitsPerComponent(imageRef), bytesPerRow, CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    if (rotate) {
        if (self.imageOrientation == UIImageOrientationDown) {
            CGContextTranslateCTM(bitmap, sourceW, sourceH);
            CGContextRotateCTM(bitmap, 180 * (M_PI/180));
            
        } else if (self.imageOrientation == UIImageOrientationLeft) {
            CGContextTranslateCTM(bitmap, sourceH, 0);
            CGContextRotateCTM(bitmap, 90 * (M_PI/180));
            
        } else if (self.imageOrientation == UIImageOrientationRight) {
            CGContextTranslateCTM(bitmap, 0, sourceW);
            CGContextRotateCTM(bitmap, -90 * (M_PI/180));
        }
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0,0,sourceW,sourceH), imageRef);
    
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* result = [UIImage imageWithCGImage:ref];
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return result;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLImageResponse

@synthesize image = _image;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_image);

  [super dealloc];
}


//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TTURLResponse


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
            data:(id)data {
  // This response is designed for NSData and UIImage objects, so if we get anything else it's
  // probably a mistake.
  TTDASSERT([data isKindOfClass:[UIImage class]]
            || [data isKindOfClass:[NSData class]]);
  TTDASSERT(nil == _image);

  if ([data isKindOfClass:[UIImage class]]) {
    _image = [data retain];

  } else if ([data isKindOfClass:[NSData class]]) {
    // TODO(jverkoey Feb 10, 2010): This logic doesn't entirely make sense. Why don't we just store
    // the data in the cache if there was a cache miss, and then just retain the image data we
    // downloaded? This needs to be tested in production.
	UIImage* image = nil;
	if(!(request.cachePolicy | TTURLRequestCachePolicyNoCache)) {
      image = [[TTURLCache sharedCache] imageForURL:request.urlPath fromDisk:NO];
  }
    if (nil == image) {
        if ([self respondsToSelector:@selector(sd_imageWithData:)]) {
            image = [self performSelector:@selector(sd_imageWithData:) withObject:data];
        } else {
            image = [UIImage imageWithData:data];
        }
    if (image.imageOrientation!=UIImageOrientationUp) {
        image=[image transformWidth:image.size.height height:image.size.width rotate:NO];
    }
       
    }
    if (nil != image) {
      if (!request.respondedFromCache) {
// XXXjoe Working on option to scale down really large images to a smaller size to save memory
//        if (image.size.width * image.size.height > (300*300)) {
//          image = [image transformWidth:300 height:(image.size.height/image.size.width)*300.0
//                         rotate:NO];
//          NSData* data = UIImagePNGRepresentation(image);
//          [[TTURLCache sharedCache] storeData:data forURL:request.URL];
//        }
        [[TTURLCache sharedCache] storeImage:image forURL:request.urlPath];
      }

      _image = [image retain];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:response.statusCode] forKey:kTTErrorResponseStatusCode];
      return [NSError errorWithDomain:kTTNetworkErrorDomain
                                 code:kTTNetworkErrorCodeInvalidImage
                             userInfo:userInfo];
    }
  }
    
  return nil;
}

@end

