//
//  DOCProvider.h
//  Patience
//
//  Created by Angie Lal on 11/17/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOCBaseModel.h"


@interface DOCProvider : DOCBaseModel

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *name;

@end
