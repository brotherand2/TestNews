//
//  SNLabel.m
//  sohunews
//
//  Created by guoyalun on 6/27/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//


#define DEFAULT_FONT_SIZE 12

#import "SNLabel.h"
#import "RegexKitLite.h"
#import "SNLinkButton.h"
#import "NSMutableAttributedString+Size.h"
#import "SNEmoticonManager.h"
#import "UIImage+Utility.h"

#define LinkRegexExpress  (@"<\\s*a.+?href=(\'|\")(.+?)(\'|\").*?>((.|\\n)*?)<\\s*/\\s*a\\s*>|(http://|https://|www\\.|3g\\.)[\\./a-z0-9_-]*((\\?[a-z0-9]+=[a-z0-9\\u4E00-\\u9FFF]*)(&[a-z0-9]+=[a-z0-9\\u4E00-\\u9FFF]*)*)*(#[a-z0-9_-]*)?")

void RunDelegateDeallocCallback(void* refCon ){
    
}

CGFloat RunDelegateGetAscentCallback( void *refCon ){
    UIFont *font = (__bridge UIFont *)refCon;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    CGFloat ascent = CTFontGetAscent(fontRef);
    CFRelease(fontRef);
    return ascent;
}

CGFloat RunDelegateGetDescentCallback(void *refCon){
    UIFont *font = (__bridge UIFont *)refCon;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    CGFloat descent = CTFontGetDescent(fontRef);
    CFRelease(fontRef);
    return descent;
}

CGFloat RunDelegateGetWidthCallback(void *refCon){
    UIFont *font = (__bridge UIFont *)refCon;
    return font.pointSize*222/48+6;
}

CGFloat EmoticonRunDelegateGetWidthCallback(void *refCon){
    UIFont *font = (__bridge UIFont *)refCon;
    return font.pointSize + 8;
}

CGRect CTLineGetTypographicBoundsAsRect(CTLineRef line, CGPoint lineOrigin)
{
	CGFloat ascent = 0;
	CGFloat descent = 0;
	CGFloat leading = 0;
	CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
	CGFloat height = ascent + descent /* + leading */;
	
	return CGRectMake(lineOrigin.x,lineOrigin.y - descent,width,height);
}

CTTextAlignment CTTextAlignmentFromNSTextAlignment(NSTextAlignment alignment)
{
	switch (alignment) {
		case NSTextAlignmentLeft: return kCTLeftTextAlignment;
		case NSTextAlignmentCenter: return kCTCenterTextAlignment;
		case NSTextAlignmentRight: return kCTRightTextAlignment;
		case NSTextAlignmentJustified: return kCTJustifiedTextAlignment; /* special OOB value if we decide to use it even if it's not really standard... */
		default: return kCTNaturalTextAlignment;
	}
}
CTLineBreakMode CTLineBreakModeFromNSLineBreakMode(NSLineBreakMode lineBreakMode)
{
	switch (lineBreakMode) {
		case NSLineBreakByWordWrapping: return kCTLineBreakByWordWrapping;
		case NSLineBreakByCharWrapping: return kCTLineBreakByCharWrapping;
		case NSLineBreakByClipping: return kCTLineBreakByClipping;
		case NSLineBreakByTruncatingHead: return kCTLineBreakByTruncatingHead;
		case NSLineBreakByTruncatingTail: return kCTLineBreakByTruncatingTail;
		case NSLineBreakByTruncatingMiddle: return kCTLineBreakByTruncatingMiddle;
		default: return 0;
	}
}

// Don't use this method for origins. Origins always depend on the height of the rect.
CGPoint CGPointFlipped(CGPoint point, CGRect bounds) {
	return CGPointMake(point.x, CGRectGetMaxY(bounds)-point.y);
}

CGRect CGRectFlipped(CGRect rect, CGRect bounds) {
	return CGRectMake(CGRectGetMinX(rect),
					  CGRectGetMaxY(bounds)-CGRectGetMaxY(rect),
					  CGRectGetWidth(rect),
					  CGRectGetHeight(rect));
}

NSRange NSRangeFromCFRange(CFRange range) {
	return NSMakeRange(range.location, range.length);
}

@interface SNLabel()
{
    NSMutableArray  *_linkInfoArray;
    NSMutableArray  *_anchorInfoArray;
    NSMutableArray  *_highLightInfoArray;
    NSMutableArray  *_fontInfoArray;
//    NSMutableDictionary  *_emoticonInfoDic;
    
    CTFrameRef frameRef;
    BOOL         inSelected;
    NSRange      touchedRange;
    NSDictionary *_touchedDic;


}
-(void)parseHrefTagWithArray:(NSArray*)textArray text:(NSMutableString *)mutableText;
@end


