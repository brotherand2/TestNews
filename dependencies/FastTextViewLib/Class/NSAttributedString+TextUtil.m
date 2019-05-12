//
//  NSAttributedString+TextUtil.m
//  tangyuanReader
//
//  Created by 王 强 on 13-6-8.
//  Copyright (c) 2013年 中文在线. All rights reserved.
//

#import "NSAttributedString+TextUtil.h"
#import "NSMutableAttributedString+TextUtil.h"
#import "FileWrapperObject.h"
#import "FastTextView.h"
//MARK: Text attachment helper functions
static void AttachmentRunDelegateDealloc(void *refCon) {
    CFBridgingRelease(refCon);
}

static CGSize AttachmentRunDelegateGetSize(void *refCon) {
    id <FastTextAttachmentCell> cell = (__bridge id<FastTextAttachmentCell>)(refCon);
    if ([cell respondsToSelector: @selector(attachmentSize)]) {
        return [cell attachmentSize];
    } else {
        return [[cell attachmentView] frame].size;
    }
}

static CGFloat AttachmentRunDelegateGetDescent(void *refCon) {
    return AttachmentRunDelegateGetSize(refCon).height;
}

static CGFloat AttachmentRunDelegateGetWidth(void *refCon) {
    return AttachmentRunDelegateGetSize(refCon).width;
}

@implementation NSAttributedString (TextUtil)

- (NSString *)getUnixTimestamp:(NSDate *)curdate {
    NSTimeInterval a=[curdate timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    return timeString;
}

- (NSInteger)getRandFromOnetoX:(NSInteger)x {
    return (arc4random() % x) + 1;
}

+ (NSAttributedString *)fromHtmlString:(NSString *)htmlstr
                    withAttachmentPath:(NSString *)attachpath {
    return nil;
}

+ (NSMutableAttributedString *)scanAttachments:(NSMutableAttributedString *)_attributedString {
    NSMutableArray *temArray = [_attributedString scanAttachments];
    [temArray removeAllObjects];
    temArray = nil;
    return _attributedString;
}

+ (NSString *)scanAttachmentsForNewFileName:(NSAttributedString *)_attributedString {
    __block NSString *newFilename = @"a1.jpg";
    __block NSInteger maxfileid = 1;
    
    [_attributedString enumerateAttribute:FastTextAttachmentAttributeName
                                  inRange:NSMakeRange(0, [_attributedString length])
                                  options:0
                               usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value != nil) {
            id<FastTextAttachmentCell> cell = (id<FastTextAttachmentCell>)value;
            NSString *filename = [cell.fileWrapperObject.fileName lowercaseString];
            if (filename != nil && [[filename substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"a"]) {
                NSInteger nowfileid = [self getObjectIntValue:[[filename stringByDeletingPathExtension] substringFromIndex:1]] + 1;
                if (nowfileid > maxfileid) {
                    maxfileid = nowfileid;
                }                
            }           
        }
    }];
    
    newFilename = [NSString stringWithFormat:@"a%ld.jpg", maxfileid];
    return newFilename;
}

+ (NSInteger)getObjectIntValue:(id)obj {
    NSNumber *_intvalue = (NSNumber *)obj;
    if (_intvalue != nil && _intvalue != (NSNumber *)[NSNull null]) {
        return _intvalue.intValue;
    } else {
        return 0;
    }
}

+ (NSMutableAttributedString *)stripStyle:(NSAttributedString *)attrstring {
    //只保留附件属性
    __block NSMutableAttributedString *mutableAttributedString =[[NSMutableAttributedString alloc] initWithString:[attrstring string]];
    
    [attrstring enumerateAttribute:FastTextAttachmentAttributeName
                           inRange:NSMakeRange(0, [attrstring length])
                           options:0
                        usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value != nil) {
            id<FastTextAttachmentCell> cell = (id<FastTextAttachmentCell>)value;
            [mutableAttributedString addAttribute:FastTextAttachmentAttributeName
                                            value:cell
                                            range:range];
        }
    }];
    
    if (mutableAttributedString) {
        return mutableAttributedString;
    }
    return nil;
}

- (CGFloat)boundingHeightForWidth:(CGFloat)width {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFMutableAttributedStringRef) self);
    CGRect box = CGRectMake(0, 0, width, CGFLOAT_MAX);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, box);
    
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(width, CGFLOAT_MAX), NULL);
    CFRelease(framesetter);
    CFRelease(path);
    return suggestedSize.height;
}

@end
