//
//  ViewController.m
//  GoogleMap
//
//  Created by Evgene Drobov on 1/30/18.
//  Copyright © 2018 drobov. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

#import <Google-Maps-iOS-Utils/GMUMarkerClustering.h>
#import  <GMUDefaultClusterRenderer.h>
#import <GMUClusterAlgorithm.h>
#import "GMUNonHierarchicalDistanceBasedAlgorithm.h"
#import <GMUClusterIconGenerator.h>
#import "GMUCluster.h"
#import "LocationManager.h"
#import "CustomGMUAlgorithm.h"
#import "CustomClusterIconGenerator.h"

@interface ViewController () <CLLocationManagerDelegate> {
    GMUClusterManager *_clusterManager;
   GMUDefaultClusterRenderer *_renderer;
}
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (strong, nonatomic) NSArray<GMSMarker*> *markers;
@property (strong, nonatomic) CLLocation *userLocation;

@property (nonatomic) NSInteger defaultZoom;
@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareMarkers];
    [self prepareCluster];
    [self prepareLocation];
    self.defaultZoom = 14;
    [self.mapView setMinZoom:10 maxZoom:34];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.markers.firstObject.position.latitude longitude:self.markers.firstObject.position.longitude zoom:self.defaultZoom ];
    self.mapView.camera = camera;
    
}


#pragma mark - Actions

- (IBAction)zoomInAction:(id)sender {
    self.defaultZoom += 0.5;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.mapView.camera.target.latitude longitude:self.mapView.camera.target.longitude zoom:self.defaultZoom ];
    self.mapView.camera = camera;
}
- (IBAction)zoomOutAction:(id)sender {
    self.defaultZoom -= 0.5;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.mapView.camera.target.latitude longitude:self.mapView.camera.target.longitude zoom:self.defaultZoom ];
    self.mapView.camera = camera;
}

- (IBAction)userLocateionAction:(id)sender {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.userLocation.coordinate.latitude longitude:self.userLocation.coordinate.longitude zoom:14];
    self.mapView.camera = camera;

}

#pragma mark GMUClusterManagerDelegate

- (void)clusterManager:(GMUClusterManager *)clusterManager didTapCluster:(id<GMUCluster>)cluster {
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    for (id<GMUClusterItem> item in cluster.items) {
        bounds = [bounds includingCoordinate:item.position];
    }
    
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds
                                                      withEdgeInsets:UIEdgeInsetsMake(100, 20, 40, 80)]];
}
#pragma mark locationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    self.userLocation = newLocation;
}

#pragma mark - Private

- (void)prepareLocation {
    [LocationManager sharedInstance].delegate = self;
}
- (void)prepareCluster {
    id<GMUClusterAlgorithm> algorithm = [[CustomGMUAlgorithm alloc] init];
    id<GMUClusterIconGenerator> iconGenerator = [[GMUDefaultClusterIconGenerator alloc] init];
    _renderer = [[GMUDefaultClusterRenderer alloc] initWithMapView:self.mapView
                                                    clusterIconGenerator:iconGenerator];
    _clusterManager = [[GMUClusterManager alloc] initWithMap:self.mapView algorithm:algorithm renderer:_renderer];
    
    [_clusterManager cluster];
    // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
    [_clusterManager setDelegate:self mapDelegate:self];
    
    [_clusterManager addItems:self.markers];

    [_clusterManager cluster];
}
- (void)prepareMarkers {
    GMSMarker *marker1 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.761288, 37.604396)];
    marker1.icon = [UIImage imageNamed:@"foto_uslugi_1"];
    GMSMarker *marker2 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.764831, 37.611439)];
    marker2.icon = [UIImage imageNamed:@"gruzchik_1"];
    GMSMarker *marker3 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.762849, 37.617949)];
    marker3.icon = [UIImage imageNamed:@"gruzoperevozki_1"];
    GMSMarker *marker4 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.765671, 37.628834)];
    marker4.icon = [UIImage imageNamed:@"krasota_1"];
    GMSMarker *marker5 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.761588, 37.630328)];
    marker5.icon = [UIImage imageNamed:@"kurer_1"];
    GMSMarker *marker6 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.756665, 37.633849)];
    marker6.icon = [UIImage imageNamed:@"org_prazdnik_1"];
    GMSMarker *marker7 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.751560, 37.641960)];
    marker7.icon = [UIImage imageNamed:@"raznorabochiy_1"];
    GMSMarker *marker8 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.761288, 37.604396)];
    marker8.icon = [UIImage imageNamed:@"remont_raboti_1"];
    GMSMarker *marker9 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.749218, 37.634810)];
    marker9.icon = [UIImage imageNamed:@"remontobuvi_1"];
    GMSMarker *marker10 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.751290, 37.628452)];
    marker10.icon = [UIImage imageNamed:@"ustanovka_remont_1"];
    GMSMarker *marker11 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.739606, 37.630946)];
    marker11.icon = [UIImage imageNamed:@"gruzchik_1"];
    GMSMarker *marker12 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.736365, 37.620543)];
    marker12.icon = [UIImage imageNamed:@"gruzoperevozki_1"];
    GMSMarker *marker13 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.739643, 37.621524)];
    marker13.icon = [UIImage imageNamed:@"krasota_1"];
    GMSMarker *marker14 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.750417, 37.594159)];
    marker14.icon = [UIImage imageNamed:@"kurer_1"];
    GMSMarker *marker15 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.739873, 37.612265)];
    marker15.icon = [UIImage imageNamed:@"org_prazdnik_1"];
    GMSMarker *marker16 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.739620, 37.603929)];
    marker16.icon = [UIImage imageNamed:@"remont_raboti_1"];
    GMSMarker *marker17 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.756218, 37.593263)];
    marker17.icon = [UIImage imageNamed:@"remontobuvi_1"];
    GMSMarker *marker18 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.760253, 37.637542)];
    marker18.icon = [UIImage imageNamed:@"ustanovka_remont_1"];
    GMSMarker *marker19 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.751022, 37.620511)];
    marker19.icon = [UIImage imageNamed:@"gruzchik_1"];
    GMSMarker *marker20 = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(55.767262, 37.645071)];
    marker20.icon = [UIImage imageNamed:@"gruzoperevozki_1"];
    
    self.markers = @[marker1,marker2,marker3,marker4,marker5,marker6,marker7,marker8,marker9,marker10,marker11,marker12,marker13,marker14,marker15,marker16,marker17,marker18,marker19,marker20];    
}
@end
