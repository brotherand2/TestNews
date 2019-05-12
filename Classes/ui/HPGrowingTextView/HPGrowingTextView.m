
//
//  HPTextView.m
//
//  Created by Hans Pinckaers on 29-06-10.
//
//	MIT License
//
//	Copyright (c) 2011 Hans Pinckaers
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

#import "HPGrowingTextView.h"
#import "HPTextViewInternal.h"
#import "SNEmoticonObject.h"

@interface HPGrowingTextView (private)
- (void)commonInitialiser;
- (void)resizeTextView:(NSInteger)newSizeH;
- (void)growDidStop;
@end

@implementation HPGrowingTextView
@synthesize internalTextView;
@synthesize delegate;

@synthesize font;
@synthesize textColor;
@synthesize textAlignment;
@synthesize selectedRange;
@synthesize editable;
@synthesize dataDetectorTypes;
@synthesize animateHeightChange;
@synthesize returnKeyType;

@synthesize lastSelectedRange;

// having initwithcoder allows us to use HPGrowingTextView in a Nib. -- aob, 9/2011
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self commonInitialiser];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self commonInitialiser];
    }
    return self;
}

- (void)commonInitialiser
{
    // Initialization code
    CGRect r = self.frame;
    r.origin.y = 0;
    r.origin.x = 0;
    internalTextView = [[HPTextViewInternal alloc] initWithFrame:r];
    internalTextView.delegate = self;
    internalTextView.scrollEnabled = YES;
    internalTextView.font = [UIFont systemFontOfSize:self.font.lineHeight];
    internalTextView.contentInset = UIEdgeInsetsZero;
    internalTextView.showsHorizontalScrollIndicator = NO;
    internalTextView.text = @"-";
    [self addSubview:internalTextView];

    UIView *internal = (UIView *)[[internalTextView subviews] objectAtIndex:0];
    minHeight = internal.frame.size.height;
    minNumberOfLines = 1;

    animateHeightChange = YES;

    internalTextView.text = @"";
    
    [self setMaxNumberOfLines:3];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];
    [pan release];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(emoticonSelect:)
                                  name:notificationSmallEmoticonSelect
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(emoticonDelete:)
                                  name:notificationEmoticonDelete
                                object:nil];
}

- (void)sizeToFit
{
    CGRect r = self.frame;
    {
        float oldHeight = r.size.height;
        
        if (oldHeight != minHeight)
        {
            if ([delegate respondsToSelector:@selector(growingTextView:willChangeHeight:)])
            {
                [delegate growingTextView:self willChangeHeight:minHeight];
            }
        }
        
        r.size.height = minHeight;
        self.frame = r;
        
        if (oldHeight != minHeight)
        {
            if ([delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)])
            {
                [delegate growingTextView:self didChangeHeight:minHeight];
            }
        }
    }
}

- (void)setFrame:(CGRect)aframe
{
    [super setFrame:aframe];
    
    internalTextView.frame = UIEdgeInsetsInsetRect(self.bounds, contentInset);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self performSelector:@selector(textViewDidChange:) withObject:internalTextView];
}

- (void)setContentInset:(UIEdgeInsets)inset
{
    contentInset = inset;

    internalTextView.frame = UIEdgeInsetsInsetRect(self.bounds, contentInset);
    
    [self setMaxNumberOfLines:maxNumberOfLines];
    [self setMinNumberOfLines:minNumberOfLines];
}

- (UIEdgeInsets)contentInset
{
    return contentInset;
}

- (void)setMaxNumberOfLines:(int)n
{
    // Use internalTextView for height calculations, thanks to Gwynne <http://blog.darkrainfall.org/>
//    NSString *saveText = internalTextView.text, *newText = @"-";

//    internalTextView.delegate = nil;
//    internalTextView.hidden = YES;

//    for (int i = 1; i < n; ++i)
//    {
//        newText = [newText stringByAppendingString:@"\n|W|"];
//    }
//
//    internalTextView.text = newText;
//
//    maxHeight = internalTextView.contentSize.height;

//    internalTextView.text = saveText;
//    internalTextView.hidden = NO;
//    internalTextView.delegate = self;
    float curMaxHeight = (internalTextView.font.lineHeight + 10) * n;
    CGSize size = internalTextView.contentSize;
    size.height = curMaxHeight;
    internalTextView.contentSize = size;
    maxHeight = curMaxHeight;
    
    [self sizeToFit];

    maxNumberOfLines = n;
}

- (int)maxNumberOfLines
{
    return maxNumberOfLines;
}

- (void)setMinNumberOfLines:(int)m
{
    float curMaxHeight = (internalTextView.font.lineHeight + 10) * m;
    CGSize size = internalTextView.contentSize;
    size.height = curMaxHeight;
    internalTextView.contentSize = size;
    minHeight = curMaxHeight;

    [self sizeToFit];

    minNumberOfLines = m;
}

- (int)minNumberOfLines
{
    return minNumberOfLines;
}

