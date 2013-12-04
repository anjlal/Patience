//
//  DOCSplashViewController.m
//  Patience
//
//  Created by Angie Lal on 11/26/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import "DOCSplashViewController.h"
#import "DOCAccount.h"
#import <AFNetworking/AFNetworking.h>
#import "UIView+AnimationOptionsForCurve.h"

@interface DOCSplashViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;

@end

@implementation DOCSplashViewController

# pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithHex:@"#1AD6FD"] CGColor],
                                                (id)[[UIColor colorWithHex:@"#1D62F0"] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    self.emailField.layer.borderColor = self.passwordField.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.85f].CGColor;
    self.logInButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.emailField.layer.borderWidth = self.passwordField.layer.borderWidth = self.logInButton.layer.borderWidth = 1.0f;
    self.emailField.backgroundColor = self.passwordField.backgroundColor = self.logInButton.backgroundColor = [UIColor clearColor];
    self.emailField.textColor = self.passwordField.textColor = [UIColor whiteColor];
    self.emailField.layer.cornerRadius = self.passwordField.layer.cornerRadius = 5.0f;
    [self.logInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.logInButton.layer.cornerRadius = 5.0f;

	// Do any additional setup after loading the view
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Need to check if the user is logged in
    if ([[DOCAccount account] isLoggedIn]) {
        //look up provider for token
        [self.indicator startAnimating];
        [[AFHTTPRequestOperationManager manager] GET:API_URL(@"/providers/current")
                                          parameters:@{@"token" : [[DOCAccount account] authToken]}
                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 //already logged in , found current provider, transition to tasks
                                                 [self.indicator stopAnimating];
                                                 [self setCurrentProviderAndSegue:responseObject[@"provider"]];
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 [self.indicator stopAnimating];
                                                 [self showFields];
                                             }];
    } else {
        [self showFields];
    }
}

# pragma mark - misc

- (void)showFields
{
    self.emailField.alpha = self.passwordField.alpha = self.logInButton.alpha = 0;
    self.emailField.hidden = self.passwordField.hidden = self.logInButton.hidden = NO;
    [UIView animateWithDuration:0.25f animations:^{
        self.emailField.alpha = self.passwordField.alpha = self.logInButton.alpha = 1;
    }];
}

- (IBAction)willLogIn
{
    // try to auth the user with email and password
    [self.view endEditing:YES];
    self.logInButton.enabled = NO;
    [[AFHTTPRequestOperationManager manager] POST:API_URL(@"/providers/log_in")
                                       parameters:@{
                                                    @"email": self.emailField.text,
                                                    @"password": self.passwordField.text
                                                    }
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              //authenticated
                                              //from json:
                                              //set token
                                              //set current provider
                                              [[DOCAccount account] logInWithToken:responseObject[@"token"]];
                                              [self setCurrentProviderAndSegue:responseObject[@"provider"]];
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              self.logInButton.enabled = YES;
                                              HUDWithErrorInView(self.view, @"Bad login.");
                                              NSLog(@"Error: %@", error);
                                              NSLog(@"Could not authenticate, do something here to let the user know");
                                          }];
}

- (void)setCurrentProviderAndSegue:(id)currentProviderJson
{
    [[DOCAccount account] setCurrentProvider:[[DOCProvider alloc] initWithJson:currentProviderJson]];
    [self performSegueWithIdentifier:@"DOCProviderLoggedInSegue" sender:self];
}

- (void)handleKeyboardWillShow:(NSNotification *)notification
{
    [self keyboardWillShow:YES notification:notification];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification
{
    [self keyboardWillShow:NO notification:notification];
}

- (void)keyboardWillShow:(BOOL)willShow notification:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
	double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:[UIView animationOptionsForCurve:curve]
                     animations:^{
                         CGRect convertedKeyboardRect = [self.view convertRect:keyboardRect fromView:nil];
                         if (willShow) {
                             CGFloat offset = ([self.logInButton maxY] - convertedKeyboardRect.origin.y) + 10;
                             [self.view adjustY:-offset];
                         } else {
                             [self.view setY:0];
                         }
                     } completion:nil];
}

# pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
