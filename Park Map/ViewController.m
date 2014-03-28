//
//  ViewController.m
//  Park Map
//
//  Created by Anton Rivera on 3/18/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Location.h"

#define METERS_PER_MILE 1609.344

@interface ViewController ()

@property (strong, nonatomic) MKMapView *myMapView;
@property (strong, nonatomic) NSMutableArray *locationArray;
@property (strong, nonatomic) NSArray *searchLocations;
@property (strong, nonatomic) UITextField *searchTextField;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.locationArray = [NSMutableArray new];
    
    self.myMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-44.0)];
    self.myMapView.delegate = self;
    [self.view addSubview:self.myMapView];
    
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    self.searchTextField.delegate = self;
    self.searchTextField.placeholder = @"Search new locations...";
    self.searchTextField.backgroundColor = [UIColor whiteColor];
    [self.myMapView addSubview:self.searchTextField];

    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        [locationManager startUpdatingLocation];
    }
    
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D someLocation = [location coordinate];
    
    if ((someLocation.latitude == 0.0) && (someLocation.longitude == 0.0)) {
        someLocation.latitude = 47.6097;
        someLocation.longitude = -122.3331;
    }
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(someLocation, 3*METERS_PER_MILE, 3*METERS_PER_MILE);
    [self.myMapView setRegion:viewRegion animated:YES];
    
    
    [self downloadParkViewpoints];
}

- (void)downloadParkViewpoints
{
    NSString *searchString = [NSString stringWithFormat:@"https://opendata.socrata.com/resource/wqph-mf44.json"];
    NSURL *searchURL = [NSURL URLWithString:searchString];
    NSData *searchData = [NSData dataWithContentsOfURL:searchURL];
    NSError *error;
    NSArray *parkArray = [NSJSONSerialization JSONObjectWithData:searchData options:NSJSONReadingMutableContainers error:&error];
    
    for (NSDictionary *dictionary in parkArray)
    {
        Location *newLocation = [Location new];
        newLocation.name = [dictionary objectForKey:@"common_name"];
        
        NSDictionary *location = [dictionary objectForKey:@"viewpoint_location"];
        newLocation.address = [location objectForKey:@"human_address"];
        
        CLLocationCoordinate2D tempCoordinate;
        tempCoordinate.longitude = [[location objectForKey:@"longitude"] doubleValue];
        tempCoordinate.latitude = [[location objectForKey:@"latitude"] doubleValue];
        newLocation.coordinate = tempCoordinate;
        //        newLocation.coordinate = CLLocationCoordinate2DMake([[location objectForKey:@"latitude"] doubleValue], [[location objectForKey:@"longitude"] doubleValue]);
        
        [self.locationArray addObject:newLocation];
        
        [self.myMapView addAnnotation:newLocation];
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSString *identifier = @"MyLocation";
    if([annotation isKindOfClass:[Location class]])
    {
        MKAnnotationView *annotationView = (MKAnnotationView *)[self.myMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        
        return annotationView;
    }
    return nil;
}

-(void)search
{
    MKCoordinateRegion region;
    region.center.latitude = 47.6097;
    region.center.longitude = -122.3331;
    
    region.span.latitudeDelta = 0.2; //Roughly 15 miles.
    region.span.longitudeDelta = 0.2;
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.region = region;
    request.naturalLanguageQuery = self.searchTextField.text;
    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response , NSError *error){
        if (error) {
            NSLog(@"whoops! no stuff");
        }else{
            self.searchLocations = response.mapItems;
            for(MKMapItem *item in self.searchLocations){
                Location *loc = [[Location alloc] init];
                loc.coordinate = item.placemark.coordinate;
                loc.name = item.placemark.name;
                [self.myMapView addAnnotation:loc];
            }
        }
    };
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [localSearch startWithCompletionHandler:completionHandler];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self search];
    return TRUE;
}

- (IBAction)updateLocation:(id)sender
{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        [locationManager startUpdatingLocation];
    }
    
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D someLocation = [location coordinate];
    
    if ((someLocation.latitude == 0.0) && (someLocation.longitude == 0.0)) {
        someLocation.latitude = 47.6097;
        someLocation.longitude = -122.3331;
    }
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(someLocation, 3*METERS_PER_MILE, 3*METERS_PER_MILE);
    [self.myMapView setRegion:viewRegion animated:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
