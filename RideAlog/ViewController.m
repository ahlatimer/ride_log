//
//  ViewController.m
//  RideAlog
//
//  Created by Andrew Latimer on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize mapView, path, pathView, locationManager, containerView, toolbar;

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
  [super loadView];
  [self.view setBackgroundColor:[UIColor whiteColor]];
  
  // mapview
  mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
  [mapView setShowsUserLocation:YES];
  mapView.delegate = self;
  
  [self.view addSubview:self.mapView];
  
  // toolbar
  toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44.0, self.view.bounds.size.width, 44.0f)];
  
  UIBarButtonItem *addNewMap = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createRoute)];
  toolbar.items = [NSArray arrayWithObject:addNewMap];
  
  [self.view addSubview:self.toolbar];
}

-(void) createRoute 
{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"hello" message:@"you clicked me" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
  [alertView show];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self; // Tells the location manager to send updates to this object
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
  [self.locationManager startUpdatingLocation];
}


- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
  if(newLocation) {		
		// make sure the old and new coordinates are different
    if ((oldLocation.coordinate.latitude != newLocation.coordinate.latitude) &&
        (oldLocation.coordinate.longitude != newLocation.coordinate.longitude))
    {    
      if (!path)
      {
        // This is the first time we're getting a location update, so create
        // the CrumbPath and add it to the map.
        //
        path = [[Path alloc] initWithCenterCoordinate:newLocation.coordinate];
        [mapView addOverlay:path];
        
        // On the first location update only, zoom map to user location
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000);
        [mapView setRegion:region animated:YES];
      }
      else
      {
        // This is a subsequent location update.
        // If the crumbs MKOverlay model object determines that the current location has moved
        // far enough from the previous location, use the returned updateRect to redraw just
        // the changed area.
        //
        // note: iPhone 3G will locate you using the triangulation of the cell towers.
        // so you may experience spikes in location data (in small time intervals)
        // due to 3G tower triangulation.
        // 
        MKMapRect updateRect = [path addCoordinate:newLocation.coordinate];
        
        if (!MKMapRectIsNull(updateRect))
        {
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

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
  if (!pathView)
  {
    pathView = [[PathView alloc] initWithOverlay:overlay];
  }
  return pathView;
}

@end

