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

@synthesize points, pointCount, name, filename;

- (id)initWithCenterCoordinate:(CLLocationCoordinate2D)coord name:(NSString *)n {
	self = [super init];
  if(self) {
    self.name = n;
    
    pointSpace = INITIAL_POINT_SPACE;
    points = malloc(sizeof(MKMapPoint) * pointSpace);
    points[0] = MKMapPointForCoordinate(coord);
    pointCount = 1;

    MKMapPoint origin = points[0];
    origin.x -= MKMapSizeWorld.width / 8.0;
    origin.y -= MKMapSizeWorld.height / 8.0;
    MKMapSize size = MKMapSizeWorld;
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
  free(points);
  pthread_rwlock_destroy(&rwLock);
}

- (CLLocationCoordinate2D)coordinate 
{
  return MKCoordinateForMapPoint(points[0]);
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
  MKMapPoint newPoint = MKMapPointForCoordinate(coord);
  MKMapPoint prevPoint = points[pointCount - 1];
  
  // Get the distance between this new point and the previous point.
  CLLocationDistance metersApart = MKMetersBetweenMapPoints(newPoint, prevPoint);
  MKMapRect updateRect = MKMapRectNull;
  
  if (metersApart > MINIMUM_DELTA_METERS)
  {
    // Grow the points array if necessary
    if (pointSpace == pointCount)
    {
      pointSpace *= 2;
      points = realloc(points, sizeof(MKMapPoint) * pointSpace);
    }    
    
    // Add the new point to the points array
    points[pointCount] = newPoint;
    pointCount++;
    
    // Compute MKMapRect bounding prevPoint and newPoint
    double minX = MIN(newPoint.x, prevPoint.x);
    double minY = MIN(newPoint.y, prevPoint.y);
    double maxX = MAX(newPoint.x, prevPoint.x);
    double maxY = MAX(newPoint.y, prevPoint.y);
    
    updateRect = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
    [self save];
  }
  
  pthread_rwlock_unlock(&rwLock);
  
  return updateRect;
}


-(void) save {
  if(!self.filename) {
    self.filename = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
  }
  [NSKeyedArchiver archiveRootObject:self toFile:[NSTemporaryDirectory() stringByAppendingPathComponent:self.filename]];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
  NSMutableArray *array = [[NSMutableArray alloc] init];
  for(int i = 0; i < pointCount; i++) {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithDouble:points[i].x], @"x", [NSNumber numberWithDouble:points[i].y], @"y", nil];
    [array addObject:dict];
  }
  [encoder encodeObject:array forKey:@"points"];
  [encoder encodeObject:self.name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)decoder {
  self = [super init];
  NSArray *array = [decoder decodeObjectForKey:@"points"];
  points = malloc(sizeof(MKMapPoint) * [array count]);
  pointCount = [array count];
  pointSpace = pointCount;
  
  for(int i = 0; i < pointCount; i++) {
    NSDictionary *dict = [array objectAtIndex:i];
    
    points[i].x = [[dict objectForKey:@"x"] doubleValue];
    points[i].y = [[dict objectForKey:@"y"] doubleValue];
  }
  
  self.name = [decoder decodeObjectForKey:@"name"];
  
  MKMapPoint origin = points[0];
  origin.x -= MKMapSizeWorld.width / 8.0;
  origin.y -= MKMapSizeWorld.height / 8.0;
  MKMapSize size = MKMapSizeWorld;
  boundingMapRect = (MKMapRect) { origin, size };
  MKMapRect worldRect = MKMapRectMake(0, 0, MKMapSizeWorld.width, MKMapSizeWorld.height);
  boundingMapRect = MKMapRectIntersection(boundingMapRect, worldRect);
  
  pthread_rwlock_init(&rwLock, NULL);
  
  return self;
}

+(Path *) loadPathNamed:(NSString *)name {
  Path *path = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingPathComponent:name]]];
  path.filename = name;
  return path;
}

@end
