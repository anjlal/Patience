//
//  DOCBaseModel.h
//  Patience
//
//  Created by Angie Lal on 11/14/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DOCBaseModel : NSObject

@property (nonatomic, strong) NSNumber *objectId;
- (id)initWithJson:(NSDictionary *)json;

@end
