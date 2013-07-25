//
//  MKMapView+Zooming.h
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 24.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (Zooming)
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated;
@end
