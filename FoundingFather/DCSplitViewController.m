//
//  DCSplitViewController.m
//  TestForSlidVC
//
//  Created by Derek Chen on 13-11-11.
//  Copyright (c) 2013年 CaptainSolid Studio. All rights reserved.
//

#import "DCSplitViewController.h"
#import <Quartz/Quartz.h>

@interface DCSplitViewController ()

@end

@implementation DCSplitViewController

@synthesize orientation = _orientation;
@synthesize leftOrTopVC = _leftOrTopVC;
@synthesize centerVC = _centerVC;
@synthesize rightOrBottomVC = _rightOrBottomVC;
@synthesize leftOrTopVCOffset = _leftOrTopVCOffset;
@synthesize rightOrBottomVCOffset = _rightOrBottomVCOffset;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
    }
    return self;
}

- (id)initWithOrientation:(DCSplitVCOrientation)anOrientation andNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    @synchronized(self) {
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        if (self) {
            _orientation = anOrientation;
            _leftOrTopVCOffset = _rightOrBottomVCOffset = DCSplitVC_DefaultSlideOffset;
        }
        return self;
    }
}

- (void)dealloc {
    do {
        if (self.rightOrBottomVC != nil) {
            [self.rightOrBottomVC.view removeFromSuperview];
        }
        self.rightOrBottomVC = nil;
        
        if (self.leftOrTopVC != nil) {
            [self.leftOrTopVC.view removeFromSuperview];
        }
        self.leftOrTopVC = nil;
        
        if (self.centerVC != nil) {
            [self.centerVC.view removeFromSuperview];
        }
        self.centerVC = nil;
        
    } while (NO);
}

- (void)loadView {
    [super loadView];
}

- (void)setCenterVC:(NSViewController *)centerVC {
    do {
        [self setCenterVC:centerVC animated:NO];
    } while (NO);
}

- (void)setCenterVC:(NSViewController *)centerVC animated:(BOOL)animated {
    do {
        if (!centerVC) {
            break;
        }
        
        if (_centerVC != nil) {
            [_centerVC viewCtrlWillDisappear];
            [_centerVC.view removeFromSuperview];
        }
        _centerVC = centerVC;
        CGRect frame = NSRectToCGRect(self.view.bounds);
        if (self.orientation == DCSplitVCOrientation_Horizontal) {
            if (self.leftOrTopVC && !self.leftOrTopVC.view.isHidden) {
                frame.origin.x -= self.leftOrTopVCOffset;
                frame.size.width -= self.leftOrTopVCOffset;
            }
            if (self.rightOrBottomVC && !self.rightOrBottomVC.view.isHidden) {
                frame.size.width -= self.rightOrBottomVCOffset;
            }
        } else if (self.orientation == DCSplitVCOrientation_Vertical) {
            if (self.leftOrTopVC && !self.leftOrTopVC.view.isHidden) {
                frame.size.height -= self.leftOrTopVCOffset;
            }
            if (self.rightOrBottomVC && !self.rightOrBottomVC.view.isHidden) {
                frame.origin.y += self.rightOrBottomVCOffset;
                frame.size.height -= self.rightOrBottomVCOffset;
            }
        } else {
            break;
        }
        
        _centerVC.view.frame = NSRectFromCGRect(frame);
        _centerVC.view.bounds = NSRectFromCGRect(CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height));
        [_centerVC viewCtrlWillAppear];
        [_centerVC.view setHidden:NO];
        
        if (animated) {
            [NSAnimationContext beginGrouping];
            {
                [[NSAnimationContext currentContext] setDuration:DCSplitVC_DefaultAnimationDuration];
                
                [[self.view animator] addSubview:_centerVC.view];
            }
            [NSAnimationContext endGrouping];
        } else {
            [self.view addSubview:_centerVC.view];
        }
        
    } while (NO);
}

