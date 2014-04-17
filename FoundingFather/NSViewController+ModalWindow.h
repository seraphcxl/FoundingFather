//
//  NSViewController+ModalWindow.h
//  FoundingFather
//
//  Created by Derek Chen on 13-11-20.
//  Copyright (c) 2013年 CaptainSolid Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSViewController (ModalWindow)

- (NSString *)getModalWindowUUID;
- (void)setModalWindowUUID:(NSString *)aModalWindowUUID;

@end
