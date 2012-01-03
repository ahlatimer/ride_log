//
//  Waypoint.m
//  RideAlog
//
//  Created by Andrew Latimer on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Waypoint.h"

@implementation Waypoint

@synthesize x, y, point;

- (id)initWithPoint:(MKMapPoint)pointStruct {
  self = [super init];
  if(self) {
    point = pointStruct;
    x = pointStruct.x;
    y = pointStruct.y;
  }
  
  return self;
}

@end
