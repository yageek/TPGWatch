//
//  TPGStopView.m
//  iOS App
//
//  Created by Yannick Heinrich on 29.11.17.
//  Copyright © 2017 Yageek. All rights reserved.
//

#import "TPGStopView.h"
@interface TPGStopView()
@property(nonatomic, strong) CAShapeLayer *roundedBackground;
@property(nonatomic, strong) UILabel *textLabel;
@end

@implementation TPGStopView
@dynamic textColor, text, backColor, rubanColor;

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        [self setupSubviews];
    }
    return self;
}

#pragma mark - Subviews

- (void) setupDefault {
    self.textColor = [UIColor whiteColor];
    self.backColor = [UIColor redColor];
    self.rubanColor = [UIColor blueColor];
}

- (void) setupSubviews {
    [self setupLayer];
    [self setupLabel];
    
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.backgroundColor = [UIColor yellowColor];
}

- (void) setupLabel {
 
    UILabel *label = [[UILabel alloc] initWithFrame:self.frame];
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"1";
    [label sizeToFit];
    
    [self addSubview:label];
    self.textLabel = label;
}

- (void) setupLayer {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    shapeLayer.fillColor = [UIColor redColor].CGColor;
    shapeLayer.strokeColor = [UIColor blueColor].CGColor;
    shapeLayer.lineWidth = 5.0;
    shapeLayer.opacity = 1.0f;
    
    [self.layer addSublayer:shapeLayer];
    self.roundedBackground = shapeLayer;
}

- (CGSize) intrinsicContentSize {
    return self.textLabel.intrinsicContentSize;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    // Text
    self.textLabel.frame = self.frame;
    
    // Adjust CA Layer
    CGFloat inset = self.lineWidth / 2.0;
    CGRect rounded = CGRectInset(self.bounds, inset, inset);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rounded cornerRadius:CGRectGetWidth(rounded)/2.0];
    self.roundedBackground.frame = self.layer.bounds;
    self.roundedBackground.path = bezierPath.CGPath;
}

#pragma mark - Setters customization
- (void) setText:(NSString *)text {
    self.textLabel.text = text;
}

- (void) setTextColor:(UIColor *)textColor {
    self.textLabel.textColor = textColor;
}

- (void) setBackColor:(UIColor *)backColor {
    self.roundedBackground.fillColor = backColor.CGColor;
}
- (void) setRubanColor:(UIColor *)rubanColor {
    self.roundedBackground.strokeColor = rubanColor.CGColor;
}

-(void) setLineWidth:(CGFloat)lineWidth {
    self.roundedBackground.lineWidth = lineWidth;
    _lineWidth = lineWidth;
    [self.roundedBackground setNeedsDisplay];
    
}

@end
