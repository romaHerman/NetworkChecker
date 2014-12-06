//
//  NetworkStatus.h
//  NetworkChecker
//
//  Created by Roma Herman on 12/6/14.
//  Copyright (c) 2014 Roma Herman. All rights reserved.
//

#import <Realm/Realm.h>

@interface NetworkStatus : RLMObject

@property NSString *statusType;
@property NSDate   *statusDate;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<NetworkStatus>
RLM_ARRAY_TYPE(NetworkStatus)
