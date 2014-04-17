//
//  DCSplashScreenWindowController.m
//  FoundingFather
//
//  Created by Derek Chen on 13-11-20.
//  Copyright (c) 2013年 CaptainSolid Studio. All rights reserved.
//

#import "DCSplashScreenWindowController.h"
#import "NSWindowController+CenterToScreen.h"
#import "DCSplashScreenViewController.h"

@interface DCSplashScreenWindowController ()

@end

@implementation DCSplashScreenWindowController

@synthesize splashScreenVC = _splashScreenVC;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)dealloc {
    do {
        _splashScreenVC = nil;
    } while (NO);
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [self.window setAlphaValue:1.0f];
    [self.window setOpaque:NO];
    [self.window setHasShadow:YES];
    [self.window setMovableByWindowBackground:YES];
    [self centerToScreen];
    [[self window] orderFront:nil];
    
    _splashScreenVC = [[DCSplashScreenViewController alloc] initWithNibName:@"DCSplashScreenViewController" bundle:nil];
    self.splashScreenVC.view.frame = [(NSView *)self.window.contentView frame];
    [self.window.contentView addSubview:self.splashScreenVC.view];
}

@end
