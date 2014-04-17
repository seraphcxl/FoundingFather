//
//  DCAsyncReactiveViewController.m
//  FoundingFather
//
//  Created by Derek Chen on 3/6/14.
//  Copyright (c) 2014 CaptainSolid Studio. All rights reserved.
//

#import "DCAsyncReactiveViewController.h"

@interface DCAsyncReactiveViewController ()

@end

@implementation DCAsyncReactiveViewController

@synthesize asyncReactiveQueue = _asyncReactiveQueue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.asyncReactiveQueue = [[NSOperationQueue alloc] init];
        [self.asyncReactiveQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (void)dealloc {
    do {
        @synchronized(self) {
            if (self.asyncReactiveQueue) {
                [self.asyncReactiveQueue cancelAllOperations];
                [self.asyncReactiveQueue waitUntilAllOperationsAreFinished];
                self.asyncReactiveQueue = nil;
            }
        }
    } while (NO);
}

- (void)addOperationForAsyncReactiveInMainThreadWithBlock:(void (^)(id strongSelf))block {
    do {
        if (!block || !self.asyncReactiveQueue) {
            break;
        }
        
        __weak id weakSelf = self;
        [self.asyncReactiveQueue addOperationWithBlock:^{
            do {
                dispatch_async(dispatch_get_main_queue(), ^{
                    DCAsyncReactiveViewController* strongSelf = weakSelf;
                    if (strongSelf) {
                        block(strongSelf);
                    }
                });
            } while (NO);
        }];
    } while (NO);
}

@end
