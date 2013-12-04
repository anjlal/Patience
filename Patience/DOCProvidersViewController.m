//
//  DOCProvidersViewController.m
//  Patience
//
//  Created by Angie Lal on 11/14/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import "DOCProvidersViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "DOCTask.h"

@interface DOCProvidersViewController ()
@property (nonatomic, strong) NSIndexPath* checkedIndexPath;
@property (strong, nonatomic) NSMutableArray *providers;
@end

@implementation DOCProvidersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Providers";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(willCancel:)];

    if (!self.providers) {
        self.providers = [NSMutableArray array];
    }

    // Load Tasks
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:API_URL(@"/providers")
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             for (NSDictionary *dict in responseObject[@"providers"]) {
                 NSLog(@"%@", dict);
                 [_providers addObject:[[DOCProvider alloc] initWithJson:dict]];
             }

             /* Usually need to update the UI on the main thread, but for now let's not do this */
             //             dispatch_async(dispatch_get_main_queue(), ^{
             //                 ;
             //             });
             [self.tableView reloadData];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"This request failed: %@", error);
         }];
    


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - UIResponder (UIBarButtonItems)

- (void)willCancel:(UIBarButtonItem *)cancelButton
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)willAssign:(UIBarButtonItem *)assignButton
{
    //do assignment here via POST
    assignButton.enabled = NO;
    DOCProvider *provider = self.providers[self.checkedIndexPath.row];

    if ([self.task.providerId isEqual:provider.objectId]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    NSString *postUrlString = [NSString stringWithFormat:@"/tasks/%d/reassign", [self.task.objectId intValue]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                                    [manager POST:API_URL(postUrlString)
                                       parameters:@{ @"providerId" : provider.objectId }
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              if (self.delegate && [self.delegate respondsToSelector:@selector(didReassignTask:toProvider:)]) {
                                                  [self.delegate didReassignTask:self.task toProvider:provider];
                                              }
                                              [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              assignButton.enabled = YES;
                                              NSLog(@"FAILED TO REASSIGN TASK: %@", error);
                                          }];
    
    //disable the assign button until server has responded - if failure, re-enable button
    //if success dismiss like in willCancel above
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (!self.providers || [self.providers count] == 0) {
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.providers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    DOCProvider *provider = self.providers[indexPath.row];
    //cell.textLabel.text = provider.email;

    cell.textLabel.text =  [NSString stringWithFormat:@"Dr. %@", provider.name];

    // looks like i lied and the default accessory is a chevron? weird. this can't be true...
    // but let's just be explicit
    // SH is a laggy piece of shite

    //set default accessory type
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //if this provider is the currently assigned provider, change accessory type
    if ([provider.objectId isEqualToNumber:self.task.providerId]) {
        self.checkedIndexPath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    return cell;

    //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    // Configure the cell...
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if we selected the same indexPath that was already selected, do nothing
    if ([self.checkedIndexPath isEqual:indexPath]) {
        return;
    }

    // get the cells using the index paths
    UITableViewCell *previouslySelectedCell = [tableView cellForRowAtIndexPath:self.checkedIndexPath];
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];

    // uncheck previously checked and check the new cell
    previouslySelectedCell.accessoryType = UITableViewCellAccessoryNone;
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;

    // save the index path of the newly checked cell
    self.checkedIndexPath = indexPath;
}

//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath
//                                                                                                     *)indexPath {
//    //add your own code to set the cell accesory type.
//    return UITableViewCellAccessoryNone;
//}
//    if(self.checkedIndexPath)
//    {
//        UITableViewCell* uncheckCell = [tableView
//                                        cellForRowAtIndexPath:self.checkedIndexPath];
//        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
//    }
//    if([self.checkedIndexPath isEqual:indexPath])
//    {
//        self.checkedIndexPath = nil;
//    }
//    else
//    {
//        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        self.checkedIndexPath = indexPath;
//    }
//}

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
