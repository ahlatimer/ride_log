//
//  TripsViewController.h
//  RideAlog
//
//  Created by Andrew Latimer on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Path.h"
#import "Trips.h"

@class TripsViewController;

@protocol TripsViewControllerDelegate <NSObject>

-(void) tripsViewController:(TripsViewController *) viewController
             didSelectRoute:(Path *) path;

@end

@interface TripsViewController : UIViewController
  
@property (nonatomic, assign) NSObject<TripsViewControllerDelegate> *delegate;
@property (nonatomic, retain) Trips *trips;
@property (nonatomic, retain) UIScrollView *scrollView;

@end
