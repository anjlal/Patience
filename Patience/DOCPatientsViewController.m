//
//  DOCPatientsViewController.m
//  Patience
//
//  Created by Angie Lal on 11/27/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import "DOCPatientsViewController.h"
#import "DOCPatient.h"
#import <AFNetworking/AFNetworking.h>

@interface DOCPatientsViewController ()

@property (strong, nonatomic) NSMutableArray *patients;

@end

@implementation DOCPatientsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Patients";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    if (!self.patients) {
        self.patients = [NSMutableArray array];
    }

    [self loadPatients];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)loadPatients
{
    // Load Tasks
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:API_URL(@"/patients")
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // remove any tasks if there were any
             [self.patients removeAllObjects];
             for (NSDictionary *dict in responseObject[@"patients"]) {
                 NSLog(@"%@", dict);
                 [_patients addObject:[[DOCPatient alloc] initWithJson:dict]];
             }

             /* Usually need to update the UI on the main thread, but for now let's not do this */
             //             dispatch_async(dispatch_get_main_queue(), ^{
             //                 ;
             //             });
             [self.tableView reloadData];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"This request failed: %@", error);
         }];
}

#pragma mark - Table view data source

- (IBAction)willCancel:(UIBarButtonItem *)cancelButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // Return the number of sections.
    if (!self.patients || [self.patients count] == 0) {
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.patients count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [(DOCPatient *)self.patients[indexPath.row] name];
    //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    // Configure the cell...

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //   cell.accessoryType = UITableViewCellAccessoryCheckmark;

    DOCPatient *selectedPatient = self.patients[indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPatient:)]) {
        [self.delegate didSelectPatient:selectedPatient];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
