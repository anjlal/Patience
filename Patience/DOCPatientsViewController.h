//
//  DOCPatientsViewController.h
//  Patience
//
//  Created by Angie Lal on 11/27/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOCPatient.h"

@protocol DOCPatientsViewControllerDelegate <NSObject>

@required
- (void)didSelectPatient:(DOCPatient *)patient;

@end

@interface DOCPatientsViewController : UITableViewController

@property (weak, nonatomic) id<DOCPatientsViewControllerDelegate> delegate;

@end
