//
//  PoloFriendManager.h
//  PoloApp
//
//  Created by Julian Locke on 8/24/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

@interface PoloFriendManager : NSObject

- (void)getFriendsWithCompletionHandler: (void (^)(BOOL success, NSMutableArray* friends))completionBlock;
- (void)deleteFriendWithUsername: (NSString *)name WithCompletionHandler:(void (^)(BOOL success))completionBlock;

- (void)getFriendRequestsWithCompletionHander: (void (^)(BOOL success, NSMutableArray* friends))completionBlock;

- (void)handleFriendRequestFrom: (NSString *)requester
                               WithResponse: (BOOL)response
                      WithCompletionHandler: (void (^)(BOOL success))completionBlock;

- (void)sendFriendRequestTo: (NSString *)name WithCompletionHandler:(void (^)(BOOL success, NSString *alertMessage))completionBlock;

- (void)handleIncomingAcceptedFriendRequests: (void (^)(BOOL success))completionBlock;
- (void)handleDeletionRequestsWithCompletionHander: (void (^)(BOOL success))completionBlock;

@end
