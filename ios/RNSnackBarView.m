//
//  RNSnackBarView.m
//  RNSnackBarTest
//
//  Created by Remi Santos on 13/04/16.
//  Copyright © 2016 Remi Santos. All rights reserved.
//

#import "RNSnackBarView.h"
#import <React/RCTConvert.h>

typedef NS_ENUM(NSInteger, RNSnackBarViewState) {
  RNSnackBarViewStateDisplayed,
  RNSnackBarViewStatePresenting,
  RNSnackBarViewStateDismissing,
  RNSnackBarViewStateDismissed
};

static NSDictionary* DEFAULT_DURATIONS;
static const NSTimeInterval ANIMATION_DURATION = 0.250;

@interface RNSnackBarView ()
{
    UILabel* titleLabel;
    UIButton* actionButton;
    UIImageView* toastImage;
    NSTimer* dismissTimer;
}
@property (nonatomic, strong) NSDictionary* pendingOptions;
@property (nonatomic) RNSnackBarViewState state;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* actionTitle;
@property (nonatomic, strong) UIColor* actionTitleColor;
@property (nonatomic, strong) void (^pendingCallback)();
@property (nonatomic, strong) void (^callback)();

@end

@implementation RNSnackBarView

+ (void)initialize {
    DEFAULT_DURATIONS = @{
                          @"-2": @INT_MAX,
                          @"-1": @1500,
                           @"0": @3000
                         };
}

+ (id)sharedSnackBar {
    static RNSnackBarView *sharedSnackBar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedSnackBar = [[self alloc] init];
    });
    return sharedSnackBar;
}

+ (void)showWithOptions:(NSDictionary *)options andCallback:(void (^)())callback {
    RNSnackBarView *snackBar = [RNSnackBarView sharedSnackBar];
    snackBar.pendingOptions = options;
    snackBar.pendingCallback = callback;
    [snackBar show];
}

+ (void)dismiss {
    RNSnackBarView *snackBar = [RNSnackBarView sharedSnackBar];
    [snackBar dismiss];
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(16, [UIScreen mainScreen].bounds.size.height - 64, [UIScreen mainScreen].bounds.size.width - 32, 48)];
    if (self) {
        [self buildView];
    }
    return self;
}

- (void)buildView {
    CGFloat topPadding = 0;
    CGFloat bottomPadding = topPadding;

    CGFloat rightmargin = [UIScreen mainScreen].bounds.size.width - 70;

    // if (@available(iOS 11.0, *)) {
    //     UIWindow *window = UIApplication.sharedApplication.keyWindow;

    //     if (window.safeAreaInsets.bottom > bottomPadding)
    //         bottomPadding = window.safeAreaInsets.bottom;
    // }

    self.backgroundColor = [UIColor colorWithRed:0.196078F green:0.196078F blue:0.196078F alpha:1.0F];
    self.accessibilityIdentifier = @"snackbar";
  
    titleLabel = [UILabel new];
    titleLabel.text = _title;
    titleLabel.numberOfLines = 2;
    titleLabel.textColor = [UIColor colorWithRed:29/255 green:45/255 blue:61/255 alpha:1.0F];
    titleLabel.font = [UIFont systemFontOfSize:12];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:titleLabel];
    
    toastImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sucessIcon"]];
    toastImage.contentMode = UIViewContentModeScaleAspectFit;
    toastImage.frame = CGRectMake(0, 0, 24, 24);
    toastImage.center = CGPointMake(25,self.frame.size.height / 2);


//    actionButton = [UIButton new];
//    actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
//    [actionButton setTitle:@"" forState:UIControlStateNormal];
    // [actionButton addTarget:self action:@selector(actionPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [actionButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:toastImage];
//    [self addSubview:actionButton];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
          @"H:|-45-[titleLabel]-24-|"
          options:0 metrics:nil views:@{@"titleLabel": titleLabel}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[titleLabel]-%f-|", topPadding, bottomPadding] options:0 metrics:nil views:@{@"titleLabel": titleLabel}]];

//     [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"H:|-10-[toastImage]-%f-|", rightmargin]
//          options:0 metrics:nil views:@{@"toastImage": toastImage}]];

