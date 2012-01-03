//
//  Path.m
//  RideAlog
//
//  Created by Andrew Latimer on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Path.h"

#define INITIAL_POINT_SPACE 1000
#define MINIMUM_DELTA_METERS 10.0

@implementation Path

@synthesize points;

- (id)initWithCenterCoordinate:(CLLocationCoordinate2D)coord {
	self = [super init];
  if(self) {
    NSLog(@"Initializing Path");
    points = [[NSMutableArray alloc] initWithCapacity:(NSInteger) INITIAL_POINT_SPACE]; 
    Waypoint *point = [[Waypoint alloc] initWithPoint:MKMapPointForCoordinate(coord)];
    [points addObject:point];
    
    // bite off up to 1/4 of the world to draw into.
    MKMapPoint origin = point.point;
    origin.x -= MKMapSizeWorld.width / 8.0;
    origin.y -= MKMapSizeWorld.height / 8.0;
    MKMapSize size = MKMapSizeWorld;
    size.width /= 4.0;
    size.height /= 4.0;
    boundingMapRect = (MKMapRect) { origin, size };
    MKMapRect worldRect = MKMapRectMake(0, 0, MKMapSizeWorld.width, MKMapSizeWorld.height);
    boundingMapRect = MKMapRectIntersection(boundingMapRect, worldRect);
    
    // initialize read-write lock for drawing and updates
    pthread_rwlock_init(&rwLock, NULL);
  }
  return self;
}

- (void)dealloc
{
  pthread_rwlock_destroy(&rwLock);
}

- (CLLocationCoordinate2D)coordinate
{
  Waypoint *waypoint = [points objectAtIndex:(NSInteger) 0];
  return MKCoordinateForMapPoint(waypoint.point);
}

- (MKMapRect)boundingMapRect
{
  return boundingMapRect;
}

- (void)lockForReading
{
  pthread_rwlock_rdlock(&rwLock);
}

- (void)unlockForReading
{
  pthread_rwlock_unlock(&rwLock);
}

- (MKMapRect)addCoordinate:(CLLocationCoordinate2D)coord
{
  // Acquire the write lock because we are going to be changing the list of points
  pthread_rwlock_wrlock(&rwLock);
  
  // Convert a CLLocationCoordinate2D to an MKMapPoint
  Waypoint *newPoint = [[Waypoint alloc] initWithPoint:MKMapPointForCoordinate(coord)];
  Waypoint *prevPoint = [points lastObject]; 
  
  // Get the distance between this new point and the previous point.
  CLLocationDistance metersApart = MKMetersBetweenMapPoints(newPoint.point, prevPoint.point);
  MKMapRect updateRect = MKMapRectNull;
  
  if(metersApart > MINIMUM_DELTA_METERS) {    
    NSString *string = [NSString stringWithFormat:@"Added point, x: %i y: %i", newPoint.x, newPoint.y];
    NSLog(string);
    
    // Add the new point to the points array
    [points addObject:newPoint];
    
    // Compute MKMapRect bounding prevPoint and newPoint
    double minX = MIN(newPoint.x, prevPoint.x);
    double minY = MIN(newPoint.y, prevPoint.y);
    double maxX = MAX(newPoint.x, prevPoint.x);
    double maxY = MAX(newPoint.y, prevPoint.y);
    
    updateRect = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
  }
  
  pthread_rwlock_unlock(&rwLock);
  
  return updateRect;
}

@end
