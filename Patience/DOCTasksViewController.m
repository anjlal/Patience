//
//  DOCTasksViewController.m
//  Patience
//
//  Created by Angie Lal on 11/11/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import "DOCTasksViewController.h"
#import "DOCTask.h"
#import "DOCProvider.h"
#import "DOCAccount.h"
#import <AFNetworking/AFNetworking.h>
#import "DOCTaskDetailViewController.h"
#import "DOCTaskTableViewCell.h"

typedef enum {
    DOCNewItemTaskButton = 0,
    DOCNewItemPatientButton
} DOCNewItemActionSheetButtons;

@interface DOCTasksViewController ()

@property (strong, nonatomic) NSMutableArray *tasks;

@end

@implementation DOCTasksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Tasks";
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.hidesBackButton = YES;

    if (!self.tasks) {
        self.tasks = [NSMutableArray array];
    }

    [self loadTasks:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReassignTask:)
                                                 name:@"ProviderDidReassignTaskNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didCompleteTask:)
                                                 name:@"ProviderDidCompleteTaskNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didCreateTask:)
                                                 name:@"ProviderDidCreateTaskNotification"
                                               object:nil];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)loadTasks:(UIRefreshControl *)refreshControl
{
    // Load Tasks
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:API_URL(@"/tasks")
      parameters:@{ @"provider_id": [[[DOCAccount account] currentProvider] objectId] }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // remove any tasks if there were any
             [self.tasks removeAllObjects];
             for (NSDictionary *dict in responseObject[@"tasks"]) {
                 NSLog(@"%@", dict);
                 [_tasks addObject:[[DOCTask alloc] initWithJson:dict]];
             }

             /* Usually need to update the UI on the main thread, but for now let's not do this */
             //             dispatch_async(dispatch_get_main_queue(), ^{
             //                 ;
             //             });
             [self.tableView reloadData];
             //refresh control could be nil
             [refreshControl endRefreshing];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"This request failed: %@", error);
         }];
}

/* Very much like we do for buttons, we create an IBAction for our UIRefreshControl */
//this could be any name, we will wire up in IB
//the sender will always be a UIRefreshControl, since we control (via IB) when this method gets called
//I can explain this more later in person
- (IBAction)willRefresh:(UIRefreshControl *)refreshControl
{
    NSLog(@"Will refresh tasks");
    [self loadTasks:refreshControl];
}

- (NSInteger)indexForTask:(DOCTask *)task
{
    NSUInteger count = [self.tasks count];
    NSInteger taskIndex = -1;
    for (int i = 0; i < count; i++) {
        if ([[(DOCTask *)self.tasks[i] objectId] isEqual:task.objectId]) {
            taskIndex = i;
            break;
        }
    }
    return taskIndex;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (!self.tasks || [self.tasks count] == 0) {
        return 0;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DOCTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DOCTaskTableViewCellIdentifier"];
    cell.task = self.tasks[indexPath.row];
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.tasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DOCTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DOCTaskTableViewCellIdentifier" forIndexPath:indexPath];
    cell.task = self.tasks[indexPath.row];
//    cell.textLabel.text = [(DOCTask *)self.tasks[indexPath.row] issue];
    //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    // Configure the cell...
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  //  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
 //   cell.accessoryType = UITableViewCellAccessoryCheckmark;

    [self performSegueWithIdentifier:@"DOCTaskDetailsSegue" sender:self];
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

#pragma mark - Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Get the name of the current pressed button
//    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    switch (buttonIndex) {
        case DOCNewItemTaskButton:
            [self performSegueWithIdentifier:@"DOCTaskNewTaskSegue" sender:self];
            break;
        case DOCNewItemPatientButton:
            [self performSegueWithIdentifier:@"DOCTaskNewPatientSegue" sender:self];
            break;
        default:
            break;
    }
}

#pragma mark - Navigation
- (IBAction)addButtonPressed:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Add New:"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Task", @"Patient", nil];
    [actionSheet showInView:self.view];
    
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[DOCTaskDetailViewController class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DOCTask *task = self.tasks[indexPath.row];
        ((DOCTaskDetailViewController *)[segue destinationViewController]).task = task;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - NSNotification

/* These look identical, and they are, but we might do something different down the road
   based on what action was taken. So leaving the code duplication for now. */

- (void)didReassignTask:(NSNotification *)notification
{
    NSDictionary *notificationInfo = [notification userInfo];
    DOCTask *task = notificationInfo[@"task"];
    NSInteger taskIndex = [self indexForTask:task];
    if (taskIndex != -1) {
        [self.tasks removeObjectAtIndex:taskIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (void)didCompleteTask:(NSNotification *)notification
{
    NSDictionary *notificationInfo = [notification userInfo];
    DOCTask *task = notificationInfo[@"task"];
    NSInteger taskIndex = [self indexForTask:task];
    if (taskIndex != -1) {
        [self.tasks removeObjectAtIndex:taskIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (void)didCreateTask:(NSNotification *)notification
{
    DOCTask *task = [notification userInfo][@"task"];
    [self.tasks insertObject:task atIndex:0];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


@end
