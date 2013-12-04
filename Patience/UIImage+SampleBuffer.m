//
//  UIImage+SampleBuffer.m
//  Patience
//
//  Created by Russell D'Sa on 11/28/13.
//  Copyright (c) 2013 Angie Lal. All rights reserved.
//

#import "UIImage+SampleBuffer.h"

@implementation UIImage (SampleBuffer)

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
	CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    uint8_t *baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(context);
	
	CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    CGColorSpaceRelease(colorSpace);
	
    UIImage *image = [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight]; // captureStillImageAsynchronouslyFromConnection always outputs image with orientation to the right
    CGImageRelease(newImage);
    
	return image;
}

+ (UIImage *)imageFromView:(UIView *)view
{
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return outputImage;
}

+ (UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    return cropped;
}

@end