@implementation SNLabel
@synthesize text = _text;
@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize linkColor = _linkColor;
@synthesize highlightedColor = _highlightedColor;
@synthesize lineHeight = _lineHeight;
@synthesize textHeight = _textHeight;
@synthesize textAlignment = _textAlignment;
@synthesize breakMode    = _breakMode;
@synthesize delegate = _delegate;
@synthesize tapEnable;
@synthesize disableLinkDetect;

+ (CGSize)sizeForContent:(NSString *)content maxSize:(CGSize)maxSize font:(CGFloat)size
{
    return [self sizeForContent:content maxSize:maxSize font:size lineHeight:[UIFont systemFontOfSize:size].lineHeight];
}

+ (CGSize)sizeForContent:(NSString *)content maxSize:(CGSize)maxSize font:(CGFloat)size lineHeight:(CGFloat)lineHeight
{
    CGFloat height = [self heightForContent:content maxSize:maxSize font:size lineHeight:lineHeight textAlignment:NSTextAlignmentLeft lineBreakMode:NSLineBreakByCharWrapping maxLineCount:0 ignoreLinks:NO];
    return CGSizeMake(maxSize.width, height);
}



+ (CGFloat)heightForContent:(NSString *)content maxSize:(CGSize)maxSize font:(CGFloat)size
{
    return [self heightForContent:content maxSize:maxSize font:size lineHeight:[UIFont systemFontOfSize:size].lineHeight textAlignment:NSTextAlignmentLeft lineBreakMode:NSLineBreakByCharWrapping maxLineCount:0 ignoreLinks:NO];
}

+ (CGFloat)heightForContent:(NSString *)content maxWidth:(CGFloat)width font:(CGFloat)size
{
    return [self heightForContent:content maxWidth:width font:size lineHeight:[UIFont systemFontOfSize:size].lineHeight];
}

+ (CGFloat)heightForContent:(NSString *)content maxWidth:(CGFloat)width font:(CGFloat)size lineHeight:(CGFloat)lineHeight
{
    return [self heightForContent:content maxSize:CGSizeMake(width, CGFLOAT_MAX_CORE_TEXT) font:size lineHeight:lineHeight textAlignment:NSTextAlignmentLeft lineBreakMode:NSLineBreakByCharWrapping maxLineCount:0 ignoreLinks:NO];
}

+ (CGFloat)heightForContent:(NSString *)content maxWidth:(CGFloat)width font:(CGFloat)size lineHeight:(CGFloat)lineHeight ignoreLinks:(BOOL)ignoreLinks {
    return [self heightForContent:content maxSize:CGSizeMake(width, CGFLOAT_MAX_CORE_TEXT) font:size lineHeight:lineHeight textAlignment:NSTextAlignmentLeft lineBreakMode:NSLineBreakByCharWrapping maxLineCount:0 ignoreLinks:ignoreLinks];
}

+ (CGFloat)heightForContent:(NSString *)content maxWidth:(CGFloat)width font:(CGFloat)size lineHeight:(CGFloat)lineHeight maxLineCount:(NSInteger)count
{
    return [self heightForContent:content maxSize:CGSizeMake(width, CGFLOAT_MAX_CORE_TEXT) font:size lineHeight:lineHeight textAlignment:NSTextAlignmentLeft lineBreakMode:NSLineBreakByCharWrapping maxLineCount:count ignoreLinks:NO];
}

+ (CGFloat)heightForContent:(NSString *)content maxSize:(CGSize)maxSize font:(CGFloat)size lineHeight:(CGFloat)lineHeight textAlignment:(NSTextAlignment)textAlignment lineBreakMode:(NSLineBreakMode)mode
{
    return [self heightForContent:content maxSize:maxSize font:size lineHeight:lineHeight textAlignment:textAlignment lineBreakMode:mode maxLineCount:0 ignoreLinks:NO];
}

+ (CGFloat)heightForContent:(NSString *)content maxSize:(CGSize)maxSize font:(CGFloat)size lineHeight:(CGFloat)lineHeight textAlignment:(NSTextAlignment)textAlignment lineBreakMode:(NSLineBreakMode)mode ignoreLinks:(BOOL)ignoreLinks {
    return [self heightForContent:content maxSize:maxSize font:size lineHeight:lineHeight textAlignment:textAlignment lineBreakMode:mode maxLineCount:0 ignoreLinks:ignoreLinks];
}

