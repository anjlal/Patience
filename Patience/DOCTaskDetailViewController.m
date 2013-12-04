//
//  DOCTaskViewController.m
//  Patience
//
//  Created by Angie Lal on 11/12/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import "DOCTaskDetailViewController.h"
#import "DOCPatientViewController.h"
#import "DOCProvidersViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "DOCNewMessageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface DOCTaskDetailViewController () <DOCProvidersViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *patientPhoto;
@property (weak, nonatomic) IBOutlet UIButton *patientName;
@property (weak, nonatomic) IBOutlet UILabel *taskDescription;
@property (weak, nonatomic) IBOutlet UIButton *completed;
@property (weak, nonatomic) IBOutlet UIButton *assign;
@property (weak, nonatomic) IBOutlet UIButton *sendMessage;
@property (weak, nonatomic) IBOutlet UIView *headerContainer;

@end

@implementation DOCTaskDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.title = self.task.issue;
    
    self.view.backgroundColor = [UIColor colorWithHex:@"#f7f7f7"];
    [self.patientName setTitle:self.task.patient.name forState:UIControlStateNormal];
    self.taskDescription.text = self.task.issue;
    
    self.headerContainer.backgroundColor = [UIColor whiteColor];
    self.headerContainer.layer.shadowColor = [UIColor colorWithHex:@"e3e3e3"].CGColor;
    self.headerContainer.layer.shadowOffset = CGSizeMake(0,1);
    self.headerContainer.layer.shadowOpacity = 1.0f;
    self.headerContainer.layer.shadowRadius = 0.0f;    

    if (!self.patientPhoto.image) {
//        self.patientPhoto.image = [UIImage imageNamed: self.task.patient.photoFilename];
        // Here we use the new provided setImageWithURL: method to load the web image
        NSString *imageUrl = [NSString stringWithFormat:@"/static/patient_photos/%@", self.task.patient.photoFilename];
        [self.patientPhoto setImageWithURL:[NSURL URLWithString:API_URL(imageUrl)]
                          placeholderImage:[UIImage imageNamed:@"homer_simpson.jpg"]];
        
    }
    self.patientPhoto.layer.cornerRadius = floorf(self.patientPhoto.frame.size.width / 2.0f);
    self.patientPhoto.clipsToBounds = YES;
    
    NSString *buttonColor = @"#1A6FD2";
    
    self.assign.backgroundColor = self.sendMessage.backgroundColor = self.completed.backgroundColor = [UIColor clearColor];
    [self.assign setTitleColor:[UIColor colorWithHex:buttonColor] forState:UIControlStateNormal];
    [self.sendMessage setTitleColor:[UIColor colorWithHex:buttonColor] forState:UIControlStateNormal];
    
    self.assign.layer.borderColor = self.sendMessage.layer.borderColor = self.completed.layer.borderColor = [UIColor colorWithHex:buttonColor].CGColor;
    self.assign.layer.borderWidth = self.sendMessage.layer.borderWidth = self.completed.layer.borderWidth = 1.0f;
    self.assign.layer.cornerRadius = self.sendMessage.layer.cornerRadius = self.completed.layer.cornerRadius = 5.0f;
    [self.completed setTitleColor:[UIColor colorWithHex:buttonColor] forState:UIControlStateNormal];
    [self.completed setTitleColor:[UIColor colorWithHex:@"#505050"] forState:UIControlStateDisabled];
    
    if ([self.task.status isEqualToString:@"CLOSED"]) {
        self.completed.enabled = NO;
        self.completed.layer.borderColor = [UIColor colorWithHex:@"#505050"].CGColor;
        [self.completed setTitleColor:[UIColor colorWithHex:@"#505050"] forState:UIControlStateNormal];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}
