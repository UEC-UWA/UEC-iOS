//
//  UECEventDetailViewController.m
//  UEC
//
//  Created by Jad Osseiran on 27/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <EventKit/EventKit.h>

#import "UECEventDetailViewController.h"
#import "UECMapViewController.h"

#import "Event.h"
#import "NSDate+Helper.h"
#import "NSDate+Formatter.h"

@interface UECEventDetailViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel, *locationLabel, *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel, *endDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UITextView *eventInfoTextView;

@property (strong, nonatomic) UIPopoverController *activityPopoverController;

@end

@implementation UECEventDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.event.name;
    self.nameLabel.text = self.event.name;
    self.locationLabel.text = self.event.location;
    self.addressLabel.text = self.event.address;
    self.eventInfoTextView.text = self.event.eventDescription;
    
    self.startDateLabel.text = [self.event.startDate stringValue];
    
    if ([self.event.startDate isInSameDayAsDate:self.event.endDate])
        self.endDateLabel.text = [self.event.endDate stringNoDateValue];
    else
        self.endDateLabel.text = [self.event.endDate stringValue];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Map Event Segue"]) {
        UECMapViewController *mapVC = [segue destinationViewController];
        mapVC.address = self.event.address;
        mapVC.location = self.event.location;
    }
}

#pragma mark - Calendar

- (void)saveEventWithTitle:(NSString *)title
                  location:(NSString *)location
                 startTime:(NSDate *)startTime
                   endTime:(NSDate *)endTime
                     alarm:(NSDate *)alarmDate
{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
	EKEvent *event = [EKEvent eventWithEventStore:eventStore];
	event.title = title;
    event.location = location;
	event.startDate = startTime;
	event.endDate = endTime;
	event.calendar = [eventStore defaultCalendarForNewEvents];
    
    if (alarmDate) {
        EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:alarmDate];
        [event addAlarm:alarm];
    }
        
	NSError *error;
	[eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
	
	if (error)
		NSLog(@"ERROR: %@", error);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDate *alarmDate = nil;
    
    switch (buttonIndex) {
        case 1:
            alarmDate = [self.event.startDate dateByRemovingNumberOfMinutes:30];
            break;
            
        case 2:
            alarmDate = [self.event.startDate dateByRemovingNumberOfHours:3];
            break;
            
        case 3:
            alarmDate = [self.event.startDate dateByRemovingNumberOfDays:1];
            break;
            
        case 4:
            alarmDate = [self.event.startDate dateByRemovingNumberOfDays:3];
            break;
            
        default:
            break;
    }
    
    [self saveEventWithTitle:self.event.name
                    location:self.event.address
                   startTime:self.event.startDate
                     endTime:self.event.endDate
                       alarm:alarmDate];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {        
        switch (indexPath.row) {
            case 1: {
                UIActionSheet *alarmActionSheet = [[UIActionSheet alloc] initWithTitle:@"Set Alarm"
                                                                              delegate:self
                                                                     cancelButtonTitle:@"Cancel"
                                                                destructiveButtonTitle:nil
                                                                     otherButtonTitles:@"No Alarms", @"30 Minutes Prior", @"3 Hours Prior", @"1 Day Prior", @"3 Days Prior", nil];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                    [alarmActionSheet showFromRect:cell.frame inView:self.view animated:YES];
                else
                    [alarmActionSheet showFromTabBar:self.tabBarController.tabBar];
                break;
            }
                
            default:
                break;
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Actions

- (void)share:(id)sender
{
    NSString *eventInfo = [[NSString alloc] initWithFormat:@"%@ \n Starts on: %@ \n Finishes on: %@ \n Facebook Link: %@", self.event.name, [self.event.startDate stringValue], [self.event.endDate stringValue], self.event.facebookLink];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[eventInfo] applicationActivities:nil];
    
    activityVC.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll];
    
    activityVC.completionHandler = ^(NSString *activityType, BOOL completed) {
        NSLog(@" activityType: %@", activityType);
        NSLog(@" completed: %i", completed);
    };
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (self.activityPopoverController.popoverVisible) {
            [self.activityPopoverController dismissPopoverAnimated:YES];
        } else {
            self.activityPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityVC];
            
            [self.activityPopoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else {
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

@end
