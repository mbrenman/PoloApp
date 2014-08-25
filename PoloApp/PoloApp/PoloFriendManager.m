//
//  PoloFriendManager.m
//  PoloApp
//
//  Created by Julian Locke on 8/24/14.
//  Copyright (c) 2014 mbrenman. All rights reserved.
//

#import "PoloFriendManager.h"

@implementation PoloFriendManager

- (void)getFriendsWithCompletionHandler: (void (^)(BOOL success, NSMutableArray* friends))completionBlock
{
    
}

- (void)deleteFriendWithUsername: (NSString *)name WithCompletionHandler:(void (^)(BOOL success))completionBlock{
    PFUser *me = [PFUser currentUser];
    PFObject *friendDeletionRequest = [PFObject objectWithClassName:@"friendDeletionRequest"];
    friendDeletionRequest[@"requester"] = [me username];
    friendDeletionRequest[@"target"] = name;
    [friendDeletionRequest saveInBackground];
    
    NSMutableArray *friends = me[@"friends"];
    [friends removeObject:name];
    me[@"friends"] = friends;

    [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded);
        }
    }];
}

- (void)handleIncomingAcceptedFriendRequests: (void (^)(BOOL success))completionBlock{
    PFUser *me = [PFUser currentUser];
    PFQuery* requesterQuery = [PFQuery queryWithClassName:@"friendRequest"];
    
    [requesterQuery whereKey:@"accepted" equalTo:[NSNumber numberWithBool:YES]];
    [requesterQuery whereKey:@"requester" equalTo:me.username];
    
    [requesterQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *friends = me[@"friends"];
            NSMutableArray *acceptedFriendRequests = (NSMutableArray*)objects;
            
            //loop through accepted friend requests and add them all then delete all the objects
            
            for (PFObject* request in acceptedFriendRequests) {
                friends = me[@"friends"];
                if (friends == nil) {
                    me[@"friends"] = [[NSMutableArray alloc] initWithObjects:request[@"target"], nil];
                } else if ([friends containsObject:request[@"target"]]) {
                    [request deleteInBackground];
                } else {
                    [me[@"friends"] addObject:request[@"target"]];
                }
                [me saveInBackground];
                [request deleteInBackground];
                if (completionBlock) {
                    completionBlock(YES);
                }
            }
        } else {
            if (completionBlock) {
                completionBlock(NO);
            }
        }
    }];
}

- (void)handleDeletionRequestsWithCompletionHander: (void (^)(BOOL success))completionBlock{
    PFUser *me = [PFUser currentUser];
    PFQuery* requesterQuery = [PFQuery queryWithClassName:@"friendDeletionRequest"];
    [requesterQuery whereKey:@"target" equalTo:me.username];
    __block NSArray *toBeDeleted = [[NSArray alloc] init];
    
    [requesterQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *friends = me[@"friends"];

            toBeDeleted = (NSMutableArray*)objects;
            for (PFObject *object in toBeDeleted) {
                [friends removeObject:object[@"requester"]];
                me[@"friends"] = friends;
                [me saveInBackground];
                [object deleteInBackground];
            }
            if (completionBlock) {
                completionBlock(YES);
            }
        } else {
            if (completionBlock) {
                completionBlock(NO);
            }
        }
    }];
}

- (void)getFriendRequestsWithCompletionHander: (void (^)(BOOL success, NSMutableArray* requests))completionBlock{
    
    PFUser *me = [PFUser currentUser];
    PFQuery* requesterQuery = [PFQuery queryWithClassName:@"friendRequest"];
    [requesterQuery whereKey:@"accepted" equalTo:[NSNumber numberWithBool:NO]];
    [requesterQuery whereKey:@"target" equalTo:me.username];
    
    [requesterQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *friends = me[@"friends"];
            NSMutableArray *friendRequestsAsStrings = [[NSMutableArray alloc] init];
            
            for (PFObject *friendrequest in objects) {
                NSString *requester = friendrequest[@"requester"];
                [friendRequestsAsStrings addObject:requester];
                
                //automatically accept requests from friends
                for (NSString *friend in friends) {
                    if ([requester isEqualToString:friend]) {
                        [friendRequestsAsStrings removeObject:friendrequest];
                        friendrequest[@"accepted"] = [NSNumber numberWithBool:YES];
                        [friendrequest saveInBackground];
                        [me saveInBackground];
                    }
                }
            }
            if (completionBlock) {
                completionBlock(YES, friendRequestsAsStrings);
            }
        } else {
            if (completionBlock) {
                completionBlock(NO, nil);
            }
        }
    }];
}

