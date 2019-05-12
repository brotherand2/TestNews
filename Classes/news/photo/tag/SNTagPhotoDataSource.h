//
//  SNTagDataSource.h
//  sohunews
//
//  Created by ivan on 3/12/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNTagPhotoModel.h"
#import "SNTagPhotoTableViewController.h"

@interface SNTagPhotoDataSource : TTListDataSource {
    SNTagPhotoModel *tagModel;
    SNTagPhotoTableViewController *__weak controller;
}

@property(nonatomic, strong)SNTagPhotoModel *tagModel;
@property(nonatomic, weak)SNTagPhotoTableViewController *controller;

@end
