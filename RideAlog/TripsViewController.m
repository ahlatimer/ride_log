//
//  TripsViewController.m
//  RideAlog
//
//  Created by Andrew Latimer on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TripsViewController.h"

@implementation TripsViewController

@synthesize delegate, trips, scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    trips = [Trips loadOrInit];
  }
  return self;
}

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
  [super loadView];
  
  self.view.frame = CGRectMake(0, 0, 320, 480 - 64);
  
  scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
  
  for(Path *path in [trips getPaths]) {
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    [mapView addOverlay:path];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(MKCoordinateForMapPoint([path points][0]), 2000, 2000);
    [mapView setRegion:region animated:NO];
    
    [scrollView addSubview:mapView];
  }
  
  self.view = scrollView;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  
  scrollView.contentSize = CGSizeMake(320 * [trips countOfPaths], 480 - 64);
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) selectRoute {
  [delegate tripsViewController:self didSelectRoute:nil];
  
}

@end