//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[toastImage]-10-|" options:0 metrics:nil views:@{@"toastImage": toastImage}]];


    [self addConstraint:[NSLayoutConstraint constraintWithItem:toastImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [titleLabel setContentCompressionResistancePriority:250 forAxis:UILayoutConstraintAxisHorizontal];
    [titleLabel setContentHuggingPriority:250 forAxis:UILayoutConstraintAxisHorizontal];
    [toastImage setContentCompressionResistancePriority:750 forAxis:UILayoutConstraintAxisHorizontal];
    [toastImage setContentHuggingPriority:750 forAxis:UILayoutConstraintAxisHorizontal];

}

-(void)setTitle:(NSString *)title {
    titleLabel.text = title;
}

-(void)setActionTitle:(NSString *)actionTitle {
    [actionButton setTitle:actionTitle forState:UIControlStateNormal];
}

-(void)setActionTitleColor:(UIColor *)actionTitleColor {
    [actionButton setTitleColor:actionTitleColor forState:UIControlStateNormal];
}

- (void)actionPressed:(UIButton*)sender {
    [self dismiss];
    self.callback();
}

- (void)presentWithDuration:(NSNumber*)duration {
    _pendingOptions = nil;
    _pendingCallback = nil;
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    [self setTranslatesAutoresizingMaskIntoConstraints:false];
    [keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[self(>=48)]-(16)-|" options:0 metrics:nil views:@{@"self": self}]];
    // [keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[self(>=48)]|" options:0 metrics:nil views:@{@"self": self}]];
    [keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(16)-[self]-(16)-|" options:0 metrics:nil views:@{@"self": self}]];

    self.transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    titleLabel.alpha = 0;
    toastImage.alpha = 0;
    self.state = RNSnackBarViewStatePresenting;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.transform = CGAffineTransformIdentity;
        titleLabel.alpha = 1;
        toastImage.alpha = 1;
     } completion:^(BOOL finished) {
        self.state = RNSnackBarViewStateDisplayed;
        NSTimeInterval interval;
        if ([duration doubleValue] <= 0) {
            NSString* durationString = [duration stringValue];
            interval = [(NSNumber*)DEFAULT_DURATIONS[durationString] floatValue] / 1000;
        } else {
            interval = [duration doubleValue] / 1000;
        }
        dismissTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                        target:self
                                                      selector:@selector(dismiss)
                                                      userInfo:nil
                                                       repeats:FALSE];
     }];
}

- (void)dismiss {
    [self.layer removeAllAnimations];
    [dismissTimer invalidate];
    self.state = RNSnackBarViewStateDismissing;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    } completion:^(BOOL finished) {
        self.state = RNSnackBarViewStateDismissed;
        [self removeFromSuperview];
        if (_pendingOptions) {
            [self show];
        }
    }];
}

- (void)show {
    if (self.state == RNSnackBarViewStateDisplayed || self.state == RNSnackBarViewStatePresenting) {
      [self dismiss];
      return;
    }
    if (self.state == RNSnackBarViewStateDismissing) {
      return;
    }
    if (!_pendingOptions) { return; }

    self.backgroundColor = [UIColor whiteColor];//backgroundColor ? [RCTConvert UIColor:backgroundColor] : [UIColor colorWithRed:0.196078F green:0.196078F blue:0.196078F alpha:1.0F];
    self.title = _pendingOptions[@"title"];
    self.callback = _pendingCallback;
    NSDictionary* action = _pendingOptions[@"action"];
    if (action) {
        self.actionTitle = _pendingOptions[@"action"][@"title"];
        NSNumber* color = _pendingOptions[@"action"][@"color"];
        self.actionTitleColor = [RCTConvert UIColor:color];
    } else {
        self.actionTitle = @"";
    }
    NSNumber* duration = _pendingOptions[@"duration"] ? (NSNumber*)_pendingOptions[@"duration"] : @(-1);
    [self setStyle];
    [self presentWithDuration:duration];
    
}

-(void)setStyle {
    self.layer.cornerRadius = 5.0;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = 3;
//    self.layer.borderWidth = 1.0;
//    self.layer.borderColor = [UIColor colorWithRed:0.196078F green:0.196078F blue:0.196078F alpha:1.0F].CGColor;
//    actionButton.backgroundColor = [UIColor redColor];
//    [actionButton setImage:[UIImage imageNamed:@"sucessIcon"] forState:UIControlStateNormal];
    NSInteger type = 1;
    if(_pendingOptions[@"type"] != nil) {
        type = [[_pendingOptions objectForKey:@"type"] integerValue];
    }
    switch (type) {
        case 0:
            toastImage.image = [UIImage imageNamed:@"sucessIcon"];
            break;
        case 1:
            toastImage.image = [UIImage imageNamed:@"warningIcon"];
            break;
        case 2:
            toastImage.image = [UIImage imageNamed:@"infoIcon"];
            break;
        case 3:
            toastImage.image = [UIImage imageNamed:@"failIcon"];
            break;
        default:
            toastImage.image = [UIImage imageNamed:@"warningIcon"];
            break;
    }
    
}
@end
