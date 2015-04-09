//
//  ViewController.m
//  TapForOverlay
//
//  Created by Jaime Connor on 4/9/15.
//  Copyright (c) 2015 Jaime Connor. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "MKCircleOverlay.h"

@interface ViewController () <MKMapViewDelegate, UIGestureRecognizerDelegate>
{
    MKMapView * mapView;
    MKCircle * circle;
    UITapGestureRecognizer * tap;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,0 , [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    mapView.delegate = self;
    [self.view addSubview:mapView];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped)];
    tap.delegate = self;
    [mapView addGestureRecognizer:tap];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)mapTapped {
    circle = [MKCircle circleWithMapRect:mapView.visibleMapRect];
    [mapView addOverlay:circle];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)map rendererForOverlay:(id <MKOverlay>)overlay
{
    MKCircleOverlay *circleView = [[MKCircleOverlay alloc] initWithOverlay:overlay];
    return circleView;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:
(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
