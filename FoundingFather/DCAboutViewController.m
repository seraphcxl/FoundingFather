//
//  DCAboutViewController.m
//  FoundingFather
//
//  Created by Derek Chen on 13-11-20.
//  Copyright (c) 2013年 CaptainSolid Studio. All rights reserved.
//

#import "DCAboutViewController.h"
#import "DCAppDelegate.h"
#import "NSViewController+ModalWindow.h"

@interface DCAboutViewController ()

@end

@implementation DCAboutViewController

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
    CGColorRef color = CGColorCreateGenericRGB(.75, .25, .75, 1);
    [self.view.layer setBackgroundColor:color];
    CGColorRelease(color);
    [self.label setStringValue:@"FoundingFather About Modal Window"];
}

- (IBAction)tapCloseButton:(id)sender {
    [(DCAppDelegate *)[[NSApplication sharedApplication] delegate] stopRunModalWithModalWindowUUID:[self getModalWindowUUID]];
}

- (IBAction)tapCloseAllButton:(id)sender {
    [(DCAppDelegate *)[[NSApplication sharedApplication] delegate] closeAllModalWindows];
}

@end
