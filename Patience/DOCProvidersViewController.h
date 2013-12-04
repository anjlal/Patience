//
//  DOCProvidersViewController.h
//  Patience
//
//  Created by Angie Lal on 11/14/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOCProvider.h"
#import "DOCTask.h"

@protocol DOCProvidersViewControllerDelegate <NSObject>

@optional
- (void)didReassignTask:(DOCTask *)task toProvider:(DOCProvider *)provider;

@end

@interface DOCProvidersViewController : UITableViewController

@property (nonatomic, weak) id<DOCProvidersViewControllerDelegate> delegate;
@property (nonatomic, strong) DOCTask *task;

@end
