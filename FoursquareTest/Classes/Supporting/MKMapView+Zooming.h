//
//  MKMapView+Zooming.h
//  FoursquareTest
//
//  Updated by Egor Dovzhenko on 24.07.13.
//

#import <MapKit/MapKit.h>

@interface MKMapView (Zooming)
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated;
@end
