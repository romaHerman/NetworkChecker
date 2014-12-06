//
//  StatusOrderTest.m
//  NetworkChecker
//
//  Created by Roma Herman on 12/6/14.
//  Copyright (c) 2014 Roma Herman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "NetworkStatusManager.h"
#import <Realm/Realm.h>
#import "NetworkStatus.h"

@interface StatusOrderTest : XCTestCase

@end

@implementation StatusOrderTest

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
  
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testExample {
  //statuses should be sent to remote server from the most early to the most recent
  // i.e. if it was connected to 3G and then to WIFI,
  //the app will send the requests to them one after the other.
  // lets fetch all statuses and compare time of first and last status
  
  NetworkStatusManager *manager = [[NetworkStatusManager alloc] init];
  RLMResults *statuses = [manager recentStatusesAscending];
  
  NetworkStatus *statusAtFirstIndex = statuses.firstObject;
  NetworkStatus *statusAtLastIndex = statuses.lastObject;
  
  BOOL isAscending = NO;
  
  if ([statusAtFirstIndex.statusDate compare:statusAtLastIndex.statusDate] == NSOrderedAscending) {
    isAscending = YES;
  }

  XCTAssertTrue(isAscending,@"statuses should be ordered from the most earlier to the most recent");
}

- (void)testPerformanceExample {
  // This is an example of a performance test case.
  [self measureBlock:^{
    // Put the code you want to measure the time of here.
  }];
}

@end
