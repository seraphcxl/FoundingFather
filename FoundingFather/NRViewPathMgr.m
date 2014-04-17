//
//  NRViewPathMgr.m
//  PCSuite
//
//  Created by Derek Chen on 13-12-3.
//
//

#import "NRViewPathMgr.h"
#import "NRViewPathDefine.h"
#import "NSMutableString+CSV.h"
#import "NSString+CSV.h"
#import "NRMainViewController.h"
#import "PCMediaNotificationDefine.h"
#import "NSString+ViewPath.h"

@interface NRViewPathMgr () {
}

- (void)markUndoAction;
- (void)markRedoAction;

- (BOOL)resetCurrentViewPath:(NSString *)aViewPath needAddToUndoAry:(BOOL)needAddToUndoAry;

- (NSString *)makeCSVStringForKeys:(NSArray *)keys andValues:(NSArray *)values;

- (NSUInteger)keyCodeForkey:(NSString *)key;

- (NSString *)getLevelVP:(NSUInteger)level;

@end

@implementation NRViewPathMgr

@synthesize currentViewPath = _currentViewPath;
@synthesize level0KeyCode = _level0KeyCode;
@synthesize level0Keys = _level0Keys;
@synthesize level0Values = _level0Values;
@synthesize level1KeyCode = _level1KeyCode;
@synthesize level1Keys = _level1Keys;
@synthesize level1Values = _level1Values;
@synthesize level2KeyCode = _level2KeyCode;
@synthesize level2Keys = _level2Keys;
@synthesize level2Values = _level2Values;
@synthesize undoVPAry = _undoVPAry;
@synthesize redoVPAry = _redoVPAry;
@synthesize inUndoRedo = _inUndoRedo;
@synthesize categoryForGallery = _categoryForGallery;
@synthesize categoryForMusic = _categoryForMusic;
@synthesize groupByForGallery = _groupByForGallery;
@synthesize filterForGalleryIcons = _filterForGalleryIcons;
@synthesize originalURLCharAry = _originalURLCharAry;
@synthesize extendedURLCharAry = _extendedURLCharAry;

SYNTHESIZE_SINGLETON_FOR_CLASS(NRViewPathMgr);

- (id)init {
    @synchronized(self) {
        self = [super init];
        if (self) {
            _undoVPAry = [[NSMutableArray alloc] init];
            _redoVPAry = [[NSMutableArray alloc] init];
            _inUndoRedo = NO;
            
            _originalURLCharAry = [[NSArray arrayWithObjects:@";", @"/", @"?", @":", @"@", @"&", @"=", @"+", @"$", @",", @"[", @"]", @"#", @"!", @"'", @"(", @")", @"*", @" ", @"\"", nil] retain];
            _extendedURLCharAry = [[NSArray arrayWithObjects:@"%3B", @"%2F", @"%3F", @"%3A", @"%40", @"%26", @"%3D", @"%2B", @"%24", @"%2C", @"%5B", @"%5D", @"%23", @"%21", @"%27", @"%28", @"%29", @"%2A", @"%20", @"%22", nil] retain];
        }
        return self;
    }
}

- (void)dealloc {
    do {
        [self close];
        
        [super dealloc];
    } while (NO);
}

- (void)close {
    do {
        self.filterForGalleryIcons = nil;
        self.groupByForGallery = nil;
        self.categoryForMusic = nil;
        self.categoryForGallery = nil;
        
        NRSafeRelease(_extendedURLCharAry);
        NRSafeRelease(_originalURLCharAry);
        
        NRSafeRelease(_undoVPAry);
        NRSafeRelease(_redoVPAry);
        NRSafeRelease(_level2Values);
        NRSafeRelease(_level2Keys);
        NRSafeRelease(_level1Values);
        NRSafeRelease(_level1Keys);
        NRSafeRelease(_level0Values);
        NRSafeRelease(_level0Keys);
        NRSafeRelease(_currentViewPath);
    } while (NO);
}

