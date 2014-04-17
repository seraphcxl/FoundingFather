//
//  DCLogger.m
//  CodeGear_ObjC_Mac
//
//  Created by Derek Chen on 13-7-1.
//  Copyright (c) 2013年 CaptainSolid Studio. All rights reserved.
//

#import "DCLogger.h"
#import <objc/runtime.h>

const NSString *DCLogger_OptionKey_LogLevel = @"LogLevel";
const NSString *DCLogger_OptionKey_EnableSourceCodeInfo = @"EnableSourceCodeInfo";
const NSString *DCLogger_OptionKey_EnableThreadInfo = @"EnableThreadInfo";
const NSString *DCLogger_OptionKey_EnableTimestamp = @"EnableTimestamp";
const NSString *DCLogger_OptionKey_EnableLogToFile = @"EnableLogToFile";

@interface DCLogger () {
}

+ (NSString *)levelToLog:(DCLogLevel)level;

@end

@implementation DCLogger

DEFINE_SINGLETON_FOR_CLASS(DCLogger)

@synthesize logLevel = _logLevel;
@synthesize enableLogToFile = _enableLogToFile;
@synthesize enableTimestamp = _enableTimestamp;
@synthesize enableSourceCodeInfo = _enableSourceCodeInfo;
@synthesize enableThreadInfo = _enableThreadInfo;
@synthesize fileHandle = _fileHandle;
@synthesize dateFormatter = _dateFormatter;

#pragma mark - DCLogger - Public method
- (id)init {
    @synchronized(self) {
        self = [super init];
        if (self) {
            _logLevel = DCLL_WARN;
            _enableSourceCodeInfo = NO;
            _enableThreadInfo = YES;
            _enableTimestamp = YES;
            _enableLogToFile = NO;
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *bundlePath = [documentsDirectory stringByAppendingPathComponent:@"/DCLogger/DCLogFile-info.plist"];
            NSBundle* bundle = [NSBundle bundleWithPath:bundlePath];
            
            if (bundle) {
                NSDictionary *infoDict = [bundle infoDictionary];
                if (infoDict) {
                    NSNumber *logLevelValue = [infoDict objectForKey:DCLogger_OptionKey_LogLevel];
                    if (logLevelValue) {
                        _logLevel = [logLevelValue intValue];
                    }
                    NSNumber *enableSourceCodeInfoValue = [infoDict objectForKey:DCLogger_OptionKey_EnableSourceCodeInfo];
                    if (enableSourceCodeInfoValue) {
                        _enableSourceCodeInfo = [enableSourceCodeInfoValue boolValue];
                    }
                    NSNumber *enableThreadInfoValue = [infoDict objectForKey:DCLogger_OptionKey_EnableThreadInfo];
                    if (enableThreadInfoValue) {
                        _enableThreadInfo = [enableThreadInfoValue boolValue];
                    }
                    NSNumber *enableTimestampValue = [infoDict objectForKey:DCLogger_OptionKey_EnableTimestamp];
                    if (enableTimestampValue) {
                        _enableTimestamp = [enableTimestampValue boolValue];
                    }
                    NSNumber *enableLogToFile = [infoDict objectForKey:DCLogger_OptionKey_EnableLogToFile];
                    if (enableLogToFile) {
                        _enableLogToFile = [enableLogToFile boolValue];
                    }
                }
            } else {
                NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_logLevel], DCLogger_OptionKey_LogLevel, [NSNumber numberWithBool:_enableSourceCodeInfo], DCLogger_OptionKey_EnableSourceCodeInfo, [NSNumber numberWithBool:_enableThreadInfo], DCLogger_OptionKey_EnableThreadInfo, [NSNumber numberWithBool:_enableTimestamp], DCLogger_OptionKey_EnableTimestamp, [NSNumber numberWithBool:_enableLogToFile], DCLogger_OptionKey_EnableLogToFile, nil];
                [infoDict writeToFile:bundlePath atomically:YES];
            }
            
            // get path to Library/Caches/DCLogger/DCLogFile.txt
            NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"/DCLogger/DCLogFile.txt"];
            // create if needed
            if (![[NSFileManager defaultManager] fileExistsAtPath:logPath]){
                NSLog(@"Creating log file at %@", logPath);
                [[NSData data] writeToFile:logPath atomically:YES];
            }
            _fileHandle = [NSFileHandle fileHandleForWritingAtPath:logPath];
            SAFE_ARC_RETAIN(_fileHandle);
            [_fileHandle truncateFileAtOffset:[_fileHandle seekToEndOfFile]];
            
//            _dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'" allowNaturalLanguage:NO];
            
            _dateFormatter = [[NSDateFormatter alloc] init];
            [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [_dateFormatter setTimeStyle:NSDateFormatterLongStyle];
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            SAFE_ARC_SAFERELEASE(_dateFormatter);
            
            if (_fileHandle) {
                [_fileHandle closeFile];
                SAFE_ARC_SAFERELEASE(_fileHandle);
            }
        }
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

