//
//  ViewController.h
//  RideAlog
//
//  Created by Andrew Latimer on 12/19/11.
//  Copyright (c) 2011 Andrew Latimer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Path.h"
#import "PathView.h"
#import "Trips.h"
#import "TripsViewController.h"

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, TripsViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) Path *path;
@property (nonatomic, retain) PathView *pathView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) Trips *trips;
@property (nonatomic, retain) TripsViewController *tripsViewController;

-(NSArray *) toolbarItems:(BOOL)tripsViewControllerShow;

@end
