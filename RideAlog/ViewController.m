//
//  ViewController.m
//  RideAlog
//
//  Created by Andrew Latimer on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize mapView, path, pathView, locationManager, toolbar, trips, tripsViewController;

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
}

#pragma mark - View lifecycle


- (void)loadView {
  [super loadView];  
  // mapview
  mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
  [mapView setShowsUserLocation:YES];
  mapView.delegate = self;
  
  [self.view addSubview:self.mapView];
  
  // toolbar
  toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44.0, self.view.bounds.size.width, 44.0f)];
  toolbar.items = [self toolbarItems:NO];
  [self.view addSubview:self.toolbar];
  
  trips = [Trips loadOrInit];
}

-(void) createRoute {
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Name:" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Done", nil];
  [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
  [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
  if([title isEqualToString:@"Done"])
  {
    NSString *name = [[alertView textFieldAtIndex:0] text];
    
    // Save the old path and remove it from the map
    if(path) {
      [path save];
      [mapView removeOverlay:path];
      self.path = nil;
      self.pathView = nil;
    }
    
    CLLocation *location = [locationManager location];
    
    path = [[Path alloc] initWithCenterCoordinate:location.coordinate name:name];
    [mapView addOverlay:path];
    
    // On the first location update only, zoom map to user location
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000);
    [mapView setRegion:region animated:YES];
    
    [trips addPath:path];
  }
}

-(void) showRoutes {
  // show all of the routes
  tripsViewController = [[TripsViewController alloc] initWithNibName:nil bundle:nil];
  [self.view addSubview:tripsViewController.view];  
  self.tripsViewController.delegate = self;
  toolbar.items = [self toolbarItems:YES];
}

-(void) hideRoutes {
  // show all of the routes
  toolbar.items = [self toolbarItems:NO];
  
  [self.tripsViewController.view removeFromSuperview];
}

-(NSArray *) toolbarItems:(BOOL)tripsViewControllerShown {
  UIBarButtonItem *addNewMap = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createRoute)];
  UIBarButtonItem *showMaps = nil;
  
  if(tripsViewControllerShown) {
    showMaps = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.tripsViewController action:@selector(selectRoute)];
  } else {
    showMaps = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(showRoutes)];
  }
  
  UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  return [NSArray arrayWithObjects:showMaps, flexibleSpace, addNewMap, nil];
}

-(void) tripsViewController:(TripsViewController *)viewController didSelectRoute:(Path *)aPath {
  [self hideRoutes];
  
  if(aPath) {
    if(path) {
      [path save];
      [mapView removeOverlay:path];
      self.path = nil;
      self.pathView = nil;
    }
    
    self.path = aPath;
    [mapView addOverlay:path];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([path getCentroid], [path getHeight], [path getWidth]);
    [mapView setRegion:region animated:NO];
  }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self; // Tells the location manager to send updates to this object
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
  [self.locationManager startUpdatingLocation];
}


- (void)viewDidUnload {
  [super viewDidUnload];
  
  self.mapView = nil;
  self.path = nil;
  self.pathView = nil;
  self.locationManager = nil;
  self.toolbar = nil;
  self.tripsViewController = nil;
  self.trips = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
  if(newLocation) {		
		// make sure the old and new coordinates are different
    if((oldLocation.coordinate.latitude != newLocation.coordinate.latitude) &&
        (oldLocation.coordinate.longitude != newLocation.coordinate.longitude)) {    
      if(path) {
        MKMapRect updateRect = [path addCoordinate:newLocation.coordinate];
        
        if (!MKMapRectIsNull(updateRect)) {
          // There is a non null update rect.
          // Compute the currently visible map zoom scale
          MKZoomScale currentZoomScale = (CGFloat)(mapView.bounds.size.width / mapView.visibleMapRect.size.width);
          // Find out the line width at this zoom scale and outset the updateRect by that amount
          CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
          updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
          // Ask the overlay view to update just the changed area.
          [pathView setNeedsDisplayInMapRect:updateRect];
        }
      }
    }
  }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
  if (!pathView) {
    pathView = [[PathView alloc] initWithOverlay:overlay];
  }
  return pathView;
}

@end

