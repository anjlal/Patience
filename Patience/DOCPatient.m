//
//  DOCPatient.m
//  Patience
//
//  Created by Angie Lal on 11/14/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import "DOCPatient.h"

@implementation DOCPatient

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if (self) {
        //set up patient properties here, like name and whatnot
        _name = json[@"name"];
        _sex = json[@"sex"];
        _phoneNumber = json[@"phoneNumber"];
        _birthYear = json[@"birthYear"];
        _photoFilename = json[@"photoFilename"];
    }
    return self;
}

@end
