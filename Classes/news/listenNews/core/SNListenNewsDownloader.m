//
//  SNListenNewsDownloader.m
//  sohunews
//
//  Created by weibin cheng on 14-6-16.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNListenNewsDownloader.h"
#import "SNArticle.h"
#import "TFHpple.h"

@implementation SNListenNewsDownloader
@synthesize delegate = _delegate;
@synthesize channelId = _channelId;
@synthesize newsId = _newsId;
@synthesize linkParams = _linkParams;

- (void)dealloc
{
     //(_channelId);
     //(_newsId);
     //(_linkParams);
}

- (void)main
{
    [super main];
    @autoreleasepool {
        NSString *content = [SNArticle newsContentForJsKitStorageWithNewsId:self.newsId];
        
        if (content) {
            
            /*
            NSData* data = [content dataUsingEncoding:NSUTF8StringEncoding];
            TFHpple * doc = [[TFHpple alloc] initWithHTMLData:data];
            NSMutableString* string = [NSMutableString stringWithCapacity:10];
            NSArray * elements  = [doc searchWithXPathQuery:@"//p"];
            for(TFHppleElement* element in elements)
            {
                if(element.firstTextChild)
                {
                    [string appendString:element.firstTextChild.content];
                }
            }
            if (string && string.length > 0) {
                
            }else{
                NSArray * elements  = [doc searchWithXPathQuery:@"//span"];
                for(TFHppleElement* element in elements)
                {
                    if(element.firstTextChild)
                    {
                        [string appendString:element.firstTextChild.content];
                    }
                }
                
            }
            [string trim];
            */
            content = [self filterHTML:content];
            [self performSelectorOnMainThread:@selector(notifyListenNewsDidFinished:) withObject:content waitUntilDone:[NSThread isMainThread]];
        }
        else
        {
            [self performSelectorOnMainThread:@selector(notifyListenNewsDidFinished:) withObject:nil waitUntilDone:[NSThread isMainThread]];
        }
    }
}

//lijian 2017.05.18 解决从html里面筛出纯文本的不准确性的问题。
-(NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        [scanner scanUpToString:@"<" intoString:nil];
        [scanner scanUpToString:@">" intoString:&text];
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    return html;
}

- (void)notifyListenNewsDidFinished:(NSString*)content
{
    if(_delegate && [_delegate respondsToSelector:@selector(listenNewsDidFinishedWithContent:)])
        [_delegate listenNewsDidFinishedWithContent:content];
}
@end
