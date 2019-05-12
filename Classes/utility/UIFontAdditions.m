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

#import "UIFontAdditions.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(UIFontAdditions)

@implementation UIFont (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)ttLineHeight {
  return (self.ascender - self.descender) + 1;
}

@end


@implementation UIFont (CoreTextExtensions)

- (CTFontRef)createCTFont;
{
    CTFontRef font = CTFontCreateWithName((CFStringRef)self.fontName, self.pointSize, NULL);
    return font;
}

+ (CTFontRef)bundledFontNamed:(NSString *)name size:(CGFloat)size
{
    // Adapted from http://stackoverflow.com/questions/2703085/how-can-you-load-a-font-ttf-from-a-file-using-core-text
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"ttf"];
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, false);
    CGDataProviderRef dataProvider = CGDataProviderCreateWithURL(url);
    CGFontRef theCGFont = CGFontCreateWithDataProvider(dataProvider);
    CTFontRef result = CTFontCreateWithGraphicsFont(theCGFont, size, NULL, NULL);
    CFRelease(theCGFont);
    CFRelease(dataProvider);
    CFRelease(url);
    return result;
}

@end

@implementation UIFont (SNFont)

+ (UIFont *)altSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:kFontFimalyName size:fontSize];
}

+ (UIFont *)altBoldSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:kFontFimalyName size:fontSize];
}

+ (UIFont *)digitAndLetterFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:kDigitAndLetterFontFimalyName size:fontSize];
}

+ (UIFont *)commentNumberFontSize:(CGFloat)fontSize {
    return [UIFont fontWithName:kCommentNumberFontFimalyName size:fontSize];
}

+ (UIFont *)copyrightFontSize:(CGFloat)fontSize {
    return [UIFont fontWithName:kCopyrightFontFimalyName size:fontSize];
}

@end
