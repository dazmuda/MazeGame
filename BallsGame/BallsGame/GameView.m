//
//  GameView.m
//  BallsGame
//
//  Created by Diana Zmuda on 9/3/12.
//  Copyright (c) 2012 Diana Zmuda. All rights reserved.
//

#import "GameView.h"
#import <CoreMotion/CoreMotion.h>
#import "Line.h"

@interface GameView ()
@property (strong, nonatomic) CMMotionManager* motionManager;
@property (strong) NSMutableArray *lines;
@property CGPoint ballLoc;
@property CGPoint holeLoc;
@property BOOL gameOver;
@property CGRect holeRect;
@property (strong) UIImageView *ballView;
@property (strong) UIImageView *boxView;
@end

@implementation GameView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
//        UIImage *bgImage = [UIImage imageNamed:@"wallpaper.png"];
//        self.backgroundColor = [UIColor colorWithPatternImage:bgImage];
        self.ballLoc = CGPointMake(100, 100);
        self.lines = [NSMutableArray new];
        
        //initializing the views
        self.ballView = [UIImageView new];
        self.boxView = [UIImageView new];
        
        self.holeRect = CGRectMake(self.bounds.size.width/2, self.bounds.size.height*.75, 40, 40);
        self.holeLoc = CGPointMake(self.holeRect.origin.x + (self.holeRect.size.width/2), self.holeRect.origin.y + (self.holeRect.size.height/2));
        
        for (int i = 0; i<4; ++i) {
            Line *vLine = [Line new];
            CGFloat x,y;
            
            //a do/while loop does the do loop first and then checks the conditions in the while loop
            do {
                //create a new line
                x = (CGFloat)(arc4random()%(int)self.bounds.size.width);
                y = (CGFloat)(arc4random()%(int)self.bounds.size.height);
                vLine.start = CGPointMake(x, y);
                vLine.end = CGPointMake(x+100, y);
            //if this line intersects the ball or the hole DO IT AGAIN
            } while (DistanceFromPointToLine(self.ballLoc, vLine) < 21 || DistanceFromPointToLine(self.holeLoc, vLine) < 21);
            //if not, add it to the line array
            [self.lines addObject:vLine];
            
            Line *hLine = [Line new];
            do {
                x = (CGFloat)(arc4random()%(int)self.bounds.size.width);
                y = (CGFloat)(arc4random()%(int)self.bounds.size.height);
                hLine.start = CGPointMake(x, y);
                hLine.end = CGPointMake(x, y+100);
            } while (DistanceFromPointToLine(self.ballLoc, hLine) < 21 || DistanceFromPointToLine(self.holeLoc, hLine) < 21);
            [self.lines addObject:hLine];
        }

        
        
        self.motionManager = [CMMotionManager new];
        self.motionManager.deviceMotionUpdateInterval = .01;
        //- (void)startDeviceMotionUpdatesToQueue:(NSOperationQueue *)queue withHandler:(CMDeviceMotionHandler)handler
        [self.motionManager startDeviceMotionUpdatesToQueue: [NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            if (!self.gameOver) {
                [self setBallPoint];
                self.gameOver = [self checkInHole];
                [self setNeedsDisplay];
            }
        }];
    
    }
    return self;
}

