 //
//  SNPhotoListRecommendCell.m
//  sohunews
//
//  Created by jialei on 13-8-27.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNPhotoListRecommendCell.h"
#import "SNPhotoListRecommendView.h"
#import "SNDBManager.h"
#import "SNNewsSdkAdRecommendView.h"
#import "SNNewsSdkAdPicTextView.h"


#define kTitleLeftOffset                            (10.0)
#define kTitlePicOffset                             (34.0 / 2)
#define kRecommendPicOffset                         (14.0 / 2)
#define kRecommendPicWidth                          (190.67 / 2)
#define kRecommendPicHeight                         (141.0 / 2)
#define kRecommendTileFont                          (13.0)

@interface SNPhotoListRecommendCell()
{
    GalleryItem *galleryItem;
    NSMutableArray *recommendViewArray;
    
    SNNewsSdkAdRecommendView *_sdkViewRecommend;
    SNNewsSdkAdPicTextView *_sdkViewTextPic;
    
    UIImageView *_sepLineFromAdViews;
}

@property (nonatomic, retain)GalleryItem *galleryItem;

@end

@implementation SNPhotoListRecommendCell

@synthesize galleryItem;
@synthesize delegate = _delegate;
@synthesize sdkAdRecommend = _sdkAdRecommend;
@synthesize sdkAdTextPic = _sdkAdTextPic;

+ (float)heightForRecommdendCell:(GalleryItem *)item
{
    float height = 0;
    if (item.moreRecommends.count > 0)
    {
        RecommendGallery *photo = [item.moreRecommends objectAtIndex:0];
        CGSize changeSize = [photo.title sizeWithFont:[UIFont systemFontOfSize:kRecommendTileFont]];
        height += kRecommendPicHeight + kTitlePicOffset * 2 + changeSize.height * 2 + 15;
    }
    return height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.imageView.userInteractionEnabled  = YES;
        [self setBackgroundColor:[UIColor clearColor]];
        
        recommendViewArray = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChanged:) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}

-  (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    TT_RELEASE_SAFELY(galleryItem);
    TT_RELEASE_SAFELY(recommendViewArray);
    
    _sdkAdRecommend.delegate = nil;
    TT_RELEASE_SAFELY(_sdkAdRecommend);
    _sdkAdTextPic.delegate = nil;
    TT_RELEASE_SAFELY(_sdkAdTextPic);
        
    [super dealloc];
}

- (void)removeAllRecommendView {
    for (SNPhotoListRecommendView *view in recommendViewArray) {
        [view removeFromSuperview];
    }
    [recommendViewArray removeAllObjects];
}

- (void)setSdkAdRecommend:(SNAdDataCarrier *)sdkAdRecommend {
    if (_sdkAdRecommend != sdkAdRecommend) {
        TT_RELEASE_SAFELY(_sdkAdRecommend);
        _sdkAdRecommend = [sdkAdRecommend retain];
    }
    if (_sdkViewRecommend) {
        [_sdkViewRecommend removeFromSuperview];
        _sdkViewRecommend = nil;
    }
    
    if (_sdkAdRecommend.dataState == SNAdDataStateReady) {
        _sdkViewRecommend = [[[SNNewsSdkAdRecommendView alloc] initWithAdDataCarrier:_sdkAdRecommend] autorelease];
        _sdkViewRecommend.left = 0;
        _sdkViewRecommend.top = kTitlePicOffset + kRecommendPicHeight;
        [self addSubview:_sdkViewRecommend];
    }
}

- (void)setSdkAdTextPic:(SNAdDataCarrier *)sdkAdTextPic {
    if (_sdkAdTextPic != sdkAdTextPic) {
        TT_RELEASE_SAFELY(_sdkAdTextPic);
        _sdkAdTextPic = [sdkAdTextPic retain];
    }
    
    if (_sdkViewTextPic) {
        [_sdkViewTextPic removeFromSuperview];
        _sdkViewTextPic = nil;
    }
    
    if (_sdkAdTextPic.dataState == SNAdDataStateReady) {
        _sdkViewTextPic = [[[SNNewsSdkAdPicTextView alloc] initWithAdDataCarrier:_sdkAdTextPic] autorelease];
        _sdkViewTextPic.left = 0;
        _sdkViewTextPic.bottom = self.height;
        [self addSubview:_sdkViewTextPic];
    }
}

