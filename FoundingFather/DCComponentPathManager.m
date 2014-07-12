//
//  DCComponentPathManager.m
//  FoundingFather
//
//  Created by Derek Chen on 7/11/14.
//  Copyright (c) 2014 CaptainSolid Studio. All rights reserved.
//

#import "DCComponentPathManager.h"

NSString *kDCComponentPathManagerArchiveTree = @"DCComponentPathManagerArchiveTree";

@interface DCComponentPathManager ()

@property (strong, nonatomic) NSURL *archiveURL;
@property (strong, nonatomic) DCTree *tree;
@property (strong, nonatomic) DCStack *undoStack;
@property (strong, nonatomic) DCStack *redoStack;

- (NSData *)archiveTree;
- (void)unarchiveTreeFromData:(NSData *)data;

@end

@implementation DCComponentPathManager

@synthesize archiveURL = _archiveURL;
@synthesize tree = _tree;
@synthesize undoStack = _undoStack;
@synthesize redoStack = _redoStack;

DEFINE_SINGLETON_FOR_CLASS(DCComponentPathManager)

- (instancetype)initWithRootNodeKey:(NSString *)key andValue:(id<NSCoding>)value {
    DCComponentPathManager *result = nil;
    do {
        DCAssert(key != nil && [key length] != 0 && value != nil);
        self.archiveURL = nil;
        self.tree = [[DCTree alloc] initWithRootNodeKey:key andValue:value];
        self.tree.delegate = self;
        self.undoStack = [[DCStack alloc] init];
        self.redoStack = [[DCStack alloc] init];
        result = self;
    } while (NO);
    return result;
}

- (instancetype)initWithArchive:(NSURL *)url {
    DCComponentPathManager *result = nil;
    do {
        DCAssert(url != nil);
        self.archiveURL = [url copy];
        NSData *compressedData = [NSData dataWithContentsOfURL:url];
        NSError *err = nil;
        NSData *rawData = [compressedData decompressByGZipWithError:&err];
        if (err) {
            NSLog(@"%@", [err localizedDescription]);
            break;
        }
        [self unarchiveTreeFromData:rawData];
        self.undoStack = [[DCStack alloc] init];
        self.redoStack = [[DCStack alloc] init];
        result = self;
    } while (NO);
    return result;
}

- (void)dealloc {
    do {
        self.redoStack = nil;
        self.undoStack = nil;
        self.tree.delegate = nil;
        self.tree = nil;
        self.archiveURL = nil;
    } while (NO);
}

- (BOOL)archiveTo:(NSURL *)url {
    BOOL result = NO;
    do {
        if (!self.tree || !url) {
            break;
        }
        self.archiveURL = [url copy];
        NSData *rwaData = [self archiveTree];
        NSError *err = nil;
        NSData *compressedData = [rwaData compressByGZipWithError:&err];
        if (err) {
            NSLog(@"%@", [err localizedDescription]);
            break;
        }
        result = [compressedData writeToURL:url atomically:YES];
    } while (NO);
    return result;
}

- (void)undo {
    do {
        if (!self.tree || !self.undoStack || self.undoStack.count == 0 || !self.redoStack) {
            break;
        }
        NSData *data = [self archiveTree];
        NSError *err = nil;
        NSData *compressedData = [data compressByGZipWithError:&err];
        if (err) {
            NSLog(@"%@", [err localizedDescription]);
            break;
        }
        [self.redoStack pushObject:compressedData];
        data = [self.undoStack popObject];
        NSData *rawData = [data decompressByGZipWithError:&err];
        if (err) {
            NSLog(@"%@", [err localizedDescription]);
            break;
        }
        [self unarchiveTreeFromData:rawData];
    } while (NO);
}

- (void)redo {
    do {
        if (!self.tree || !self.undoStack || !self.redoStack || self.redoStack.count == 0) {
            break;
        }
        NSData *data = [self archiveTree];
        NSError *err = nil;
        NSData *compressedData = [data compressByGZipWithError:&err];
        if (err) {
            NSLog(@"%@", [err localizedDescription]);
            break;
        }
        [self.undoStack pushObject:compressedData];
        data = [self.redoStack popObject];
        NSData *rawData = [data decompressByGZipWithError:&err];
        if (err) {
            NSLog(@"%@", [err localizedDescription]);
            break;
        }
        [self unarchiveTreeFromData:rawData];
    } while (NO);
}

- (BOOL)resetPathWithNodeDescription:(NSString *)desc andActionBlock:(DCTreeActionBlock)actionBlock {
    BOOL result = NO;
    do {
        if (!self.tree) {
            break;
        }
        result = [self.tree actionWithNodeByTreeNodeDescription:desc andActionBlock:actionBlock];
        if (result && self.redoStack) {
            [self.redoStack resetStack];
        }
    } while (NO);
    return result;
}

- (NSString *)keyLevelTraversal:(BOOL)needLevelSeparator {
    NSString *result = nil;
    do {
        if (!self.tree) {
            break;
        }
        result = [self.tree keyLevelTraversal:needLevelSeparator];
    } while (NO);
    return result;
}

- (NSData *)archiveTree {
    NSMutableData *result = nil;
    do {
        if (!self.tree) {
            break;
        }
        result = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:result];
        [archiver encodeObject:self.tree forKey:kDCComponentPathManagerArchiveTree];
        [archiver finishEncoding];
    } while (NO);
    return result;
}

- (void)unarchiveTreeFromData:(NSData *)data {
    do {
        if (!data) {
            break;
        }
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        self.tree = [unarchiver decodeObjectForKey:kDCComponentPathManagerArchiveTree];
        self.tree.delegate = self;
        [unarchiver finishDecoding];
    } while (NO);
}

#pragma mark - DCTreeDelegate
- (void)Tree:(DCTree *)tree didActionWithNode:(DCTreeNode *)node {
    do {
        if (!tree || tree != self.tree || !node) {
            break;
        }
    } while (NO);
}

@end
