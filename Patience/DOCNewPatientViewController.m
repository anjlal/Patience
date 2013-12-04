//
//  DOCNewPatientViewController.m
//  Patience
//
//  Created by Angie Lal on 11/25/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import "DOCNewPatientViewController.h"
#import "DOCCameraViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "DOCAccount.h"

@interface DOCNewPatientViewController () <DOCCameraViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumber;
@property (strong, nonatomic) IBOutlet UITextField *birthYear;
@property (strong, nonatomic) IBOutlet UITextField *sex;

@property (assign, nonatomic) BOOL didChangePhoto;

@end

@implementation DOCNewPatientViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.photoImageView.userInteractionEnabled = YES;
    self.photoImageView.clipsToBounds = YES;
	// Do any additional setup after loading the view.
}

#pragma mark - UIResponder

- (IBAction)willCreatePatient:(UIBarButtonItem *)createButton
{
    createButton.enabled = NO;
    //multipart post
    // regular parameters in dictionary
    // photo goes in the block
    HUDWithIndicatorInView(self.view);
    [[AFHTTPRequestOperationManager manager] POST:API_URL(@"/patients/create")
                                       parameters:@{
                                                    @"name": self.name.text,
                                                    @"sex": self.sex.text,
                                                    @"birthYear": @([self.birthYear.text intValue]), //remember, must be NSNumber
                                                    @"phoneNumber": self.phoneNumber.text,
                                                    @"providerId": [[[DOCAccount account] currentProvider] objectId]
                                                    }
                        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                            if (self.didChangePhoto) {
                                UIImage *photo = self.photoImageView.image;
                                NSData *photoData = UIImageJPEGRepresentation(photo, 0.7f);
                                [formData appendPartWithFileData:photoData
                                                            name:@"photo"
                                                        fileName:@"image.jpg"
                                                        mimeType:@"image/jpeg"];

                            }
                        }
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              NSLog(@"Response: %@", responseObject);
                                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                                              [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                                              createButton.enabled = YES;
                                              HUDWithErrorInView(self.view, @"Error creating task.");
                                          }];


    //regular post
//    [[AFHTTPRequestOperationManager manager] POST:API_URL(@"/patients/create")
//                                       parameters:@{
//                                                    @"name": self.name.text,
//                                                    @"birthYear": [self.birthYear.text intValue],
//                                                    //@"photo": self.photo
//                                                    @"phoneNumber": self.phoneNumber.text
//                                                    }
//                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                              ;
//                                          }
//                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                                              createButton.enabled = YES;
//                                              HUDWithErrorInView(self.view, @"Error creating task.");
//                                          }];

}

#pragma mark - Superclass overrides

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destinationVC = [segue destinationViewController];
    
    if ([destinationVC isKindOfClass:[UINavigationController class]] &&
        [[(UINavigationController *)destinationVC topViewController] isKindOfClass:[DOCCameraViewController class]]) {
        DOCCameraViewController *cameraVC = (DOCCameraViewController *)[(UINavigationController *)destinationVC topViewController];
        cameraVC.delegate = self;
    }
}

#pragma mark - UIResponder

- (IBAction)willCancel:(UIBarButtonItem *)cancelButton
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GestureRecognizer

- (IBAction)willChangePhoto:(UITapGestureRecognizer *)tgr
{
    [self.view endEditing:YES];
    [self performSegueWithIdentifier:@"DOCWillTakePatientPhotoSegue" sender:self];
}

#pragma mark - DOCCameraViewControllerDelegate

- (void)didTakePhoto:(UIImage *)photo
{
    self.photoImageView.image = photo;
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoImageView.layer.cornerRadius = 50;
    self.didChangePhoto = YES;
}

@end
