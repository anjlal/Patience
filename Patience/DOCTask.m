//
//  DOCTask.m
//  Patient.ly
//
//  Created by Angie Lal on 11/8/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import "DOCTask.h"

@implementation DOCTask

- (id)initWithJson:(NSDictionary *)json //see, we now inherit from base model and can override this method
{
    self = [super initWithJson:json]; //gotta make sure we call the superclass constructor (i.e. DOCBaseModel)
    if (self) {
        //_tid = json[@"id"];
        //_name = json[@"name"];
        _issue = json[@"description"];
        _patient = [[DOCPatient alloc] initWithJson:json[@"patient"]];
        _providerId = json[@"providerId"];
        _createdAt = json[@"createdAt"];
        _updatedAt = json[@"updatedAt"];
        _status = json[@"status"];
        _priority = json[@"priority"];

    }
    return self;
}

/* can comment this out */
//-(DOCTask *)initWithId:(NSNumber *)tid name:(NSString *)name issue:(NSString *)issue
//{
//    self = [super init];
//    if (self) {
//        _tid = tid;
//        _name = name;
//        _issue = issue;
//    }
//    return self;
//}

@end
