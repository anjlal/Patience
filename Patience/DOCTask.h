//
//  DOCTask.h
//  Patient.ly
//
//  Created by Angie Lal on 11/8/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOCBaseModel.h"
#import "DOCPatient.h"

@interface DOCTask : DOCBaseModel

//@property (nonatomic, strong) NSNumber *tid;
//@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *issue;
@property (nonatomic, strong) DOCPatient *patient;
@property (nonatomic, strong) NSNumber *providerId;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *updatedAt;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSNumber *priority;







//@property (nonatomic, strong) NSDate *timestamp;

-(DOCTask *)initWithJson:(NSDictionary *)json;
@end