- (void)setObject:(GalleryItem *)obj
{
    self.galleryItem = obj;
    self.selectionStyle     = UITableViewCellSelectionStyleNone;
    [self setBackgroundColor:[UIColor clearColor]];
    
    int itemIndex              = 0;
    
    //[self removeAllSubviews]; 
    [self removeAllRecommendView];
    
    for (RecommendGallery *photo in obj.moreRecommends)
    {
        CGRect rcRecommendFrame = CGRectMake(kTitleLeftOffset + kRecommendPicOffset * itemIndex + kRecommendPicWidth * itemIndex
                                            , kTitlePicOffset, kRecommendPicWidth, kRecommendPicHeight);
        SNPhotoListRecommendView *recommendItem  = [[SNPhotoListRecommendView alloc] initWithRecommendGallery:photo
                                                                                                        frame:rcRecommendFrame
                                                                                                     delegate:self];
        [recommendItem setTag:itemIndex + 100];
        [self addSubview:recommendItem];
        [recommendViewArray addObject:recommendItem];
        TT_RELEASE_SAFELY(recommendItem);
        if(++itemIndex >= kMaxRecommendCount)
        {
            break;
        }
    }
    
    [self loadRecommendInfo];
}

-(void)loadRecommendInfo
{
    int nIndex = 0;
    for (RecommendGallery *item in self.galleryItem.moreRecommends)
    {
        SNPhotoListRecommendView *recommendView = (SNPhotoListRecommendView*)[self viewWithTag:nIndex + 100];
        if (![recommendView isRecommendIconLoaded])
        {
            recommendView.urlPath = item.iconUrl;
        }
        
        if(++nIndex >= kMaxRecommendCount)
        {
            break;
        }
    }
}

-(void)clickRecommendPhoto:(id)sender
{
    SNPhotoListRecommendView *recommendView  = (SNPhotoListRecommendView*)sender;
    int nTag    = recommendView.tag;
    if (nTag < 100 || nTag >= 100 + [self.galleryItem.moreRecommends count])
    {
        SNDebugLog(@"clickRecommendPhoto : Invalid tag = %d",nTag);
        return;
    }
    
    if ([recommendView isRecommendIconLoaded])
    {
        if ([self.delegate respondsToSelector:@selector(openRecommendGallery:)])
        {
            RecommendGallery *recommendGallery  = [self.galleryItem.moreRecommends objectAtIndex:nTag - 100];
            [self.delegate performSelector:@selector(openRecommendGallery:) withObject:recommendGallery];
        }
    }
    else
    {
        RecommendGallery *recommendGallery  = [self.galleryItem.moreRecommends objectAtIndex:nTag - 100];
        
        [recommendView clickToLoadImage:recommendGallery.iconUrl];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_sepLineFromAdViews) {
        _sepLineFromAdViews = [[UIImageView alloc] initWithFrame:CGRectMake(10,
                                                                            0,
                                                                            self.width - 2 * 10,
                                                                            1)];
        
        _sepLineFromAdViews.image = [UIImage imageNamed:@"list_headline.png"];
        [self addSubview:_sepLineFromAdViews];
    }
    
    _sepLineFromAdViews.hidden = YES;
    
    _sdkViewTextPic.bottom = self.height;
    
    if ([recommendViewArray count] > 0) {
        if (_sdkViewRecommend) {
            _sdkViewRecommend.top = [(UIView *)recommendViewArray[0] bottom] + 12;
            _sepLineFromAdViews.bottom = _sdkViewRecommend.top;
            _sepLineFromAdViews.hidden = NO;
        }
        else if (_sdkViewTextPic) {
            _sepLineFromAdViews.bottom = _sdkViewTextPic.top;
            _sepLineFromAdViews.hidden = NO;
        }
    }
    else {
        _sdkViewRecommend.top = 0;
    }
}

- (void)onThemeChanged:(id)sender {
    if (_sepLineFromAdViews) {
        _sepLineFromAdViews.image = [UIImage imageNamed:@"list_headline.png"];
    }
}

@end