+ (CGFloat)heightForContent:(NSString *)content maxSize:(CGSize)maxSize font:(CGFloat)size lineHeight:(CGFloat)lineHeight textAlignment:(NSTextAlignment)textAlignment lineBreakMode:(NSLineBreakMode)mode maxLineCount:(NSInteger)count ignoreLinks:(BOOL)ignoreLinks
{
    if (content.length == 0) {
        return 0.0;
    }
    
    //检测是否只有一个大表情图，如果是返回图片高度
    NSArray *imageNames = [content itemsWithPattern:commentEmoticonPattern captureGroupIndex:1];
    if (imageNames.count > 0) {
        BOOL isHasEmoticon = NO;
        NSString *emotionContent = [content replaceSubStringWithSpace:commentEmoticonPattern];
        for (NSString *emoticonDes in imageNames) {
            SNEmoticonObject *emoticon = [[SNEmoticonManager sharedManager] emoticonForDes:emoticonDes];
            if (emoticon.type == SNEmoticonDynamic && ([emotionContent trim].length == 0)) {
                UIImage *image = [emoticon emoticonImage];
                return image.size.height;
            }
            if (emoticon) {
                isHasEmoticon = YES;
            }
        }
        
        if (isHasEmoticon) {
            content = [content replaceSubStringWithSpace:commentEmoticonPattern];
        }
    }
    
    NSMutableArray *rangeArray = [NSMutableArray array];
    
    NSMutableString *mutableStr = [NSMutableString stringWithString:content];
    
    if (!ignoreLinks) {
        while ([mutableStr isMatchedByRegex:LinkRegexExpress options:RKLCaseless inRange:NSMakeRange(0, mutableStr.length) error:nil]) {
            NSString *str = [mutableStr stringByMatching:LinkRegexExpress options:RKLCaseless inRange:NSMakeRange(0, mutableStr.length) capture:0L error:nil];
            NSRange range = [mutableStr rangeOfString:str];
            [mutableStr replaceCharactersInRange:range withString:@"*"];
            range.length = 1;
            [rangeArray addObject:[NSValue valueWithRange:range]];
        }
    }
    
    NSMutableAttributedString *_attributeString = [[NSMutableAttributedString alloc] initWithString:mutableStr];
    
    CTFontRef font = [[UIFont systemFontOfSize:size] createCTFont];
    [_attributeString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:NSMakeRange(0, mutableStr.length)];
    CFRelease(font);
    
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.dealloc = RunDelegateDeallocCallback;
    callbacks.getAscent = RunDelegateGetAscentCallback;
    callbacks.getDescent = RunDelegateGetDescentCallback;
    callbacks.getWidth = RunDelegateGetWidthCallback;
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void * _Nullable)([UIFont systemFontOfSize:size]));

    for (NSValue *value in rangeArray) {
        NSRange range = [value rangeValue];
        [_attributeString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:range];
        [_attributeString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor clearColor].CGColor range:range];
    }
    CFRelease(runDelegate);
    
    CTLineBreakMode   _lineBreakMode = CTLineBreakModeFromNSLineBreakMode(mode);
    CTTextAlignment   _alignment = CTTextAlignmentFromNSTextAlignment(textAlignment);
    CFIndex theNumberOfSettings = 6;
    CGFloat _paraSpace = 0;
    CGFloat _lineSpace = lineHeight - [UIFont systemFontOfSize:size].lineHeight;
    CTParagraphStyleSetting theSettings[6] =
    {
        { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &_alignment },
        { kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &_lineBreakMode },
        { kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &_paraSpace },
        { kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &_paraSpace },
        { kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(CGFloat), &_lineSpace},
        { kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(CGFloat), &_lineSpace}
        
    };
    
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);
    [_attributeString addAttribute:(NSString *)kCTParagraphStyleAttributeName
                              value:(id)paragraphStyle
                              range:NSMakeRange(0,mutableStr.length)];
    
    CFRelease(paragraphStyle);
    CGFloat height = 0.0;
    if (count > 0) {
        height = (CGFloat)[_attributeString getHeightWithWidth:maxSize.width maxLineCount:count font:[UIFont systemFontOfSize:size]];
    } else {
        height = (CGFloat)[_attributeString getHeightWithWidth:maxSize.width maxHeight:maxSize.height];
    }
    return height;

}

+ (CGFloat)heightForAttributeString:(NSAttributedString *)attrString maxWidth:(CGFloat)width
{
    return [attrString getHeightWithWidth:width maxHeight:CGFLOAT_MAX_CORE_TEXT];
}

- (void)setup {
    _textHeight = 0;
    self.font = [UIFont systemFontOfSize:DEFAULT_FONT_SIZE];
    self.lineHeight = _font.lineHeight;
    self.textAlignment = NSTextAlignmentLeft;
    self.breakMode   = NSLineBreakByCharWrapping;
    self.textColor = [UIColor blackColor];
    self.linkColor = [UIColor blueColor];
	self.highlightedColor = [UIColor colorWithWhite:0.4 alpha:0.3];
    self.tapEnable = NO;
    [self setOpaque:NO];
    [self setBackgroundColor:[UIColor clearColor]];
    self.isAccessibilityElement = YES;
    if (_anchorInfoArray == nil) {
        _anchorInfoArray = [[NSMutableArray alloc] init];
    }
    if (!_highLightInfoArray) {
        _highLightInfoArray = [[NSMutableArray alloc] init];
    }
    if (_fontInfoArray) {
        _fontInfoArray = [[NSMutableArray alloc] init];
    }
}