- (int)numberOfLines
{
	return (int)floor(internalTextView.contentSize.height / internalTextView.font.lineHeight);
}

- (void)textViewDidChange:(UITextView *)textView
{
    //size of content, so we can set the frame of self
    NSInteger newSizeH = internalTextView.contentSize.height;
    
    if (newSizeH < minHeight || !internalTextView.hasText)
    {
        newSizeH = minHeight;                                               //not smalles than minHeight
    }
    
    if (internalTextView.frame.size.height > maxHeight)
    {
        newSizeH = maxHeight;                                               // not taller than maxHeight
    }
    
    if (internalTextView.frame.size.height != newSizeH)
    {
        // [fixed] Pasting too much text into the view failed to fire the height change,
        // thanks to Gwynne <http://blog.darkrainfall.org/>

        if (newSizeH > maxHeight && internalTextView.frame.size.height <= maxHeight)
        {
            newSizeH = maxHeight;
        }

        if (newSizeH <= maxHeight)
        {
            if (animateHeightChange)
            {
                if ([UIView resolveClassMethod:@selector(animateWithDuration:animations:)])
                {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
                    [UIView animateWithDuration:0.1f
                                          delay:0
                                        options:(UIViewAnimationOptionAllowUserInteraction |
                              UIViewAnimationOptionBeginFromCurrentState)
                                     animations:^(void) {
                         [self resizeTextView:newSizeH];
                     }
                                     completion:^(BOOL finished) {
                         if ([delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)])
                         {
                             [delegate growingTextView:self didChangeHeight:newSizeH];
                         }
                     }
                    ];
#endif /* if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */
                }
                else
                {
                    [UIView beginAnimations:@"" context:nil];
                    [UIView setAnimationDuration:0.1f];
                    [UIView setAnimationDelegate:self];
                    [UIView setAnimationDidStopSelector:@selector(growDidStop)];
                    [UIView setAnimationBeginsFromCurrentState:YES];
                    [self resizeTextView:newSizeH];
                    [UIView commitAnimations];
                }
            }
            else
            {
                [self resizeTextView:newSizeH];
                // [fixed] The growingTextView:didChangeHeight: delegate method was not called at all when not animating height changes.
                // thanks to Gwynne <http://blog.darkrainfall.org/>

                if ([delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)])
                {
                    [delegate growingTextView:self didChangeHeight:newSizeH];
                }
            }
        }


        // if our new height is greater than the maxHeight
        // sets not set the height or move things
        // around and enable scrolling
        if (newSizeH >= maxHeight)
        {
            if (!internalTextView.scrollEnabled)
            {
                internalTextView.scrollEnabled = YES;
                [internalTextView flashScrollIndicators];
            }
        }
        else
        {
            internalTextView.scrollEnabled = NO;
        }
    }


    if ([delegate respondsToSelector:@selector(growingTextViewDidChange:)])
    {
        [delegate growingTextViewDidChange:self];
    }
}

- (void)resizeTextView:(NSInteger)newSizeH
{
    CGFloat newHeight = newSizeH + contentInset.top + contentInset.bottom;
    
    if ([delegate respondsToSelector:@selector(growingTextView:willChangeHeight:)])
    {
        [delegate growingTextView:self willChangeHeight:newHeight];
    }
    
    CGRect frame = self.frame;
    frame.size.height = newHeight;
    self.frame = frame;
}

- (void)growDidStop
{
    if ([delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)])
    {
        [delegate growingTextView:self didChangeHeight:self.frame.size.height];
    }
}

- (NSRange)lastSelectedRange
{
	if (lastSelectedRange.location == NSNotFound || 
		lastSelectedRange.location + lastSelectedRange.length > [self.text length])
	{
		lastSelectedRange = NSMakeRange([self.text length], 0);
	}
	
	return lastSelectedRange;
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    return [self.internalTextView becomeFirstResponder];
//    return YES;
}

- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    return [internalTextView resignFirstResponder];
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
    [internalTextView release];
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextView properties
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setText:(NSString *)newText
{
    internalTextView.text = newText;

    // include this line to analyze the height of the textview.
    // fix from Ankit Thakur
    [self performSelector:@selector(textViewDidChange:) withObject:internalTextView];
}

