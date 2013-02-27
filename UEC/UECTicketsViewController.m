//
//  UECTicketsViewController.m
//  UEC
//
//  Created by Jad Osseiran on 9/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECTicketsViewController.h"

@interface UECTicketsViewController ()

@end

@implementation UECTicketsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fetchedResultsController = [[APSDataManager sharedManager] fetchedResultsControllerWithRequest:^(NSFetchRequest *request) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];
        request.sortDescriptors = @[sortDescriptor];
    } entityName:@"Event" sectionNameKeyPath:@"startSale" cacheName:nil];
}

@end
