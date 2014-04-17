//
//  DCModalWindowController.m
//  FoundingFather
//
//  Created by Derek Chen on 13-11-20.
//  Copyright (c) 2013年 CaptainSolid Studio. All rights reserved.
//

#import "DCModalWindowController.h"
#import "NSWindowController+CenterToScreen.h"
#import "NSViewController+ModalWindow.h"
#import "DCAppDelegate.h"

@interface DCModalWindowController ()

@end

@implementation DCModalWindowController

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
        [self.modalVC.view removeFromSuperview];
        _modalVC = nil;
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
}

- (void)runModalWindowWithViewCtrl:(NSViewController *)aViewCtrl supportTapToClose:(BOOL)isSupportTapToClose {
    do {
        if (!aViewCtrl || aViewCtrl == self.modalVC) {
            break;
        }
        [self stopModal];
        
        _modalVC = aViewCtrl;
        [self.window setFrame:self.modalVC.view.frame display:YES];
        [self.window.contentView addSubview:self.modalVC.view];
        
        _supportTapToClose = isSupportTapToClose;
        
        [self centerToScreen];
        [[self window] orderFront:self];
        
        [NSApp runModalForWindow:self.window];
    } while (NO);
}

- (void)stopModal {
    do {
        [NSApp stopModal];
        [self close];
    } while (NO);
}

- (NSString *)getModalWindowUUID {
    NSString *result = nil;
    do {
        if (!self.modalVC) {
            break;
        }
        result = [self.modalVC getModalWindowUUID];
    } while (NO);
    return result;
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self.modalVC mouseDown:theEvent];
    if (self.supportTapToClose) {
        [(DCAppDelegate *)[[NSApplication sharedApplication] delegate] stopRunModalWithModalWindowUUID:[self.modalVC getModalWindowUUID]];
    }
}

- (void)keyDown:(NSEvent *)theEvent {
    [self.modalVC keyDown:theEvent];
    if ([theEvent keyCode] == 53 && self.supportTapToClose) {  // esc
        [(DCAppDelegate *)[[NSApplication sharedApplication] delegate] stopRunModalWithModalWindowUUID:[self.modalVC getModalWindowUUID]];
    }
}

@end
