//
//  DOCTaskTableViewCell.m
//  Patience
//
//  Created by Russell D'Sa on 12/3/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import "DOCTaskTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DOCTaskTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *patientPhoto;
@property (weak, nonatomic) IBOutlet UILabel *description;

@end

@implementation DOCTaskTableViewCell

- (void)setTask:(DOCTask *)task
{
    _task = task;
    self.description.text = task.issue;
    NSString *imageUrl = [NSString stringWithFormat:@"/static/patient_photos/%@", self.task.patient.photoFilename];
    [self.patientPhoto setImageWithURL:[NSURL URLWithString:API_URL(imageUrl)]
                      placeholderImage:[UIImage imageNamed:@"homer_simpson.jpg"]];
    self.patientPhoto.layer.cornerRadius = floorf(self.patientPhoto.frame.size.width / 2.0f);
    self.patientPhoto.clipsToBounds = YES;
}

@end
