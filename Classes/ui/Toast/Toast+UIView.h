/***************************************************************************
 
Toast+UIView.h
Toast
Version 2.0

Copyright (c) 2013 Charles Scalesse.
 
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:
 
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
***************************************************************************/


#import <Foundation/Foundation.h>

#define TOAST_CLOSE_BUTTON 901

@interface UIView (Toast)

- (void)makeToast:(NSString *)message image:(UIImage *)image duration:(CGFloat)interval position:(id)position;
- (void)makeToast:(NSString *)message action:(NSString *)actionURL userInfo:(NSDictionary *)userInfo
       forFullScreen:(BOOL)fullScreen duration:(CGFloat)interval position:(id)position;
- (void)makeToast:(NSString *)message image:(UIImage *)image duration:(CGFloat)interval position:(id)position arrowXPosition:(CGFloat)xPos;
- (void)closeToast;

- (void)makeActivityToast:(NSString *)message position:(id)position;
- (void)hideActivityToast;

//- (void)makeToastActivity;
//- (void)makeToastActivity:(id)position;

- (void)showToast:(UIView *)toast duration:(CGFloat)interval position:(id)point rightIcon:(NSString *)iconname;
- (void)showActivityToast:(UIView *)toast position:(id)point;
- (void)hideToastAnimation;

+ (UIView *)viewForMessage:(NSString *)message image:(UIImage *)image activity:(BOOL)showActivity;

@end