- (IBAction)willChangeStatus:(UIButton *)doneButton {
    doneButton.enabled = NO;
    [doneButton setTitleColor:[UIColor colorWithHex:@"#505050"] forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor colorWithHex:@"#505050"] forState:UIControlStateDisabled];
    doneButton.layer.borderColor = [UIColor colorWithHex:@"#505050"].CGColor;
    NSString *postUrlString = [NSString stringWithFormat:@"/tasks/%d/status", [self.task.objectId intValue]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:API_URL(postUrlString)
       parameters:@{ @"status" : @"CLOSED" }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [[NSNotificationCenter defaultCenter] postNotificationName:@"ProviderDidCompleteTaskNotification"
                                                                  object:self
                                                                userInfo:@{ @"task" : self.task }];
              [self.navigationController popViewControllerAnimated:YES];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              doneButton.enabled = YES;
              [doneButton setTitleColor:[UIColor colorWithHex:@"#1A6FD2"] forState:UIControlStateNormal];
              [doneButton setTitleColor:[UIColor colorWithHex:@"#505050"] forState:UIControlStateDisabled];
              doneButton.layer.borderColor = [UIColor colorWithHex:@"#1A6FD2"].CGColor;
              HUDWithErrorInView(self.view, @"Could not complete task.");
              NSLog(@"FAILED TO CHANGE STATUS: %@", error);
          }];


}
- (IBAction)willViewPatient:(UIButton *)patientNameButton
{
    NSLog(@"Implement will view patient");

    // Commenting out performSegueWithIdentifier: http://stackoverflow.com/questions/11813091/nested-push-animation-can-result-in-corrupted-navigation-bar-multiple-warning

    /*** The NEW way ***/
    /* In the storyboard world, we don't have to create a Patient VC. We have already
     in our storyboard, dragged on a PatientVC and wired up a transition between the
     patient name button and a patientVC. We gave that segue (transition) a name, 
     'DOCPatientDetailsSegue'. iOS is going to basically do exactly what we did below in
     THE OLD WAY, except, it's not going to set the patient property. iOS doesn't know about
     what data requirements we have. So in THE NEW WAY, since iOS is doing everything with
     regards to instantiating our Patient VC, except the important part, that is wiring up
     the data, we need a place to do that... enter prepareForSegue */

    //[self performSegueWithIdentifier:@"DOCPatientDetailsSegue" sender:self];

    /*** The OLD way ***/

    /* So here is where the user tapped the patient name.
     Normally what would happen is we would say, OK, they want to move to 
     patient details, let's move them over: */

    /* Notice that we're manually creating an instance of our Patient VC,
     and setting the public property 'patient'. We're populating the required
     patient data here ourselves. */

    //DOCPatientViewController *patientVC = [DOCPatientViewController new];
    //patientVC.patient = self.task.patient;

    // our taskVC is in a navigation controller, so we tell our nav controller
    // to push on another VC with animation (the iOS slide that you know and love)

    //[self.navigationController pushViewController:patientVC animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

-(void)textViewDidEndEditing:(UITextView *)textView
{
    NSString *postUrlString = [NSString stringWithFormat:@"/tasks/%d/description", [self.task.objectId intValue]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:API_URL(postUrlString)
       parameters:@{ @"description" : self.taskDescription.text }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"Response object: %@", responseObject);
              self.task.issue = self.taskDescription.text;
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              HUDWithErrorInView(self.view, @"Could not update task.");
              NSLog(@"FAILED TO UPDATE DESCRIPTION: %@", error);
          }];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /* This gets called by iOS right _before_ a segue occurs. So our Patient VC or
     any other VC hasn't appeared yet. Note, this method is called when ANY segue
     will occur. So if you do two different segues, this will get called in both of those
     different cases. That's why we need to check here what type of class we're seguiing(sp?)
     to. In this case, there is currently only one segue, to the Patient VC. We'll still check
     anyway, in case you add more. */

    UIViewController *destinationVC = [segue destinationViewController];

    NSLog(@"destination class: %@", [destinationVC class]);
    if ([destinationVC isKindOfClass:[DOCPatientViewController class]]) {

        // you pretty much got it here!

        /* Remember above, in the handler for the patient button being hit, i said iOS was
         going to do all the instantiation and pushing of the VC onto the navigationController
         viewControllers array. Well, this is the in-between phase. iOS has already instantiated
         the Patient VC and passed it to us here, via [segue destinationViewController] - makes sense right? Destination is where we're headed, i.e. the Patient VC. But we haven't
         segued yet. The segue will be that "push" (horizontal slide) animation. We're in _prepare_ for segue. So it hasn't happened yet. Hence, in-between phase. In between instantiation => push. The thing we were doing manually above in  THE OLD WAY. And in THE OLD WAY, what were we doing in between? If you look at the code, we were instantiating => setting the patient property => pushing. So since iOS is now taking care of (1) and (3) automatically. We need to still do (2). And we do it here. */

        /* This is where we set the patient property. We do the cast (DOCPatientViewController *) because the compiler will complain that it doesn't know about a patient property otherwise. Remember, I said above that this method gets called by iOS when ANY segue is happening from this VC. So the destination VC could be something other than Patient VC (hence why we check above in the if statement). But we still need to tell the compiler that this is a Patient VC, so it knows that setting the patient property is OK. */
        [(DOCPatientViewController *)destinationVC setPatient:self.task.patient];

//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        DOCTask *task = self.tasks[indexPath.row];
//        ((DOCTaskDetailViewController *)[segue destinationViewController]).task = task;
    }
    else if ([destinationVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *wrapperVC = (UINavigationController *)destinationVC;

        if ([wrapperVC.topViewController isKindOfClass:[DOCProvidersViewController class]]) {
            [(DOCProvidersViewController *)wrapperVC.topViewController setTask:self.task];
            [(DOCProvidersViewController *)wrapperVC.topViewController setDelegate:self];
        }
        else if ([wrapperVC.topViewController isKindOfClass:[DOCNewMessageViewController class]]){
            [(DOCNewMessageViewController *)wrapperVC.topViewController setPatient:self.task.patient];
        }

    }

    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - DOCProvidersViewControllerDelegate

- (void)didReassignTask:(DOCTask *)task toProvider:(DOCProvider *)provider
{
    //if we came from the patient view, can only reassign a task that was owned by currently logged in provider
    //if reassigned to the currently logged in provider, i.e. not reassigned at all, don't remove task
    //else pop this view controller and remove task from list

    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProviderDidReassignTaskNotification"
                                                        object:self
                                                      userInfo:@{@"task": task, @"provider":provider}];
}

@end
