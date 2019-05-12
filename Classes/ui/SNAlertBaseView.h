//
//  SNAlertBaseView.h
//  sohunews
//
//  Created by Dan on 7/29/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SNAlertBaseView : UIAlertView {
    
	NSString *_title;
	NSString *_message;
	NSString *_cancelButtonTitle;
	NSString *_otherButtonTitle;
	id <UIAlertViewDelegate> _alertDelegate;
    
    id _snAlertUserData;
}

@property(nonatomic,strong) id snAlertUserData;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<UIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;


@end
