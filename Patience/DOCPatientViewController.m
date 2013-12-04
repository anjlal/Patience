//
//  DOCPatientViewController.m
//  Patience
//
//  Created by Angie Lal on 11/13/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import "DOCPatientViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "DOCTaskDetailViewController.h"
#import "DOCProvider.h"
#import <SDWebImage/UIImageView+WebCache.h>


typedef enum {
    DOCPatientChangePhotoFromCamera = 0,
    DOCPatientChangePhotoFromPhotoLibrary
} DOCChangePhotoActionSheetButtonIndices;


@interface DOCPatientViewController ()

@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UIImageView *patientPhoto;
@property (weak, nonatomic) IBOutlet UILabel *patientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientBirthYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientSexLabel;


@end

@implementation DOCPatientViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.tableHeaderView = self.tableHeaderView;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.tableHeaderView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithHex:@"#4A4A4A"] CGColor],
                       (id)[[UIColor colorWithHex:@"#2B2B2B"] CGColor], nil];
    [self.tableHeaderView.layer insertSublayer:gradient atIndex:0];
    
    
    //for whatever reason setting this in IB doesn't work
//    self.patientPhoto.userInteractionEnabled = YES;
//    if (!self.patientPhoto.image) {
//        self.patientPhoto.image = [UIImage imageNamed:@"defaultPatient"];
//    }
    NSString *imageUrl = [NSString stringWithFormat:@"/static/patient_photos/%@", self.patient.photoFilename];

    [self.patientPhoto setImageWithURL:[NSURL URLWithString:API_URL(imageUrl)]
                      placeholderImage:[UIImage imageNamed:@"homer_simpson.jpg"]];
    self.patientPhoto.layer.cornerRadius = floorf(self.patientPhoto.frame.size.width / 2.0f);;
    self.patientPhoto.clipsToBounds = YES;

    self.patientNameLabel.text = self.patient.name;
    self.patientBirthYearLabel.text = [NSString stringWithFormat:@"%d", [self.patient.birthYear intValue]];
    self.patientSexLabel.text = self.patient.sex;

    NSLog(@"Sex: %@", self.patient.sex);

    if (!self.tasks) {
        self.tasks = [NSMutableArray array];
    }

    // Load Tasks
    NSString *gettUrlString = [NSString stringWithFormat:@"/patients/%d/tasks", [self.patient.objectId intValue]];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:API_URL(gettUrlString)
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             for (NSDictionary *dict in responseObject[@"tasks"]) {
                 NSLog(@"%@", dict);
                 [_tasks addObject:[[DOCTask  alloc] initWithJson:dict]];
             }

             /* Usually need to update the UI on the main thread, but for now let's not do this */
             //             dispatch_async(dispatch_get_main_queue(), ^{
             //                 ;
             //             });
             [self.tableView reloadData];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"This request failed: %@", error);
         }];


    //self.patientNameLabel.text = [ patientNameLabel.text];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (IBAction)presentPhotoPicker:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:picker animated:YES completion:NULL];
    }

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.tasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [(DOCTask *)self.tasks[indexPath.row] issue];

    // Configure the cell...
    //cell.textLabel.text = @"Foo";
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Tasks";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //   cell.accessoryType = UITableViewCellAccessoryCheckmark;

    [self performSegueWithIdentifier:@"DOCPatientToTaskDetailSegue" sender:self];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[DOCTaskDetailViewController class]]) {
        //NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        //NSLog(@"Cell: %@", [self.tableView indexPathForSelectedRow]);
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DOCTask *task = self.tasks[indexPath.row];
        ((DOCTaskDetailViewController *)[segue destinationViewController]).task = task;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - UIGestureRecognizer

//- (IBAction)willChangePhoto:(UITapGestureRecognizer *)tgr
//{
//    [self performSegueWithIdentifier:@"DOCEditPatientWillTakePhotoSegue" sender:self];
//}

@end
