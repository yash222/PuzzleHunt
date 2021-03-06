//
//  PHClueLocationViewController.h
//  PuzzleHunt
//
//  Created by Nick Troccoli on 1/26/14.
//  Copyright (c) 2014 Trancos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PHCreateClueViewController.h"

@class MKMapView;
@interface PHClueLocationViewController : UIViewController <UITextFieldDelegate, MKMapViewDelegate>
@property (nonatomic, weak) IBOutlet UITextField *locationField;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

@property (nonatomic, weak) id <LocationFinderDelegate> delegate;
@end