-(id)init {
    
    self = [super init];
    
    if (self) {
        [self setup];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
        self.text = text;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    if (!CGRectEqualToRect(self.frame, frame)) {
        [super setFrame:frame];
        [self setNeedsDisplay];
    }
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (!inSelected) {
        [self makeAttributedString];
    }
    
    // fix crash caused by nil text .  by jojo
    if (!_attributedString) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Grab the drawing context and flip it to prevent drawing upside-down
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSaveGState(context);

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributedString);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, &CGAffineTransformIdentity, rect);

    TT_RELEASE_CF_SAFELY(frameRef);
    frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, _attributedString.length), path, nil);
    CFArrayRef lineArray = CTFrameGetLines(frameRef);

    CGFloat height = [SNLabel heightForAttributeString:_attributedString maxWidth:CGRectGetWidth(rect)];
    if (height > CGRectGetHeight(rect) && lineArray && CFArrayGetCount(lineArray) > 0) {
        NSRange tmpRange;
        CTFontRef fontRef = (__bridge CTFontRef)[_attributedString attribute:(NSString *)kCTFontAttributeName atIndex:0 effectiveRange:&tmpRange];
        CGFloat fontSize = CTFontGetSize(fontRef);
        
        CTLineRef line = CFArrayGetValueAtIndex(lineArray, CFArrayGetCount(lineArray)-1);
        CFIndex index = CTLineGetStringIndexForPosition(line, CGPointMake(CGRectGetWidth(rect) - fontSize*1.5, CGRectGetHeight(rect) - fontSize*0.5));
        [_attributedString replaceCharactersInRange:NSMakeRange(index, _attributedString.length - index ) withString:@"..."];
        
        CFRelease(frameRef);
        CFRelease(framesetter);
        framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributedString);
        frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, _attributedString.length), path, nil);
        lineArray = CTFrameGetLines(frameRef);
    }
    CGPathRelease(path);
    
    CTFrameDraw(frameRef, context);
    CGContextRestoreGState(context);
    [super drawRect:self.bounds];
    
    [self removeAllSubviews];
    
    if (lineArray && CFArrayGetCount(lineArray) > 0) {
        CGPoint origins[CFArrayGetCount(lineArray)];
        CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
        for (CFIndex i = 0 ; i<CFArrayGetCount(lineArray); i++) {
            CTLineRef line = CFArrayGetValueAtIndex(lineArray, i);
            CFArrayRef runArray = CTLineGetGlyphRuns(line);
            for (CFIndex j = 0; j < CFArrayGetCount(runArray); j++) {
                CTRunRef run = CFArrayGetValueAtIndex(runArray, j);
                CFRange cfRange = CTRunGetStringRange(run);
                NSRange range = NSMakeRange(cfRange.location, cfRange.length);

                NSRange tmpRange;
                CTFontRef fontRef = (__bridge CTFontRef)[_attributedString attribute:(NSString *)kCTFontAttributeName atIndex:range.location effectiveRange:&tmpRange];
                CGFloat fontSize = CTFontGetSize(fontRef);
                
                CGFloat offsetX;
                CTLineGetOffsetForStringIndex(line, range.location, &offsetX);
                //CGContextDrawImage 绘制不需要翻转坐标，在翻转的坐标系中使用相对坐标的位置，再减去偏移量
                CGFloat offsetY = origins[i].y - 5;
                
                CGPoint emoticonPoint = CGPointMake(offsetX, offsetY);
                [self drawEmotcions:context run:run range:range origin:emoticonPoint];
                
                for (NSDictionary *dict in _linkInfoArray) {
                    NSValue *value = [dict objectForKey:@"range"];
                    NSRange range1 = [value rangeValue];
                    if (NSLocationInRange(range1.location, range) ) {
                        CGFloat offsetX;
                        CTLineGetOffsetForStringIndex(line, range.location, &offsetX);
                        CGPoint point = origins[i];
                        
                        CGRect rect = CGRectMake(offsetX+4,self.height - point.y-fontSize+2*(fontSize/14.0), fontSize*222/48-2, fontSize);
                        SNLinkButton *btn = [[SNLinkButton alloc] initWithFrame:rect];
                        [btn setTitleFont:[UIFont systemFontOfSize:fontSize/1.6]];
                        btn.url = [dict objectForKey:@"link"];
                        [btn addTarget:self action:@selector(openURL:) forControlEvents:UIControlEventTouchUpInside];
                        [self addSubview:btn];
                    }
                }
            }
        }
    }
    CFRelease(framesetter);
}

