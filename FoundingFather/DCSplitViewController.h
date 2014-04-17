//
//  DCSplitViewController.h
//  FoundingFather
//
//  Created by Derek Chen on 13-11-11.
//  Copyright (c) 2013年 CaptainSolid Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    DCSplitVCOrientation_Horizontal,
    DCSplitVCOrientation_Vertical,
} DCSplitVCOrientation;

#define DCSplitVC_DefaultSlideOffset (128.0f)
#define DCSplitVC_DefaultAnimationDuration (0.3f)

@interface DCSplitViewController : NSViewController {
    DCSplitVCOrientation _orientation;
    
    NSViewController *_leftOrTopVC;
    NSViewController *_centerVC;
    NSViewController *_rightOrBottomVC;
        
    CGFloat _leftOrTopVCOffset;
    CGFloat _rightOrBottomVCOffset;
}

@property (assign, nonatomic, readonly) DCSplitVCOrientation orientation;

@property (strong, nonatomic) NSViewController *leftOrTopVC;
@property (strong, nonatomic) NSViewController *centerVC;
@property (strong, nonatomic) NSViewController *rightOrBottomVC;

@property (assign, nonatomic) CGFloat leftOrTopVCOffset;
@property (assign, nonatomic) CGFloat rightOrBottomVCOffset;

- (id)initWithOrientation:(DCSplitVCOrientation)anOrientation andNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

- (void)setCenterVC:(NSViewController *)centerVC animated:(BOOL)animated;

- (void)showHideLeftOrTopViewControllerAnimated:(BOOL)animated;
- (void)showHideRightOrBottomViewControllerAnimated:(BOOL)animated;

- (void)showHideLeftOrTopViewController:(BOOL)hidden animated:(BOOL)animated;
- (void)showHideRightOrBottomViewController:(BOOL)hidden animated:(BOOL)animated;

@end
