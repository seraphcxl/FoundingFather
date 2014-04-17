//
//  DCAppDelegate.m
//  FoundingFather
//
//  Created by Derek Chen on 13-11-20.
//  Copyright (c) 2013年 CaptainSolid Studio. All rights reserved.
//

#import "DCAppDelegate.h"
#import "DCSplashScreenWindowController.h"
#import "RMBlurredView.h"
#import "DCModalWindowController.h"
#import "NSViewController+ModalWindow.h"
#import "DCAlarmViewController.h"
#import "DCAboutViewController.h"
#import "DCAsyncReactiveViewController.h"

@interface DCAppDelegate () {
}

@end

@implementation DCAppDelegate

@synthesize splashScreenWC = _splashScreenWC;
@synthesize blurredView = _blurredView;
@synthesize modalWindowsDict = _modalWindowsDict;
@synthesize modalWindowsAry = _modalWindowsAry;

+ (NSString *)createUUID {
	CFUUIDRef uuidRef = CFUUIDCreate(NULL);
	CFStringRef uuidStr = CFUUIDCreateString(NULL, uuidRef);
	
	NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuidStr];
	
	CFRelease(uuidRef);
	CFRelease(uuidStr);
	
	return uuid;
}

- (void)dealloc {
    do {
        [self closeAllModalWindows];
        
        @synchronized(self.modalWindowsDict) {
            _modalWindowsDict = nil;
        }
        
        @synchronized(self.modalWindowsAry) {
            _modalWindowsAry = nil;
        }
        
        _splashScreenWC = nil;
        _blurredView = nil;
    } while (NO);
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    do {
        [self.window orderOut:self];
        _splashScreenWC = [[DCSplashScreenWindowController alloc] initWithWindowNibName:@"DCSplashScreenWindowController"];
        [self.splashScreenWC.window makeKeyAndOrderFront:self];
        
        DCAsyncReactiveViewController *testVC = [[DCAsyncReactiveViewController alloc] init];
        
//        for (int i = 0; i < 5; ++i) {
//            __weak id weakVC = testVC;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                for (int m = 0; m < 10; ++m) {
//                    DCAsyncReactiveViewController* strongVC = weakVC;
//                    NSLog(@"dispatch %@, %d", strongVC, (i * 10 + m));
//                }
//            });
//        }
        
        for (int i = 0; i < 5; ++i) {
            [testVC addOperationForAsyncReactiveInMainThreadWithBlock:^(id strongSelf) {
                for (int m = 0; m < 10; ++m) {
                    NSLog(@"operation %@, %d", strongSelf, (i * 10 + m));
                }
            }];
//            [testVC addAsyncReactiveOperationWithBlock:^{
//                for (int m = 0; m < 10; ++m) {
//                    DCAsyncReactiveViewController* strongVC = weakVC;
//                    NSLog(@"operation %@, %d", strongVC, (i * 10 + m));
//                }
//            }];
        }
        
    } while (NO);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    do {
        _blurredView = [[RMBlurredView alloc] initWithFrame:[(NSView *)[self.window contentView] frame]];
        @synchronized(self.modalWindowsDict) {
            _modalWindowsDict = [NSMutableDictionary dictionary];
        }
        @synchronized(self.modalWindowsAry) {
            _modalWindowsAry = [NSMutableArray array];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            sleep(3);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.splashScreenWC.window orderOut:self];
                [self.window makeKeyAndOrderFront:self];
            });
        });
    } while (NO);
}

- (IBAction)showSingleModalWindow:(id)sender {
    do {
        DCAboutViewController *aboutVC = [[DCAboutViewController alloc] initWithNibName:@"DCAboutViewController" bundle:nil];
        [aboutVC setModalWindowUUID:[DCAppDelegate createUUID]];
        [self runModalWindowWithViewCtrl:aboutVC supportTapToClose:NO];
    } while (NO);
}

- (IBAction)showMultipeModalWindows:(id)sender {
    do {
        DCAlarmViewController *alarmVC1 = [[DCAlarmViewController alloc] initWithNibName:@"DCAlarmViewController" bundle:nil];
        [alarmVC1 setModalWindowUUID:[DCAppDelegate createUUID]];
        [self runModalWindowWithViewCtrl:alarmVC1 supportTapToClose:YES];
    } while (NO);
}

- (void)setBlurredViewHidden:(BOOL)hidden {
    do {
        if (![NSThread isMainThread]) {
            break;
        }
        if (hidden) {
            if (self.blurredView) {
                [self.blurredView removeFromSuperview];
            }
        } else {
            if (self.blurredView != nil) {
                self.blurredView.frame = [(NSView *)[self.window contentView] bounds];
                [(NSView *)[self.window contentView] addSubview:self.blurredView];
            }
        }
    } while (NO);
}

- (void)runModalWindowWithViewCtrl:(NSViewController *)aViewCtrl supportTapToClose:(BOOL)isSupportTapToClose {
    do {
        if (!aViewCtrl || ![NSThread isMainThread]) {
            break;
        }
        @synchronized(self.modalWindowsAry) {
            @synchronized(self.modalWindowsDict) {
                if (!self.modalWindowsDict || !self.modalWindowsAry) {
                    break;
                }
                NSString *modalWindowUUID = [aViewCtrl getModalWindowUUID];
                
                DCModalWindowController *oldModalWC = [self.modalWindowsDict objectForKey:modalWindowUUID];
                if (oldModalWC) {
                    [oldModalWC stopModal];
                    [self.modalWindowsAry removeObject:oldModalWC];
                    [self.modalWindowsDict removeObjectForKey:modalWindowUUID];
                }
                
                DCModalWindowController *newModalWC = [[DCModalWindowController alloc] initWithWindowNibName:@"DCModalWindowController"];
                [self.modalWindowsDict setObject:newModalWC forKey:modalWindowUUID];
                [self.modalWindowsAry insertObject:newModalWC atIndex:0];
                
                [self setBlurredViewHidden:NO];
                
                [newModalWC runModalWindowWithViewCtrl:aViewCtrl supportTapToClose:isSupportTapToClose];
            }
        }
    } while (NO);
}

- (void)stopRunModalWithModalWindowUUID:(NSString *)aModalWindowUUID {
    do {
        if (!aModalWindowUUID || ![NSThread isMainThread]) {
            break;
        }
        @synchronized(self.modalWindowsAry) {
            @synchronized(self.modalWindowsDict) {
                if (!self.modalWindowsDict || !self.modalWindowsAry) {
                    break;
                }
                
                DCModalWindowController *modalWC = [self.modalWindowsDict objectForKey:aModalWindowUUID];
                if (modalWC) {
                    [modalWC stopModal];
                    [self.modalWindowsAry removeObject:modalWC];
                    [self.modalWindowsDict removeObjectForKey:aModalWindowUUID];
                    
                    if ([self.modalWindowsDict count] == 0) {
                        [self setBlurredViewHidden:YES];
                    }
                }
            }
        }
    } while (NO);
}

- (void)closeAllModalWindows {
    do {
        if (![NSThread isMainThread]) {
            break;
        }
        @synchronized(self.modalWindowsAry) {
            @synchronized(self.modalWindowsDict) {
                if (!self.modalWindowsDict || !self.modalWindowsAry) {
                    break;
                }
                for (DCModalWindowController *wc in self.modalWindowsAry) {
                    [wc stopModal];
                }
                [self.modalWindowsAry removeAllObjects];
                [self.modalWindowsDict removeAllObjects];

                [self setBlurredViewHidden:YES];
            }
        }
    } while (NO);
}

@end
