//
//  RMBlurredView.m
//
//  Created by Raffael Hannemann on 08.10.13.
//  Copyright (c) 2013 Raffael Hannemann. All rights reserved.
//

#import "RMBlurredView.h"

#define kRMBlurredViewDefaultTintColor ([NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:0.7f])
#define kRMBlurredViewDefaultSaturationFactor (1.0f)
#define kRMBlurredViewDefaultBlurRadius (2.0f)

@implementation RMBlurredView

@synthesize tintColor = _tintColor;
@synthesize saturationFactor = _saturationFactor;
@synthesize blurRadius = _blurRadius;
@synthesize saturationFactorNumber = _saturationFactorNumber;
@synthesize blurRadiusNumber = _blurRadiusNumber;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void) setTintColor:(NSColor *)tintColor {
	_tintColor = tintColor;
	 
	// Since we need a CGColor reference, store it for the drawing of the layer.
	if (_tintColor) {
        CGFloat red = 0.0f;
        CGFloat green = 0.0f;
        CGFloat blue = 0.0f;
        CGFloat alpha = 0.0f;
        [_tintColor getRed:&red green:&green blue:&blue alpha:&alpha];
        CGColorRef cgColor = CGColorCreateGenericRGB(red, green, blue, alpha);
		[self.layer setBackgroundColor:cgColor];
        CGColorRelease(cgColor);
	}
	
	// Trigger a re-drawing of the layer
	[self.layer setNeedsDisplay];
}

- (void) setBlurRadius:(float)blurRadius {
	// Setting the blur radius requires a resetting of the filters
	_blurRadius = blurRadius;
	[self resetFilters];
}

- (void) setBlurRadiusNumber:(NSNumber *)blurRadiusNumber {
	[self setBlurRadius:blurRadiusNumber.floatValue];
}

- (void) setSaturationFactor:(float)saturationFactor {
	// Setting the saturation factor also requires a resetting of the filters
	_saturationFactor = saturationFactor;
	[self resetFilters];
}

- (void) setSaturationFactorNumber:(NSNumber *)saturationFactorNumber {
	[self setSaturationFactor:saturationFactorNumber.floatValue];
}

- (void) setUp {
	// Instantiate a new CALayer and set it as the NSView's layer (layer-hosting)
	_hostedLayer = [CALayer layer];
	[self setWantsLayer:YES];
	[self setLayer:_hostedLayer];
	
	// Set up the default parameters
	_blurRadius = kRMBlurredViewDefaultBlurRadius;
	_saturationFactor = kRMBlurredViewDefaultSaturationFactor;
	[self setTintColor:kRMBlurredViewDefaultTintColor];
	
	// It's important to set the layer to mask to its bounds, otherwise the whole parent view might get blurred
	[self.layer setMasksToBounds:YES];
	
	// To apply CIFilters on OS X 10.9, we need to set the property accordingly:
	if ([self respondsToSelector:@selector(setLayerUsesCoreImageFilters:)]) {
		BOOL flag = YES;
		NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(setLayerUsesCoreImageFilters:)]];
		[inv setSelector:@selector(setLayerUsesCoreImageFilters:)];
		[inv setArgument:&flag atIndex:2];
		[inv invokeWithTarget:self];
	}
	
	// Set the layer to redraw itself once it's size is changed
	[self.layer setNeedsDisplayOnBoundsChange:YES];
	
	// Initially create the filter instances
	[self resetFilters];
}

- (void) resetFilters {
	
	// To get a higher color saturation, we create a ColorControls filter
	_saturationFilter = [CIFilter filterWithName:@"CIColorControls"];
	[_saturationFilter setDefaults];
	[_saturationFilter setValue:[NSNumber numberWithFloat:_saturationFactor] forKey:@"inputSaturation"];
	
	// Next, we create the blur filter
	_blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
	[_blurFilter setDefaults];
	[_blurFilter setValue:[NSNumber numberWithFloat:_blurRadius] forKey:@"inputRadius"];
	
	// Now we apply the two filters as the layer's background filters
	[self.layer setBackgroundFilters:@[_saturationFilter, _blurFilter]];
	
	// ... and trigger a refresh
	[self.layer setNeedsDisplay];
}

@end
