//
//  DOCAccount.h
//  Patience
//
//  Created by Angie Lal on 11/26/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOCProvider.h"

@interface DOCAccount : NSObject

+ (DOCAccount *)account;

@property (strong, nonatomic, readonly) DOCProvider *currentProvider;
@property (strong, nonatomic, readonly) NSString *authToken;

- (void)setCurrentProvider:(DOCProvider *)provider;
- (BOOL)isLoggedIn;
- (void)logInWithToken:(NSString *)token;

@end
