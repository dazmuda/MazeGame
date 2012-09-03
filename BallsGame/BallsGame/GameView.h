//
//  GameView.h
//  BallsGame
//
//  Created by Diana Zmuda on 9/3/12.
//  Copyright (c) 2012 Diana Zmuda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CMMotionManager;

@interface GameView : UIView

@property (strong, nonatomic) CMMotionManager* motionManager;

@end
