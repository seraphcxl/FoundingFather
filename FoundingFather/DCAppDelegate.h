//
//  DCAppDelegate.h
//  FoundingFather
//
//  Created by Derek Chen on 13-11-20.
//  Copyright (c) 2013年 CaptainSolid Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DCSplashScreenWindowController;
@class RMBlurredView;

@interface DCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (strong, nonatomic, readonly) DCSplashScreenWindowController *splashScreenWC;
@property (strong, nonatomic, readonly) RMBlurredView *blurredView;
@property (strong, nonatomic, readonly) NSMutableDictionary *modalWindowsDict;
@property (strong, nonatomic, readonly) NSMutableArray *modalWindowsAry;

+ (NSString *)createUUID;

- (IBAction)showSingleModalWindow:(id)sender;
- (IBAction)showMultipeModalWindows:(id)sender;

- (void)setBlurredViewHidden:(BOOL)hidden;

- (void)runModalWindowWithViewCtrl:(NSViewController *)aViewCtrl supportTapToClose:(BOOL)isSupportTapToClose;
- (void)stopRunModalWithModalWindowUUID:(NSString *)aModalWindowUUID;

- (void)closeAllModalWindows;

@end
