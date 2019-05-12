//
//  UIImage+Utility.h
//
//  Created by sohunews on 12-5-17.
//

#import <Foundation/Foundation.h>

typedef enum {
    UIImageRoundedCornerTopLeft = 1,
    UIImageRoundedCornerTopRight = 1 << 1,
    UIImageRoundedCornerBottomRight = 1 << 2,
    UIImageRoundedCornerBottomLeft = 1 << 3
} UIImageRoundedCorner;

@interface UIImage (Utility)

//+ (void)addRoundedRectToPath(CGContextRef context, CGRect rect, float radius, UIImageRoundedCorner cornerMask);
-(UIImage*)imageAdujstOrientation:(int) maxDimension;
-(UIImage*)addSubImage:(CGRect)rect subImage:(UIImage*)image;
-(UIImage *)roundedRectWith:(float)radius;
- (UIImage *)roundedRectWith:(float)radius cornerMask:(UIImageRoundedCorner)cornerMask;

+ (UIImage *)imageWithScreenshot;  // 获取当前屏幕的截图

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

@interface UIImage (SNCategory)

/*
 * Resizes an image. Optionally rotates the image based on imageOrientation.
 */
//- (UIImage*)transformWidth:(CGFloat)width height:(CGFloat)height rotate:(BOOL)rotate;

/**
 * Returns a CGRect positioned within rect given the contentMode.
 */
- (CGRect)convertRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode;

/**
 * Draws the image using content mode rules.
 */
- (void)drawInRect:(CGRect)rect contentMode:(UIViewContentMode)contentMode;

/**
 * Draws the image as a rounded rectangle.
 */
- (void)drawInRect:(CGRect)rect radius:(CGFloat)radius;

- (void)drawInRect:(CGRect)rect radius:(CGFloat)radius contentMode:(UIViewContentMode)contentMode;

/**
 * Draws the image using content mode rules ,blendMode and alpha.
 * add by ivan
 */
- (void)drawInRect:(CGRect)rect
       contentMode:(UIViewContentMode)contentMode
         blendMode:(CGBlendMode)blendMode
             alpha:(CGFloat)alpha;

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

/**
 * Convenience methods to help with resizing images retrieved from the
 * ObjectiveFlickr library.
 */
@interface UIImage (OpenFlowExtras)

- (UIImage *)rescaleImageToSize:(CGSize)size;
- (UIImage *)cropImageToRect:(CGRect)cropRect;
- (CGSize)calculateNewSizeForCroppingBox:(CGSize)croppingBox;
- (UIImage *)cropCenterAndScaleImageToSize:(CGSize)cropSize;

@end

@interface UIImage (ScaleImage)
+ (UIImage *)imageWithBundleName:(NSString *)bundleName;
+ (void)saveImageByName:(UIImage*)image name:(NSString *)imageName;
+ (UIImage *)rotateImage:(UIImage *)aImage;
+ (void)removeImageWithContentFile:(NSString *)contentFile;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
@end

@interface UIImage (TableCellClip)
//是否水平方向溢出
-(BOOL)isHorizontalOverflow;
-(BOOL)isVerticalOverflow;
//返回一个图片为了充满制定rect的溢出时的rect
-(CGRect)getOverflowRectByFillingRect:(CGRect)rect byAnimation:(NSString *)animationName;
//返回的Rect，是相对于image本身的，以图片左上角为原点
-(CGRect)getClipRectDependingOnSize:(CGSize)size;
//返回一个新创建的image,不对原image造成影响
-(UIImage*)cliptoSize:(CGSize)size;
@end

@interface TTURLCache (ScalceImage)
//- (id)imageForURL:(NSString*)URL fromDisk:(BOOL)fromDisk;
- (id)imageWithoutScaleForURL:(NSString*)URL fromDisk:(BOOL)fromDisk;
-(BOOL)ifImageExist:(NSString*)URL fromDisk:(BOOL)fromDisk;
//Added by handy
-(BOOL)ifImageExistInDisk:(NSString*)URL;
@end

@interface UIImage (SNImage)
+ (UIImage*)imageFromView:(UIView*)view;
+ (UIImage*)imageFromView:(UIView*)view height:(float) height;
+ (NSString *)screenshotImagePathFromView:(UIView*)view;
+ (UIImage*)imageFromView:(UIView*)view scaledToSize:(CGSize)newSize;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageFromView:(UIView *)view clipRect:(CGRect)edge;
+ (NSString *)screenshotImagePathFromUIWebView:(UIWebView*)webView;
+ (CGSize)getImageWithSize:(CGSize)originalSize resizeWithMaxSize:(CGSize)maxSize;  // 给定尺寸进行缩放
@end
