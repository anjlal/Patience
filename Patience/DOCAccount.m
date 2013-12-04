//
//  DOCAccount.m
//  Patience
//
//  Created by Angie Lal on 11/26/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import "DOCAccount.h"

@implementation DOCAccount

+ (DOCAccount *)account
{
    static DOCAccount *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [DOCAccount new];
    });
    return singleton;
}

- (NSString *)authToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"AUTH_TOKEN"];
}

- (BOOL)isLoggedIn
{
    return !![self authToken];
}

- (void)logInWithToken:(NSString *)token
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs setObject:token forKey:@"AUTH_TOKEN"];
    [defs synchronize];
}

- (void)setCurrentProvider:(DOCProvider *)provider
{
    _currentProvider = provider;
}

@end
