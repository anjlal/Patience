//
//  DOCPatient.h
//  Patience
//
//  Created by Angie Lal on 11/14/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOCBaseModel.h"

@interface DOCPatient : DOCBaseModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSNumber *birthYear;
@property (nonatomic, strong) NSString *photoFilename;

@property (nonatomic, strong) NSString *sex;
@end
