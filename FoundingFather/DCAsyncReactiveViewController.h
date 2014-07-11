//
//  DCAsyncReactiveViewController.h
//  FoundingFather
//
//  Created by Derek Chen on 3/6/14.
//  Copyright (c) 2014 CaptainSolid Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DCAsyncReactiveViewController : NSViewController {
}

@property (strong, atomic) NSOperationQueue *asyncReactiveQueue;

- (void)addOperationForAsyncReactiveInMainThreadWithBlock:(void (^)(id strongSelf))block;

@end
