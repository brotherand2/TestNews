//
//  SNFollowedViewController.m
//  sohunews
//
//  Created by weibin cheng on 13-12-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNFollowedViewController.h"
#import "SNBubbleBadgeObject.h"
#import "SNFollowCell.h"

@interface SNFollowedViewController ()

@end

@implementation SNFollowedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [SNNotificationManager addObserver:self selector:@selector(updateTheme:) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    _model.isFollowing = NO;
//    [self.headerView setSections:[NSArray arrayWithObjects:@"粉丝", nil]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)loadView
{
    [super loadView];
    _model.isFollowing = NO;
    [self.headerView setSections:[NSArray arrayWithObjects:@"粉丝", nil]];
}
-(void)showEmptyView
{
    if(!_emptyView)
    {
        UIImage* image = [UIImage themeImageNamed:@"circle_no_followed.png"];
        _emptyView = [[UIImageView alloc] initWithImage:image];
        _emptyView.left = (_tableView.width - image.size.width)/2;
        _emptyView.top = (_tableView.height - image.size.height)/2;
        _emptyView.size = image.size;
        [_tableView addSubview:_emptyView];
    }
    _emptyView.hidden = NO;
}
-(void)updateEmptyView
{
    if(_emptyView)
        _emptyView.image = [UIImage themeImageNamed:@"circle_no_followed.png"];
}
-(UITableViewCell*)createNoMoreCell
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nomorecell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImage* image = [UIImage themeImageNamed:@"circle_no_followed_more.png"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, kAppScreenWidth, image.size.height);
    [cell.contentView addSubview:imageView];
    return cell;
}
-(CGFloat)noMoreCellHeight
{
    UIImage* image = [UIImage themeImageNamed:@"circle_no_followed_more.png"];
    return image.size.height;
}
-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath.row < _model.userArray.count)
    {
        NSString *cellIdentifier = @"userCell";
        SNFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell)
            cell = [[SNFollowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        SNUserinfoEx *user = [_model.userArray objectAtIndex:indexPath.row];
        [cell reuseWithUser2:user cellIndexPath:indexPath];
        return cell;
    }
    else
    {
        return [self createNoMoreCell];
    }
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath.row < [_model.userArray count])
    {
        SNUserinfoEx* userinfo = (SNUserinfoEx*)[_model.userArray objectAtIndex:indexPath.row];
        if(![userinfo isKindOfClass:[SNUserinfoEx class]] || userinfo.pid.length==0)
            return;
        
        TTURLAction* urlAction = [[[TTURLAction actionWithURLPath:@"tt://userCenter"] applyQuery:@{@"pid" : userinfo.pid}] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}

-(void)requestUserModelDidFinish:(BOOL)hasMore
{
    [super requestUserModelDidFinish:hasMore];
    [[SNBubbleNumberManager shareInstance] resetFollowed];
    if(_model.userArray.count <= 0)
        [self showEmptyView];
    else
        [self hideEmptyView];
}

- (void)updateTheme:(NSNotification *)notifiction {
    [super updateTheme:notifiction];
    [_tableView reloadData];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end
