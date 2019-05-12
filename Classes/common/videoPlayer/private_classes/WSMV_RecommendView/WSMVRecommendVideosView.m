//
//  WSRecommendVideosView.m
//  WeSee
//
//  Created by handy wang on 9/11/13.
//  Copyright (c) 2013 handy. All rights reserved.
//  全屏播放时，点右上角按钮出来的推荐视频列表
//

#import "WSMVRecommendVideosView.h"
#import "UIViewAdditions+WSMV.h"
#import "WSMVUtility.h"
#import "SNVideoObjects.h"

#define kRecommendEmptyNoticeViewWidth     (152.f/2.f)
#define kRecommendEmptyNoticeViewHeight    (152.f/2.f)
#define kRecommendEmptyNoticeLabelHeight   (18.f)

@interface WSMVRecommendVideosView()
{
    UIView *_emptyNoticeView;
}
@property (nonatomic, strong)UITableView *tableView;
@end

@implementation WSMVRecommendVideosView

#pragma mark - Lifecycle
- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [self addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
        self.recommendVideos = [NSMutableArray array];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //TableView
    if (!(self.tableView)) {
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.left = self.width-kWSMVRecommendVideoTableViewWidth;
        self.tableView.width = kWSMVRecommendVideoTableViewWidth;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundView = [[UIView alloc] init];
        self.tableView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
        self.tableView.backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.scrollsToTop = NO;
        [self addSubview:self.tableView];
    }
    if (self.recommendVideos.count <= 0 && [self.delegate respondsToSelector:@selector(recommendVideos:)]) {
        NSArray *_tmpRecommendVideos = [self.delegate recommendVideos:NO];
        if (_tmpRecommendVideos.count > 0) {
            [self.recommendVideos addObjectsFromArray:_tmpRecommendVideos];
        }
    }
    
    if (!_emptyNoticeView)
    {
        _emptyNoticeView = [[UIView alloc] initWithFrame:self.tableView.frame];
        _emptyNoticeView.backgroundColor = [UIColor clearColor];
        [self addSubview:_emptyNoticeView];
        UIImageView *emptyImageView = [[UIImageView alloc] initWithFrame:CGRectMake((_emptyNoticeView.width - kRecommendEmptyNoticeViewWidth)/2.f, (_emptyNoticeView.height - kRecommendEmptyNoticeViewHeight)/2.f - 20.f, kRecommendEmptyNoticeViewWidth, kRecommendEmptyNoticeViewHeight)];
        emptyImageView.image = [UIImage imageNamed:@"wsmv_recommendViewEmpty_fullscreen.png"];
        [_emptyNoticeView addSubview:emptyImageView];
        
        UILabel *noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, emptyImageView.bottom + 20.f, _emptyNoticeView.width, kRecommendEmptyNoticeLabelHeight)];
        noticeLabel.textColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:.4f];
        noticeLabel.text = @"暂时没有相关视频";
        noticeLabel.backgroundColor = [UIColor clearColor];
        noticeLabel.textAlignment = NSTextAlignmentCenter;
        [_emptyNoticeView addSubview:noticeLabel];
    }
}

- (void)dealloc {
    _emptyNoticeView = nil;
}

#pragma mark - Public
- (void)refreshEmptyNoticeIfNeed
{
    _tableView.left = self.width-kWSMVRecommendVideoTableViewWidth;
    _tableView.height = self.height;
    if (self.recommendVideos.count == 0)
    {
        _emptyNoticeView.hidden = NO;
    }
    else
    {
        _emptyNoticeView.hidden = YES;
    }
}

- (void)appendRecommendVideos:(NSArray *)recommendVideos {
    if (recommendVideos.count > 0) {
        [self.recommendVideos addObjectsFromArray:recommendVideos];
        [self reloadData];
    }
}

- (void)replaceAllRecommendVieos:(NSArray *)videos {
    [self.recommendVideos removeAllObjects];
    if (videos.count > 0) {
        [self.recommendVideos addObjectsFromArray:videos];
    }
    [self reloadData];
}

- (void)clearRecommendVideos {
    [self.recommendVideos removeAllObjects];
    [self reloadData];
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)dismissIfNeeded {
    if (self.alpha != 0) {
        [self dismissSelf];
    }
}

