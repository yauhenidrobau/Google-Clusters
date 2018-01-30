//
//  CustomClusterIconGenerator.m
//  Mishiko
//
//  Created by Admin on 10/10/17.
//  Copyright © 2017 Intech. All rights reserved.
//

#import "CustomClusterIconGenerator.h"

@implementation CustomClusterIconGenerator

- (UIImage *)iconForSize:(NSUInteger)size {
    // Return custom icon for cluster
    return [UIImage imageNamed:@"remont_raboti_1"];
}

- (UIImage *)iconForMarker {
    // Return custom icon for pin
    return [UIImage imageNamed:@"remont_raboti_1"];
}

- (CGPoint)markerIconGroundAnchor {
    // If your marker icon center shifted, return custom value for anchor
    return CGPointMake(0, 0);
}

- (CGPoint)clusterIconGroundAnchor {
    // If your cluster icon center shifted, return custom value for anchor
    return CGPointMake(0.5, 0.5);
}

@end
