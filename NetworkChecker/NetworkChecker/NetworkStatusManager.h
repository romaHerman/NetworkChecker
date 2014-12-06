//
//  NetworkStatusManager.h
//  NetworkChecker
//
//  Created by Roma Herman on 12/6/14.
//  Copyright (c) 2014 Roma Herman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkStatusManager : NSObject

@property(nonatomic, strong) NSString *serverUrl;

- (void)setNetworkStatusBlock:(void(^)(NSString *status))networkStatus;
- (void)sendRecentStatuses;

@end
