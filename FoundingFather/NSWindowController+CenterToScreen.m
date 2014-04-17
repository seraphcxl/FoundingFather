//
//  NSWindowController+CenterToScreen.m
//  FoundingFather
//
//  Created by Derek Chen on 13-11-20.
//  Copyright (c) 2013年 CaptainSolid Studio. All rights reserved.
//

#import "NSWindowController+CenterToScreen.h"

@implementation NSWindowController (CenterToScreen)

- (void)centerToScreen {
    NSPoint theCoordinate = NSMakePoint(0, 0);
    NSRect theScreensFrame = [[NSScreen mainScreen] frame];
	NSRect theWindowsFrame = [self.window frame];
    
	theCoordinate.x = (theScreensFrame.size.width - theWindowsFrame.size.width) / 2 + theScreensFrame.origin.x;
	theCoordinate.y = (theScreensFrame.size.height - theWindowsFrame.size.height) / 2  + theScreensFrame.origin.y;
	
	[self.window setFrameOrigin:theCoordinate];
}

@end
