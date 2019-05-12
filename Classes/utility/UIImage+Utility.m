#import "UIImage+Utility.h"

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float radius, UIImageRoundedCorner cornerMask)
{
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
    if (cornerMask & UIImageRoundedCornerTopLeft) {
        CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius,
                        radius, M_PI, M_PI / 2, 1);
    }
    else {
        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
        CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y + rect.size.height);
    }

    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius,
                            rect.origin.y + rect.size.height);

    if (cornerMask & UIImageRoundedCornerTopRight) {
        CGContextAddArc(context, rect.origin.x + rect.size.width - radius,
                        rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    }
    else {
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - radius);
    }

    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);

    if (cornerMask & UIImageRoundedCornerBottomRight) {
        CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius,
                        radius, 0.0f, -M_PI / 2, 1);
    }
    else {
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius, rect.origin.y);
    }

    CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);

    if (cornerMask & UIImageRoundedCornerBottomLeft) {
        CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius,
                        -M_PI / 2, M_PI, 1);
    }
    else {
        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + radius);
    }

    CGContextClosePath(context);
}

@implementation UIImage (Utility)
-(UIImage*)imageAdujstOrientation:(int) maxDimension
{
	CGImageRef imgRef = self.CGImage;  
	
	CGFloat width = CGImageGetWidth(imgRef);  
	CGFloat height = CGImageGetHeight(imgRef);  
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);  
	
	if(maxDimension > 0) //need scale
	{
		if (width > maxDimension || height > maxDimension) 
		{  
			CGFloat ratio = width/height;  
			if (ratio > 1)
			{  
				bounds.size.width = maxDimension;  
				bounds.size.height = bounds.size.width / ratio;  
			}  
			else
			{  
				bounds.size.height = maxDimension;  
				bounds.size.width = bounds.size.height * ratio;  
			}  
		}
	}
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));  
    CGFloat boundHeight;  
	
	UIImageOrientation orient = self.imageOrientation;  
    switch(orient) 
	{  
        case UIImageOrientationUp: //EXIF = 1  
            transform = CGAffineTransformIdentity;  
            break;  
			
        case UIImageOrientationUpMirrored: //EXIF = 2  
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);  
            transform = CGAffineTransformScale(transform, -1.0, 1.0);  
            break;  
			
        case UIImageOrientationDown: //EXIF = 3  
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);  
            transform = CGAffineTransformRotate(transform, M_PI);  
            break;  
			
        case UIImageOrientationDownMirrored: //EXIF = 4  
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);  
            transform = CGAffineTransformScale(transform, 1.0, -1.0);  
            break;  
			
        case UIImageOrientationLeftMirrored: //EXIF = 5  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);  
            transform = CGAffineTransformScale(transform, -1.0, 1.0);  
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
            break;  
			
        case UIImageOrientationLeft: //EXIF = 6  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);  
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
            break;  
			
        case UIImageOrientationRightMirrored: //EXIF = 7  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeScale(-1.0, 1.0);  
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
            break;  
			
        case UIImageOrientationRight: //EXIF = 8  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);  
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
            break;  
			
        default:
            transform = CGAffineTransformIdentity;
            //[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
	
    UIGraphicsBeginImageContext(bounds.size);
	
    CGContextRef context = UIGraphicsGetCurrentContext();  
	
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
	{
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);  
    }
    else
	{  
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);  
    }  
	
    CGContextConcatCTM(context, transform);  
	
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);  
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();  
	
    return imageCopy;
	
}

-(UIImage*)addSubImage:(CGRect)rect subImage:(UIImage*)image
{
    int w = self.size.width;
    int h = self.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), self.CGImage);
    CGContextDrawImage(context, rect, image.CGImage);

    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage    *newImage = [UIImage imageWithCGImage:imageMasked];
    CGImageRelease(imageMasked);
    return newImage;
    
}

