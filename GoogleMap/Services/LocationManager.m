//
//  LocationManager.m
//  GoogleMap
//
//  Created by Evgene Drobov on 1/30/18.
//  Copyright © 2018 drobov. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager()

@end

@implementation LocationManager

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
        
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}
@end