#pragma mark - Private
- (void)dismissSelf {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if ([_delegate respondsToSelector:@selector(didHideRecommendVideosView)]) {
            [_delegate didHideRecommendVideosView];
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return self.recommendVideos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *_cellIdentifier = @"RecommendVideoCell";
    
    WSRecommendVideoCell *_cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    if (!_cell) {
        _cell = [[WSRecommendVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellIdentifier];
        _cell.width = self.tableView.width;
    }
    
    SNVideoData *_video = [self.recommendVideos objectAtIndex:indexPath.row];
    NSString *_playingVID = nil;
    if ([_delegate respondsToSelector:@selector(playingVID)]) {
        _playingVID = [_delegate playingVID];
    }
    [_cell setData:_video playingVID:_playingVID];
    
    return _cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ((SNVideoData *)[self.recommendVideos objectAtIndex:indexPath.row]).recommendCellHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //显示最后一行时加载更多
    if (indexPath.row == (self.recommendVideos.count-1)) {
        if ([self.delegate respondsToSelector:@selector(recommendVideos:)]) {
            NSArray *_tmpRecommendVideos = [self.delegate recommendVideos:YES];
            if (_tmpRecommendVideos.count > 0) {
                [self.recommendVideos addObjectsFromArray:_tmpRecommendVideos];
                [self reloadData];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WSRecommendVideoCell *_selectedCell = (WSRecommendVideoCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    for (WSRecommendVideoCell *_cell in tableView.visibleCells) {
        if (_selectedCell.data.vid.length > 0 && [_cell.data.vid isEqualToString:_selectedCell.data.vid]) {
            [_cell setSelected];
        }
        else {
            [_cell setUnselected];
        }
    }
    
    
    [self dismissSelf];
    if ([_delegate respondsToSelector:@selector(switchToPlayRecommendVideo:inRecommendVideos:)]) {
        [_delegate switchToPlayRecommendVideo:[self.recommendVideos objectAtIndex:indexPath.row] inRecommendVideos:self.recommendVideos];
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define WSMVRecommendVideoCellSeparatorLineHeight                                   (2.0f/2.0f)

@interface WSRecommendVideoCell()
@property (nonatomic, strong)UILabel            *headlineLabel;
@property (nonatomic, strong)UIImageView        *separatorLine;
@end

@implementation WSRecommendVideoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


#pragma mark - Public
- (void)setData:(SNVideoData *)data playingVID:(NSString *)playingVID {
    if (_data != data) {
        _data = nil;
        _data = data;
        
        [self updateUI];
    }
    
    if (self.data.vid.length > 0 && [self.data.vid isEqualToString:playingVID]) {
        [self setSelected];
    }
    else {
        [self setUnselected];
    }
}

#pragma mark - Private
- (void)updateUI {
    if (!(self.headlineLabel)) {
        
        CGFloat headlineLabelWidth = self.width-kWSMVRecommendVideoCellHeadlineLabelMarginLeft
        -kWSMVRecommendVideoCellHeadlineLabelMarginRight;
        if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            headlineLabelWidth -= 20;
        }
        CGRect _headlineLabelFrame = CGRectMake(kWSMVRecommendVideoCellHeadlineLabelMarginLeft,
                                                    kWSMVRecommendVideoCellHeadlineLabelMarginTop,
                                                headlineLabelWidth,
                                                self.contentView.height-kWSMVRecommendVideoCellHeadlineLabelMarginTop
                                                    -kWSMVRecommendVideoCellHeadlineLabelMarginBottom);
        self.headlineLabel = [[UILabel alloc] initWithFrame:_headlineLabelFrame];
        self.headlineLabel.numberOfLines = 2;
        //self.headlineLabel.tag = 999;
        self.headlineLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.headlineLabel.backgroundColor = [UIColor clearColor];
        self.headlineLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        self.headlineLabel.font = [UIFont systemFontOfSize:kWSMVRecommendVideoCellHeadlineLabelFontSize];
        [self.contentView addSubview:self.headlineLabel];
    }
    self.headlineLabel.text = self.data.title;
    self.headlineLabel.height = self.data.recommendCellHeight-kWSMVRecommendVideoCellHeadlineLabelMarginTop-kWSMVRecommendVideoCellHeadlineLabelMarginBottom;
    
    if (!(self.separatorLine)) {
        CGRect _separatorLineFrame = CGRectMake(kWSMVRecommendVideoCellHeadlineLabelMarginLeft,
                                                self.contentView.height-WSMVRecommendVideoCellSeparatorLineHeight,
                                                self.headlineLabel.width,
                                                WSMVRecommendVideoCellSeparatorLineHeight);
        self.separatorLine = [[UIImageView alloc] initWithFrame:_separatorLineFrame];
        self.separatorLine.image = [UIImage imageNamed:@"wsmv_recommendvideocell_separator.png"];
        [self.contentView addSubview:self.separatorLine];
    }
    self.separatorLine.top = self.data.recommendCellHeight-WSMVRecommendVideoCellSeparatorLineHeight;
}

- (void)setSelected {
    self.contentView.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.4f];
    self.headlineLabel.textColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:1.f];

}

- (void)setUnselected {
    self.contentView.backgroundColor = [UIColor clearColor];
    self.headlineLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
}

@end
