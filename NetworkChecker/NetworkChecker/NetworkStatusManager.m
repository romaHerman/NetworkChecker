//
//  NetworkStatusManager.m
//  NetworkChecker
//
//  Created by Roma Herman on 12/6/14.
//  Copyright (c) 2014 Roma Herman. All rights reserved.
//

#import "NetworkStatusManager.h"
#import "AFNetworkReachabilityManager.h"
#import "AFHTTPRequestOperationManager.h"

#import <Realm/Realm.h>
#import "NetworkStatus.h"
//constants for connection type
static NSString *const ConnectionStatusAbsent  = @"No Connection";
static NSString *const ConnectionStatus3G      = @"3G";
static NSString *const ConnectionStatusWIFI    = @"WIFI";
//backend keys for network statuses
static NSString *const TypeKey   = @"Type";
static NSString *const DeviceIDKey = @"Unique_id";

@implementation NetworkStatusManager

- (void)setNetworkStatusBlock:(void(^)(NSString *status))networkStatus {
  //init reachability manager
  AFNetworkReachabilityManager *reachabiliryManager = [AFNetworkReachabilityManager sharedManager];
  [reachabiliryManager startMonitoring];
  //start observing changes
  [reachabiliryManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
    
    NSString *connectionStatus;
    
    switch (status) {
      case AFNetworkReachabilityStatusNotReachable:
        connectionStatus = ConnectionStatusAbsent;
        break;
      case AFNetworkReachabilityStatusReachableViaWWAN:
        connectionStatus = ConnectionStatus3G;
        break;
      case AFNetworkReachabilityStatusReachableViaWiFi:
        connectionStatus = ConnectionStatusWIFI;
        break;
      default:
        break;
    }
    //invoke connection status block
    networkStatus(connectionStatus);
    //save localy status when status changed
    [self saveStatus:connectionStatus complition:^{
      //when saved send all saved statuses
      [self sendRecentStatuses];
    }];
    
  }];
}

#pragma mark - Managing statuses methods

- (void)saveStatus:(NSString *)statusString complition:(void(^)())saved {
  //getting acces to Realm DB
  RLMRealm *realm = [RLMRealm defaultRealm];
  //init new NetworkStatus realm object and set values to it
  NetworkStatus *status = [[NetworkStatus alloc] init];
  status.statusType = statusString;
  status.statusDate = [NSDate date];
  //save status asyncronously
  [realm transactionWithBlock:^{
    //saving status
    [realm addObject:status];
    //invoke complition block
    saved();
  }];
}

- (void)deleteStatus:(NetworkStatus *)status {
  //getting acces to Realm DB
  RLMRealm *realm = status.realm;//[RLMRealm defaultRealm];
  //delelte status asyncronously
  [realm transactionWithBlock:^{
    [realm deleteObject:status];
  }];
}

- (void)sendRecentStatuses {
 //create background queue to send statuses 
  dispatch_queue_t sendStatusQueue = dispatch_queue_create("com.networkChecker.sendStatusesQueue", NULL);
  dispatch_async(sendStatusQueue, ^{
    // get all network statuses arranged by date from old to the most recent
    RLMResults *recentStatuses = [self recentStatusesAscending];
    NSMutableArray *sentStatuses = [[NSMutableArray alloc] init];
    //iterate through all statuses and send them to the remote server
    for (NetworkStatus *networkStatus in recentStatuses) {
      dispatch_semaphore_t sema = dispatch_semaphore_create(0);
      [self sendStatus:networkStatus complition:^(BOOL success) {
        
        if (success) {
          //sent successfully => add current status to sentStatuses array
          [sentStatuses addObject:networkStatus];
        } else {
          //need to stop sending statuses to prevent order misplacing
          return;
        }
        
        dispatch_semaphore_signal(sema);
      }];
      dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    // delete all sent statuses
    [self deleteSentStatuses:sentStatuses];
  });
}

- (void)deleteSentStatuses:(NSArray *)sentStatuses {
  for (NetworkStatus *status in sentStatuses) {
    [self deleteStatus:status];
  }
}

- (RLMResults *)recentStatusesAscending {
  return [[NetworkStatus allObjects] sortedResultsUsingProperty:@"statusDate" ascending:YES];
}

#pragma mark - Request operations

- (void)sendStatus:(NetworkStatus *)status complition:(void(^)(BOOL success))sent {
  if (!self.serverUrl) {
    return;
  }
  // init request manager
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  manager.requestSerializer.timeoutInterval = 15.0;
  NSString *uniqID = [UIDevice currentDevice].identifierForVendor.UUIDString;
  // add parameters
  NSDictionary *parameters = @{DeviceIDKey : uniqID,
                               TypeKey     : status.statusType};
  //send status to remote server
  [manager GET:self.serverUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    BOOL success = NO;
    NSInteger statusCode = operation.response.statusCode;
    if (statusCode == 200) {
      NSLog(@"succeded");
      success = YES;
    }
    sent(success);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"failure");
    sent(NO);
  }];
}

@end
