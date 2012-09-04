//
//  Line.m
//  BallsGame
//
//  Created by Diana Zmuda on 9/3/12.
//  Copyright (c) 2012 Diana Zmuda. All rights reserved.
//

#import "Line.h"

@implementation Line
@synthesize start, end;

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:NSStringFromCGPoint(self.start) forKey:@"start"];
    [aCoder encodeObject:NSStringFromCGPoint(self.end) forKey:@"end"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.start = CGPointFromString([aDecoder decodeObjectForKey:@"start"]);
        self.end = CGPointFromString([aDecoder decodeObjectForKey:@"end"]);
    }
    return self;
}

@end
