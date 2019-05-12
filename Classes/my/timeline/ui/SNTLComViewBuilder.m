//
//  SNTLComViewBuilder.m
//  sohunews
//
//  Created by jojo on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTLComViewBuilder.h"
#import "SNTimelineTrendObjects.h"
#import "SNTLCommonView.h"
#import "SNTLComViewOnlyTextBuilder.h"
#import "SNTLComViewTextAndPicsBuilder.h"
#import "SNTLComViewSubscribeBuilder.h"

@implementation SNTLComViewBuilder
@synthesize isForShare = _isForShare;
@synthesize link = _link;
@synthesize btnClickAction = _btnClickAction;

- (id)init {
    self = [super init];
    if (self) {
        self.isForShare = NO;
    }
    return self;
}

- (void)dealloc {
     //(_link);
     //(_btnClickAction);
}

+ (CGFloat)heightForObject:(id)object {
    CGFloat height = 0;
    if ([object isKindOfClass:[SNTimelineOriginContentObject class]]) {
        SNTimelineOriginContentObject *obj = object;
        switch (obj.type) {
            case SNTimelineOriginContentTypeText: {
                SNTLComViewOnlyTextBuilder *builder = [SNTLComViewOnlyTextBuilder new];
                builder.title = obj.abstract;
                builder.fromString = obj.fromString;
                height = [builder suggestViewSize].height;
                break;
            }
            case SNTimelineOriginContentTypeTextAndPics:
                // 图文新闻类型的  固定高度 不要计算
                height = kTLViewViewMaxHeight;
                break;
            case SNTimelineOriginContentTypeSub:
                // 订阅类型 固定高度
                height = kTLViewSubViewHeight;
                break;
            default:
                break;
        }
    }
    return height;
}

+ (SNTLCommonView *)viewForObject:(id)object {
    UIView *view = nil;
    if ([object isKindOfClass:[SNTimelineOriginContentObject class]]) {
        SNTimelineOriginContentObject *obj = object;
        switch (obj.type) {
            case SNTimelineOriginContentTypeText: {
                SNTLComViewOnlyTextBuilder *builder = [SNTLComViewOnlyTextBuilder new];
                builder.title = obj.abstract;
                builder.fromString = obj.fromString;
                view = [builder buildView];
                break;
            }
            case SNTimelineOriginContentTypeTextAndPics: {
                SNTLComViewTextAndPicsBuilder *builder = [SNTLComViewTextAndPicsBuilder new];
                builder.title = obj.abstract;
                builder.fromString = obj.fromString;
                if (obj.picsArray.count > 0) {
                    builder.imageUrl = [obj.picsArray objectAtIndex:0];
                }
                view = [builder buildView];
                break;
            }
            case SNTimelineOriginContentTypeSub:
                break;
                
            default:
                break;
        }
    }
    return (SNTLCommonView *)view;
}

- (void)setIsForShare:(BOOL)isForShare {
    _isForShare = isForShare;
    _suggestViewWidth = _isForShare ? kTLViewWidthForShare : kTLViewWidth;
}

- (UIView *)buildView {
    SNTLCommonView *tmpView = [SNTLCommonView new];
    [tmpView setBuilder:self];
    [tmpView sizeToFit];
    return tmpView;
}

- (CGSize)suggestViewSize {
    return CGSizeZero;
}

- (UIButton *)actionButton {
    return nil;
}

- (UIView *)imageView {
    return nil;
}

- (UIView *)videoIconView {
    return nil;
}

- (CGRect)imageViewFrameForRect:(CGRect)rect {
    return CGRectZero;
}

- (NSString *)imageUrlPath {
    return nil;
}

- (void)renderInRect:(CGRect)rect withContext:(CGContextRef)context {
    UIImage *bgImage = [UIImage imageNamed:@"timeline_common_bg.png"];
    if ([bgImage respondsToSelector:@selector(resizableImageWithCapInsets:)])
        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    else
        bgImage = [bgImage stretchableImageWithLeftCapWidth:20 topCapHeight:20];
    
    if (bgImage) [bgImage drawInRect:rect];
}

@end
