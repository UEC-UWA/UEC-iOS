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

@interface UECMonthViewController () <TSQCalendarViewDelegate, TSQCalendarViewDataSource>
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
    
    self.calendarView.delegate = self;
    self.calendarView.dataSource = self;
    
    self.view = self.calendarView;
    
    self.fetchedResultsController = [[APSDataManager sharedManager] fetchedResultsControllerWithRequest:^(NSFetchRequest *request) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
        request.sortDescriptors = @[sortDescriptor];
    } entityName:@"Event" sectionNameKeyPath:nil cacheName:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Actions

- (void)handleRefresh:(id)sender
{
    // Refresh data here
    
    [self.delegate didRequestDataRefresh];
    
    [self.refreshControl endRefreshing];
}

- (void)refresh
{
    [self.calendarView.tableView reloadData];
}

#pragma mark - TSQCalendarViewDelegate

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    
}

#pragma mark - TSQCalendarViewDataSource

- (NSArray *)calendarViewEventDates
{
    NSArray *events = [self.fetchedResultsController fetchedObjects];
    
    return [events valueForKeyPath:@"@distinctUnionOfObjects.startDate"];
}

@end