- (void)setLeftOrTopVC:(NSViewController *)leftOrTopVC {
    do {
        if (!leftOrTopVC) {
            break;
        }
        
        if (_leftOrTopVC != nil) {
            [_leftOrTopVC viewCtrlWillDisappear];
            [_leftOrTopVC.view removeFromSuperview];
        }
        
        CGRect defaultFrame = CGRectZero;
        if (self.orientation == DCSplitVCOrientation_Horizontal) {
            defaultFrame = CGRectMake(0.0f, 0.0f, self.leftOrTopVCOffset, self.view.bounds.size.height);
        } else if (self.orientation == DCSplitVCOrientation_Vertical) {
            CGFloat locY = 0.0f;
            if (self.centerVC != nil) {
                locY += (self.centerVC.view.frame.origin.y + self.centerVC.view.frame.size.height - self.leftOrTopVCOffset);
                locY = locY > 0 ? locY : 0;
            }
            defaultFrame = CGRectMake(0.0f, locY, self.view.bounds.size.width, self.leftOrTopVCOffset);
            
        }
        
        BOOL show = _leftOrTopVC != nil ? !_leftOrTopVC.view.isHidden : NO;
        CGRect frame = _leftOrTopVC != nil ? NSRectToCGRect(_leftOrTopVC.view.frame) : defaultFrame;
        
        _leftOrTopVC = leftOrTopVC;
        [_leftOrTopVC.view setHidden:YES];
        _leftOrTopVC.view.frame = NSRectFromCGRect(frame);
        _leftOrTopVC.view.bounds = NSRectFromCGRect(CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height));
        
        if (show) {
            [_leftOrTopVC viewCtrlWillAppear];
            [_leftOrTopVC.view setHidden:NO];
        }
        
        [self.view addSubview:_leftOrTopVC.view];
    } while (NO);
}

- (void)setRightOrBottomVC:(NSViewController *)rightOrBottomVC {
    do {
        if (!rightOrBottomVC) {
            break;
        }
        
        if (_rightOrBottomVC != nil) {
            [_rightOrBottomVC viewCtrlWillDisappear];
            [_rightOrBottomVC.view removeFromSuperview];
        }
        
        CGRect defaultFrame = CGRectZero;
        if (self.orientation == DCSplitVCOrientation_Horizontal) {
            CGFloat locX = 0.0f;
            if (self.centerVC != nil) {
                locX += (self.centerVC.view.frame.origin.x + self.centerVC.view.frame.size.width - self.rightOrBottomVCOffset);
                locX = locX > 0 ? locX : 0;
            }
            defaultFrame = CGRectMake(locX, 0.0f, self.rightOrBottomVCOffset, self.view.bounds.size.height);
        } else if (self.orientation == DCSplitVCOrientation_Vertical) {
            defaultFrame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.rightOrBottomVCOffset);
        }
        
        BOOL show = _rightOrBottomVC != nil ? !_rightOrBottomVC.view.isHidden : NO;
        CGRect frame = _rightOrBottomVC != nil ? NSRectToCGRect(_rightOrBottomVC.view.frame) : defaultFrame;
        
        _rightOrBottomVC = rightOrBottomVC;
        [_rightOrBottomVC.view setHidden:YES];
        _rightOrBottomVC.view.frame = NSRectFromCGRect(frame);
        _rightOrBottomVC.view.bounds = NSRectFromCGRect(CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height));
        
        if (show) {
            [_rightOrBottomVC viewCtrlWillAppear];
            [_rightOrBottomVC.view setHidden:NO];
        }
        
        [self.view addSubview:_rightOrBottomVC.view];
    } while (NO);
}

- (void)setLeftOrTopVCOffset:(CGFloat)leftOrTopVCOffset {
    do {
        CGFloat diff = leftOrTopVCOffset - _leftOrTopVCOffset;
        _leftOrTopVCOffset = leftOrTopVCOffset;
        if (diff == 0) {
            break;
        }
        if (self.leftOrTopVC) {
            CGRect frameLT = NSRectToCGRect(self.leftOrTopVC.view.frame);
            if (self.orientation == DCSplitVCOrientation_Horizontal) {
                frameLT.size.width += diff;
            } else if (self.orientation == DCSplitVCOrientation_Vertical) {
                frameLT.origin.y -= diff;
                frameLT.size.height += diff;
            }
            self.leftOrTopVC.view.frame = NSRectFromCGRect(frameLT);
            self.leftOrTopVC.view.bounds = NSRectFromCGRect(CGRectMake(0.0f, 0.0f, frameLT.size.width, frameLT.size.height));
        }
        if (self.centerVC && self.leftOrTopVC && ![self.leftOrTopVC.view isHidden]) {
            CGRect frameC = NSRectToCGRect(self.centerVC.view.frame);
            if (self.orientation == DCSplitVCOrientation_Horizontal) {
                frameC.origin.x += diff;
                frameC.size.width -= diff;
            } else if (self.orientation == DCSplitVCOrientation_Vertical) {
                frameC.size.height -= diff;
            }
            self.centerVC.view.frame = NSRectFromCGRect(frameC);
            self.centerVC.view.bounds = NSRectFromCGRect(CGRectMake(0.0f, 0.0f, frameC.size.width, frameC.size.height));
        }
    } while (NO);
}

