//
//  NSViewController+ModalWindow.m
//  FoundingFather
//
//  Created by Derek Chen on 13-11-20.
//  Copyright (c) 2013年 CaptainSolid Studio. All rights reserved.
//

#import "NSViewController+ModalWindow.h"
#import <objc/runtime.h>

static char modalWindowUUID;

@implementation NSViewController (ModalWindow)

- (NSString *)getModalWindowUUID {
    return (NSString *)objc_getAssociatedObject(self, &modalWindowUUID);
}

- (void)setModalWindowUUID:(NSString *)aModalWindowUUID {
    objc_setAssociatedObject(self, &modalWindowUUID, aModalWindowUUID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
