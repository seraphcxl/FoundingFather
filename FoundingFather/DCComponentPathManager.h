//
//  DCComponentPathManager.h
//  FoundingFather
//
//  Created by Derek Chen on 7/11/14.
//  Copyright (c) 2014 CaptainSolid Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kDCComponentPathManagerArchiveTree;

@interface DCComponentPathManager : NSObject <DCTreeDelegate>

@property (strong, nonatomic, readonly) NSURL *archiveURL;
@property (strong, nonatomic, readonly) DCTree *tree;

DEFINE_SINGLETON_FOR_HEADER(DCComponentPathManager)

- (instancetype)initWithRootNodeKey:(NSString *)key andValue:(id<NSCoding>)value;
- (instancetype)initWithArchive:(NSURL *)url;

- (BOOL)archiveTo:(NSURL *)url;

- (void)undo;
- (void)redo;

- (BOOL)resetPathWithNodeDescription:(NSString *)desc andActionBlock:(DCTreeActionBlock)actionBlock;

- (NSString *)keyLevelTraversal:(BOOL)needLevelSeparator;

@end
