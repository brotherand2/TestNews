#import <UIKit/UIKit.h>

typedef enum SNActivityIndicatorDirection
{
    SNActivityIndicatorDirectionClockwise = -1,
    SNActivityIndicatorDirectionCounterClockwise = 1
} SNActivityIndicatorDirection;

@interface SNActivityIndicatorView : UIView
{
    NSUInteger      _steps;
    CGFloat         _stepDuration;
    BOOL            _isAnimating;
    
    UIColor                         *_color;
    BOOL                            _hidesWhenStopped;
    UIRectCorner                    _roundedCoreners;
    CGSize                          _cornerRadii;
    CGSize                          _finSize;
    SNActivityIndicatorDirection    _direction;
    UIActivityIndicatorViewStyle    _actualActivityIndicatorViewStyle;
}

@property (nonatomic) NSUInteger                    steps;
@property (nonatomic) NSUInteger                    indicatorRadius;
@property (nonatomic) CGFloat                       stepDuration;
@property (nonatomic) CGSize                        finSize;
@property (nonatomic, strong) UIColor               *color;
@property (nonatomic) UIRectCorner                  roundedCoreners;
@property (nonatomic) CGSize                        cornerRadii;
@property (nonatomic) SNActivityIndicatorDirection  direction;
@property (nonatomic) UIActivityIndicatorViewStyle  activityIndicatorViewStyle;

@property(nonatomic) BOOL                           hidesWhenStopped;

- (id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end
