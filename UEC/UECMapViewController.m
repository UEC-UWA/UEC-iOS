//
//  UECMapViewController.m
//  UEC
//
//  Created by Jad Osseiran on 27/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "UECMapViewController.h"

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

- (CLLocationCoordinate2D)geoCodeUsingAddress:(NSString *)address
{
    NSString *urlStr = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv",
                        [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSError *error;
    NSString *locationStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlStr] encoding:NSUTF8StringEncoding error:&error];
    NSArray *items = [locationStr componentsSeparatedByString:@","];
    
    CGFloat latitude = 0.0;
    CGFloat longitude = 0.0;
    
    if ([items count] >= 4 && [[items objectAtIndex:0] isEqualToString:@"200"]) {
        latitude = [[items objectAtIndex:2] doubleValue];
        longitude = [[items objectAtIndex:3] doubleValue];
    } else {
        NSLog(@"Address, %@ not found: Error %@",address, [items objectAtIndex:0]);
    }
    
    CLLocationCoordinate2D location;
    location.latitude = latitude;
    location.longitude = longitude;
    
    return location;
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
#warning not smooth zooming and cluncky code.
    CLLocation *perthLocation = [[CLLocation alloc] initWithLatitude:PERTH_CENTER.latitude
                                                           longitude:PERTH_CENTER.longitude];
    [self goToLocation:perthLocation spanningLat:SPAN_LATITUDE andLong:SPAN_LONGITUDE];
    
    CLLocationCoordinate2D center = [self geoCodeUsingAddress:address];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:center.latitude
                                                      longitude:center.longitude];
    
    [self goToLocation:location spanningLat:SPAN_LATITUDE andLong:SPAN_LONGITUDE];
    
    // Show the pin.
    MKPointAnnotation *addressAnnotation = [[MKPointAnnotation alloc] init];
    addressAnnotation.title = self.eventTitle;
    addressAnnotation.subtitle = self.address;
    addressAnnotation.coordinate = center;
        
    [self.mapView addAnnotation:addressAnnotation];
}

@end