- (void)markUndoAction {
    do {
        if (!self.undoVPAry || !self.currentViewPath) {
            break;
        }
        if ([self.undoVPAry count] >= NRViewUndoRedoManager_MaxUndoRedo) {
            [self.undoVPAry removeLastObject];
        }
        [self.undoVPAry insertObject:self.currentViewPath atIndex:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:NR_NOTIFICATION_MARKUNDO object:NULL];
        
    } while (NO);
}

- (void)markRedoAction {
    do {
        if (!self.redoVPAry) {
            break;
        }
        if ([self.redoVPAry count] >= NRViewUndoRedoManager_MaxUndoRedo) {
            [self.redoVPAry removeLastObject];
        }
        [self.redoVPAry insertObject:self.currentViewPath atIndex:0];
    } while (NO);
}

- (void)undo {
    do {
        if (!self.undoVPAry || !self.redoVPAry) {
            break;
        }
        
        if ([self.undoVPAry count] == 0) {
            break;
        }
        
        _inUndoRedo = YES;
        
        [self markRedoAction];
        
        NSString *undoViewPath = [[[self.undoVPAry objectAtIndex:0] copy] autorelease];
        [self.undoVPAry removeObjectAtIndex:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:NR_NOTIFICATION_BEGINUNDO object:NULL];
        
        if (![self resetCurrentViewPath:undoViewPath needAddToUndoAry:NO]) {
            break;
        }
        
        if (![[NRMainViewController sharedNRMainViewController] setViewPath]) {
            if (self.undoVPAry && [self.undoVPAry count] != 0) {
                [self undo];
            } else {
                if (![self resetCurrentViewPath:kNRVP_Default needAddToUndoAry:NO]) {
                    break;
                }
                [[NRMainViewController sharedNRMainViewController] setViewPath];
            }
        }
    } while (NO);
    _inUndoRedo = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:NR_NOTIFICATION_ENDUNDO object:NULL];
}

- (void)redo {
    do {
        if (!self.undoVPAry || !self.redoVPAry) {
            break;
        }
        
        if ([self.redoVPAry count] == 0) {
            break;
        }
        
        _inUndoRedo = YES;
        
        [self markUndoAction];
        
        NSString *redoViewPath = [[[self.redoVPAry objectAtIndex:0] copy] autorelease];
        [self.redoVPAry removeObjectAtIndex:0];
        
        if (![self resetCurrentViewPath:redoViewPath needAddToUndoAry:NO]) {
            break;
        }
        
        if (![[NRMainViewController sharedNRMainViewController] setViewPath]) {
            if (self.redoVPAry && [self.redoVPAry count] != 0) {
                [self redo];
            } else {
                if (![self resetCurrentViewPath:kNRVP_Default needAddToUndoAry:NO]) {
                    break;
                }
                [[NRMainViewController sharedNRMainViewController] setViewPath];
            }
        }
    } while (NO);
    _inUndoRedo = NO;
}

- (NSUInteger)keyCodeForkey:(NSString *)key {
    NSUInteger result = 0;
    do {
        if (!key) {
            break;
        }
        result = [key integerValue];
    } while (NO);
    return result;
}

- (void)initCurrentViewPath:(NSString *)aViewPath {
    do {
        if (!aViewPath) {
            break;
        }
        if (![self resetCurrentViewPath:aViewPath needAddToUndoAry:NO]) {
            break;
        }
    } while (NO);
}