+ (void)logWithLevel:(DCLogLevel)level andFormat:(NSString *)format, ... {
    do {
        DCLogger *logger = [DCLogger sharedDCLogger];
        if (!logger) {
            break;
        }
        
        if (level < logger.logLevel) {
            break;
        }
        @synchronized(self) {
            NSMutableString *prefix = [NSMutableString stringWithFormat:@"%@", [DCLogger levelToLog:level]];
            
            if (logger.enableTimestamp) {
                [prefix appendFormat:@"T:<%@>; ", [logger.dateFormatter stringFromDate:[NSDate date]]];
            }
            
            if (logger.enableThreadInfo) {
                [prefix appendFormat:@"Thd:"];
                NSThread *thread = [NSThread currentThread];
                if (thread.name) {
                    [prefix appendFormat:@"%@", thread.name];
                }
                [prefix appendFormat:@"[0x%lx]; ", (unsigned long)thread];
            }
            
            if (logger.enableSourceCodeInfo) {
                [prefix appendFormat:@"SC:%16s:%4d%16s; ", __FILE__, __LINE__, __PRETTY_FUNCTION__];
            }
            
            va_list ap;
            va_start (ap, format);
            format = [format stringByAppendingString:@"\n"];
            NSString *msg = [[NSString alloc] initWithFormat:[NSString stringWithFormat:@"%@", format] arguments:ap];
            va_end (ap);
            
            NSString *log = [NSString stringWithFormat:@"%@%@", prefix, msg];
            
            fprintf(stderr, "%s", [log UTF8String]);
            
            if (logger.enableLogToFile) {
                [logger.fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    } while (NO);
}

+ (void)dumpClass:(Class)cls {
    do {
        if (!cls) {
            break;
        }
        DCLogger *logger = [DCLogger sharedDCLogger];
        if (!logger) {
            break;
        }
        @synchronized(self) {
            NSMutableString *classInfo = nil;
            
            // Class common information
            const char *className = class_getName(cls);
            
            [classInfo appendFormat:@"T:<%@>;\n", [logger.dateFormatter stringFromDate:[NSDate date]]];
            [classInfo appendFormat:@"/** Class dump for %s **/\n", className];
            
            Class isa = object_getClass(cls);
            Class superClass = class_getSuperclass(cls);
            
            [classInfo appendFormat:@"    isa = %@\n", isa];
            [classInfo appendFormat:@"    superclass = %@\n", superClass];
            
            // Protocols
            [classInfo appendFormat:@"  Protocols:\n"];
            unsigned int protocolCount = 0;
            Protocol *__unsafe_unretained* protocolList = class_copyProtocolList(cls, &protocolCount);
            for (unsigned int i = 0; i < protocolCount; ++i) {
                Protocol *protocol = protocolList[i];
                const char *name = protocol_getName(protocol);
                [classInfo appendFormat:@"    <%s>\n", name];
            }
            free(protocolList);
            protocolList = nil;
            
            // Instance variables
            [classInfo appendFormat:@"  Instance variables:\n"];
            unsigned int ivarCount = 0;
            Ivar *ivarList = class_copyIvarList(cls, &ivarCount);
            for (unsigned int i = 0; i < ivarCount; ++i) {
                Ivar ivar = ivarList[i];
                const char *name = ivar_getName(ivar);
                ptrdiff_t offset = ivar_getOffset(ivar);
                const char *encoding = ivar_getTypeEncoding(ivar);
                [classInfo appendFormat:@"    %s [%ti] %s\n", name, offset, encoding];
            }
            free(ivarList);
            ivarList = nil;
            
            // Class methods
            [classInfo appendFormat:@"  Class methods:\n"];
            unsigned int classMethodCount = 0;
            Method *classMethodList = class_copyMethodList(isa, &classMethodCount);
            for (unsigned int i = 0; i < classMethodCount; ++i) {
                Method method = classMethodList[i];
                SEL name = method_getName(method);
                const char *encoding = method_getTypeEncoding(method);
                [classInfo appendFormat:@"    +[%s %@] %s\n", className, NSStringFromSelector(name), encoding];
            }
            free(classMethodList);
            classMethodList = nil;
            
            // Instance methods
            [classInfo appendFormat:@"  Instance methods:\n"];
            unsigned int instanceMethodCount = 0;
            Method *instanceMethodList = class_copyMethodList(cls, &instanceMethodCount);
            for (unsigned int i = 0; i < instanceMethodCount; ++i) {
                Method method = instanceMethodList[i];
                SEL name = method_getName(method);
                const char *encoding = method_getTypeEncoding(method);
                [classInfo appendFormat:@"    -[%s %@] %s\n", className, NSStringFromSelector(name), encoding];
            }
            free(instanceMethodList);
            instanceMethodList = nil;            
            
            fprintf(stderr, "%s", [classInfo UTF8String]);
            
            if (logger.enableLogToFile) {
                [logger.fileHandle writeData:[classInfo dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    } while (NO);
}

#pragma mark - DCLogger - Private method
+ (NSString *)levelToLog:(DCLogLevel)level {
    NSString *result = nil;
    do {
        switch (level) {
            case DCLL_DEBUG:
                result = @"D: ";
                break;
            case DCLL_INFO:
                result = @"I: ";
                break;
            case DCLL_WARN:
                result = @"W: ";
                break;
            case DCLL_ERROR:
                result = @"E: ";
                break;
            case DCLL_FATAL:
                result = @"F: ";
                break;
                
            default:
                break;
        }
    } while (NO);
    return result;
}
@end
