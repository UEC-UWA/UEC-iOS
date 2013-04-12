//
//  UECVersionInfoViewController.m
//  UEC
//
//  Created by Jad Osseiran on 12/04/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECVersionInfoViewController.h"

@interface UECVersionInfoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *buildLabel;

@end

@implementation UECVersionInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.buildLabel.text = [NSString stringWithFormat:@"Build: %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
