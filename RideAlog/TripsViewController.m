//
//  TripsViewController.m
//  RideAlog
//
//  Created by Andrew Latimer on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TripsViewController.h"

@implementation TripsViewController

@synthesize delegate, trips, scrollView, pathView;

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
  scrollView.pagingEnabled = YES;
  
  for(int i = 0; i < [trips countOfPaths]; i++) {
    Path *path = [trips getPathAtIndex:i];
    
    CGFloat xOrigin = i * self.view.frame.size.width;
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(xOrigin, 0, self.view.frame.size.width, self.view.frame.size.height)];
    mapView.delegate = self;
    
    mapView.scrollEnabled = NO;
    mapView.zoomEnabled = NO;
    
    [mapView addOverlay:path];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([path getCentroid], [path getHeight], [path getWidth]);
    [mapView setRegion:region animated:NO];
    
    UITextView *name = [[UITextView alloc] initWithFrame:CGRectMake(0, 20, 320, 40)];
    name.text = [[trips getPathAtIndex:i] name];
    name.textAlignment = UITextAlignmentCenter;
    name.font = [UIFont systemFontOfSize:20];
    [mapView addSubview:name];
    
    [scrollView addSubview:mapView];
  }
  
  scrollView.contentSize = CGSizeMake(self.view.frame.size.width * [trips countOfPaths], self.view.frame.size.height);
  
  [self.view addSubview:scrollView];
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
  NSInteger page = (int) (scrollView.contentOffset.x / 320);
  if(page < [trips countOfPaths]) {
    Path *selectedPath = [trips getPathAtIndex:page];
    [delegate tripsViewController:self didSelectRoute:selectedPath];
  } else {
    [delegate tripsViewController:self didSelectRoute:nil];
  }
  
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
  pathView = [[PathView alloc] initWithOverlay:overlay];
  return pathView;
}

@end
