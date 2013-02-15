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

#import "NSDate+Helper.h"

@interface TSQCalendarView (AccessingPrivateStuff)

@property (nonatomic, readonly) UITableView *tableView;

@end

@interface UECMonthViewController () <TSQCalendarViewDelegate>
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) TSQCalendarView *calendarView;
@end

@implementation UECMonthViewController

@synthesize events = _events;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.calendarView = [[TSQCalendarView alloc] init];
    self.calendarView.calendar = [NSCalendar currentCalendar];
    self.calendarView.rowCellClass = [UECCalendarRowCell class];
    self.calendarView.firstDate = [[NSDate date] startOfCurrentYear];
    self.calendarView.lastDate = [[NSDate date] endOfCurrentYear];
    self.calendarView.backgroundColor = [UIColor colorWithRed:0.84f green:0.85f blue:0.86f alpha:1.0f];
    self.calendarView.pagingEnabled = YES;
    CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
    self.calendarView.contentInset = UIEdgeInsetsMake(0.0f, onePixel, 0.0f, onePixel);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.calendarView.tableView addSubview:self.refreshControl];
    
    self.calendarView.delegate = self;
    
    self.view = self.calendarView;
}

- (void)setEvents:(NSArray *)events
{
    if (_events != events) {
        _events = events;
        self.events = events;
    }
}

#pragma mark - Actions

- (void)handleRefresh:(id)sender
{
    // Refresh data here
    [self refresh];
    
    [self.refreshControl endRefreshing];
}

- (void)refresh
{
    [self.delegate didRefreshData];
    
    NSArray *dates = [self.events valueForKeyPath:@"@distinctUnionOfObjects.startDate"];
    
    [self.calendarView setEventsForDates:dates];
    [self.calendarView.tableView reloadData];
}

#pragma mark - TSQCalendarViewDelegate

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    
}

@end
