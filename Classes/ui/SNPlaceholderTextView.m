//
//  SNPlaceholderTextView.m
//  sohunews
//
//  Created by 李 雪 on 11-8-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNPlaceholderTextView.h"
#import "UIFontAdditions.h"

@implementation SNPlaceholderTextView

@synthesize placeHolderLabel;
@synthesize placeholder;
@synthesize placeholderColor;

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
     placeholder = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,self.font.ttLineHeight)];
        placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
        placeHolderLabel.numberOfLines = 0;
        placeHolderLabel.font = self.font;
        placeHolderLabel.backgroundColor = [UIColor clearColor];
        placeHolderLabel.textColor = self.placeholderColor;
        placeHolderLabel.alpha = 1;
        placeHolderLabel.tag = 999;
        [self addSubview:placeHolderLabel];
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [SNNotificationManager addObserver:self 
												 selector:@selector(textChanged:) 
													 name:UITextViewTextDidChangeNotification 
												   object:nil];
    }
    return self;
}

- (void)setPlaceholder:(NSString *)aPlaceholder {
    if (placeholder != aPlaceholder) {
        placeholder = aPlaceholder;
    }

    self.placeHolderLabel.text = self.placeholder;
    [self setNeedsDisplay];
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
	
    if([[self text] length] == 0)
    {
        UIView *v = [self viewWithTag:999];
        [v setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
}

- (void)drawRect:(CGRect)rect
{
    //if( [[self placeholder] length] > 0 )
    //{
        if ( placeHolderLabel == nil )
        {
            placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,self.font.ttLineHeight)];
            placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            placeHolderLabel.numberOfLines = 0;
            placeHolderLabel.font = self.font;
            placeHolderLabel.backgroundColor = [UIColor clearColor];
            placeHolderLabel.textColor = self.placeholderColor;
            placeHolderLabel.alpha = 1;
            placeHolderLabel.tag = 999;
            [self addSubview:placeHolderLabel];
        }
		
        //[placeHolderLabel sizeToFit];
    //}
	
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
	
    [super drawRect:rect];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    placeHolderLabel.frame = CGRectMake(8,8,self.bounds.size.width - 16,self.font.ttLineHeight);
    placeHolderLabel.textColor = self.placeholderColor;
}

@end

