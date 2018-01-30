//
//  LocationManager.h
//  GoogleMap
//
//  Created by Evgene Drobov on 1/30/18.
//  Copyright © 2018 drobov. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface LocationManager : CLLocationManager

+ (instancetype)sharedInstance;

@end
