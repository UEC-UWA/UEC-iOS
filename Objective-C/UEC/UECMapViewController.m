//
//  UECMapViewController.m
//  UEC
//
//  Created by Jad Osseiran on 27/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

@import MapKit;

#import <AFNetworking/AFHTTPRequestOperation.h>

#import "UECMapViewController.h"

#define SPAN_LATITUDE 0.040872
#define SPAN_LONGITUDE 0.037863

#define PERTH_CENTER CLLocationCoordinate2DMake(-31.9554, 115.8585)

#define GOOGLE_GEO_ADDRESS @"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true"

@interface UECMapViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation UECMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.tintColor = UEC_YELLOW;

    self.title = self.location;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self gotToAddress:self.address];
}

#pragma mark - Map view

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;

    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Event Pin"];

    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Event Pin"];

        pin.animatesDrop = YES;
        pin.pinColor = MKPinAnnotationColorRed;
    }

    return pin;
}

#pragma mark - Google geocoding

- (void)hitGoogleWithURLString:(NSString *)urlString
                       success:(void (^)(CLLocationCoordinate2D coordinate, NSString *googleError))success
                       failure:(void (^)(NSError *error))failure {
    //build request URL
    NSURL *requestURL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //build NSURLRequest
    NSURLRequest *geocodingRequest = [NSURLRequest requestWithURL:requestURL
                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                  timeoutInterval:60.0];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
        initWithRequest:geocodingRequest];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *results = responseObject[@"results"];
        NSDictionary *locationDict = [results firstObject][@"geometry"][@"location"];
        
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([locationDict[@"lat"] doubleValue],
                                                                     [locationDict[@"lng"] doubleValue]);
        
        if (success) {
            success(location, responseObject[@"error_message"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    [operation start];
}

- (void)getLocationFromAddressString:(NSString *)addressStr
                          completion:(void (^)(BOOL success, CLLocationCoordinate2D coordinate, NSString *googleError))completionBlock {
    [self hitGoogleWithURLString:[NSString stringWithFormat:GOOGLE_GEO_ADDRESS, addressStr]
        success:^(CLLocationCoordinate2D coordinate, NSString *googleError) {
        if (completionBlock) {
            completionBlock(YES, coordinate, googleError);
        }
        }
        failure:^(NSError *error) {
        if (completionBlock) {
            completionBlock(NO, CLLocationCoordinate2DMake(0.0, 0.0), nil);
        }
        
        if (error != nil) {
            [error handle];
        }
        }];
}

#pragma mark - Map Regions

- (void)goToLocation:(CLLocation *)location
         spanningLat:(CLLocationDegrees)latSpan
             andLong:(CLLocationDegrees)longSapn {
    MKCoordinateRegion newRegion;
    newRegion.center = location.coordinate;
    newRegion.span.latitudeDelta = latSpan;
    newRegion.span.longitudeDelta = longSapn;

    [self.mapView setRegion:newRegion animated:YES];
}

- (void)gotToAddress:(NSString *)address {
    [self getLocationFromAddressString:address completion:^(BOOL success, CLLocationCoordinate2D coordinate, NSString *googleError) {
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