- (void)handleFriendRequestFrom: (NSString *)requester
                   WithResponse: (BOOL)isResponseYes
          WithCompletionHandler: (void (^)(BOOL success))completionBlock
{
    PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"friendRequest"];
    [friendRequestQuery whereKey:@"requester" equalTo:requester];

    [friendRequestQuery getFirstObjectInBackgroundWithBlock:^(PFObject *friendRequest, NSError *error) {
        if (!error) {
            if (isResponseYes) {
                
                [self addFriendWithName:requester withCompeltionHandler:^(BOOL success){
                    if (success) {
                        NSLog(@"Success");
                    }
                }];

                friendRequest[@"accepted"] = [NSNumber numberWithBool:YES];
                [friendRequest saveInBackground];

                if (completionBlock) {
                    completionBlock(YES);
                }
            } else {
                [friendRequest saveInBackground];
                [friendRequest deleteInBackground];
                
                if (completionBlock) {
                    completionBlock(YES);
                }
            }
        }
    }];
}

- (void)addFriendWithName: (NSString *)name withCompeltionHandler: (void (^)(BOOL success))completionBlock{
    PFUser* me = [PFUser currentUser];
    NSMutableArray *friends = me[@"friends"];
    
    if (![friends containsObject:name]){
        if (![[me username] isEqualToString:name]){
            if ((!friends) || (friends.count == 0)) {
                friends = [[NSMutableArray alloc] init];
            }
            
            [friends addObject:name];
            
            me[@"friends"] = friends;
            
            [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    if (completionBlock) { completionBlock(YES); }
                }
            }];
            
        } else {
            if (completionBlock) { completionBlock(NO); }
        }
    } else {
        if (completionBlock) { completionBlock(NO); }
    }
}

- (void)sendFriendRequestTo: (NSString *)newFriend WithCompletionHandler:(void (^)(BOOL success, NSString *alertMessage))completionBlock {
    
    PFUser *me = [PFUser currentUser];
    NSMutableArray *friends = me[@"friends"];
    
    if (friends == nil){
        me[@"friends"] = [[NSMutableArray alloc] init];
        friends = me[@"friends"];
    }
    
    if ([friends containsObject:newFriend]){
        if (completionBlock) {
            completionBlock(NO, @"Already friends with selcted user");
        }
        return;
    }
    
    if ([[me username] isEqualToString:newFriend]){
        if (completionBlock) {
            completionBlock(NO, @"Cannot add yourself");
        }
        return;
    }
    
    PFQuery *query= [PFUser query];
    
    //check if other there is an existing request, if not, make and sent it
    [query whereKey:@"username" equalTo: newFriend];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *otherUser, NSError *error) {
        if (otherUser == nil){
            if (completionBlock) {
                completionBlock(NO, @"There is no user with that name in our database, please double check your information");
            }
        } else {
            PFQuery* query = [PFQuery queryWithClassName:@"friendRequest"];
            
            [query whereKey:@"target" equalTo:newFriend];
            [query whereKey:@"requester" equalTo:me.username];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *existingFriendRequests, NSError *error) {
                if (!error) {
                    if (existingFriendRequests.count == 0){
                        
                        PFObject *friendRequest = [PFObject objectWithClassName:@"friendRequest"];
                        friendRequest[@"requester"] = [me username];
                        friendRequest[@"target"] = newFriend;
                        friendRequest[@"accepted"] = [NSNumber numberWithBool:NO];
                        [friendRequest saveInBackground];
                        
                        if (completionBlock) { completionBlock(YES, nil); }
                    } else {
                        if (completionBlock) { completionBlock(NO, @"Friend request currently pending");}
                    }
                } else {
                    if (completionBlock) { completionBlock(NO, @"Error, try again"); }
                }
            }];
        }
    }];
}




@end