-(void)setBallPoint
{
    //constraining the new ball point to the screen
    CGFloat newX = MIN(MAX(self.ballLoc.x + self.motionManager.deviceMotion.attitude.roll*10, 0), self.bounds.size.width);
    CGFloat newY = MIN(MAX(self.ballLoc.y + self.motionManager.deviceMotion.attitude.pitch*10,0), self.bounds.size.height);

    //constraining the ball to walls
    //if the new y direction that you want to move to causes a collision
    //keep the same y as before the collision
    if ( [self checkCollision:CGPointMake(self.ballLoc.x, newY) ] ) {
        newY = self.ballLoc.y;
    }

    //constraining the ball to walls
    //if the new x direction that you want to move to causes a collision
    //keep the same x as before the collision
    if ( [self checkCollision:CGPointMake(newX, self.ballLoc.y)] ) {
        newX = self.ballLoc.x;
    }
    
    self.ballLoc = CGPointMake(newX, newY);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    NSLog(@"THE YAW IS = %f", self.motionManager.deviceMotion.attitude.yaw);
//    NSLog(@"THE PITCH IS = %f", self.motionManager.deviceMotion.attitude.pitch);
//    NSLog(@"THE ROLL IS = %f", self.motionManager.deviceMotion.attitude.roll);
    
    //OLD BOX
//    [[UIColor blackColor] set];
//    CGContextFillRect(context, self.holeRect);
//    CGContextFillPath(context);
    
    //CHERRIES BOX
    [self.boxView removeFromSuperview];
    UIImage *boxImage = [UIImage imageNamed:@"cherries.png"];
    self.boxView = [[UIImageView alloc] initWithFrame:self.holeRect];
    self.boxView.image = boxImage;
    [self addSubview:self.boxView];
    
    //OLD BALL
    //[[UIColor yellowColor] set];
    //CGContextAddArc(context, self.ballLoc.x, self.ballLoc.y , 20, 0, M_PI * 2, NO);
    //CGContextFillPath(context);
    
    //PAC MAN BALL
    //remove the old view so it doesn't leave a trail
    [self.ballView removeFromSuperview];
    //make a new rect that contains the ball
    CGRect ballRect = CGRectMake(self.ballLoc.x-20, self.ballLoc.y-20, 40, 40);
    //create the image with a png with no background
    UIImage *ballImage = [UIImage imageNamed:@"pacman.png"];
    //and a view with the image and add this as a subview
    self.ballView = [[UIImageView alloc] initWithFrame:ballRect];
    self.ballView.image = ballImage;
    [self addSubview:self.ballView];

    
    //draw the lines
    for (Line *line in self.lines) {
        CGContextMoveToPoint(context, line.start.x, line.start.y);
        CGContextAddLineToPoint(context, line.end.x, line.end.y);
    }
    [[UIColor whiteColor] set];
    CGContextStrokePath(context);

}

-(BOOL)checkInHole
{
    //check if the ball intersects the box
    
    if (DistanceBetweenTwoPoints(self.holeLoc, self.ballLoc) < 5) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Winner!" message:@"You put your ball in my hole!" delegate:nil cancelButtonTitle:@"This does nothing" otherButtonTitles: nil];
        [alert show];
        return YES;
    }
    return NO;
}

CGFloat DistanceBetweenTwoPoints(CGPoint point1,CGPoint point2)
{
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy );
};

CGFloat DistanceFromPointToLine(CGPoint point, Line *line) {
    CGFloat A = (line.end.y - line.start.y);
    CGFloat B = -(line.end.x - line.start.x);
    CGFloat C = -((A*line.start.x) + (B*line.start.y));
    
    //you are closest to the line
    return fabs((A*point.x) + (B*point.y) + C)/sqrt((A*A)+(B*B));
}

-(BOOL)checkCollision: (CGPoint)point
{
    //point(m,n)
    //our point is the center of our ball
    //Ax + By + C = 0
    //float distance = fabs(Am+Bn+C) / sqrt(A*A+B*B);
    // slope = -A/B

    
    BOOL collided = NO;
    
    for (Line *line in self.lines) {
        
        if ( (line.start.x <= point.x  && point.x <= line.end.x) || (line.start.y <= point.y  && point.y <= line.end.y)
            || DistanceBetweenTwoPoints(line.start, point) < 20 || DistanceBetweenTwoPoints(line.end, point) <20 )
        {
            
            CGFloat realDistance = DistanceFromPointToLine(point, line) - 20;
            if (realDistance <= 0) {
                collided = YES;
            }
        };

    }
    
    return collided;
}

@end
