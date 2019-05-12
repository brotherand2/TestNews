//
//  SNTagTableViewController.m
//  sohunews
//
//  Created by ivan.qi on 3/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNTagPhotoTableViewController.h"
#import "SNTagPhotoDataSource.h"
#import "SNTagPhotoTableDelegate.h"
#import "SNTabBarItem.h"
#import "SNTagPhotoTableCell.h"


@implementation SNTagPhotoTableViewController

@synthesize delegate, targetType, typeId;// isViewReleased;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
    }
    return self;
}

- (void)createModel {
	SNTagPhotoDataSource *ds = [[SNTagPhotoDataSource alloc] init];
    ds.controller = self;
	self.dataSource = ds;
    [ds release];
}

- (id)createDelegate {
	SNTagPhotoTableDelegate *aDelegate = [[SNTagPhotoTableDelegate alloc] initWithController:self];
	return [aDelegate autorelease];
}

-(void)changeAllCellsItemStatus:(NSString *)aType strId:(NSString *)aId {
    for (id item in self.tableView.visibleCells) {
        SNTagPhotoTableCell *pcell = (SNTagPhotoTableCell *)item; 
        [pcell selectedButton:aType strId:aId];
    }
}

-(void)clickOnCategoryBtn:(CategoryItem *)aCategory {
    self.typeId = aCategory.categoryID;
    self.targetType = kGroupPhotoCategory;
    if (delegate && [delegate respondsToSelector:@selector(selectedCategory:)]) {
        [delegate selectedCategory:aCategory];
    }
}

-(void)clickOnTagBtn:(TagItem *)aTag {
    self.typeId = aTag.tagId;
    self.targetType = kGroupPhotoTag;
    if (delegate && [delegate respondsToSelector:@selector(selectedTag:)]) {
        [delegate selectedTag:aTag];
    }
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.bounces = YES;
	self.tableView.scrollsToTop = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)viewWillAppear:(BOOL)animated {
//    SNDebugLog(@"%d",_isViewReleased);
//    if (_isViewReleased) {
//        _isViewReleased = NO;
//        _flags.isViewInvalid = YES;
//        TT_RELEASE_SAFELY(_model);
//        TT_RELEASE_SAFELY(_tableDelegate);
//        TT_RELEASE_SAFELY(_dataSource);
//    }
    
    [super viewWillAppear:animated];
}

-(void)updateTheme {
    [self customerTableBg];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customerTableBg];
}

- (void)viewDidUnload {
    //_isViewReleased = YES;
    [super viewDidUnload];
}

-(void)reCreateModel {
    [self invalidateModel];
}

- (void)didShowModel:(BOOL)firstTime {
//    if (firstTime || isViewReleased) {
//        isViewReleased = NO;
//    }
    [self changeAllCellsItemStatus:self.targetType strId:self.typeId];
	[super didShowModel:firstTime];
}

//-(void)viewWillDisappear:(BOOL)animated {
//    [((SNPhotoModel *)self.dataSource.model) cancelAllRequest];
//}

-(void)dealloc {
    TT_RELEASE_SAFELY(typeId);
    TT_RELEASE_SAFELY(targetType);
    [super dealloc];
}


@end
