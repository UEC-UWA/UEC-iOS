//
//  UECMonthViewController.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <TimesSquare/TimesSquare.h>

#import "UECMonthViewController.h"

#import "UECCalendarRowCell.h"

#import "APSDataManager.h"
#import "NSDate+Helper.h"

@interface TSQCalendarView (AccessingPrivateStuff)

@property (nonatomic, readonly) UITableView *tableView;

@end

@interface UECMonthViewController () <TSQCalendarViewDelegate, NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) TSQCalendarView *calendarView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation UECMonthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.calendarView = [[TSQCalendarView alloc] init];
    self.calendarView.calendar = [NSCalendar currentCalendar];
    self.calendarView.rowCellClass = [UECCalendarRowCell class];
    self.calendarView.firstDate = [[NSDate date] startOfCurrentYear];
    self.calendarView.lastDate = [[NSDate date] endOfCurrentYear];
    self.calendarView.backgroundColor = [UIColor colorWithRed:0.84f green:0.85f blue:0.86f alpha:1.0f];
    self.calendarView.pagingEnabled = NO;
    CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
    self.calendarView.contentInset = UIEdgeInsetsMake(0.0f, onePixel, 0.0f, onePixel);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.calendarView.tableView addSubview:self.refreshControl];
    
//    self.calendarView.dataSource = self;
    self.calendarView.delegate = self;
    
    self.view = self.calendarView;
    
    self.fetchedResultsController = [[APSDataManager sharedManager] fetchedResultsControllerWithRequest:^(NSFetchRequest *request) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
        request.sortDescriptors = @[sortDescriptor];
    } entityName:@"Event" sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchedResultsController.delegate = self;
    
    [self.delegate didRequestDataOnManualRefresh:NO completion:^{
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Actions

- (void)handleRefresh:(id)sender
{
    // Refresh data here
    
    [self.delegate didRequestDataOnManualRefresh:YES completion:^{
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
        
        [self.calendarView.tableView reloadData];
        
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - TSQCalendarViewDelegate

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    
}

#pragma mark - TSQCalendarViewDataSource

- (NSArray *)calendarViewEventDaes
{
    NSArray *events = [self.fetchedResultsController fetchedObjects];
    
//    NSLog(@"CUNT: %@", [events valueForKeyPath:@"@distinctUnionOfObjects.startDate"]);
    
    NSArray *cunt = [events valueForKeyPath:@"@distinctUnionOfObjects.startDate"];
    
    if (cunt)
    return @[[cunt lastObject]];
    else
        return nil;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.calendarView.tableView reloadData];
}

@end
