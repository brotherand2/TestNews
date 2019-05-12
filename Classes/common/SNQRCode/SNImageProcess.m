//
//  SNImageProcess.m
//  sohunews
//
//  Created by H on 16/5/18.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

static int WIDTH = 8;
static int HEIGHT = 8;

#import "SNImageProcess.h"

@implementation SNImageProcess

//平均灰度
+ (int)averageGray:(NSArray *)pix width:(int)w height:(int)h {
    int sum = 0;
    for(int i=0; i<h; i++) {
        for(int j=0; j<w; j++) {
            NSNumber * numValue = pix[i*w + j];
            if (numValue) {
                int value = numValue.intValue;
                sum = sum+value;
            }
         }
    }
    return (int)(sum/(w*h));
}

//采样
+ (NSArray *)shrink:(NSArray *)pix width:(int)w height:(int)h m:(int)m n:(int)n {
    float k1 = (float) m / w;
    float k2 = (float) n / h;
    int ii = (int)(1 / k1); // 采样的行间距
    int jj = (int)(1 / k2); // 采样的列间距
    int dd = ii * jj;
    // int m=0 , n=0;
    // int imgType = img.getType();
    //    int[] newpix = new int[m * n];
    NSMutableArray * newpix = [NSMutableArray array];
    
    for (int j = 0; j < n; j++) {
        for (int i = 0; i < m; i++) {
            int r = 0, g = 0, b = 0;
            for (int k = 0; k <  jj; k++) {
                for (int l = 0; l <  ii; l++) {
                    //Log.v(tag,"rrrr:" + ((pix[(jj * j + k) * w
                    //+  (ii * i + l)] & 0xff0000) >> 16));
                    int index = ((jj * j + k) * w +  (ii * i + l));
                    NSNumber * valueNum = nil;
                    if (index < pix.count) {
                        valueNum = [pix objectAtIndex:index];
                    }
                    if (valueNum) {
                        int value = valueNum.intValue;
                        r = r + ((value & 0xff0000) >> 16);
                        g = g + ((value & 0xff00) >> 8);
                        b = b + ((value & 0xff));
                        
                    }
                    //Log.v(tag,"r:" +  r + "g:" + g + "b:" + b + " ");
                }
            }
            r = r / dd;
            g = g / dd;
            b = b / dd;
            //            newpix[j * m + i] = 255 << 24 | r << 16 | g << 8 | b;
            int newValue = 255 << 24 | r << 16 | g << 8 | b;
            [newpix addObject:[NSNumber numberWithInt:newValue]];
            // Log.v(tag," " +  newpix[j * m + i]);
            // 255<<24 | r<<16 | g<<8 | b 这个公式解释一下，颜色的RGB在内存中是
            // 以二进制的形式保存的，从右到左1-8位表示blue，9-16表示green，17-24表示red
            // 所以"<<24" "<<16" "<<8"分别表示左移24,16,8位
            
            // newpix[j*m + i] = new Color(r,g,b).getRGB();
        }
    }
    //Log.v(tag);
    return newpix;
    
}

+ (NSArray *)grayImage:(NSArray *)pix width:(int)w height:(int)h
{
     NSMutableArray * newPix = [NSMutableArray arrayWithArray:pix];
    for(int i=0; i<h; i++) {
        for(int j=0; j<w; j++) {
            //0.3 * c.getRed() + 0.58 * c.getGreen() + 0.12 * c.getBlue()
            NSNumber * pixValue = pix[i*w + j];
            if (pixValue) {
                int value = pixValue.intValue;
                int newValue = (int) (0.3*((value & 0xff0000) >> 16) + 0.58*((value & 0xff00) >> 8) + 0.12*((value & 0xff)) );
                newPix[i*w + j] = [NSNumber numberWithInt:newValue];
            }
        }
    }
    return newPix;
}

/**
 *  求图片的指纹
 * @param pix 图像的像素矩阵
 * @param w 图像的宽
 * @param h 图像的高
 * @return
 */
