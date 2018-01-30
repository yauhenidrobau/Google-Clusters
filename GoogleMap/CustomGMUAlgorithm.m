//
//  CustomGMUNonHierarchicalDistanceBasedAlgorithm.m
//  Mishiko
//
//  Created by Admin on 10/10/17.
//  Copyright © 2017 Intech. All rights reserved.
//

#import "CustomGMUAlgorithm.h"


#import <GoogleMaps/GMSGeometryUtils.h>

#import "GMUStaticCluster.h"
#import "GMUClusterItem.h"
#import "GMUWrappingDictionaryKey.h"
#import "GQTPointQuadTree.h"

static const NSUInteger kCustomGMUClusterDistancePoints = 100;
static const double kCustomGMUMapPointWidth = 2.0;  // MapPoint is in a [-1,1]x[-1,1] space.

#pragma mark Utilities Classes

@interface CustomGMUClusterItemQuadItem : NSObject<GQTPointQuadTreeItem>

@property(nonatomic, readonly) id<GMUClusterItem> clusterItem;

- (instancetype)initWithClusterItem:(id<GMUClusterItem>)clusterItem;

@end

@implementation CustomGMUClusterItemQuadItem {
    id<GMUClusterItem> _clusterItem;
    GQTPoint _clusterItemPoint;
}

- (instancetype)initWithClusterItem:(id<GMUClusterItem>)clusterItem {
    if ((self = [super init])) {
        _clusterItem = clusterItem;
        GMSMapPoint point = GMSProject(clusterItem.position);
        _clusterItemPoint.x = point.x;
        _clusterItemPoint.y = point.y;
    }
    return self;
}

- (GQTPoint)point {
    return _clusterItemPoint;
}

// Forwards hash to clusterItem.
- (NSUInteger)hash {
    return [_clusterItem hash];
}

// Forwards isEqual to clusterItem.
- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    
    if ([object class] != [self class]) return NO;
    
    CustomGMUClusterItemQuadItem *other = (CustomGMUClusterItemQuadItem *)object;
    return [_clusterItem isEqual:other->_clusterItem];
}

@end

@implementation CustomGMUAlgorithm {
    NSMutableArray<id<GMUClusterItem>> *_items;
    GQTPointQuadTree *_quadTree;
}

- (instancetype)init {
    if ((self = [super init])) {
        _items = [[NSMutableArray alloc] init];
        GQTBounds bounds = {-1, -1, 1, 1};
        _quadTree = [[GQTPointQuadTree alloc] initWithBounds:bounds];
    }
    return self;
}

- (void)addItems:(NSArray<id<GMUClusterItem>> *)items {
    [_items addObjectsFromArray:items];
    for (id<GMUClusterItem> item in items) {
        CustomGMUClusterItemQuadItem *quadItem = [[CustomGMUClusterItemQuadItem alloc] initWithClusterItem:item];
        [_quadTree add:quadItem];
    }
}

/**
 * Removes an item.
 */
- (void)removeItem:(id<GMUClusterItem>)item {
    [_items removeObject:item];
    
    CustomGMUClusterItemQuadItem *quadItem = [[CustomGMUClusterItemQuadItem alloc] initWithClusterItem:item];
    // This should remove the corresponding quad item since GMUClusterItemQuadItem forwards its hash
    // and isEqual to the underlying item.
    [_quadTree remove:quadItem];
}

/**
 * Clears all items.
 */
- (void)clearItems {
    [_items removeAllObjects];
    [_quadTree clear];
}


/**
 * Returns the set of clusters of the added items.
 */




- (NSArray<id<GMUCluster>> *)clustersAtZoom:(float)zoom {
    NSMutableArray<id<GMUCluster>> *clusters = [[NSMutableArray alloc] init];
    NSMutableDictionary<GMUWrappingDictionaryKey *, id<GMUCluster>> *itemToClusterMap =
    [[NSMutableDictionary alloc] init];
    NSMutableDictionary<GMUWrappingDictionaryKey *, NSNumber *> *itemToClusterDistanceMap =
    [[NSMutableDictionary alloc] init];
    NSMutableSet<id<GMUClusterItem>> *processedItems = [[NSMutableSet alloc] init];
    
    for (id<GMUClusterItem> item in _items) {
        if ([processedItems containsObject:item]) continue;
        
        GMUStaticCluster *cluster = [[GMUStaticCluster alloc] initWithPosition:item.position];
        
        GMSMapPoint point = GMSProject(item.position);
        
        // Query for items within a fixed point distance from the current item to make up a cluster
        // around it.
        double radius = kCustomGMUClusterDistancePoints * kCustomGMUMapPointWidth / pow(2.0, zoom + 8.0);
        GQTBounds bounds = {point.x - radius, point.y - radius, point.x + radius, point.y + radius};
        NSArray *nearbyItems = [_quadTree searchWithBounds:bounds];
        for (CustomGMUClusterItemQuadItem *quadItem in nearbyItems) {
            id<GMUClusterItem> nearbyItem = quadItem.clusterItem;
            [processedItems addObject:nearbyItem];
            GMSMapPoint nearbyItemPoint = GMSProject(nearbyItem.position);
            GMUWrappingDictionaryKey *key = [[GMUWrappingDictionaryKey alloc] initWithObject:nearbyItem];
            
            NSNumber *existingDistance = [itemToClusterDistanceMap objectForKey:key];
            double distanceSquared = [self distanceSquaredBetweenPointA:point andPointB:nearbyItemPoint];
            if (existingDistance != nil) {
                if ([existingDistance doubleValue] < distanceSquared) {
                    // Already belongs to a closer cluster.
                    continue;
                }
                GMUStaticCluster *existingCluster = [itemToClusterMap objectForKey:key];
                [existingCluster removeItem:nearbyItem];
            }
            NSNumber *number = [NSNumber numberWithDouble:distanceSquared];
            [itemToClusterDistanceMap setObject:number forKey:key];
            [itemToClusterMap setObject:cluster forKey:key];
            [cluster addItem:nearbyItem];
        }
        [clusters addObject:cluster];
    }
    if (itemToClusterDistanceMap.count != _items.count) {
        NSAssert(itemToClusterDistanceMap.count == _items.count,
                 @"All items should be mapped to a distance");
    }
    if (itemToClusterMap.count != _items.count) {
        NSAssert(itemToClusterMap.count == _items.count,
                 @"All items should be mapped to a cluster");
    }
    
    
#if DEBUG
    NSUInteger totalCount = 0;
    for (id<GMUCluster> cluster in clusters) {
        totalCount += cluster.count;
    }
    if (_items.count != totalCount) {
        NSAssert(_items.count == totalCount, @"All clusters combined should make up original item set");
    }
    
#endif
    return clusters;
}

#pragma mark Private

- (double)distanceSquaredBetweenPointA:(GMSMapPoint)pointA andPointB:(GMSMapPoint)pointB {
    double deltaX = pointA.x - pointB.x;
    double deltaY = pointA.y - pointB.y;
    return deltaX * deltaX + deltaY * deltaY;
}

@end
