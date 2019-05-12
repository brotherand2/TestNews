//
//  SNPlaceholderTextView.h
//  sohunews
//
//  Created by 李 雪 on 11-8-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

@interface SNPlaceholderTextView : UITextView {
	NSString *placeholder;
    UIColor *placeholderColor;
	
@private
    UILabel *placeHolderLabel;
}

@property (nonatomic, strong) UILabel *placeHolderLabel;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end

