//
//  SNEncryptManager.m
//  sohunews
//
//  Created by Diaochunmeng on 12-12-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNEncryptManager.h"

static SNEncryptManager* g_EncryptManager;

@implementation SNEncryptManager

+(SNEncryptManager*)GetInstance
{
	if(g_EncryptManager==nil)
	{
		g_EncryptManager = [[SNEncryptManager alloc]init];
	}
	return g_EncryptManager;
}

+(NSString*)EncrptUpdateUserinfoString:(NSString*)aUrlString
{
    if(aUrlString!=nil && [aUrlString length]>0)
    {
        //切割问号后面的部分
        NSString* split = @"?";
        NSCharacterSet* set = [NSCharacterSet characterSetWithCharactersInString:split];
        NSArray* strings = [aUrlString componentsSeparatedByCharactersInSet:set];
        
        //切割参数
        if(strings!=nil && [strings count]==2)
        {
            NSString* parameter = (NSString*)[strings objectAtIndex:1];
            if(parameter!=nil && [parameter length]>0)
            {
                NSString* split2 = @"&";
                NSCharacterSet* set2 = [NSCharacterSet characterSetWithCharactersInString:split2];
                NSArray* paras = [parameter componentsSeparatedByCharactersInSet:set2];
                
                if(paras!=nil && [paras count]>0)
                {
                    NSMutableString* base64 = [NSMutableString stringWithCapacity:0];
                    NSArray* sortedParas = [paras sortedArrayUsingSelector:@selector(compare:)];
                    for(NSInteger i=0; i<[sortedParas count]; i++)
                    {
                        NSString* item = (NSString*)[sortedParas objectAtIndex:i];
                        NSData* base64Data = [item dataUsingEncoding:NSUTF8StringEncoding];
                        [base64 appendString:[base64Data base64Encoding]];
                    }
                    
                    if([base64 length]>0)
                    {
                        NSString* string = [NSString stringWithFormat:@"%@&code=%@", aUrlString, [base64 md5Hash]];
                        return string;
                    }
                }
            }
        }
    }
    
    //By default
    return nil;
}

+(NSDictionary*)dictionaryFromQuery:(NSString*)query usingEncoding:(NSStringEncoding)encoding
{
    if(query==nil || [query length]==0)
        return nil;
    else
    {
        //切割问号后面的部分
        NSString* split = @"////";
        NSCharacterSet* set = [NSCharacterSet characterSetWithCharactersInString:split];
        NSArray* strings = [query componentsSeparatedByCharactersInSet:set];
        
        //有时会解析出空字符串来
        NSMutableArray* stringsWithOutEmpty = [NSMutableArray arrayWithCapacity:0];
        for(NSString* str in strings)
            if([str length]>0)
                [stringsWithOutEmpty addObject:str];
        
        //解析协议
        NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
        if([stringsWithOutEmpty count]==2)
        {
            NSString* first = (NSString*)[stringsWithOutEmpty objectAtIndex:0];
            NSString* trim = [first stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [pairs setObject:trim forKey:@"_protocol_"];
        }
        
        //切割参数
        if([stringsWithOutEmpty count]>0)
        {
            NSString* last = (NSString*)[stringsWithOutEmpty lastObject];
            NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
            NSScanner* scanner = [[NSScanner alloc] initWithString:last];
            while(![scanner isAtEnd])
            {
                NSString* pairString = nil;
                [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
                [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
                NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
                if(kvPair.count==2)
                {
                    NSString* key = [[kvPair objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:encoding];
                    NSString* value = [[kvPair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:encoding];
                    [pairs setObject:value forKey:key];
                }
            }
        }
        return pairs;
    }
}
@end
