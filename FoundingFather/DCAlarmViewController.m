//
//  DCAlarmViewController.m
//  FoundingFather
//
//  Created by Derek Chen on 13-11-20.
//  Copyright (c) 2013年 CaptainSolid Studio. All rights reserved.
//

#import "DCAlarmViewController.h"
#import "DCAppDelegate.h"
#import "NSViewController+ModalWindow.h"
#import "DCAboutViewController.h"

@interface DCAlarmViewController ()

@end

@implementation DCAlarmViewController

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
    CGColorRef color = CGColorCreateGenericRGB(0, .25, .75, 1);
    [self.view.layer setBackgroundColor:color];
    CGColorRelease(color);
    [self.label setStringValue:@"FoundingFather Alarm Modal Window"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        DCAboutViewController *aboutVC = [[DCAboutViewController alloc] initWithNibName:@"DCAboutViewController" bundle:nil];
        [aboutVC setModalWindowUUID:[DCAppDelegate createUUID]];
        [(DCAppDelegate *)[[NSApplication sharedApplication] delegate] runModalWindowWithViewCtrl:aboutVC supportTapToClose:NO];
    });
}

@end
