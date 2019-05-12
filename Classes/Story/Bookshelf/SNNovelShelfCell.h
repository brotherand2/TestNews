//
//  SNNovelShelfCell.h
//  sohunews
//
//  Created by qz on 16/04/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNNovelShelfCell : UITableViewCell

@property (nonatomic, weak) id sourceController;

-(void)updateView:(NSArray *)array isEdit:(BOOL)isEditing indexPath:(NSIndexPath *)indexPath;

@end
