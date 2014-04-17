//
//  DCSplashScreenViewController.m
//  FoundingFather
//
//  Created by Derek Chen on 13-11-20.
//  Copyright (c) 2013年 CaptainSolid Studio. All rights reserved.
//

#import "DCSplashScreenViewController.h"

@interface DCSplashScreenViewController ()

@end

@implementation DCSplashScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)loadView {
    [super loadView];
    [self.view setWantsLayer:YES];
    CGColorRef color = CGColorCreateGenericRGB(.5, .25, .75, 1);
    [self.view.layer setBackgroundColor:color];
    CGColorRelease(color);
    [self.label setStringValue:@"FoundingFather Splash Screen"];
}

@end
