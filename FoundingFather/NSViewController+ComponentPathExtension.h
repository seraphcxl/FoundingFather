//
//  NSViewController+ComponentPathExtension.h
//  FoundingFather
//
//  Created by Derek Chen on 7/12/14.
//  Copyright (c) 2014 CaptainSolid Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSViewController (ComponentPathExtension)

- (BOOL)setComponentPath:(DCTreeNode *)pathNode;

@end
