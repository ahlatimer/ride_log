//
//  Trips.m
//  RideAlog
//
//  Created by Andrew Latimer on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Trips.h"

@implementation Trips

@synthesize paths, pathFilenames;

+(Trips *) loadOrInit { 
  Trips *trips = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingPathComponent:@"trips"]]];
  if(!trips) {
    trips = [[Trips alloc] init];
    [trips save];
  }
  return trips;
}

-(Trips *) init {
  if((self = [super init]) != nil) {
    self.pathFilenames = [[NSMutableArray alloc] init];
    self.paths = [[NSMutableArray alloc] init];
  }
  
  return self;
}

-(void) encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:pathFilenames forKey:@"pathFilenames"];
}

-(id) initWithCoder:(NSCoder *)decoder {
  self = [super init];
  
  pathFilenames = [decoder decodeObjectForKey:@"pathFileNames"] ? : [[NSMutableArray alloc] init];
  paths = [self getPaths];
  
  return self;
}

-(void) save {
  [NSKeyedArchiver archiveRootObject:self toFile:[NSTemporaryDirectory() stringByAppendingPathComponent:@"trips"]];
}

-(void) addPath:(Path *) path {
  [pathFilenames addObject:path.filename];
  [[self getPaths] addObject:path];
  [self save];
}

-(Path *) getPathAtIndex:(NSUInteger)index {
  return [Path loadPathNamed:[paths objectAtIndex:index]];
}

-(NSMutableArray *) getPaths {
  if(!paths) {
    paths = [[NSMutableArray alloc] init];
    for(int i = 0; i < [pathFilenames count]; i++) {
      [paths addObject:[self getPathAtIndex:i]];
    }
  }
  
  return paths;
}

-(NSInteger) countOfPaths {
  return [paths count];
}

@end
