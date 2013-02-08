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

@interface UECMonthViewController ()
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation UECMonthViewController

- (void)loadView;
{
    TSQCalendarView *calendarView = [[TSQCalendarView alloc] init];
    calendarView.calendar = [NSCalendar currentCalendar];
    calendarView.rowCellClass = [UECCalendarRowCell class];
    calendarView.firstDate = [[NSDate date] startOfCurrentYear];
    calendarView.lastDate = [[NSDate date] endOfCurrentYear];
    calendarView.backgroundColor = [UIColor colorWithRed:0.84f green:0.85f blue:0.86f alpha:1.0f];
    calendarView.pagingEnabled = YES;
    CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
    calendarView.contentInset = UIEdgeInsetsMake(0.0f, onePixel, 0.0f, onePixel);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [calendarView.tableView addSubview:self.refreshControl];
    
    self.view = calendarView;
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
}

#pragma mark - Actions

- (void)handleRefresh:(id)sender
{
    // Refresh data here
    [self.refreshControl endRefreshing];
}

@end