- (void)setRightOrBottomVCOffset:(CGFloat)rightOrBottomVCOffset {
    do {
        CGFloat diff = rightOrBottomVCOffset - _rightOrBottomVCOffset;
        _rightOrBottomVCOffset = rightOrBottomVCOffset;
        if (diff == 0) {
            break;
        }
        if (self.rightOrBottomVC) {
            CGRect frameRB = NSRectToCGRect(self.rightOrBottomVC.view.frame);
            if (self.orientation == DCSplitVCOrientation_Horizontal) {
                frameRB.size.width += diff;
            } else if (self.orientation == DCSplitVCOrientation_Vertical) {
                frameRB.size.height += diff;
            }
            self.rightOrBottomVC.view.frame = NSRectFromCGRect(frameRB);
            self.rightOrBottomVC.view.bounds = NSRectFromCGRect(CGRectMake(0.0f, 0.0f, frameRB.size.width, frameRB.size.height));
        }

        if (self.centerVC && self.rightOrBottomVC && ![self.rightOrBottomVC.view isHidden]) {
            CGRect frameC = NSRectToCGRect(self.centerVC.view.frame);
            if (self.orientation == DCSplitVCOrientation_Horizontal) {
                frameC.size.width -= diff;
            } else if (self.orientation == DCSplitVCOrientation_Vertical) {
                frameC.origin.y += diff;
                frameC.size.height -= diff;
            }
            self.centerVC.view.frame = NSRectFromCGRect(frameC);
            self.centerVC.view.bounds = NSRectFromCGRect(CGRectMake(0.0f, 0.0f, frameC.size.width, frameC.size.height));
        }
        _rightOrBottomVCOffset = rightOrBottomVCOffset;
    } while (NO);
}

- (void)showHideLeftOrTopViewControllerAnimated:(BOOL)animated {
    do {
        if (!self.leftOrTopVC) {
            break;
        }
        CGRect frameC = NSRectToCGRect(self.centerVC.view.frame);
        if (self.leftOrTopVC.view.isHidden) {
            if (self.orientation == DCSplitVCOrientation_Horizontal) {
                frameC.origin.x += self.leftOrTopVCOffset;
                frameC.size.width -= self.leftOrTopVCOffset;
            } else if (self.orientation == DCSplitVCOrientation_Vertical) {
                frameC.size.height -= self.leftOrTopVCOffset;
            }
        } else {
            if (self.orientation == DCSplitVCOrientation_Horizontal) {
                frameC.origin.x -= self.leftOrTopVCOffset;
                frameC.size.width += self.leftOrTopVCOffset;
            } else if (self.orientation == DCSplitVCOrientation_Vertical) {
                frameC.size.height += self.leftOrTopVCOffset;
            }
        }
        
        if (animated) {
            [NSAnimationContext beginGrouping];
            {
                [[NSAnimationContext currentContext] setDuration:DCSplitVC_DefaultAnimationDuration];
                
                self.centerVC.view.frame = NSRectFromCGRect(frameC);
                self.centerVC.view.bounds = NSRectFromCGRect(CGRectMake(0.0f, 0.0f, frameC.size.width, frameC.size.height));
                
                [self.leftOrTopVC.view setHidden:!self.leftOrTopVC.view.isHidden];
            }
            [NSAnimationContext endGrouping];
        } else {
            self.centerVC.view.frame = NSRectFromCGRect(frameC);
            self.centerVC.view.bounds = NSRectFromCGRect(CGRectMake(0.0f, 0.0f, frameC.size.width, frameC.size.height));
            
            [self.leftOrTopVC.view setHidden:!self.leftOrTopVC.view.isHidden];
        }
    } while (NO);
}

- (void)showHideRightOrBottomViewControllerAnimated:(BOOL)animated {
    do {
        if (!self.rightOrBottomVC) {
            break;
        }
        
        CGRect frameC = NSRectToCGRect(self.centerVC.view.frame);
        if (self.rightOrBottomVC.view.isHidden) {
            if (self.orientation == DCSplitVCOrientation_Horizontal) {
                frameC.size.width -= self.rightOrBottomVCOffset;
            } else if (self.orientation == DCSplitVCOrientation_Vertical) {
                frameC.origin.y += self.rightOrBottomVCOffset;
                frameC.size.height -= self.rightOrBottomVCOffset;
            }
        } else {
            if (self.orientation == DCSplitVCOrientation_Horizontal) {
                frameC.size.width += self.rightOrBottomVCOffset;
            } else if (self.orientation == DCSplitVCOrientation_Vertical) {
                frameC.origin.y -= self.rightOrBottomVCOffset;
                frameC.size.height += self.rightOrBottomVCOffset;
            }
        }
        
        if (animated) {
            [NSAnimationContext beginGrouping];
            {
                [[NSAnimationContext currentContext] setDuration:DCSplitVC_DefaultAnimationDuration];
                
                self.centerVC.view.frame = NSRectFromCGRect(frameC);
                self.centerVC.view.bounds = NSRectFromCGRect(CGRectMake(0.0f, 0.0f, frameC.size.width, frameC.size.height));
                [self.rightOrBottomVC.view setHidden:!self.rightOrBottomVC.view.isHidden];
            }
            [NSAnimationContext endGrouping];
        } else {
            self.centerVC.view.frame = NSRectFromCGRect(frameC);
            self.centerVC.view.bounds = NSRectFromCGRect(CGRectMake(0.0f, 0.0f, frameC.size.width, frameC.size.height));
            [self.rightOrBottomVC.view setHidden:!self.rightOrBottomVC.view.isHidden];
        }
    } while (NO);
}

