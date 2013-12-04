//
//  UIImage+SampleBuffer.h
//  Patience
//
//  Created by Russell D'Sa on 11/28/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface UIImage (SampleBuffer)

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
+ (UIImage *)imageFromView:(UIView *)view;
+ (UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;

@end
