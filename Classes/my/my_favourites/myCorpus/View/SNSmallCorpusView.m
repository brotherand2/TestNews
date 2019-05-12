//
//  SNSmallCorpusView.m
//  sohunews
//
//  Created by Scarlett on 15/9/2.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNSmallCorpusView.h"
#import "SNSmallCorpusTableViewCell.h"

@interface SNSmallCorpusView ()<UITableViewDelegate, UITableViewDataSource>{
    BOOL _isMove;
}

@property (nonatomic, strong)UITableView *corpusTableView;
@property (nonatomic, strong)NSMutableArray *corpusTextArray;
@property (nonatomic, strong)NSMutableArray *corpusIDArray;
@property (nonatomic,   copy)NSString *corpusName;

@end

@implementation SNSmallCorpusView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _corpusTextArray = [[NSMutableArray alloc] init];
        _corpusIDArray = [[NSMutableArray alloc] init];
        if (!_corpusTableView) {
            _corpusTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 8.0f, kAppScreenWidth, frame.size.height - 8.0f) style:UITableViewStylePlain];
            _corpusTableView.bounces = NO;
            if (_corpusTableView.height > 4 * kSmallCorpusTabelCellHeight + 8.0f * 2) {
                _corpusTableView.bounces = YES;
            }
            _corpusTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            _corpusTableView.separatorColor = [UIColor clearColor];
            _corpusTableView.backgroundColor = [UIColor clearColor];
            _corpusTableView.scrollsToTop = YES;
            [self addSubview:_corpusTableView];
            _corpusTableView.delegate = self;
            _corpusTableView.dataSource = self;
        }
    }
    return self;
}


- (void)setInfoWithCorpusName:(NSString *)corpusName isMove:(BOOL)isMove {
    self.corpusName = corpusName;
    _isMove = isMove;

    [self getCorpusList];
}

- (void)getCorpusList {
    
    if ([self.corpusListArray count] > 0) {
        if (_isMove) {
            self.corpusTextArray = [NSMutableArray arrayWithObjects:kCorpusNewFavourite, nil];
        }
        else {
            self.corpusTextArray = [NSMutableArray arrayWithObjects:kCorpusNewFavourite, kCorpusMyFavourite, nil];
        }
        NSDictionary *dictCorpus = nil;
        [self.corpusIDArray removeAllObjects];
        for (int i = 0; i < [self.corpusListArray count]; i++) {
            dictCorpus = [self.corpusListArray objectAtIndex:i];
            NSString *corpusName = [dictCorpus objectForKey:kCorpusFolderName];
            if (![corpusName isEqualToString:self.corpusName]) {
                [self.corpusTextArray addObject:corpusName];
                NSString *idString = [dictCorpus stringValueForKey:kCorpusID defaultValue:@""];
                [self.corpusIDArray addObject:idString];

            }
        }
        [_corpusTableView reloadData];
    }

}

#pragma mark UITableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kSmallCorpusTabelCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.corpusTextArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SNSmallCorpusTableViewCell *cell = nil;
    NSInteger row = [indexPath row];
    static NSString * cellIdentifier = @"smallCorpusCellIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SNSmallCorpusTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *imageName = nil;
    if (_isMove) {
        if (row > 0 && [self.corpusIDArray count] > 0) {
            NSInteger remainder = (row-1)%kCorpusCount;
            imageName = [NSString stringWithFormat:@"ico_sfile%zd_v5.png",remainder + 1];
        }
        else {
            if (row == 0) {
                imageName = @"ico_xinjian_v5.png";
            }
        }
    }
    else {
        if (row > 1 && [self.corpusIDArray count] > 0) {
            NSInteger remainder = (row-2)%kCorpusCount;
            imageName = [NSString stringWithFormat:@"ico_sfile%zd_v5.png",remainder + 1];
        }
        else {
            if (row == 0) {
                imageName = @"ico_xinjian_v5.png";
            }
            else if (row == 1) {
                imageName = @"ico_sshouchang_v5.png";
            }
        }
    }
    
    
    [cell setCellWithText:[self.corpusTextArray objectAtIndex:row] imageName:imageName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    NSInteger row = [indexPath row];
    NSString *corpusID = nil;

    if (row == 0) {//打开新建收藏夹，并保存到新建的收藏夹
        if ([self.delegate respondsToSelector:@selector(corpusAlertDismiss)]) {
            [self.delegate corpusAlertDismiss];
        }
        NSValue* method = [NSValue valueWithPointer:@selector(clickSmallItemDelegate:)];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kIsFromCorpusListCreat, [NSNumber numberWithBool:_isMove], kIsMoveCorpusList, self.delegate, @"delegate", method, @"method", nil];
        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://creatCorpus"] applyAnimated:YES] applyQuery:dict];
        [[TTNavigator navigator] openURLAction:_urlAction];
       
        return;
    }
    else if (row != 1){
        if ([self.corpusIDArray count] > 0) {
            corpusID = [self.corpusIDArray objectAtIndex:row-2];
        }
    }
    
    if (_isMove && row !=0) {
        corpusID = [self.corpusIDArray objectAtIndex:row-1];
    }
    
    //corpusID为空，保存到我的收藏，否则保存到对应收藏夹一份
    if (!corpusID) {
        corpusID = @"0";
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
    [dict setValue:corpusID forKey:kCorpusID];
    [dict setValue:[self.corpusTextArray objectAtIndex:row] forKey:kCorpusFolderName];
    [dict setValue:[NSNumber numberWithBool:_isMove] forKey:kIsMoveCorpusList];

    if ([self.delegate respondsToSelector:@selector(clickSmallItemDelegate:)]) {
        
        [self.delegate clickSmallItemDelegate:dict];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

@end