- (BOOL)resetCurrentViewPath:(NSString *)aViewPath needAddToUndoAry:(BOOL)needAddToUndoAry {
    BOOL result = NO;
    do {
        if (!aViewPath) {
            break;
        }
        
        if ([aViewPath isEqualToString:self.currentViewPath]) {
            break;
        }
        
        if (needAddToUndoAry) {
            [self markUndoAction];
        }
        
        NRSafeRelease(_level2Values);
        _level2Values = [[NSMutableArray array] retain];
        NRSafeRelease(_level2Keys);
        _level2Keys = [[NSMutableArray array] retain];
        _level2KeyCode = 0;
        NRSafeRelease(_level1Values);
        _level1Values = [[NSMutableArray array] retain];
        NRSafeRelease(_level1Keys);
        _level1Keys = [[NSMutableArray array] retain];
        _level1KeyCode = 0;
        NRSafeRelease(_level0Values);
        _level0Values = [[NSMutableArray array] retain];
        NRSafeRelease(_level0Keys);
        _level0Keys = [[NSMutableArray array] retain];
        _level0KeyCode = 0;
        NRSafeRelease(_currentViewPath);
        
        _currentViewPath = [aViewPath retain];
        NSMutableArray *csvAry = [self.currentViewPath csvComponents];
        NSUInteger count = [csvAry count];
        
        NSUInteger level = 0;
        for (NSUInteger idx = 0; idx < count; ) {
            NSString *vpGear = [csvAry objectAtIndex:idx];
            if ([vpGear isEqualToString:kNRVP_LevelMark_0]) {
                level = 0;
                ++idx;
            } else if ([vpGear isEqualToString:kNRVP_LevelMark_1]) {
                level = 1;
                ++idx;
            } else if ([vpGear isEqualToString:kNRVP_LevelMark_2]) {
                level = 2;
                ++idx;
            } else {
                NSInteger *keyCode = &_level0KeyCode;
                NSMutableArray *keys = _level0Keys;
                NSMutableArray *values = _level0Values;
                if (level == 0) {
                    keyCode = &_level0KeyCode;
                    keys = _level0Keys;
                    values = _level0Values;
                } else if (level == 1) {
                    keyCode = &_level1KeyCode;
                    keys = _level1Keys;
                    values = _level1Values;
                } else if (level == 2) {
                    keyCode = &_level2KeyCode;
                    keys = _level2Keys;
                    values = _level2Values;
                } else {
                    break;
                }
                
                *keyCode |= [self keyCodeForkey:vpGear];
                [keys addObject:vpGear];
                [values addObject:[[csvAry objectAtIndex:idx + 1] convertFromViewPathValue]];
                
                idx += 2;
            }
        }
        
        [PCLogControl outputLog:@"<<< reset VP: %@ >>>", _currentViewPath];
        result = YES;
    } while (NO);
    return result;
}

- (NSString *)makeCSVStringForKeys:(NSArray *)keys andValues:(NSArray *)values {
    NSMutableString *result = nil;
    do {
        if (!keys || [keys count] == 0 || !values || [values count] == 0 || [keys count] != [values count]) {
            break;
        }
        result = [NSMutableString string];
        NSUInteger count = [keys count];
        for (NSUInteger idx = 0; idx < count; ++idx) {
            [result appendCSVComponent:[keys objectAtIndex:idx]];
            [result appendCSVComponent:[[values objectAtIndex:idx] convertToViewPathValue]];
        }
    } while (NO);
    return result;
}

- (NSString *)getLevelVP:(NSUInteger)level {
    NSMutableString *result = nil;
    do {
        NSString *levelID = nil;
        NSMutableArray *keys = nil;
        NSMutableArray *values = nil;
        if (level == 0) {
            levelID = kNRVP_LevelMark_0;
            keys = _level0Keys;
            values = _level0Values;
        } else if (level == 1) {
            levelID = kNRVP_LevelMark_1;
            keys = _level1Keys;
            values = _level1Values;
        } else if (level == 2) {
            levelID = kNRVP_LevelMark_2;
            keys = _level2Keys;
            values = _level2Values;
        } else {
            break;
        }
        result = [NSMutableString string];
        [result appendCSVComponent:levelID];
        [result appendCSVComponent:[self makeCSVStringForKeys:keys andValues:values]];
    } while (NO);
    return result;
}

