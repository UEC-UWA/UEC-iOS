//
//  UECMapViewController.m
//  UEC
//
//  Created by Jad Osseiran on 27/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "UECMapViewController.h"

#import "AFJSONRequestOperation.h"

#define SPAN_LATITUDE 0.040872
#define SPAN_LONGITUDE 0.037863

#define PERTH_CENTER CLLocationCoordinate2DMake(-31.9554, 115.8585)

@interface UECMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation UECMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = self.location;
    
    self.mapView.showsUserLocation = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self gotToAddress:self.address];
}

#pragma mark - Map view

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKPinAnnotationView *pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Event Pin"];
    
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Event Pin"];
        
        pin.animatesDrop = YES;
        pin.pinColor = MKPinAnnotationColorRed;
    }
    
    return pin;
}

#pragma mark - Google geocoding

- (void)getLocationFromAddressString:(NSString *)addressStr completion:(void (^)(BOOL success, CLLocationCoordinate2D location))completionBlock
{
    //build url string using address query
	NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", addressStr];
	
	//build request URL
	NSURL *requestURL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //build NSURLRequest
    NSURLRequest *geocodingRequest = [NSURLRequest requestWithURL:requestURL
                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                  timeoutInterval:60.0];
    AFJSONRequestOperation *operation = nil;
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:geocodingRequest
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                    
                                                                    NSDictionary *locationDict = [JSON[@"results"] lastObject] [@"geometry"][@"location"];
                                                                    
                                                                    CLLocationCoordinate2D location;
                                                                    location.latitude = [locationDict[@"lat"] floatValue];
                                                                    location.longitude = [locationDict[@"lng"] floatValue];
                                                                    
                                                                    if (completionBlock) {
                                                                        completionBlock(YES, location);
                                                                    }
                                                                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                    
                                                                    CLLocationCoordinate2D location;
                                                                    location.latitude = 0.0;
                                                                    location.longitude = 0.0;
                                                                    
                                                                    if (completionBlock) {
                                                                        completionBlock(NO, location);
                                                                    }
                                                                    
                                                                    NSLog(@"Error: %@", error);
                                                                }];
    [operation start];
}


#pragma mark - Map Regions

- (void)goToLocation:(CLLocation *)location
         spanningLat:(CLLocationDegrees)latSpan
             andLong:(CLLocationDegrees)longSapn
{
    MKCoordinateRegion newRegion;
    newRegion.center = location.coordinate;
    newRegion.span.latitudeDelta = latSpan;
    newRegion.span.longitudeDelta = longSapn;
    
    [self.mapView setRegion:newRegion animated:YES];
}

- (void)gotToAddress:(NSString *)address
{
    [self getLocationFromAddressString:address completion:^(BOOL success, CLLocationCoordinate2D coordinate) {
        if (success) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                              longitude:coordinate.longitude];
            
            [self goToLocation:location spanningLat:SPAN_LATITUDE andLong:SPAN_LONGITUDE];
            
            // Show the pin.
            MKPointAnnotation *addressAnnotation = [[MKPointAnnotation alloc] init];
            addressAnnotation.title = self.eventTitle;
            addressAnnotation.subtitle = self.address;
            addressAnnotation.coordinate = coordinate;
            
            [self.mapView addAnnotation:addressAnnotation];
        } else {
            NSString *message = [[NSString alloc] initWithFormat:@"\"%@\" was not found.", address];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Address Not Found"
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
            CLLocation *perthLocation = [[CLLocation alloc] initWithLatitude:PERTH_CENTER.latitude
                                                                   longitude:PERTH_CENTER.longitude];
            [self goToLocation:perthLocation spanningLat:SPAN_LATITUDE andLong:SPAN_LONGITUDE];
        }
    }];
}

@end