- (void)drawEmotcions:(CGContextRef)context run:(CTRunRef)run range:(NSRange)range origin:(CGPoint)point
{
    CFDictionaryRef attributes = CTRunGetAttributes(run);
    NSNumber *num = (NSNumber *)CFDictionaryGetValue(attributes, @"emoticonType");
    SNEmoticonType emoticonType = [num intValue];
    UIImage *emoticonImage = (UIImage *)CFDictionaryGetValue(attributes, @"emoticonImage");
    if (emoticonImage) {
        NSRange tmpRange;
        CTFontRef fontRef = (__bridge CTFontRef)[_attributedString attribute:(NSString *)kCTFontAttributeName
                                                            atIndex:range.location
                                                     effectiveRange:&tmpRange];
        CGFloat fontSize = CTFontGetSize(fontRef);
        
        CGRect imageRect = CGRectZero;
        imageRect.origin = point;
//        int length = [_attributedString.string trim].length;
        //如果是只有大图，画大图，如果是图文混排中出现大图，压缩大图到字体高度，绘制压缩后的小图
        if (emoticonType == SNEmoticonDynamic && [_attributedString.string trim].length == 1) {
            imageRect.size = emoticonImage.size;
            imageRect.origin.y = 0;
        }
        else {
            imageRect.size = CGSizeMake(fontSize + 4, fontSize + 4);
            if (emoticonType == SNEmoticonDynamic) {
                //压缩图片
//                emoticonImage = [UIImage imageWithImage:emoticonImage scaledToSize:imageRect.size];
                emoticonImage = [emoticonImage rescaleImageToSize:imageRect.size];
            }
        }
//        UIImage *scaleImage = [emoticonImage rescaleImageToSize:imageRect.size];
        CGContextDrawImage(context, imageRect, emoticonImage.CGImage);
    }
}

- (void)dealloc
{
     //(_text);
     //(_font);
     //(_textColor);
     //(_highlightedColor);
     //(_linkColor);
    TT_RELEASE_CF_SAFELY(frameRef);
     //(_anchorInfoArray);
     //(_highLightInfoArray);
//     //(_emoticonInfoDic);
     //(_linkInfoArray);
     //(_fontInfoArray);
     //(_attributedString);
    
}

- (void)setFont:(UIFont *)font
{
    if (_font != font) {
        _font = font;
        if (self.lineHeight == 0) {
            self.lineHeight = _font.lineHeight;
        }
        [self setNeedsDisplay];
    }
}

- (void)setTextColor:(UIColor *)textColor
{
    if (_textColor != textColor) {
        _textColor = textColor;
        [self setNeedsDisplay];
    }
}

- (void)setLineHeight:(CGFloat)lineHeight
{
    if (_lineHeight != lineHeight) {
        _lineHeight = lineHeight;
        [self setNeedsDisplay];
    }
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    if (_textAlignment !=  textAlignment) {
        _textAlignment = textAlignment;
        [self setNeedsDisplay];
    }
}

- (void)setBreakMode:(NSLineBreakMode)breakMode
{
    if (_breakMode != breakMode) {
        _breakMode = breakMode;
        [self setNeedsDisplay];
    }
}

- (void)setText:(NSString *)text
{
    if (_text != text) {
        _text = text;
        self.accessibilityLabel = self.text;
        [self removeAllSubviews];
        [self setNeedsDisplay];
    }
}

