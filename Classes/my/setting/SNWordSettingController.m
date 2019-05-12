//
//  SNTypeFaceSettingController.m
//  sohunews
//
//  Created by wangxiang on 3/16/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNWordSettingController.h"

#import "UIColor+ColorUtils.h"
#import "SNHeadSelectView.h"
#import "SNToolbar.h"

@interface ImgViewIcon : UIImageView
@property (nonatomic,assign) int indextIcon;
@end

@implementation ImgViewIcon
@synthesize indextIcon;
@end

@interface SNWordSettingController()
@property (nonatomic, strong)NSArray *_aryImageIncon;
@property (nonatomic, strong)NSArray *_aryTitles;
@property (nonatomic,strong) UITableView *_tbView;
@property (nonatomic, assign) int _iRow;
- (void) loadReasoures;
@end

@implementation SNWordSettingController
@synthesize _aryImageIncon;
@synthesize _aryTitles;
@synthesize _tbView;
@synthesize _iRow;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

-(void)customerBg {
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self customerBg];
    
    [self loadReasoures];
    
    [self addHeaderView];
    
    [self addToolbar];
    
    [self.headerView setSections:[NSArray arrayWithObject:NSLocalizedString(@"worldSetting", @"")]];
    CGSize titleSize = [NSLocalizedString(@"worldSetting", @"") sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
}

- (void) loadReasoures{
    @autoreleasepool {
        self._iRow = -1;
        UITableView *tbView = [[UITableView alloc] initWithFrame:TTApplicationFrame() style:UITableViewStyleGrouped];
        tbView.backgroundColor = [UIColor clearColor];
        tbView.backgroundView = nil;
        if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
            tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
        else
            tbView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tbView.rowHeight = 46.0f;
        tbView.delegate = self;
        tbView.dataSource = self;
        
        UIColor *grayColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTableCellSeparatorColor1]];
        [tbView setSeparatorColor:grayColor];
        self._tbView = tbView;
        [self.view addSubview:tbView];
        tbView = nil;
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_logo_dark.png"]];
        [logo setFrame:CGRectMake((320-kAppLogoWidth/2)/2,-100, kAppLogoWidth/2, kAppLogoHeight/2)];
        [_tbView addSubview:logo];
         logo = nil;
        NSArray *aryTitles = [[NSArray  alloc] initWithObjects: NSLocalizedString(SN_String("MoreLargeFont"), @""),
                              NSLocalizedString(SN_String("LargeFont"), @""),
                              NSLocalizedString(SN_String("MediumFont"), @""),nil];
        self._aryTitles = aryTitles;
        aryTitles = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super  viewWillAppear:animated];

    @autoreleasepool {
        if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
        {
            CGRect screenFrame = TTApplicationFrame();
            
            UIImage *bg = [UIImage imageNamed:@"postTab0.png"];
            self._tbView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
            self._tbView.scrollIndicatorInsets = UIEdgeInsetsMake(10, 0, 0, 0);
            self._tbView.contentOffset = CGPointMake(0, -20);
            self._tbView.frame = CGRectMake(0, kHeaderTotalHeight-kHeadBottomHeight, screenFrame.size.width, screenFrame.size.height - kHeaderTotalHeight - bg.size.height + 15 - 44);
        }
        else
        {
            self._tbView.contentInset = UIEdgeInsetsMake(10 + kHeaderHeightWithoutBottom, 0.f, 0.f, 0.f);
            self._tbView.contentOffset = CGPointMake(0.f, -kHeaderHeightWithoutBottom);
            self._tbView.frame = CGRectMake(0, kHeadSelectViewBottom, kAppScreenWidth, kAppScreenHeight - kHeadSelectViewBottom - kToolbarViewTop);
        }
        
        
        NSString *savedFontClass = [SNUtility getNewsFontSizeClass];
        if ([savedFontClass isEqualToString:kWordMoreBig]) {
            self._iRow = 0;
        }
        else if ([savedFontClass isEqualToString:kWordBig]) {
            self._iRow = 1;
        }
        else if ([savedFontClass isEqualToString:kWordMiddle]){
            self._iRow = 2;
        }
        //    else if ([savedFontClass isEqualToString:kWordSmall]){
        //        self._iRow = 3;
        //    }
        [_tbView reloadData];
    }
}

#pragma mark -
#pragma mark TableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *RootCellIdentifier = @"cellIdentifier";
    UITableViewCell *myCell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:RootCellIdentifier];
    
    if (myCell == nil)
    {
        myCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                         reuseIdentifier:RootCellIdentifier];
//        if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
//            myCell.selectionStyle = UITableViewCellSelectionStyleNone;
//        else
//            myCell.selectionStyle = UITableViewCellSelectionStyleGray;
        myCell.selectionStyle = UITableViewCellSelectionStyleNone;
        myCell.backgroundColor = [UIColor  clearColor];
        
        NSString *fileName = @"pushOff.png";
        UIImage *img = [UIImage imageNamed:fileName];
        ImgViewIcon *imgView = [[ImgViewIcon alloc] initWithImage:img];
        imgView.frame = CGRectMake(myCell.contentView.frame.size.width-img.size.width -35,
                                (myCell.contentView.frame.size.height -img.size.height)/2+3,
                                img.size.width,
                                img.size.height);
        imgView.tag = 100;
        [myCell.contentView addSubview:imgView];
         imgView = nil;
    }
    ImgViewIcon *icon = (ImgViewIcon *)[myCell.contentView viewWithTag:100];
    icon.indextIcon =  (int)indexPath.row;
    
    NSString *strTitle = [_aryTitles objectAtIndex:indexPath.row];
    myCell.textLabel.backgroundColor = [UIColor clearColor];
    myCell.textLabel.textColor= SNUICOLOR(kThemeText1Color);
    myCell.textLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    myCell.textLabel.text = strTitle;
    if (self._iRow == icon.indextIcon) {
        icon.hidden = NO;
    }
    else{
         icon.hidden = YES;
    }
    return  myCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self._iRow = (int)indexPath.row;
    int fontSize = -1 ;
    switch (_iRow) {
        case 0:
            fontSize = 4;
            break;
        case 1:
            fontSize = 3;
            break;
        case 2:
        case 3:
            fontSize = 2;
            break;
        default:
            break;
    }

    [SNUtility setNewsFontSize:fontSize];
    
    [tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self._aryImageIncon = nil;
    self._aryTitles = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