- (void)resetViewPathForLevel0forKeys:(NSArray *)keys values:(NSArray *)values needAddToUndoAry:(BOOL)needAddToUndoAry withComplete:(NRResetViewPathCompleteBlock)completeBlock {
    do {
        if (!keys || [keys count] == 0 || !values || [values count] == 0 || [keys count] != [values count]) {
            break;
        }
        
        NSMutableString *vp = [NSMutableString string];
        [vp appendCSVComponent:kNRVP_LevelMark_0];
        [vp appendCSVComponent:[self makeCSVStringForKeys:keys andValues:values]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            do {
                if ([self resetCurrentViewPath:vp needAddToUndoAry:needAddToUndoAry]) {
                    [[NRMainViewController sharedNRMainViewController] setViewPath];
                }
                
                if (completeBlock) {
                    completeBlock();
                }
            } while (NO);
        });
    } while (NO);
}

- (void)resetViewPathForLevel1forKeys:(NSArray *)keys values:(NSArray *)values needAddToUndoAry:(BOOL)needAddToUndoAry withComplete:(NRResetViewPathCompleteBlock)completeBlock {
    do {
        if (!keys || [keys count] == 0 || !values || [values count] == 0 || [keys count] != [values count]) {
            break;
        }
        
        NSMutableString *vp = [NSMutableString string];
        [vp appendCSVComponent:[self getLevelVP:0]];
        
        [vp appendCSVComponent:kNRVP_LevelMark_1];
        [vp appendCSVComponent:[self makeCSVStringForKeys:keys andValues:values]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            do {
                if ([self resetCurrentViewPath:vp needAddToUndoAry:needAddToUndoAry]) {
                    [[NRMainViewController sharedNRMainViewController] setViewPath];
                }
                
                if (completeBlock) {
                    completeBlock();
                }
            } while (NO);
        });
    } while (NO);
}

- (void)resetViewPathForLevel2forKeys:(NSArray *)keys values:(NSArray *)values needAddToUndoAry:(BOOL)needAddToUndoAry withComplete:(NRResetViewPathCompleteBlock)completeBlock {
    do {
        if (!keys || [keys count] == 0 || !values || [values count] == 0 || [keys count] != [values count]) {
            break;
        }
        
        NSMutableString *vp = [NSMutableString string];
        [vp appendCSVComponent:[self getLevelVP:0]];
        [vp appendCSVComponent:[self getLevelVP:1]];
        
        [vp appendCSVComponent:kNRVP_LevelMark_2];
        [vp appendCSVComponent:[self makeCSVStringForKeys:keys andValues:values]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            do {
                if ([self resetCurrentViewPath:vp needAddToUndoAry:needAddToUndoAry]) {
                    [[NRMainViewController sharedNRMainViewController] setViewPath];
                }
                
                if (completeBlock) {
                    completeBlock();
                }
            } while (NO);
        });
    } while (NO);
}