- (void)makeAttributedString
{
    if (_linkInfoArray) {
        [_linkInfoArray removeAllObjects];
    } else {
        _linkInfoArray = [[NSMutableArray alloc] init];
    }
    
    if (self.text) {
        
        NSMutableString *mutableText = [NSMutableString stringWithString:self.text];
        
        //解析表情
        NSMutableDictionary *imageRangeDic = [NSMutableDictionary dictionary];
        mutableText = [[SNEmoticonManager sharedManager] parseEmoticonFromText:mutableText emoticon:imageRangeDic];
        
        //解析链接
        if (!self.disableLinkDetect) {
            NSArray	*hrefLinkArray = [mutableText arrayOfCaptureComponentsMatchedByRegex:LinkRegexExpress options:RKLCaseless range:NSMakeRange(0, mutableText.length) error:nil];
            [self parseHrefTagWithArray:hrefLinkArray
                                   text:mutableText];
        }
        
         //(_attributedString);
        _attributedString = [[NSMutableAttributedString alloc] initWithString:mutableText];
        
        //生成表情
        if (imageRangeDic.count > 0) {
            CTRunDelegateCallbacks callbacks;
            callbacks.version = kCTRunDelegateVersion1;
            callbacks.dealloc = RunDelegateDeallocCallback;
            callbacks.getAscent = RunDelegateGetAscentCallback;
            callbacks.getDescent = RunDelegateGetDescentCallback;
            callbacks.getWidth = EmoticonRunDelegateGetWidthCallback;
            CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void * _Nullable)(self.font));
            
            if (imageRangeDic) {
                NSArray *keyRanges = [imageRangeDic allKeys];
                NSInteger count = [keyRanges count];
                for (int i = 0; i < count; i++) {
                    NSRange rangeKey = [keyRanges[i] rangeValue];
                    SNEmoticonObject *emoticon = (SNEmoticonObject *)[imageRangeDic objectForKey:keyRanges[i]];
                    
                    if (rangeKey.location + rangeKey.length <= _attributedString.length) {
                        [_attributedString addAttribute:@"emoticonType" value:(id)@(emoticon.type) range:rangeKey];
                        //区别重复表情
                        [_attributedString addAttribute:@"emoticonIndex" value:(id)@(i) range:rangeKey];
                        [_attributedString addAttribute:@"emoticonImage" value:(id)emoticon.emoticonImage range:rangeKey];
                        [_attributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:rangeKey];
                    }
                }
            }
            
            CFRelease(runDelegate);
        }
        
        //生成链接属性
        CTRunDelegateCallbacks callbacks;
        callbacks.version = kCTRunDelegateVersion1;
        callbacks.dealloc = RunDelegateDeallocCallback;
        callbacks.getAscent = RunDelegateGetAscentCallback;
        callbacks.getDescent = RunDelegateGetDescentCallback;
        callbacks.getWidth = RunDelegateGetWidthCallback;
        CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void * _Nullable)(self.font));
        
        for (NSDictionary *dict in _linkInfoArray) {
            NSRange range = [(NSValue *)[dict objectForKey:@"range"] rangeValue];
            if (range.location + range.length <= _attributedString.length) {
                [_attributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:range];
                [_attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName
                                          value:(id)[UIColor clearColor].CGColor
                                          range:range];
            }
        }
        
        CFRelease(runDelegate);
        
        if (self.textColor.CGColor) {
            [_attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)self.textColor.CGColor range:NSMakeRange(0, [_attributedString length])];
        }
        
        CTFontRef fontRef = [self.font createCTFont];
        if (fontRef) {
            [_attributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, [_attributedString length])];
            CFRelease(fontRef);
        }
        
        CTLineBreakMode   _lineBreakMode = CTLineBreakModeFromNSLineBreakMode(self.breakMode);
        CTTextAlignment   _alignment = CTTextAlignmentFromNSTextAlignment(self.textAlignment);
        CFIndex theNumberOfSettings = 6;
        CGFloat _paraSpace = 0;
        CGFloat _lineSpace = _lineHeight - self.font.lineHeight;
        CTParagraphStyleSetting theSettings[6] =
        {
            { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &_alignment },
            { kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &_lineBreakMode },
            { kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &_paraSpace },
            { kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &_paraSpace },
            { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &_lineSpace},
            { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &_lineSpace}
        };
        
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);
        if (paragraphStyle) {
            [_attributedString addAttribute:(NSString *)kCTParagraphStyleAttributeName
                                      value:(id)paragraphStyle
                                      range:NSMakeRange(0,_attributedString.length)];
            CFRelease(paragraphStyle);
        }
        
        for(NSDictionary *fontDic in _fontInfoArray)
        {
            NSRange fontRange = [[fontDic objectForKey:@"range"] rangeValue];
            UIFont *textFont = [fontDic objectForKey:@"font"];
            CTFontRef textFontRef = [textFont createCTFont];
            if (textFontRef) {
                [_attributedString addAttribute:(NSString *)kCTFontAttributeName
                                          value:(__bridge id)textFontRef
                                          range:fontRange];
                CFRelease(textFontRef);
            }
        }
        
        for(NSDictionary *highLightDic in _highLightInfoArray)
        {
            NSRange highLightRange = [[highLightDic objectForKey:@"range"] rangeValue];
            if (_linkColor.CGColor && (highLightRange.location + highLightRange.length <= _attributedString.length)) {
                [_attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName
                                          value:(id)_linkColor.CGColor
                                          range:highLightRange];
            }
        }
        
        
        for(NSDictionary *highLightDic in _anchorInfoArray)
        {
            NSRange highLightRange = [[highLightDic objectForKey:@"range"] rangeValue];
            if (_linkColor.CGColor && (highLightRange.location + highLightRange.length <= _attributedString.length)) {
                [_attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName
                                          value:(id)_linkColor.CGColor
                                          range:highLightRange];
            }
        }
    }
}


