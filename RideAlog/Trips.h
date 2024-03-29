//
//  Trips.h
//  RideAlog
//
//  Created by Andrew Latimer on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Path.h"

@interface Trips : NSObject <NSCoding>

@property (nonatomic, retain) NSMutableArray *pathFileNames;
@property (nonatomic, retain) NSMutableArray *paths;

+(Trips *) loadOrInit;
-(void) encodeWithCoder:(NSCoder *)aCoder;
-(id)   initWithCoder:(NSCoder *)aDecoder;
-(void) save;
-(void) addPath:(Path *) path;
-(Path *) getPathAtIndex:(NSUInteger)index;
-(NSMutableArray *) getPaths;
-(NSInteger) countOfPaths;

@end