+ (NSString *)getFingerprint:(NSArray *)pix width:(int)w height:(int)h
 {
//     pix = [self shrink:pix width:w height:h m:WIDTH n:HEIGHT];
     NSArray * newpix = [self grayImage:pix width:WIDTH height:HEIGHT];
     int avrPix = [self averageGray:newpix width:WIDTH height:HEIGHT];
     NSString * sb = [NSString string];

     for(int i=0; i<WIDTH * HEIGHT; i++) {
         NSNumber * numValue = newpix[i];
         if (numValue) {
             int value = numValue.intValue;
             if(value >= avrPix) {
                 if (sb) {
                     sb = [sb stringByAppendingString:@"1"];
                 }else{
                     sb = @"1";
                 }
              } else {
                  if (sb) {
                      sb = [sb stringByAppendingString:@"0"];
                  }else{
                      sb = @"0";
                  }
             }
         }
    }
//    long result = 0;
//     
//     NSString * firstStr = [sb substringWithRange:NSMakeRange(0, 1)];
//     
//    if([firstStr isEqualToString:@"0"]) {
////        result = Long.parseLong(sb.toString(), 2);
//        result = [sb longLongValue];
//    } else {
//        //如果第一个字符是1，则表示负数，不能直接转换成long，
//        NSString * subStr = [sb substringFromIndex:1];
//        result = 0x8000000000000000l ^ [sb longLongValue];
////        result = 0x8000000000000000l ^ Long.parseLong(sb.substring(1), 2);
//    }
    
    return sb;
}


+ (NSString *)getFingerprint:(UIImage *)image{

    CGImageRef cgimage = image.CGImage;
    
    size_t width  = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
    
    NSString * longStr = [self getFingerprint:[self imagePixel:image] width:width height:height];
    if(longStr.length < 64) {
        int n = 64 - longStr.length;
        for(int i=0; i<n; i++) {
//            sb.insert(0, "0");
            longStr = [@"0" stringByAppendingString:longStr];
        }
    }
    return longStr;
 }

+ (NSString *)getFingerprintImageBuffer:(CVImageBufferRef) imageBuffer{
    
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    NSString * longStr = [self getFingerprint:[self imageBufferPixel:imageBuffer] width:width height:height];
    if(longStr.length < 64) {
        int n = 64 - longStr.length;
        for(int i=0; i<n; i++) {
            //            sb.insert(0, "0");
            longStr = [@"0" stringByAppendingString:longStr];
        }
    }
    return longStr;
}

