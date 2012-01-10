//
//  Path.h
//  RideAlog
//
//  Created by Andrew Latimer on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <pthread.h>
#import "Waypoint.h"

@interface Path : NSObject <MKOverlay, NSCoding>
{ 
  MKMapRect boundingMapRect;
  MKMapPoint *points;
  NSUInteger pointCount;
  NSUInteger pointSpace;
  
  pthread_rwlock_t rwLock;
}

// Initialize the CrumbPath with the starting coordinate.
// The CrumbPath's boundingMapRect will be set to a sufficiently large square
// centered on the starting coordinate.
//
- (id)initWithCenterCoordinate:(CLLocationCoordinate2D)coord name:(NSString *)n;

// Add a location observation. A MKMapRect containing the newly added point
// and the previously added point is returned so that the view can be updated
// in that rectangle.  If the added coordinate has not moved far enough from
// the previously added coordinate it will not be added to the list and 
// MKMapRectNull will be returned.
//
- (MKMapRect)addCoordinate:(CLLocationCoordinate2D)coord;

- (void)lockForReading;

// The following properties must only be accessed when holding the read lock
// via lockForReading.  Once you're done accessing the points, release the
// read lock with unlockForReading.
//
@property (readonly) MKMapPoint *points;
@property (readonly) NSUInteger pointCount;
@property (nonatomic, retain) NSString *name;

- (void)unlockForReading;
- (void)save;

@end
