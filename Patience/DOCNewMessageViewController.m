//
//  DOCNewMessageViewController.m
//  Patience
//
//  Created by Angie Lal on 11/27/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import "DOCNewMessageViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "DOCAccount.h"

@interface DOCNewMessageViewController ()

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIImageView *patientPhoto;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation DOCNewMessageViewController

//new in iOS7 to prevent UITextView from starting in the middle
- (BOOL)automaticallyAdjustsScrollViewInsets
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"New Message";
    
    self.textView.layer.shadowColor = [UIColor colorWithHex:@"e3e3e3"].CGColor;
    self.textView.layer.shadowOffset = CGSizeMake(0, -1);
    self.textView.layer.shadowOpacity = 1.0f;
    self.textView.layer.shadowRadius = 0.0f;
    self.textView.layer.masksToBounds = NO;
    self.textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.nameLabel.text = self.patient.name;
    self.nameLabel.textColor = [UIColor colorWithHex:@"757575"];
    if (!self.patientPhoto.image) {
        //        self.patientPhoto.image = [UIImage imageNamed: self.task.patient.photoFilename];
        // Here we use the new provided setImageWithURL: method to load the web image
        NSString *imageUrl = [NSString stringWithFormat:@"/static/patient_photos/%@", self.patient.photoFilename];
        [self.patientPhoto setImageWithURL:[NSURL URLWithString:API_URL(imageUrl)]
                          placeholderImage:[UIImage imageNamed:@"homer_simpson.jpg"]];
        
    }
    self.patientPhoto.layer.cornerRadius = floorf(self.patientPhoto.frame.size.width / 2.0f);;
    self.patientPhoto.clipsToBounds = YES;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

#pragma mark - UIResponder

- (IBAction)willSendMessage:(UIBarButtonItem *)sendButton
{
    //send message then dismiss after sending
    sendButton.enabled = NO;
    NSString *postUrlString = [NSString stringWithFormat:@"/patients/%d/message", [self.patient.objectId intValue]];
    [[AFHTTPRequestOperationManager manager] POST:API_URL(postUrlString)
                                       parameters:@{
                                                    @"message" : self.textView.text,
                                                    @"providerId" : [[[DOCAccount account] currentProvider] objectId]
                                                   }
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                              NSLog(@"Response: %@", responseObject);
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              sendButton.enabled = YES;
                                              HUDWithErrorInView(self.view, @"Error sending message.");
                                              NSLog(@"Error: %@", error);
                                          }];
}

- (IBAction)willCancel:(UIBarButtonItem *)cancelButton
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
