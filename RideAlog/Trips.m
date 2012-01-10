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

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:pathFilenames forKey:@"pathFilenames"];
}

- (id)initWithCoder:(NSCoder *)decoder {
  self = [super init];
  
  pathFilenames = [decoder decodeObjectForKey:@"pathFileNames"];
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

@end