+ (NSArray *) imagePixel:(UIImage *)image
{
    NSMutableArray * ret = [NSMutableArray array];
    
    struct pixel {
        unsigned char r, g, b, a;
    };
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef imageRef = image.CGImage;
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    struct pixel *pixels = (struct pixel *) calloc(1, sizeof(struct pixel) * width * height);
    
    size_t bytesPerComponent = 8;
    size_t bytesPerRow = width * sizeof(struct pixel);
    
    CGContextRef context = CGBitmapContextCreate(pixels,
                                                 width,
                                                 height,
                                                 bytesPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
   

//    unsigned long numberOfPixels = width * height;
    
    if (context != NULL) {
//        for (unsigned i = 0; i < numberOfPixels; i++) {
//            SNDebugLog(@"%d",(255 << 24 |pixels[i].r << 16) | (pixels[i].g << 8) | pixels[i].b);
//            NSNumber * rgbNum = [NSNumber numberWithInt:(pixels[i].r << 16) | (pixels[i].g << 8) | pixels[i].b];
//            [ret addObject:rgbNum];
//        }
        /***********/
        int m = WIDTH;
        int n = HEIGHT;
        float k1 = (float) m / width;
        float k2 = (float) n / height;
        int ii = (int)(1 / k1); // 采样的行间距
        int jj = (int)(1 / k2); // 采样的列间距
        int dd = ii * jj;
        
        //    int[] newpix = new int[m * n];
        
        for (int j = 0; j < n; j++) {
            for (int i = 0; i < m; i++) {
                int r = 0, g = 0, b = 0;
                for (int k = 0; k <  jj; k++) {
                    for (int l = 0; l <  ii; l++) {
                        //Log.v(tag,"rrrr:" + ((pix[(jj * j + k) * w
                        //+  (ii * i + l)] & 0xff0000) >> 16));
                        r = r + ((pixels[(jj * j + k) * width +  (ii * i + l)].r));
                        g = g + ((pixels[(jj * j + k) * width +  (ii * i + l)].g ));
                        b = b + ((pixels[(jj * j + k) * width +  (ii * i + l)].b ));
                        //Log.v(tag,"r:" +  r + "g:" + g + "b:" + b + " ");
                    }
                }
                r = r / dd;
                g = g / dd;
                b = b / dd;
                ret[j * m + i] = [NSNumber numberWithInt:(255 << 24 | r << 16 | g << 8 | b)];
                // Log.v(tag," " +  newpix[j * m + i]);
                // 255<<24 | r<<16 | g<<8 | b 这个公式解释一下，颜色的RGB在内存中是
                // 以二进制的形式保存的，从右到左1-8位表示blue，9-16表示green，17-24表示red
                // 所以"<<24" "<<16" "<<8"分别表示左移24,16,8位
                
                // newpix[j*m + i] = new Color(r,g,b).getRGB();
            }
        }
        /*********/
        
        free(pixels);
        CGContextRelease(context);
    }
    
    CGColorSpaceRelease(colorSpace);
    return ret;
}

+ (NSArray *)imageBufferPixel:(CVImageBufferRef) imageBuffer{

    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSMutableArray * ret = [NSMutableArray array];
    
    struct pixel {
        unsigned char r, g, b, a;
    };
    
    
    struct pixel *pixels = (struct pixel *) calloc(1, sizeof(struct pixel) * width * height);
    
    size_t bytesPerComponent = 8;
    size_t bytesPerRow = width * sizeof(struct pixel);
    
    CGContextRef context = CGBitmapContextCreate(pixels,
                                                 width,
                                                 height,
                                                 bytesPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    

//    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
//    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
//                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), quartzImage);
    
    if (context != NULL) {
        /***********/
        int m = WIDTH;
        int n = HEIGHT;
        float k1 = (float) m / width;
        float k2 = (float) n / height;
        int ii = (int)(1 / k1); // 采样的行间距
        int jj = (int)(1 / k2); // 采样的列间距
        int dd = ii * jj;
        
        //    int[] newpix = new int[m * n];
        
        for (int j = 0; j < n; j++) {
            for (int i = 0; i < m; i++) {
                int r = 0, g = 0, b = 0;
                for (int k = 0; k <  jj; k++) {
                    for (int l = 0; l <  ii; l++) {
                        //Log.v(tag,"rrrr:" + ((pix[(jj * j + k) * w
                        //+  (ii * i + l)] & 0xff0000) >> 16));
                        r = r + ((pixels[(jj * j + k) * width +  (ii * i + l)].r) );
                        g = g + ((pixels[(jj * j + k) * width +  (ii * i + l)].g ));
                        b = b + ((pixels[(jj * j + k) * width +  (ii * i + l)].b ));
                        //Log.v(tag,"r:" +  r + "g:" + g + "b:" + b + " ");
                    }
                }
                r = r / dd;
                g = g / dd;
                b = b / dd;
                ret[j * m + i] = [NSNumber numberWithInt:(255 << 24 | r << 16 | g << 8 | b)];
                // Log.v(tag," " +  newpix[j * m + i]);
                // 255<<24 | r<<16 | g<<8 | b 这个公式解释一下，颜色的RGB在内存中是
                // 以二进制的形式保存的，从右到左1-8位表示blue，9-16表示green，17-24表示red
                // 所以"<<24" "<<16" "<<8"分别表示左移24,16,8位
                
                // newpix[j*m + i] = new Color(r,g,b).getRGB();
            }
        }
        /*********/
        
        free(pixels);
        CGContextRelease(context);
    }
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    
    // 释放Quartz image对象
    CGImageRelease(quartzImage);

    CGColorSpaceRelease(colorSpace);
    return ret;

}

+ (NSString *)getFingerPrint:(UIImage *)image {
    return [self getFingerprint:image];
}

+ (NSString *)getFingerPrintImageBuffer:(CVImageBufferRef) imageBuffer {
    return [self getFingerprintImageBuffer:imageBuffer];
}



+ (UIImage *) compressImage:(UIImage *)image withWidth:(size_t)scaleWidth
{
//    NSMutableArray * ret = [NSMutableArray array];
    UIImage *newImage = nil;
    
    struct pixel {
        unsigned char r, g, b, a;
    };
    struct newPixel {
        unsigned char r, g, b, a;
    };
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef imageRef = image.CGImage;
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    struct pixel *pixels = (struct pixel *) calloc(1, sizeof(struct pixel) * width * height);
    
    size_t scale = scaleWidth/width;
    size_t scaleHeight = height * scale;
    struct newPixel * newpixels = (struct newPixel *) calloc(1, sizeof(struct newPixel) * scaleWidth * scaleHeight);
    
    size_t bytesPerComponent = 8;
    size_t bytesPerRow = width * sizeof(struct pixel);
    
    CGContextRef context = CGBitmapContextCreate(pixels,
                                                 width,
                                                 height,
                                                 bytesPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    if (context != NULL) {
        int m = WIDTH;
        int n = HEIGHT;
        float k1 = (float) m / width;
        float k2 = (float) n / height;
        int ii = (int)(1 / k1); // 采样的行间距
        int jj = (int)(1 / k2); // 采样的列间距
        int dd = ii * jj;
        
        for (int j = 0; j < n; j++) {
            for (int i = 0; i < m; i++) {
                int r = 0, g = 0, b = 0;
                for (int k = 0; k <  jj; k++) {
                    for (int l = 0; l <  ii; l++) {
                        r = r + ((pixels[(jj * j + k) * width +  (ii * i + l)].r));
                        g = g + ((pixels[(jj * j + k) * width +  (ii * i + l)].g ));
                        b = b + ((pixels[(jj * j + k) * width +  (ii * i + l)].b ));
                        //Log.v(tag,"r:" +  r + "g:" + g + "b:" + b + " ");
                    }
                }
                r = r / dd;
                g = g / dd;
                b = b / dd;
//                ret[j * m + i] = [NSNumber numberWithInt:(255 << 24 | r << 16 | g << 8 | b)];
                
                newpixels[j * m + i].r = r;
                newpixels[j * m + i].g = g;
                newpixels[j * m + i].b = b;
                
                // Log.v(tag," " +  newpix[j * m + i]);
                // 255<<24 | r<<16 | g<<8 | b 这个公式解释一下，颜色的RGB在内存中是
                // 以二进制的形式保存的，从右到左1-8位表示blue，9-16表示green，17-24表示red
                // 所以"<<24" "<<16" "<<8"分别表示左移24,16,8位
                
                // newpix[j*m + i] = new Color(r,g,b).getRGB();
            }
        }
        /*********/
        
        size_t newbytesPerComponent = 8;
        size_t newbytesPerRow = scaleWidth * sizeof(struct newPixel);
        
        CGContextRef newContext = CGBitmapContextCreate(newpixels,
                                                     scaleWidth,
                                                     scaleHeight,
                                                     newbytesPerComponent,
                                                     newbytesPerRow,
                                                     colorSpace,
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//        newContext = contextcreate
        CGImageRef quartzImage = CGBitmapContextCreateImage(newContext);
        newImage = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationRight];
        CGContextRelease(newContext);
        CGImageRelease(quartzImage);
    }
    
    free(pixels);
    CGContextRelease(context);
    free(newpixels);
    CGColorSpaceRelease(colorSpace);
    return newImage;
}

#pragma mark - image tools
+ (UIImage*)getSubImage:(UIImage *)image mCGRect:(CGRect)mCGRect {
    CGRect rect = CGRectMake( mCGRect.origin.y * image.scale, - mCGRect.origin.x * image.scale , mCGRect.size.width * image.scale , mCGRect.size.height * image.scale );
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage * newImage = [UIImage imageWithCGImage:imageRef scale:1 orientation:UIImageOrientationRight];
    CGImageRelease(imageRef);
    
    return newImage;
}

//缩图
+ (UIImage *)compressImage:(UIImage *)sourceImage toTargetWidth:(CGFloat)targetWidth {
    CGSize imageSize = sourceImage.size;
    
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetHeight = (targetWidth / width) * height;
    
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
// 根据size截取图片中间矩形区域的图片 这里的size是正方形
+ (UIImage *)cutCenterImage:(UIImage *)image size:(CGSize)size{
    CGSize imageSize = image.size;
    CGRect rect;
    
    imageSize.width = imageSize.width * 0.67;
    imageSize.height = imageSize.height * 0.67;
    
    //根据图片的大小计算出图片中间矩形区域的位置与大小
    if (imageSize.width > imageSize.height) {
        float leftMargin = (imageSize.width - imageSize.height) * 0.5;
        rect = CGRectMake(leftMargin, 0, imageSize.height, imageSize.height);
    }else{
        float topMargin = (imageSize.height - imageSize.width) * 0.5;
        rect = CGRectMake(0, topMargin, imageSize.width, imageSize.width);
    }
    
    //x : 420.000000 ,y:0.000000,width:1080.000000,height:1080.000000
    //y + 左移  ； - 右移
    //x + 下移  ； - 上移
    rect = CGRectMake(rect.origin.x +220 , rect.origin.y+200, rect.size.width, rect.size.height);
    
    CGImageRef imageRef = image.CGImage;
    //截取中间区域矩形图片
    CGImageRef imageRefRect = CGImageCreateWithImageInRect(imageRef, rect);
    UIImage *tmp = [[UIImage alloc] initWithCGImage:imageRefRect];
    CGImageRelease(imageRefRect);

    UIGraphicsBeginImageContext(size);
    CGRect rectDraw = CGRectMake(0, 0, size.width, size.height);
    [tmp drawInRect:rectDraw];
    // 从当前context中创建一个改变大小后的图片
    tmp = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:tmp.CGImage scale:tmp.scale orientation:UIImageOrientationRight];
}

/**
 * 截取部分图像
 *
 **/
+ (UIImage*)getSubImage:(UIImage *)image mCGRect:(CGRect)mCGRect centerBool:(BOOL)centerBool
{
    
    /*如若centerBool为Yes则是由中心点取mCGRect范围的图片*/
    
    
    float imgwidth = image.size.width;
    float imgheight = image.size.height;
    float viewwidth = mCGRect.size.width;
    float viewheight = mCGRect.size.height;
    float y = 0;
    
    CGRect rect;
    if(centerBool)
        rect = CGRectMake((imgwidth-viewwidth)/2, (imgheight-viewheight)/2, viewwidth, viewheight);
    else{
        if (viewheight < viewwidth) {
            if (imgwidth <= imgheight) {
                rect = CGRectMake(0, 0, imgwidth, imgwidth*viewheight/viewwidth);
            }else {
                float width = viewwidth*imgheight/viewheight;
                float x = (imgwidth - width)/2 ;
                if (x > 0) {
                    rect = CGRectMake(x, y, width, imgheight);
                }else {
                    rect = CGRectMake(0, y, imgwidth, imgwidth*viewheight/viewwidth);
                }
            }
        }else {
            if (imgwidth <= imgheight) {
                float height = viewheight*imgwidth/viewwidth;
                if (height < imgheight) {
                    rect = CGRectMake(0, y, imgwidth, height);
                }else {
                    rect = CGRectMake(0, y, viewwidth*imgheight/viewheight, imgheight);
                }
            }else {
                float width = viewwidth*imgheight/viewheight;
                if (width < imgwidth) {
                    float x = (imgwidth - width)/2 ;
                    rect = CGRectMake(x, y, width, imgheight);
                }else {
                    rect = CGRectMake(0, y, imgwidth, imgheight);
                }
            }
        }
    }
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    //    clip
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    //    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    UIImage *smallImage = [UIImage imageWithCGImage:subImageRef scale:1.0f orientation:UIImageOrientationRight];
    
    return smallImage;
}

/**
 *  旋转图片
 */
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}

@end
