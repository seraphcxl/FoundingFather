//
//  DCModalWindowController.h
//  FoundingFather
//
//  Created by Derek Chen on 13-11-20.
//  Copyright (c) 2013年 CaptainSolid Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DCModalWindowController : NSWindowController

@property (strong, atomic, readonly) NSViewController *modalVC;
@property (assign, atomic, readonly) BOOL supportTapToClose;

- (void)runModalWindowWithViewCtrl:(NSViewController *)aViewCtrl supportTapToClose:(BOOL)isSupportTapToClose;
- (void)stopModal;
- (NSString *)getModalWindowUUID;

@end
