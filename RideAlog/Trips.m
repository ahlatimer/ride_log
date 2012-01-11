//
//  Trips.m
//  RideAlog
//
//  Created by Andrew Latimer on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Trips.h"

@implementation Trips

@synthesize paths, pathFileNames;

+(Trips *) loadOrInit { 
  Trips *trips = [NSKeyedUnarchiver unarchiveObjectWithData:
                   [NSData dataWithContentsOfFile:
                     [NSTemporaryDirectory() stringByAppendingPathComponent:@"trips"]]];
  if(!trips) {
    trips = [[Trips alloc] init];
    [trips save];
  }
  return trips;
}

-(Trips *) init {
  if((self = [super init]) != nil) {
    self.pathFileNames = [[NSMutableArray alloc] init];
    self.paths = [[NSMutableArray alloc] init];
  }
  
  return self;
}

-(void) encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:pathFileNames forKey:@"pathFileNames"];
}

-(id) initWithCoder:(NSCoder *)decoder {
  self = [super init];
  
  pathFileNames = [decoder decodeObjectForKey:@"pathFileNames"] ? : [[NSMutableArray alloc] init];
  paths = [self getPaths];
  
  return self;
}

-(void) save {
  [NSKeyedArchiver archiveRootObject:self toFile:[NSTemporaryDirectory() stringByAppendingPathComponent:@"trips"]];
}

-(void) addPath:(Path *) path {
  [pathFileNames addObject:path.filename];
  [[self getPaths] addObject:path];
  [self save];
}

-(Path *) getPathAtIndex:(NSUInteger)index {
  return [Path loadPathNamed:[pathFileNames objectAtIndex:index]];
}

-(NSMutableArray *) getPaths {
  if(!paths) {
    paths = [[NSMutableArray alloc] init];
    for(int i = 0; i < [pathFileNames count]; i++) {
      [paths addObject:[self getPathAtIndex:i]];
    }
  }
  
  return paths;
}

-(NSInteger) countOfPaths {
  return [[self getPaths] count];
}

@end