-(void)parseHrefTagWithArray:(NSArray*)textArray text:(NSMutableString *)mutableText
{
    NSRange nextTextRange = NSMakeRange(0,mutableText.length);
    for (int x=0; x<textArray.count; x++) {
        NSArray *herfArray = [textArray objectAtIndex:x];
        
        NSString *content = [herfArray objectAtIndex:0];
        
        NSString *url = content;
        NSMutableDictionary *highLightTextDic = [NSMutableDictionary dictionaryWithCapacity:4];
        if ([content hasPrefix:@"<"] && herfArray.count > 2) {
            url = [herfArray objectAtIndex:2];
            [highLightTextDic setObject:@"href" forKey:@"linkType"];
        } else {
            [highLightTextDic setObject:@"url" forKey:@"linkType"];
        }
        [highLightTextDic setObject:url forKey:@"link"];

        
        NSString *newStr= [mutableText substringFromIndex:nextTextRange.location];
        NSRange nameRange = [newStr rangeOfString:content];
        nameRange.location += nextTextRange.location;
        
        unichar attachmentCharacter = spaceHolderCharacter;
        NSString *spaceHolder = [NSString stringWithFormat:@"%@",[NSString stringWithCharacters:&attachmentCharacter length:1]];
        [mutableText replaceCharactersInRange:nameRange withString:spaceHolder];
        nameRange.length = 1;
        
        [highLightTextDic setObject:[NSValue valueWithRange:nameRange] forKey:@"range"];
        [_linkInfoArray addObject:highLightTextDic];
        //range向前！
        NSInteger nexPlace = nameRange.location+nameRange.length;
        nextTextRange = NSMakeRange(nexPlace,mutableText.length-nexPlace);
    }
}


- (void)openURL:(id)sender
{
    if ([sender isKindOfClass:[SNLinkButton class]]) {
        SNLinkButton *linkBtn = (SNLinkButton *)sender;
        if ([_delegate respondsToSelector:@selector(tapOnLink:)]) {
            NSString *url = linkBtn.url;
            if ((![SNAPI isWebURL:url])&&(![url hasPrefix:@"link"])) {
                url = [[SNAPI rootScheme] stringByAppendingString:url];
            }
            [_delegate performSelector:@selector(tapOnLink:) withObject:url];
        }
    }
}

- (void)addCustomLink:(NSString*)linkUrl inRange:(NSRange)range
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:linkUrl forKey:@"url"];
    [dict setObject:[NSValue valueWithRange:range] forKey:@"range"];
    [_anchorInfoArray addObject:dict];
	[self setNeedsDisplay];
}
- (void)removeAllCustomLinks
{
	[_anchorInfoArray removeAllObjects];
	[self setNeedsDisplay];
}

- (void)addHighlightText:(NSString *)text inRange:(NSRange)range
{
    if (!text || range.length ==0) {
        return;
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:text forKey:@"highlightText"];
    [dict setObject:[NSValue valueWithRange:range] forKey:@"range"];
    [_highLightInfoArray addObject:dict];
}

- (void)removeAllHighlightInfo
{
    [_highLightInfoArray removeAllObjects];
}

- (void)addEmoticons:(NSMutableDictionary *)imageRangeDic
{
//    if (imageRangeDic.count > 0) {
//        if (_emoticonInfoArray.count > 0 ) {
//            [_emoticonInfoArray removeAllObjects];
//        }
//        
//        for (NSInteger i = 0; i < [ranges count]; i++) {
//            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//            [dict setObject:[emoticonImages objectAtIndex:i] forKey:@"emoticonImage"];
//            [dict setObject:[ranges objectAtIndex:i] forKey:@"range"];
//            [_emoticonInfoArray addObject:dict];
//            
//            [dict release];
//        }
//        if (_emoticonInfoDic != imageRangeDic) {
//             //(_emoticonInfoDic);
//            _emoticonInfoDic = [imageRangeDic retain];
//        }
//    }
}

- (void)removeAllEmoticonInfo
{
//    [_emoticonInfoDic removeAllObjects];
//     //(_emoticonInfoDic);
}

- (void)addFont:(UIFont *)font inRange:(NSRange)range
{
    if (!font || range.length == 0) {
        return;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:font forKey:@"font"];
    [_highLightInfoArray addObject:dict];
    [dict setObject:[NSValue valueWithRange:range] forKey:@"range"];
}

- (void)removeAllFontInfo
{
    [_fontInfoArray removeAllObjects];
}

