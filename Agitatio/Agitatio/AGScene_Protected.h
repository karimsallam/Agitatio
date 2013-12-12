//
//  AGScene_Protected.h
//  Agitatio
//
//  Created by Karim Sallam on 20/09/2013.
//  Copyright (c) 2013 K-Apps. All rights reserved.
//

@import CoreMotion;
@import UIKit;

#import "AGScene.h"
#import "AGLayer.h"

@interface AGScene ()

// Layers.
@property (strong, nonatomic)   NSMutableArray      *mutableLayers;
@property (strong, nonatomic)   NSArray             *layers;

// Motion.
@property (strong, nonatomic)   CMMotionManager     *motionManager;
@property (nonatomic)           UIDeviceOrientation orientation;
@property (nonatomic)           CGPoint             motion;

// Calibration.
@property (nonatomic)           BOOL                needsCalibration;
@property (nonatomic)           CGPoint             calibration;
@property (nonatomic)           CGFloat             calibrationThreshold;

@end

@interface AGScene (AGSceneLayerValuesProviders)

- (BOOL)invertXValueForLayer:(id<AGLayer>)layer;
- (BOOL)invertYValueForLayer:(id<AGLayer>)layer;

- (BOOL)limitXValueForLayer:(id<AGLayer>)layer;
- (BOOL)limitYValueForLayer:(id<AGLayer>)layer;

- (CGFloat)xLimitValueForLayer:(id<AGLayer>)layer;
- (CGFloat)yLimitValueForLayer:(id<AGLayer>)layer;

- (CGFloat)xScaleValueForLayer:(id<AGLayer>)layer;
- (CGFloat)yScaleValueForLayer:(id<AGLayer>)layer;

- (CGFloat)xFrictionValueForLayer:(id<AGLayer>)layer;
- (CGFloat)yFrictionValueForLayer:(id<AGLayer>)layer;

@end

@protocol AGExetendedLayer <AGLayer>

@property (nonatomic) CGPoint ag_velocity;

@end