- (void)resetViewPathForLevel0forKeys:(NSArray *)l0keys values:(NSArray *)l0values level1forKeys:(NSArray *)l1keys values:(NSArray *)l1values level2forKeys:(NSArray *)l2keys values:(NSArray *)l2values needAddToUndoAry:(BOOL)needAddToUndoAry withComplete:(NRResetViewPathCompleteBlock)completeBlock {
    do {
        if (!l0keys || [l0keys count] == 0 || !l0values || [l0values count] == 0 || [l0keys count] != [l0values count]) {
            break;
        }
        NSMutableString *vp = [NSMutableString string];
        if (!l0keys || [l0keys count] == 0 || !l0values || [l0values count] == 0 || [l0keys count] != [l0values count]) {
            ;
        } else {
            [vp appendCSVComponent:kNRVP_LevelMark_0];
            [vp appendCSVComponent:[self makeCSVStringForKeys:l0keys andValues:l0values]];
            
            if (!l1keys || [l1keys count] == 0 || !l1values || [l1values count] == 0 || [l1keys count] != [l1values count]) {
                ;
            } else {
                [vp appendCSVComponent:kNRVP_LevelMark_1];
                [vp appendCSVComponent:[self makeCSVStringForKeys:l1keys andValues:l1values]];
                
                if (!l2keys || [l2keys count] == 0 || !l2values || [l2values count] == 0 || [l2keys count] != [l2values count]) {
                    ;
                } else {
                    [vp appendCSVComponent:kNRVP_LevelMark_2];
                    [vp appendCSVComponent:[self makeCSVStringForKeys:l2keys andValues:l2values]];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            do {
                if ([self resetCurrentViewPath:vp needAddToUndoAry:needAddToUndoAry]) {
                    [[NRMainViewController sharedNRMainViewController] setViewPath];
                }
                
                if (completeBlock) {
                    completeBlock();
                }
            } while (NO);
        });
    } while (NO);
}

- (void)resetViewPathForLevel0forKeys:(NSArray *)keys values:(NSArray *)values withComplete:(NRResetViewPathCompleteBlock)completeBlock {
    [self resetViewPathForLevel0forKeys:keys values:values needAddToUndoAry:YES withComplete:completeBlock];
}

- (void)resetViewPathForLevel1forKeys:(NSArray *)keys values:(NSArray *)values withComplete:(NRResetViewPathCompleteBlock)completeBlock {
    [self resetViewPathForLevel1forKeys:keys values:values needAddToUndoAry:YES withComplete:completeBlock];
}

- (void)resetViewPathForLevel2forKeys:(NSArray *)keys values:(NSArray *)values withComplete:(NRResetViewPathCompleteBlock)completeBlock {
    [self resetViewPathForLevel2forKeys:keys values:values needAddToUndoAry:YES withComplete:completeBlock];
}

- (void)resetViewPathForLevel0forKeys:(NSArray *)l0keys values:(NSArray *)l0values level1forKeys:(NSArray *)l1keys values:(NSArray *)l1values level2forKeys:(NSArray *)l2keys values:(NSArray *)l2values withComplete:(NRResetViewPathCompleteBlock)completeBlock {
    [self resetViewPathForLevel0forKeys:l0keys values:l0values level1forKeys:l1keys values:l1values level2forKeys:l2keys values:l2values needAddToUndoAry:YES withComplete:completeBlock];
}

- (void)handleErrorViewPathForLevel0forKeys:(NSArray *)keys values:(NSArray *)values withComplete:(NRResetViewPathCompleteBlock)completeBlock {
    [self resetViewPathForLevel0forKeys:keys values:values needAddToUndoAry:NO withComplete:completeBlock];
}

- (void)handleErrorViewPathForLevel1forKeys:(NSArray *)keys values:(NSArray *)values withComplete:(NRResetViewPathCompleteBlock)completeBlock {
    [self resetViewPathForLevel1forKeys:keys values:values needAddToUndoAry:NO withComplete:completeBlock];
}

- (void)handleErrorViewPathForLevel2forKeys:(NSArray *)keys values:(NSArray *)values withComplete:(NRResetViewPathCompleteBlock)completeBlock {
    [self resetViewPathForLevel2forKeys:keys values:values needAddToUndoAry:NO withComplete:completeBlock];
}

- (void)handleErrorViewPathForLevel0forKeys:(NSArray *)l0keys values:(NSArray *)l0values level1forKeys:(NSArray *)l1keys values:(NSArray *)l1values level2forKeys:(NSArray *)l2keys values:(NSArray *)l2values withComplete:(NRResetViewPathCompleteBlock)completeBlock {
    [self resetViewPathForLevel0forKeys:l0keys values:l0values level1forKeys:l1keys values:l1values level2forKeys:l2keys values:l2values needAddToUndoAry:NO withComplete:completeBlock];
}

@end
