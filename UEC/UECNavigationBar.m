//
//  UECNavigationBar.m
//  UEC
//
//  Created by Jad Osseiran on 13/10/2013.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECNavigationBar.h"

@interface UECNavigationBar ()

@property (strong, nonatomic) CALayer *extraColorLayer;

@end

static CGFloat const kDefaultColorLayerOpacity = 0.5;
static CGFloat const kSpaceToCoverStatusBars = 64.0;

@implementation UECNavigationBar

#pragma mark - Instance

- (CALayer *)extraColorLayer
{
    if (_extraColorLayer)
        return _extraColorLayer;
    
    _extraColorLayer = [CALayer layer];
    _extraColorLayer.opacity = kDefaultColorLayerOpacity;
    [self.layer addSublayer:_extraColorLayer];
    
    return _extraColorLayer;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.extraColorLayer)
        self.extraColorLayer.frame = CGRectMake(0.f, -kSpaceToCoverStatusBars, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + kSpaceToCoverStatusBars);
    
    [self.extraColorLayer removeFromSuperlayer];
    [self.layer insertSublayer:_extraColorLayer atIndex:1];
}

#pragma mark - UINavigationBar

- (void)setBarTintColor:(UIColor *)barTintColor
{
    [super setBarTintColor:barTintColor];
    
    self.extraColorLayer.backgroundColor = barTintColor.CGColor;
}

@end