- (NSString *)text
{
    return internalTextView.text;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setFont:(UIFont *)afont
{
    internalTextView.font = afont;

    [self setMaxNumberOfLines:maxNumberOfLines];
    [self setMinNumberOfLines:minNumberOfLines];
}

- (UIFont *)font
{
    return internalTextView.font;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setTextColor:(UIColor *)color
{
    internalTextView.textColor = color;
}

- (UIColor *)textColor
{
    return internalTextView.textColor;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setTextAlignment:(UITextAlignment)aligment
{
    internalTextView.textAlignment = aligment;
}

- (UITextAlignment)textAlignment
{
    return internalTextView.textAlignment;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setSelectedRange:(NSRange)range
{
    internalTextView.selectedRange = range;
}

- (NSRange)selectedRange
{
    return internalTextView.selectedRange;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setEditable:(BOOL)beditable
{
    internalTextView.editable = beditable;
}

- (BOOL)isEditable
{
    return internalTextView.editable;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setReturnKeyType:(UIReturnKeyType)keyType
{
    internalTextView.returnKeyType = keyType;
}

- (UIReturnKeyType)returnKeyType
{
    return internalTextView.returnKeyType;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setDataDetectorTypes:(UIDataDetectorTypes)datadetector
{
    internalTextView.dataDetectorTypes = datadetector;
}

- (UIDataDetectorTypes)dataDetectorTypes
{
    return internalTextView.dataDetectorTypes;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)hasText
{
    return [internalTextView hasText];
}

- (void)scrollRangeToVisible:(NSRange)range
{
    [internalTextView scrollRangeToVisible:range];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([delegate respondsToSelector:@selector(growingTextViewShouldBeginEditing:)])
    {
        return [delegate growingTextViewShouldBeginEditing:self];
    }
    else
    {
        return YES;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	lastSelectedRange = textView.selectedRange;
	
    if ([delegate respondsToSelector:@selector(growingTextViewShouldEndEditing:)])
    {
        return [delegate growingTextViewShouldEndEditing:self];
    }
    else
    {
        return YES;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([delegate respondsToSelector:@selector(growingTextViewDidBeginEditing:)])
    {
        [delegate growingTextViewDidBeginEditing:self];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([delegate respondsToSelector:@selector(growingTextViewDidEndEditing:)])
    {
        [delegate growingTextViewDidEndEditing:self];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
   replacementText:(NSString *)atext
{
    if ([atext isEqualToString:@""])
    {
        BOOL shouldBackspace = YES;
        
        if ([delegate respondsToSelector:@selector(growingTextViewShouldBackspace:)])
        {
            shouldBackspace = [delegate growingTextViewShouldBackspace:self];
        }
        
        if (![textView hasText])
        {
            // weird 1 pixel bug when clicking backspace when textView is empty.
            return NO;
        }
        else
        {
            return shouldBackspace;
        }
    }
    
    if ([atext isEqualToString:@"\n"])
    {
        if ([delegate respondsToSelector:@selector(growingTextViewShouldReturn:)])
        {
            if (![delegate performSelector:@selector(growingTextViewShouldReturn:) withObject:self])
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
    }
    
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChangeSelection:(UITextView *)textView
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (delegate && [delegate respondsToSelector:@selector(textViewDidChangeSelection)]) {
        [delegate performSelector:@selector(textViewDidChangeSelection)];
    }
#pragma clang diagnostic pop

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.internalTextView.dragging)
    {
        if (delegate && [delegate respondsToSelector:@selector(growingTextViewDidScroll)])
        {
            [delegate performSelector:@selector(growingTextViewDidScroll)];
        }
    }
}

// called on start of dragging (may require some time and or distance to move)fdsa
- (void)handlePan:(UIPanGestureRecognizer*)tap
{
    if (delegate && [delegate respondsToSelector:@selector(growingTextViewDidScroll)])
    {
        [delegate performSelector:@selector(growingTextViewDidScroll)];
    }
}

#pragma mark- emoticonFunction
#pragma mark- emoticonFuntion
- (void)emoticonSelect:(NSNotification *)notification
{
    SNEmoticonObject *obj = (SNEmoticonObject *)[notification object];
    NSRange selectRange = self.internalTextView.selectedRange;
    
    NSMutableString *currentText = [NSMutableString stringWithString:self.text];
    [currentText insertString:obj.chineseName atIndex:selectRange.location];
    
    self.text = currentText;
}

- (void)emoticonDelete:(NSNotification *)notification
{
    NSRange selectRange = self.internalTextView.selectedRange;
    if (selectRange.location > 0) {
        NSRange deleteRange = NSMakeRange(selectRange.location - 1, 1);
        NSMutableString *currentText = [NSMutableString stringWithString:self.text];
        
        if ([[self.text substringWithRange:deleteRange] isEqualToString:@"]"]) {
            NSString *subtext = [self.text substringToIndex:deleteRange.location];
            if (subtext.length > 0) {
                [self deleteEmoticonStringInRange:currentText range:deleteRange];
            }
        }
        else {
            [currentText deleteCharactersInRange:deleteRange];
            self.text = currentText;
        }
    }
}

- (void)deleteEmoticonStringInRange:(NSMutableString *)currentText range:(NSRange)range
{
    NSString *subtext = [self.text substringToIndex:range.location];
    if (subtext.length > 0) {
        NSInteger index = subtext.length - 1;
        for (; index >= 0; index--) {
            NSString *subChar = [currentText substringWithRange:NSMakeRange(index, 1)];
            if ([subChar isEqualToString:@"["]) {
                break;
            }
        }
        NSRange deleteRange = NSMakeRange(index, range.location - index + 1);
        if (deleteRange.location + deleteRange.length <= currentText.length) {
            [currentText deleteCharactersInRange:deleteRange];
            self.text = currentText;
        }
    }
}


@end
