//
//  TPGStopView.h
//  iOS App
//
//  Created by Yannick Heinrich on 29.11.17.
//  Copyright © 2017 Yageek. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface TPGStopView : UIView

@property(nonatomic, strong) IBInspectable UIColor *backColor;
@property(nonatomic, strong) IBInspectable UIColor *textColor;
@property(nonatomic, strong) IBInspectable UIColor *rubanColor;

@property(nonatomic, copy) IBInspectable NSString *text;
@property(nonatomic, assign) IBInspectable CGFloat lineWidth;

@end
