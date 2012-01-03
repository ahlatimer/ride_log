//
//  Waypoint.h
//  RideAlog
//
//  Created by Andrew Latimer on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Waypoint : NSObject {
  MKMapPoint point;
  int x;
  int y;
}

@property (readonly) MKMapPoint point;
@property (readonly) int x;
@property (readonly) int y;

- (id)initWithPoint:(MKMapPoint)point;


@end
