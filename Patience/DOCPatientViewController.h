//
//  DOCPatientViewController.h
//  Patience
//
//  Created by Angie Lal on 11/13/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOCPatient.h"
#import "DOCTask.h"

@interface DOCPatientViewController : UITableViewController

@property (strong, nonatomic) DOCPatient *patient;
@property (strong, nonatomic) NSMutableArray *tasks;
@end