- (void)showHideLeftOrTopViewController:(BOOL)hidden animated:(BOOL)animated {
    do {
        if (!self.leftOrTopVC) {
            break;
        }
        if (self.leftOrTopVC.view.isHidden == hidden) {
            break;
        }
        CGRect frameC = NSRectToCGRect(self.centerVC.view.frame);
        if (self.leftOrTopVC.view.isHidden) {
            if (self.orientation == DCSplitVCOrientation_Horizontal) {
                frameC.origin.x += self.leftOrTopVCOffset;
                frameC.size.width -= self.leftOrTopVCOffset;
            } else if (self.orientation == DCSplitVCOrientation_Vertical) {
                frameC.size.height -= self.leftOrTopVCOffset;
            }
        } else {
            if (self.orientation == DCSplitVCOrientation_Horizontal) {
                frameC.origin.x -= self.leftOrTopVCOffset;
                frameC.size.width += self.leftOrTopVCOffset;
            } else if (self.orientation == DCSplitVCOrientation_Vertical) {
                frameC.size.height += self.leftOrTopVCOffset;
            }
        }
        
        if (animated) {
            [NSAnimationContext beginGrouping];
            {
                [[NSAnimationContext currentContext] setDuration:DCSplitVC_DefaultAnimationDuration];
                
                self.centerVC.view.frame = NSRectFromCGRect(frameC);
                self.centerVC.view.bounds = NSRectFromCGRect(CGRectMake(0.0f, 0.0f, frameC.size.width, frameC.size.height));
                
                [self.leftOrTopVC.view setHidden:hidden];
            }
            [NSAnimationContext endGrouping];
        } else {
            self.centerVC.view.frame = NSRectFromCGRect(frameC);
            self.centerVC.view.bounds = NSRectFromCGRect(CGRectMake(0.0f, 0.0f, frameC.size.width, frameC.size.height));
            
            [self.leftOrTopVC.view setHidden:hidden];
        }
    } while (NO);
}

- (void)showHideRightOrBottomViewController:(BOOL)hidden animated:(BOOL)animated {
    do {
        if (!self.rightOrBottomVC) {
            break;
        }
        if (self.rightOrBottomVC.view.isHidden == hidden) {
            break;
        }
        CGRect frameC = NSRectToCGRect(self.centerVC.view.frame);
        if (self.rightOrBottomVC.view.isHidden) {
            if (self.orientation == DCSplitVCOrientation_Horizontal) {
                frameC.size.width -= self.rightOrBottomVCOffset;
            } else if (self.orientation == DCSplitVCOrientation_Vertical) {
                frameC.origin.y += self.rightOrBottomVCOffset;
                frameC.size.height -= self.rightOrBottomVCOffset;
            }
        } else {
            if (self.orientation == DCSplitVCOrientation_Horizontal) {
                frameC.size.width += self.rightOrBottomVCOffset;
            } else if (self.orientation == DCSplitVCOrientation_Vertical) {
                frameC.origin.y -= self.rightOrBottomVCOffset;
                frameC.size.height += self.rightOrBottomVCOffset;
            }
        }
        
        if (animated) {
            [NSAnimationContext beginGrouping];
            {
                [[NSAnimationContext currentContext] setDuration:DCSplitVC_DefaultAnimationDuration];
                
                self.centerVC.view.frame = NSRectFromCGRect(frameC);
                self.centerVC.view.bounds = NSRectFromCGRect(CGRectMake(0.0f, 0.0f, frameC.size.width, frameC.size.height));
                
                [self.rightOrBottomVC.view setHidden:hidden];
            }
            [NSAnimationContext endGrouping];
        } else {
            self.centerVC.view.frame = NSRectFromCGRect(frameC);
            self.centerVC.view.bounds = NSRectFromCGRect(CGRectMake(0.0f, 0.0f, frameC.size.width, frameC.size.height));
            
            [self.rightOrBottomVC.view setHidden:hidden];
        }
    } while (NO);
}

@end
