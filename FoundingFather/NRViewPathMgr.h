//
//  NRViewPathMgr.h
//  PCSuite
//
//  Created by Derek Chen on 13-12-3.
//
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

#define NRViewUndoRedoManager_MaxUndoRedo ((int)30)

typedef void (^NRResetViewPathCompleteBlock)();

@interface NRViewPathMgr : NSObject {
    NSString *_currentViewPath;
    
    NSInteger _level0KeyCode;
    NSMutableArray *_level0Keys;
    NSMutableArray *_level0Values;
    
    NSInteger _level1KeyCode;
    NSMutableArray *_level1Keys;
    NSMutableArray *_level1Values;
    
    NSInteger _level2KeyCode;
    NSMutableArray *_level2Keys;
    NSMutableArray *_level2Values;
    
    NSMutableArray *_undoVPAry;
    NSMutableArray *_redoVPAry;
    BOOL _inUndoRedo;
    
    NSString *_categoryForGallery;
    NSString *_categoryForMusic;
    NSString *_groupByForGallery;
    NSString *_filterForGalleryIcons;
    
    NSArray *_originalURLCharAry;
    NSArray *_extendedURLCharAry;
}

@property (nonatomic, retain, readonly) NSString *currentViewPath;

@property (nonatomic, assign, readonly) NSInteger level0KeyCode;
@property (nonatomic, retain, readonly) NSMutableArray *level0Keys;
@property (nonatomic, retain, readonly) NSMutableArray *level0Values;

@property (nonatomic, assign, readonly) NSInteger level1KeyCode;
@property (nonatomic, retain, readonly) NSMutableArray *level1Keys;
@property (nonatomic, retain, readonly) NSMutableArray *level1Values;

@property (nonatomic, assign, readonly) NSInteger level2KeyCode;
@property (nonatomic, retain, readonly) NSMutableArray *level2Keys;
@property (nonatomic, retain, readonly) NSMutableArray *level2Values;

@property (nonatomic, retain, readonly) NSMutableArray *undoVPAry;
@property (nonatomic, retain, readonly) NSMutableArray *redoVPAry;
@property (atomic, assign, readonly) BOOL inUndoRedo;

@property (nonatomic, retain) NSString *categoryForGallery;
@property (nonatomic, retain) NSString *categoryForMusic;
@property (nonatomic, retain) NSString *groupByForGallery;
@property (nonatomic, retain) NSString *filterForGalleryIcons;

@property (nonatomic, retain, readonly) NSArray *originalURLCharAry;
@property (nonatomic, retain, readonly) NSArray *extendedURLCharAry;

+ (NRViewPathMgr *)sharedNRViewPathMgr;
- (void)close;

- (void)undo;
- (void)redo;

- (void)initCurrentViewPath:(NSString *)aViewPath;

- (void)resetViewPathForLevel0forKeys:(NSArray *)keys values:(NSArray *)values withComplete:(NRResetViewPathCompleteBlock)completeBlock;
- (void)resetViewPathForLevel1forKeys:(NSArray *)keys values:(NSArray *)values withComplete:(NRResetViewPathCompleteBlock)completeBlock;
- (void)resetViewPathForLevel2forKeys:(NSArray *)keys values:(NSArray *)values withComplete:(NRResetViewPathCompleteBlock)completeBlock;
- (void)resetViewPathForLevel0forKeys:(NSArray *)l0keys values:(NSArray *)l0values level1forKeys:(NSArray *)l1keys values:(NSArray *)l1values level2forKeys:(NSArray *)l2keys values:(NSArray *)l2values withComplete:(NRResetViewPathCompleteBlock)completeBlock;

- (void)handleErrorViewPathForLevel0forKeys:(NSArray *)keys values:(NSArray *)values withComplete:(NRResetViewPathCompleteBlock)completeBlock;
- (void)handleErrorViewPathForLevel1forKeys:(NSArray *)keys values:(NSArray *)values withComplete:(NRResetViewPathCompleteBlock)completeBlock;
- (void)handleErrorViewPathForLevel2forKeys:(NSArray *)keys values:(NSArray *)values withComplete:(NRResetViewPathCompleteBlock)completeBlock;
- (void)handleErrorViewPathForLevel0forKeys:(NSArray *)l0keys values:(NSArray *)l0values level1forKeys:(NSArray *)l1keys values:(NSArray *)l1values level2forKeys:(NSArray *)l2keys values:(NSArray *)l2values withComplete:(NRResetViewPathCompleteBlock)completeBlock;

- (void)resetViewPathForLevel0forKeys:(NSArray *)keys values:(NSArray *)values needAddToUndoAry:(BOOL)needAddToUndoAry withComplete:(NRResetViewPathCompleteBlock)completeBlock;
- (void)resetViewPathForLevel1forKeys:(NSArray *)keys values:(NSArray *)values needAddToUndoAry:(BOOL)needAddToUndoAry withComplete:(NRResetViewPathCompleteBlock)completeBlock;
- (void)resetViewPathForLevel2forKeys:(NSArray *)keys values:(NSArray *)values needAddToUndoAry:(BOOL)needAddToUndoAry withComplete:(NRResetViewPathCompleteBlock)completeBlock;
- (void)resetViewPathForLevel0forKeys:(NSArray *)l0keys values:(NSArray *)l0values level1forKeys:(NSArray *)l1keys values:(NSArray *)l1values level2forKeys:(NSArray *)l2keys values:(NSArray *)l2values needAddToUndoAry:(BOOL)needAddToUndoAry withComplete:(NRResetViewPathCompleteBlock)completeBlock;

@end
