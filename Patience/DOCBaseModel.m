//
//  DOCBaseModel.m
//  Patience
//
//  Created by Angie Lal on 11/14/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import "DOCBaseModel.h"

@implementation DOCBaseModel

- (id)initWithJson:(NSDictionary *)json
{
    self = [super init];

    if(self) {
        _objectId = json[@"id"];
    }

    return self;
}

@end
