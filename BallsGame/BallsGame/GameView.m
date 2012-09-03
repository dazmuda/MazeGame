//
//  GameView.m
//  BallsGame
//
//  Created by Diana Zmuda on 9/3/12.
//  Copyright (c) 2012 Diana Zmuda. All rights reserved.
//

#import "GameView.h"
#import <CoreMotion/CoreMotion.h>

@implementation GameView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.motionManager = [CMMotionManager new];
        self.motionManager.deviceMotionUpdateInterval = .1;
        //[self.motionManager startDeviceMotionUpdates];
        //- (void)startDeviceMotionUpdatesToQueue:(NSOperationQueue *)queue withHandler:(CMDeviceMotionHandler)handler
        [self.motionManager startDeviceMotionUpdatesToQueue: [NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            [self setNeedsDisplay];
        }];
    
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddArc(context, 100, 100, 20, 0, M_PI * 2, NO);
    [[UIColor redColor] set];
    CGContextFillPath(context);
    
    NSLog(@"THE YAW IS = %f", self.motionManager.deviceMotion.attitude.yaw);
    NSLog(@"THE PITCH IS = %f", self.motionManager.deviceMotion.attitude.pitch);
    NSLog(@"THE ROLL IS = %f", self.motionManager.deviceMotion.attitude.roll);
}

@end
