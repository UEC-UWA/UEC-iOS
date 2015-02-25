//
//  UECAboutClubViewController.m
//  UEC
//
//  Created by Jad Osseiran on 25/11/2013.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECAboutClubViewController.h"

@interface UECAboutClubViewController ()

@property (nonatomic, weak) IBOutlet UITextView *textView;

@end

@implementation UECAboutClubViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.textView setContentOffset:CGPointZero animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
