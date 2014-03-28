//
//  Location.h
//  Park Map
//
//  Created by Anton Rivera on 3/18/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Location : NSObject <MKAnnotation>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;

@property (nonatomic) CLLocationCoordinate2D coordinate;

@end
