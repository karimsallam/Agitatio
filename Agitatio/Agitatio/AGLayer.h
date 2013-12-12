//
//  AGLayer.h
//  Agitatio
//
//  Created by Karim Sallam on 19/09/2013.
//  Copyright (c) 2013 K-Apps. All rights reserved.
//

@import Foundation;

@protocol AGLayer <NSObject>

- (BOOL)isEnabled;

- (CGFloat)factor; // Valid range: 0.0 - 1.0. Other values will be ignored and the nearest valid value will be used.

- (BOOL)manuallyHandleUpdates;

@optional

@property (nonatomic) BOOL invertX;         // Default YES
@property (nonatomic) BOOL invertY;         // Default YES

@property (nonatomic) BOOL limitX;          // Default NO
@property (nonatomic) BOOL limitY;          // Default NO

@property (nonatomic) CGFloat xLimit;       // Default 0.0f
@property (nonatomic) CGFloat yLimit;       // Default 0.0f

@property (nonatomic) CGFloat xScale;       // Default 90.0f
@property (nonatomic) CGFloat yScale;       // Default 90.0f

@property (nonatomic) CGFloat xFriction;    // Default 0.1f. Valid range: 0.0 - 1.0. Other values will be ignored and the nearest valid value will be used.
@property (nonatomic) CGFloat yFriction;    // Default 0.1f. Valid range: 0.0 - 1.0. Other values will be ignored and the nearest valid value will be used.

- (void)manuallyHandlePositionUpdate:(CGPoint)newPoint;
- (void)manuallyHandleRotationUpdate:(id)someRotationObject; // TODO

@end
