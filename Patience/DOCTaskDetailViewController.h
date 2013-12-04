//
//  DOCTaskDetailViewController.h
//  Patience
//
//  Created by Angie Lal on 11/12/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOCTask.h"

@interface DOCTaskDetailViewController : UIViewController <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property DOCTask *task;

@end
