//
//  NewsImageUrlParser.m
//  sohunews
//
//  Created by Chen Hong on 13-3-12.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNNewsImageUrlParser.h"
#import "TBXML.h"

@implementation SNNewsImageUrlParser

+ (NSArray *)extractImageAttributeValueFromRawHTML:(NSString *)rawHTML attributeName:(NSString *)attrName {
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    if (rawHTML != nil && [rawHTML length] != 0) {
        
        NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"<\\s*?img\\s+[^>]*?\\s*src\\s*=\\s*([\"\'])((\\\\?+.)*?)\\1[^>]*?>" options:NSRegularExpressionCaseInsensitive error:nil];
        
        NSArray *imagesHTML = [regex matchesInString:rawHTML options:0 range:NSMakeRange(0, [rawHTML length])];
        
        
        for (NSTextCheckingResult *image in imagesHTML) {
            
            NSString *imageHTML = [rawHTML substringWithRange:image.range];
            
            TBXML *tbxml = [TBXML tbxmlWithXMLString:imageHTML];
            
            TBXMLElement *root = tbxml.rootXMLElement;
            
            NSString *url = [TBXML valueOfAttributeNamed:attrName forElement:root];
            
            if (url && ![images containsObject:url]) {
                [images addObject:url];
            }
        }
    }
    
    return images;
}

+ (NSArray*)getImageUrlFromNewsContent:(NSString*)newsContent {
    if (newsContent == nil || [newsContent length] == 0) {
		return nil;
	}
    
	return [self extractImageAttributeValueFromRawHTML:newsContent attributeName:@"src"];
}

+ (NSArray*)getThumbnailUrlFromNewsContent:(NSString*)newsContent {
    if (newsContent == nil || [newsContent length] == 0) {
		return nil;
	}
    
	return [self extractImageAttributeValueFromRawHTML:newsContent attributeName:@"thumbnail"];
}



@end