-(UIImage *)roundedRectWith:(float)radius
{
    //test
    return self;
    //test
    return [self roundedRectWith:radius cornerMask:UIImageRoundedCornerTopLeft|UIImageRoundedCornerTopRight|UIImageRoundedCornerBottomRight|UIImageRoundedCornerBottomLeft];
}
- (UIImage *)roundedRectWith:(float)radius cornerMask:(UIImageRoundedCorner)cornerMask
{
    int w = self.size.width;
    int h = self.size.height;
    CGRect imageFrame = CGRectMake(0, 0, w, h);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);

    CGContextBeginPath(context);
    //绘制弧线
    addRoundedRectToPath(context,imageFrame, radius, cornerMask);
    CGContextClosePath(context);
    
    //剪切
    CGContextClip(context);

    CGContextDrawImage(context, CGRectMake(0, 0, w, h), self.CGImage);

    //绘制边框    
    CGContextBeginPath(context);
    addRoundedRectToPath(context,imageFrame, radius, cornerMask);
    CGContextClosePath(context);
    CGContextSetLineWidth(context, 1.2);
    CGContextSetStrokeColorWithColor(context,[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15].CGColor);
    CGContextStrokePath(context);
    //
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    UIImage    *newImage = [UIImage imageWithCGImage:imageMasked];

    CGImageRelease(imageMasked);

    return newImage;
}
@end

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

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(UIImageAdditions)

