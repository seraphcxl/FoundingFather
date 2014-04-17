//
//  DCViewPathManager.h
//  FoundingFather
//
//  Created by Derek Chen on 1/31/14.
//  Copyright (c) 2014 CaptainSolid Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCSingletonTemplate.h"

#define DCViewPathManager_MaxUndoRedo ((int)16)

typedef void (^DCResetViewPathCompleteBlock)();

@interface DCViewPathGroup : NSObject {
}

@property (assign, atomic) NSInteger levelNumber;
@property (assign, atomic) NSInteger keyCode;
@property (strong, atomic) NSMutableArray *keys;
@property (strong, atomic) NSMutableArray *values;

@end

@interface DCViewPathManager : NSObject {
}

@property (strong, nonatomic, readonly) NSString *currentViewPath;
@property (strong, nonatomic, readonly) NSMutableArray *viewPathGroupAry;
@property (strong, nonatomic, readonly) NSMutableArray *undoViewPathAry;
@property (strong, nonatomic, readonly) NSMutableArray *redoViewPathAry;
@property (assign, nonatomic, readonly) BOOL inUndoRedoAction;

DEFINE_SINGLETON_FOR_HEADER(DCViewPathManager);

- (void)initCurrentViewPath:(NSString *)aViewPath;

- (void)undo;
- (void)redo;

@end
