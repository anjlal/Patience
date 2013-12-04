//
//  DOCNewTaskViewController.m
//  Patience
//
//  Created by Angie Lal on 11/25/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import "DOCNewTaskViewController.h"
#import "DOCPatientsViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "DOCPatient.h"
#import "DOCAccount.h"
#import "DOCTask.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DOCNewTaskViewController () <UITextFieldDelegate, UITextViewDelegate, DOCPatientsViewControllerDelegate>

@property (strong, nonatomic) DOCPatient *patient;
@property (weak, nonatomic) IBOutlet UITextView *description;
@property (weak, nonatomic) IBOutlet UIView *selectedPatientView;
@property (weak, nonatomic) IBOutlet UIImageView *patientPhoto;
@property (weak, nonatomic) IBOutlet UILabel *patientName;
@property (weak, nonatomic) IBOutlet UILabel *selectPatientInstruction;

@end

@implementation DOCNewTaskViewController

//new in iOS7 to prevent UITextView from starting in the middle
- (BOOL)automaticallyAdjustsScrollViewInsets
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"New Task";
    
    self.description.layer.shadowColor = [UIColor colorWithHex:@"e3e3e3"].CGColor;
    self.description.layer.shadowOffset = CGSizeMake(0, -1);
    self.description.layer.shadowOpacity = 1.0f;
    self.description.layer.shadowRadius = 0.0f;
    self.description.layer.masksToBounds = NO;
    self.description.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
	// Do any additional setup after loading the view.
    self.patientPhoto.layer.cornerRadius = floorf(self.patientPhoto.frame.size.width / 2.0f);;
    self.patientPhoto.clipsToBounds = YES;
    self.patientPhoto.hidden = self.patientName.hidden = YES;
    self.selectPatientInstruction.hidden = NO;
}

- (void)setPatient:(DOCPatient *)patient
{
    _patient = patient;
    self.patientName.text = self.patient.name;
    NSString *imageUrl = [NSString stringWithFormat:@"/static/patient_photos/%@", self.patient.photoFilename];
    [self.patientPhoto setImageWithURL:[NSURL URLWithString:API_URL(imageUrl)]
                      placeholderImage:[UIImage imageNamed:@"homer_simpson.jpg"]];
    self.patientPhoto.hidden = self.patientName.hidden = NO;
    self.selectPatientInstruction.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.description becomeFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"DOCSelectPatientSegue"]) {
        [(DOCPatientsViewController *)[(UINavigationController *)[segue destinationViewController] topViewController] setDelegate:self];
    }
}

#pragma mark - UIResponder

- (IBAction)willCreateTask:(UIBarButtonItem *)createButton
{
    //create task via post and dismiss
    createButton.enabled = NO;
    [[AFHTTPRequestOperationManager manager] POST:API_URL(@"/tasks/create")
                                       parameters:@{
                                                    @"description": self.description.text,
                                                    @"patient_id": self.patient.objectId,
                                                    @"provider_id": [[[DOCAccount account] currentProvider] objectId]
                                                    }
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              DOCTask *task = [[DOCTask alloc] initWithJson:responseObject[@"task"]];
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"ProviderDidCreateTaskNotification"
                                                                                                  object:self
                                                                                                userInfo:@{@"task" : task}];
                                              [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              createButton.enabled = YES;
                                              HUDWithErrorInView(self.view, @"Error creating task.");
                                          }];
}

- (IBAction)willCancel:(UIBarButtonItem *)cancelButton
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (IBAction)willSelectPatient:(UITapGestureRecognizer *)tgr
{
    [self.view endEditing:YES];
    [self performSegueWithIdentifier:@"DOCSelectPatientSegue" sender:self];
}

//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    [self performSegueWithIdentifier:@"DOCSelectPatientSegue" sender:self];
//    return NO;
//}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    NSLog(@"string: %@", text);
//
//    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//        return NO;
//    }
//    return YES;
//}

#pragma mark - DOCPatientsViewControllerDelegate

- (void)didSelectPatient:(DOCPatient *)patient
{
    self.patient = patient;
}

@end