@implementation UIImage (SNCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius {
    CGContextBeginPath(context);
    CGContextSaveGState(context);
    
    if (radius == 0) {
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextAddRect(context, rect);
        
    } else {
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextScaleCTM(context, radius, radius);
        float fw = CGRectGetWidth(rect) / radius;
        float fh = CGRectGetHeight(rect) / radius;
        
        CGContextMoveToPoint(context, fw, fh/2);
        CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
        CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
        CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
        CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    }
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Creates a new image by resizing the receiver to the desired size, and rotating it if receiver's
 * imageOrientation shows it to be necessary (and the rotate argument is YES).
 */
//- (UIImage*)transformWidth:(CGFloat)width height:(CGFloat)height rotate:(BOOL)rotate {
//  CGFloat destW = width;
//  CGFloat destH = height;
//  CGFloat sourceW = width;
//  CGFloat sourceH = height;
//  if (rotate) {
//    if (self.imageOrientation == UIImageOrientationRight
//        || self.imageOrientation == UIImageOrientationLeft) {
//      sourceW = height;
//      sourceH = width;
//    }
//  }
//
//  CGImageRef imageRef = self.CGImage;
//  int bytesPerRow = destW * (CGImageGetBitsPerPixel(imageRef) >> 3);
//  CGContextRef bitmap = CGBitmapContextCreate(NULL, destW, destH,
//    CGImageGetBitsPerComponent(imageRef), bytesPerRow, CGImageGetColorSpace(imageRef),
//    CGImageGetBitmapInfo(imageRef));
//
//  if (rotate) {
//    if (self.imageOrientation == UIImageOrientationDown) {
//      CGContextTranslateCTM(bitmap, sourceW, sourceH);
//      CGContextRotateCTM(bitmap, 180 * (M_PI/180));
//
//    } else if (self.imageOrientation == UIImageOrientationLeft) {
//      CGContextTranslateCTM(bitmap, sourceH, 0);
//      CGContextRotateCTM(bitmap, 90 * (M_PI/180));
//
//    } else if (self.imageOrientation == UIImageOrientationRight) {
//      CGContextTranslateCTM(bitmap, 0, sourceW);
//      CGContextRotateCTM(bitmap, -90 * (M_PI/180));
//    }
//  }
//
//  CGContextDrawImage(bitmap, CGRectMake(0,0,sourceW,sourceH), imageRef);
//
//  CGImageRef ref = CGBitmapContextCreateImage(bitmap);
//  UIImage* result = [UIImage imageWithCGImage:ref];
//  CGContextRelease(bitmap);
//  CGImageRelease(ref);
//
//  return result;
//}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)convertRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode {
    if (self.size.width != rect.size.width || self.size.height != rect.size.height) {
        if (contentMode == UIViewContentModeLeft) {
            return CGRectMake(rect.origin.x,
                              rect.origin.y + floor(rect.size.height/2 - self.size.height/2),
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeRight) {
            return CGRectMake(rect.origin.x + (rect.size.width - self.size.width),
                              rect.origin.y + floor(rect.size.height/2 - self.size.height/2),
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeTop) {
            return CGRectMake(rect.origin.x + floor(rect.size.width/2 - self.size.width/2),
                              rect.origin.y,
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeBottom) {
            return CGRectMake(rect.origin.x + floor(rect.size.width/2 - self.size.width/2),
                              rect.origin.y + floor(rect.size.height - self.size.height),
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeCenter) {
            return CGRectMake(rect.origin.x + floor(rect.size.width/2 - self.size.width/2),
                              rect.origin.y + floor(rect.size.height/2 - self.size.height/2),
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeBottomLeft) {
            return CGRectMake(rect.origin.x,
                              rect.origin.y + floor(rect.size.height - self.size.height),
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeBottomRight) {
            return CGRectMake(rect.origin.x + (rect.size.width - self.size.width),
                              rect.origin.y + (rect.size.height - self.size.height),
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeTopLeft) {
            return CGRectMake(rect.origin.x,
                              rect.origin.y,
                              
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeTopRight) {
            return CGRectMake(rect.origin.x + (rect.size.width - self.size.width),
                              rect.origin.y,
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeScaleAspectFill) {
            CGSize imageSize = self.size;
            if (imageSize.height < imageSize.width) {
                imageSize.width = floor((imageSize.width/imageSize.height) * rect.size.height);
                imageSize.height = rect.size.height;
                
            } else {
                imageSize.height = floor((imageSize.height/imageSize.width) * rect.size.width);
                imageSize.width = rect.size.width;
            }
            return CGRectMake(rect.origin.x + floor(rect.size.width/2 - imageSize.width/2),
                              rect.origin.y + floor(rect.size.height/2 - imageSize.height/2),
                              imageSize.width, imageSize.height);
            
        } else if (contentMode == UIViewContentModeScaleAspectFit) {
            CGSize imageSize = self.size;
            if (imageSize.height < imageSize.width) {
                imageSize.height = floor((imageSize.height/imageSize.width) * rect.size.width);
                imageSize.width = rect.size.width;
                
            } else {
                imageSize.width = floor((imageSize.width/imageSize.height) * rect.size.height);
                imageSize.height = rect.size.height;
            }
            return CGRectMake(rect.origin.x + floor(rect.size.width/2 - imageSize.width/2),
                              rect.origin.y + floor(rect.size.height/2 - imageSize.height/2),
                              imageSize.width, imageSize.height);
        }
    }
    return rect;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawInRect:(CGRect)rect contentMode:(UIViewContentMode)contentMode {
    BOOL clip = NO;
    CGRect originalRect = rect;
    if (self.size.width != rect.size.width || self.size.height != rect.size.height) {
        clip = contentMode != UIViewContentModeScaleAspectFill
        && contentMode != UIViewContentModeScaleAspectFit;
        rect = [self convertRect:rect withContentMode:contentMode];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (clip) {
        CGContextSaveGState(context);
        CGContextAddRect(context, originalRect);
        CGContextClip(context);
    }
    
    [self drawInRect:rect];
    
    if (clip) {
        CGContextRestoreGState(context);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawInRect:(CGRect)rect
       contentMode:(UIViewContentMode)contentMode
         blendMode:(CGBlendMode)blendMode
             alpha:(CGFloat)alpha {
    BOOL clip = NO;
    CGRect originalRect = rect;
    if (self.size.width != rect.size.width || self.size.height != rect.size.height) {
        clip = contentMode != UIViewContentModeScaleAspectFill
        && contentMode != UIViewContentModeScaleAspectFit;
        rect = [self convertRect:rect withContentMode:contentMode];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (clip) {
        CGContextSaveGState(context);
        CGContextAddRect(context, originalRect);
        CGContextClip(context);
    }
    
    [self drawInRect:rect blendMode:blendMode alpha:alpha];
    
    if (clip) {
        CGContextRestoreGState(context);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawInRect:(CGRect)rect radius:(CGFloat)radius {
    [self drawInRect:rect radius:radius contentMode:UIViewContentModeScaleToFill];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawInRect:(CGRect)rect radius:(CGFloat)radius contentMode:(UIViewContentMode)contentMode {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    if (radius) {
        [self addRoundedRectToPath:context rect:rect radius:radius];
        CGContextClip(context);
    }
    
    [self drawInRect:rect contentMode:contentMode];
    
    CGContextRestoreGState(context);
}

@end

/**
 * Copyright (c) 2009 Alex Fajkowski, Apparent Logic LLC
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
#import "UIImage+Utility.h"
#import "UIImage+MultiFormat.h"

@implementation UIImage (OpenFlowExtras)

- (UIImage *)rescaleImageToSize:(CGSize)size {
	CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
	UIGraphicsBeginImageContext(rect.size);
	[self drawInRect:rect];  // scales image to rect
	UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return resImage;
}

- (UIImage *)cropImageToRect:(CGRect)cropRect {
	// Begin the drawing (again)
	UIGraphicsBeginImageContext(cropRect.size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	// Tanslate and scale upside-down to compensate for Quartz's inverted coordinate system
	CGContextTranslateCTM(ctx, 0.0, cropRect.size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	
	// Draw view into context
	CGRect drawRect = CGRectMake(-cropRect.origin.x,
								 cropRect.origin.y - (self.size.height - cropRect.size.height) ,
								 self.size.width,
								 self.size.height);
	
	CGContextDrawImage(ctx, drawRect, self.CGImage);
	
	// Create the new UIImage from the context
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// End the drawing
	UIGraphicsEndImageContext();
	
	return newImage;
}

- (CGSize)calculateNewSizeForCroppingBox:(CGSize)croppingBox {
	// Make the shortest side be equivalent to the cropping box.
	CGFloat newHeight, newWidth;
	if (self.size.width < self.size.height) {
		newWidth = croppingBox.width;
		newHeight = (self.size.height / self.size.width) * croppingBox.width;
	} else {
		newHeight = croppingBox.height;
		newWidth = (self.size.width / self.size.height) *croppingBox.height;
	}
	
	return CGSizeMake(newWidth, newHeight);
}

- (UIImage *)cropCenterAndScaleImageToSize:(CGSize)cropSize {
	UIImage *scaledImage = [self rescaleImageToSize:[self calculateNewSizeForCroppingBox:cropSize]];
	
	return [scaledImage cropImageToRect:CGRectMake((scaledImage.size.width-cropSize.width)/2,
												   (scaledImage.size.height-cropSize.height)/2,
												   cropSize.width,
												   cropSize.height)];
}

@end

@implementation  UIImage (ScaleImage)

+ (UIImage *)imageWithBundleName:(NSString *)bundleName
{
    return [self themeImageNamed:bundleName];
}

//用时间命名用户图像并保存到沙盒
+ (void)saveImageByName:(UIImage*)image name:(NSString *)imageName
{
    if (!image || [imageName length] <= 0)
    {
        return;
    }
    NSString *imagePath = nil;
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    if ([paths count] > 0) {
        imagePath = [NSString stringWithFormat:@"%@", [[paths objectAtIndex:0] stringByAppendingPathComponent:kCommentImageFolderName]];
    }
    BOOL isDir;
    if (![fileManager fileExistsAtPath:imagePath isDirectory:&isDir])
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject: [NSNumber numberWithUnsignedLong: 0755] forKey: NSFilePosixPermissions];
        NSError *theError = NULL;
        
        if (![fileManager createDirectoryAtPath:imagePath withIntermediateDirectories: YES attributes: attributes error: &theError])
        {
            SNDebugLog(@"createDirectoryAtPath error %@", theError);
            return;
        }
    }
    
    imagePath = [imagePath stringByAppendingPathComponent:[NSString stringWithString:imageName]];
    BOOL result = [UIImageJPEGRepresentation(image, 0.8) writeToFile:imagePath atomically:YES];
    
    if (!result) {
        SNDebugLog(@"UIImagePNGRepresentation result %d", result);
    }
    
}

+ (void)removeImageWithContentFile:(NSString *)contentFile
{
}

+(UIImage *)rotateImage:(UIImage *)aImage
{
    if (!aImage) {
        return nil;
    }
    
    if (aImage.imageOrientation == UIImageOrientationUp) {
        return aImage;
    }
    
    CGImageRef imgRef = aImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat scaleRatio = 1;
    CGFloat boundHeight;
    UIImageOrientation orient = aImage.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(width, height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}
//+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
//{
//    UIGraphicsBeginImageContext(newSize);
//    
//
//    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//    
//  
//    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//   
//    UIGraphicsEndImageContext();
//    
//  
//    return newImage;
//}

@end

@implementation UIImage (TableCellClip)

-(BOOL)isHorizontalOverflow
{
    
    CGSize imageSize = self.size;
    
    CGFloat x   = imageSize.width * kMaxPhotoHeight;
    CGFloat y   = imageSize.height  * TTScreenBounds().size.width;
    
    return x > y;
}

- (CGRect)getFrameToFitScreenBySize:(CGSize)size
{
    CGFloat width, height;
    
    
    if (size.width / size.height > TTScreenBounds().size.width / TTScreenBounds().size.height) {
        width = TTScreenBounds().size.width;
        height = size.height/size.width * TTScreenBounds().size.width;
        
    } else {
        width = size.width/size.height * TTScreenBounds().size.height;
        height = TTScreenBounds().size.height;
    }
    
    
    CGFloat xd = width - TTScreenBounds().size.width;
    CGFloat yd = height - TTScreenBounds().size.height;
    
    return CGRectMake(-xd/2, -yd/2, width, height);
}

-(BOOL)isVerticalOverflow
{
    
    CGSize imageSize = self.size;
    
    CGFloat x   = imageSize.width * TTScreenBounds().size.height;
    CGFloat y   = imageSize.height  * TTScreenBounds().size.width;
    
    return y > x;
}


-(CGRect)getOverflowRectByFillingRect:(CGRect)rect byAnimation:(NSString *)animationName
{
    CGSize imageSize = self.size;
    if ([self isHorizontalOverflow]) {
        
        CGFloat width = imageSize.width/imageSize.height * kMaxPhotoHeight;
        CGRect overflowRect = CGRectMake((rect.size.width - width) / 2, 0, width, kMaxPhotoHeight);
        return overflowRect;
        
    } else {
        
        CGFloat height = imageSize.height/imageSize.width * TTScreenBounds().size.width;
        
        if (rect.size.width < TTScreenBounds().size.width) {
            if ([kFadeOutAnimation isEqualToString:animationName]) {
                CGFloat clipTop = kClipTopPercent*height;
                return CGRectMake(0, -clipTop, TTScreenBounds().size.width, height);
            } else {
                return CGRectMake(0, 0, TTScreenBounds().size.width, height);
            }
            
        } else {
            if ([kFadeOutAnimation isEqualToString:animationName]) {
                CGFloat clipTop = kClipTopPercent*rect.size.height;
                return CGRectMake(0, -clipTop, rect.size.width, rect.size.height);
            } else {
                return CGRectMake(0, 0, rect.size.width, rect.size.height);
            }
        }
        
    }
}

-(CGRect)getClipRectDependingOnSize:(CGSize)size
{
    CGSize imageSize = self.size;
    if (size.width == 0 || size.height == 0
        || imageSize.width == 0 || imageSize.height == 0) {
        return CGRectMake(0, 0, 0, 0);
    }
    
    CGFloat x   = imageSize.width * size.height;
    CGFloat y   = imageSize.height  * size.width;
    CGFloat scale   = 0;
    
    if (x > y) {//期望的图片高度大于图片实际高度
        scale   = size.height/imageSize.height;
        CGFloat clipWidth   = size.width/scale;
        CGFloat clipLeft    = (imageSize.width - clipWidth)/2;
        return CGRectMake(clipLeft, 0, clipWidth, imageSize.height);
    } else {
        scale   = size.width/imageSize.width;
        CGFloat clipHeight  = size.height/scale;
        //中间截取
        //CGFloat clipTop     = (imageSize.height - clipHeight)/2;
        //从上部截取
        //CGFloat clipTop = 0;
        //按指定比例（图片高度）截取
        CGFloat clipTop = kClipTopPercent*imageSize.height;
        return CGRectMake(0, clipTop, imageSize.width, clipHeight);
    }
}


-(UIImage*)cliptoSize:(CGSize)size;
{
    CGRect clipRect   = [self getClipRectDependingOnSize:size];
    if (clipRect.size.width == 0 || clipRect.size.height == 0) {
        return nil;
    }
    
    //首先裁剪
    CGImageRef uiImageRef = CGImageCreateWithImageInRect([self CGImage], clipRect);
	UIImage *clippedImage   = [UIImage imageWithCGImage:uiImageRef];
    CGImageRelease(uiImageRef);
    
    //然后缩放
	if (UIGraphicsBeginImageContextWithOptions != NULL) {
		UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
	} else {
		UIGraphicsBeginImageContext(size);
	}
	
	[clippedImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return scaledImage;
}
@end


#import "NSObject+MethodExchange.h"
@implementation TTURLCache (ScalceImage)

BOOL TTIsInternetURL(NSString* URL) {
    return ([URL hasPrefix:@"http://"] || [URL hasPrefix:@"https://"] || [URL hasPrefix:@"ftp://"]);
}

+ (void)load
{
    [self replaceMethod:@selector(imageForURL:fromDisk:) withNewMethod:@selector(inner_imageForURL:fromDisk:)];
}

- (id)inner_imageForURL:(NSString*)URL fromDisk:(BOOL)fromDisk
{
    //判断内存中有没有对应的图片
	UIImage* image = [_imageCache objectForKey:URL];
	
	if (nil == image && fromDisk) {
		if (TTIsBundleURL(URL)) {
			image = [self loadImageFromBundle:URL];
			[self storeImage:image forURL:URL];
			
		}
		else if (TTIsDocumentsURL(URL)) {
			image = [self loadImageFromDocuments:URL];
			[self storeImage:image forURL:URL];
		}
        else if (TTIsInternetURL(URL)) {
            NSString *_imagePath = [self cachePathForURL:URL];
            NSData* data = [NSData dataWithContentsOfFile:_imagePath];
            image = [UIImage sd_imageWithData:data];
            //            image = [UIImage imageWithContentsOfFile:_imagePath];
        }
	}
	
	return image;
}
-(BOOL)ifImageExist:(NSString*)URL fromDisk:(BOOL)fromDisk
{
    if (URL.length==0) {
        return NO;
    }
    //判断内存中有没有对应的图片
	UIImage* image = [_imageCache objectForKey:URL];
    if (image) {
        return YES;
    }
    if (image==nil&&fromDisk) {
        NSString *_imagePath = [self cachePathForURL:URL];
        NSFileManager* fm = [NSFileManager defaultManager];
        return [fm fileExistsAtPath:_imagePath];
    }
    else{
        return NO;
    }
}

//Added by handy
-(BOOL)ifImageExistInDisk:(NSString*)URL {
    if (URL.length==0) {
        return NO;
    }
    
    NSString *_imagePath = [self cachePathForURL:URL];
    NSFileManager* fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:_imagePath];
}

- (id)imageWithoutScaleForURL:(NSString*)URL fromDisk:(BOOL)fromDisk {
    //判断内存中有没有对应的图片
	UIImage* image = [_imageCache objectForKey:URL];
	SNDebugLog(@"INFO: URL [%@]", URL);
	if (nil == image && fromDisk) {
		if (TTIsBundleURL(URL)) {
			image = [self loadImageFromBundle:URL];
            SNDebugLog(@"INFO: image [%@], URL [%@]", image, URL);
			[self storeImage:image forURL:URL];
			
		}
		else if (TTIsDocumentsURL(URL)) {
			image = [self loadImageFromDocuments:URL];
			[self storeImage:image forURL:URL];
		}
        else if (TTIsInternetURL(URL)) {
            NSString *_imagePath = [self cachePathForURL:URL];
            image = [UIImage imageWithContentsOfFile:_imagePath];
        }
	}
	
	return image;
}

@end


@implementation UIImage (SNImage)
+ (void)beginImageContextWithSize:(CGSize)size
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(size, YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(size);
        }
    } else {
        UIGraphicsBeginImageContext(size);
    }
}

+ (void)endImageContext
{
    UIGraphicsEndImageContext();
}

+ (UIImage*)imageFromView:(UIView*) view height:(float) heightValue
{
    CGSize viewSize = [view bounds].size;
    UIGraphicsBeginImageContext(viewSize);
    BOOL hidden = [view isHidden];
    [view setHidden:NO];
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self endImageContext];
    [view setHidden:hidden];
    
    CGRect imageRect = CGRectMake(0, TTApplicationFrame().size.height - heightValue, viewSize.width, heightValue);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], imageRect);
    UIImage *backImage =[UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return backImage;
}

+ (UIImage*)imageFromView:(UIView*)view
{
    [self beginImageContextWithSize:[view bounds].size];
    BOOL hidden = [view isHidden];
    [view setHidden:NO];
    
    /**
     * renderInContext 相当耗时 iPhone 6plus上测试某些页面 调用时间 0.4s - 1.xs
     * http://www.wensj.net/blog/2014/05/11/ios-7mo-hu-ji-qiao/ http://damir.me/ios7-blurring-techniques
     */
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        // iOS 7 后新增
        [view drawViewHierarchyInRect:view.frame afterScreenUpdates:NO];
    } else {
        [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self endImageContext];
    [view setHidden:hidden];
    return image;
}

+ (NSString *)screenshotImagePathFromView:(UIView*)view
{
    NSString *lastScreenImagePath = nil;
    UIImage *image = [self imageFromView:view];
    if (image) {
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        NSString *path = @"";
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        path = [array objectAtIndex:0];
        if ([path length] > 0) {
            lastScreenImagePath = [path stringByAppendingPathComponent:@"tmpScreenShot.jpg"];
            [data writeToFile:lastScreenImagePath atomically:YES];
        }
    }
    return lastScreenImagePath;
}

+ (UIImage*)imageFromView:(UIView*)view scaledToSize:(CGSize)newSize
{
    UIImage *image = [self imageFromView:view];
    if ([view bounds].size.width != newSize.width ||
		[view bounds].size.height != newSize.height) {
        image = [self imageWithImage:image scaledToSize:newSize];
    }
    return image;
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    NSInteger newSizeW = (NSInteger)newSize.width;  //  转化为整型,不然像素补全会出现黑边
    NSInteger newSizeH = (NSInteger)newSize.height;
    [self beginImageContextWithSize:CGSizeMake(newSizeW, newSizeH)];
    [image drawInRect:CGRectMake(0,0,newSizeW,newSizeH)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    [self endImageContext];
    return newImage;
}

+ (UIImage *)imageFromView:(UIView *)view clipRect:(CGRect)edge {
    UIImage* image = [self imageFromView:view];
    
    CGImageRef imageRef = image.CGImage;
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, CGRectMake(0, edge.origin.y * scale, edge.size.width * scale, edge.size.height * scale));
    
    image = [UIImage imageWithCGImage:subImageRef];
    
    CGImageRelease(subImageRef);
    
    return image;
}

+ (NSString *)screenshotImagePathFromUIWebView:(UIWebView*)webView
{
    NSString *lastScreenImagePath = nil;
    webView.transform = CGAffineTransformMakeScale(1,1);
    UIImage *image = [self captureScrollView:webView.scrollView];
    if (image) {
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        NSString *path = @"";
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        path = [array objectAtIndex:0];
        if ([path length] > 0) {
            lastScreenImagePath = [path stringByAppendingPathComponent:@"tmpWebViewScreenShot.jpg"];
            [data writeToFile:lastScreenImagePath atomically:YES];
        }
    }
    return lastScreenImagePath;
}

+ (UIImage *)captureScrollView:(UIScrollView *)scrollView{
    UIImage* image = nil;
    UIGraphicsBeginImageContext(scrollView.contentSize);
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    
    if (image != nil) {
        return image;
    }
    return nil;
}

/**
 *  返回截取到的图片
 *
 *  @return UIImage *
 */
+ (UIImage *)imageWithScreenshot {
    
    NSData *imageData = [self dataWithScreenshotInPNGFormat];
    return [UIImage imageWithData:imageData];
}

/**
 截取当前屏幕
 */
+ (NSData *)dataWithScreenshotInPNGFormat
{
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }
        else
        {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(image);
}

+ (CGSize)getImageWithSize:(CGSize)originalSize resizeWithMaxSize:(CGSize)maxSize
{
    CGFloat maxWidth = maxSize.width;
    CGFloat maxHeight = maxSize.height;
    CGFloat imgWidth = originalSize.width;
    CGFloat imgHeight = originalSize.height;
    CGFloat rate = 0.0f;
    CGFloat newWidth = 0.0f;
    CGFloat newHeight = 0.0f;
    if (imgWidth > maxWidth || imgHeight > maxHeight) {
        if (imgWidth/imgHeight > maxWidth / maxHeight) {
            rate = maxWidth/imgWidth;
            newWidth = maxWidth;
            newHeight = imgHeight * rate;
        } else {
            rate = maxHeight/imgHeight;
            newHeight = maxHeight;
            newWidth = imgWidth * rate;
        }
    } else {
        newWidth = imgWidth;
        newHeight = imgHeight;
    }
    return CGSizeMake(newWidth, newHeight);
}



@end
