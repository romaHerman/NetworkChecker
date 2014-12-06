//
//  NetworkStatusViewController.m
//  NetworkChecker
//
//  Created by Roma Herman on 12/6/14.
//  Copyright (c) 2014 Roma Herman. All rights reserved.
//

#import "NetworkStatusViewController.h"
#import "NetworkStatusManager.h"

@interface NetworkStatusViewController ()

@property (weak, nonatomic) IBOutlet UILabel *networkStatusLabel;
@property (strong, nonatomic) NetworkStatusManager *networkStatusManager;

@end

@implementation NetworkStatusViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self startObservingNetworkStatus];
}

#pragma mark Updating Network status methods

- (void)startObservingNetworkStatus {
  //create weak reference to ViewController in order not to create retain cycle which leads to memory leaks
  __unsafe_unretained id weakSelf = self;
  //set block which will invokes each time network status changes
  [self.networkStatusManager setNetworkStatusBlock:^(NSString *status) {
    //update user inteface with new statys
    [weakSelf updateUIWithConnectionType:status];
  }];
}

- (void)updateUIWithConnectionType:(NSString *)connectionStatus {
  self.networkStatusLabel.text = connectionStatus;
}

#pragma mark - Accessors

- (NetworkStatusManager *)networkStatusManager {
  if (!_networkStatusManager) {
    _networkStatusManager = [[NetworkStatusManager alloc] init];
  }
  return _networkStatusManager;
}

#pragma mark - TextField delegate method

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  //set new URL to the network manager
  [self.networkStatusManager setServerUrl:textField.text];
  //force manager to send all asved statuses which was collected
  [self.networkStatusManager sendRecentStatuses];
  //hide keyboard
  [textField resignFirstResponder];
  
  return NO;
}

@end