#pragma mark -
#pragma mark touch deal
- (CFIndex) getStringIndexInFrameWith:(CGPoint) touchPoint
{
    CFIndex lineIndex = -1;
    CFIndex stringIndex = -1;
    
    //转换为相对frame pos
    CGPathRef path = CTFrameGetPath(frameRef);
    CGRect frameRect = CGPathGetBoundingBox(path);
    CGPoint locatePoint;
    locatePoint.x = touchPoint.x-frameRect.origin.x;
    float topCap = self.frame.size.height-frameRect.size.height-frameRect.origin.y;
    locatePoint.y = touchPoint.y-topCap;
    
    //
    NSArray *linesArray = (NSArray *) CTFrameGetLines(frameRef);
    CGPoint origins[[linesArray count]];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
    
    float last_y = 0.0;
    for (int i = 0; i < [linesArray count]; i++)
    {
        float line_y = frameRect.size.height - origins[i].y;
        
        if (locatePoint.y > last_y && locatePoint.y <= line_y)
        {
            lineIndex = i;
            break;
        }
        last_y = line_y;
    }
    
    //获取stringIndex
    if (lineIndex >= 0)
    {
        CTLineRef touchLine	= (__bridge CTLineRef) [linesArray objectAtIndex:lineIndex];
        CFRange	lineRange = CTLineGetStringRange(touchLine);
        stringIndex	= CTLineGetStringIndexForPosition(touchLine, locatePoint);
        if( stringIndex > (lineRange.location + lineRange.length - 1))
        {
            stringIndex = -1;
        }
        else{
            stringIndex += 0;
        }
    }
    return stringIndex;
}

- (BOOL)isTouchedHighLightTextWith:(NSRange) range
{
    BOOL isHighLight = NO;
    
    for (int i = 0; i < [_anchorInfoArray count]; i++)
    {
        NSDictionary *highLightDic = [_anchorInfoArray objectAtIndex:i];
        NSRange highLightRange = [[highLightDic objectForKey:@"range"] rangeValue];
        
        if (NSEqualRanges(range,highLightRange))
        {
            isHighLight = YES;
            break;
        }
    }
    
    return isHighLight;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch	= [touches anyObject];
	CGPoint	beginPoint 	= [touch locationInView:self];
    
    beginPoint.x = beginPoint.x - 5;
    
    inSelected = NO;
    
    //获取点击字符Index
    CFIndex stringIndex = -1;
    stringIndex = [self getStringIndexInFrameWith:beginPoint];
    
    if (stringIndex >= 0)
    {
        NSRange	range;
		NSDictionary *attributeDic = [_attributedString attributesAtIndex:(NSUInteger)stringIndex effectiveRange:&range];
        
        BOOL isHighLightText = [self isTouchedHighLightTextWith:(NSRange) range];
		if( attributeDic && [attributeDic count] > 0 && isHighLightText == YES)
		{
            inSelected = YES;
            touchedRange = range;
			_touchedDic = attributeDic;
            
            [_attributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)_highlightedColor.CGColor range:range];
            [self setNeedsDisplay];
            
            return;
		}
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (touchedRange.length > 0)
    {
        UITouch *touch	= [touches anyObject];
        CGPoint	beginPoint 	= [touch locationInView:self];
        
        beginPoint.x = beginPoint.x - 5;
        
        //获取点击字符Index
        CFIndex stringIndex = -1;
        stringIndex = [self getStringIndexInFrameWith:beginPoint];
        
        if (stringIndex >= 0)
        {
            inSelected = NSLocationInRange(stringIndex, touchedRange);
            if (inSelected) {
                [_attributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)_highlightedColor.CGColor range:touchedRange];
            }
            [self setNeedsDisplay];
        }
    }
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [[self nextResponder] touchesEnded:touches withEvent:event];
    //超链接部分
    if (touchedRange.length > 0)
    {
        [_attributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)_highlightedColor.CGColor range:touchedRange];
        [self setNeedsDisplay];
        
        if (inSelected == YES)
        {
            if ([_delegate respondsToSelector:@selector(tapOnLink:)]) {
                NSString *url = nil;
                for (int i = 0; i < [_anchorInfoArray count]; i++)
                {
                    NSDictionary *highLightDic = [_anchorInfoArray objectAtIndex:i];
                    NSRange highLightRange = [[highLightDic objectForKey:@"range"] rangeValue];
                    
                    if (NSEqualRanges(touchedRange,highLightRange))
                    {
                        url = [highLightDic objectForKey:@"url"];
                        [_delegate tapOnLink:url];
                        break;
                    }
                }
            }
        }
    }
    else {
        if (tapEnable&&[_delegate respondsToSelector:@selector(tapOnNotLink:)]) {
            [_delegate tapOnNotLink:self];
        }
    }
    
    inSelected = NO;
    touchedRange = NSMakeRange(0, 0);
    _touchedDic = nil;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touchedRange.length > 0)
    {
        inSelected = NO;
        [self setNeedsDisplay];
        touchedRange = NSMakeRange(0, 0);
        _touchedDic = nil;
    }
}

@end
