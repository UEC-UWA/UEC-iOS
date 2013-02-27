//
//  UECEventListViewController.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECEventsListViewController.h"

@interface UECEventsListViewController ()

@end

@implementation UECEventsListViewController

- (void)viewDidLoad
{    
    [super viewDidLoad];
        
    self.fetchedResultsController = [[APSDataManager sharedManager] fetchedResultsControllerWithRequest:^(NSFetchRequest *request) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];
        request.sortDescriptors = @[sortDescriptor];
    } entityName:@"Event" sectionNameKeyPath:@"startDate" cacheName:nil];
}

@end
