//
//  AGScene.m
//  Agitatio
//
//  Created by Karim Sallam on 20/09/2013.
//  Copyright (c) 2013 K-Apps. All rights reserved.
//

@import ObjectiveC.runtime;

#import "AGScene.h"
#import "AGScene_Protected.h"
#import "AGMath.h"

#pragma mark Scene default values

#define kDefaultUpdateIntervalValue         1.0f/40 //0.5f
#define kDefaultCalibrateXValue             NO
#define kDefaultCalibrateYValue             YES

#define kDefaultCalibrationThresholdValue   100.0f

#pragma mark - AGScene

@implementation AGScene

#pragma mark Lifecycle

- (void)dealloc
{
    [self.motionManager stopDeviceMotionUpdates];
}

- (instancetype)init
{
    [NSException raise:NSInternalInconsistencyException
                format:
     @"Calling %@ which is not a designated initializer. "
     @"You must use one of the designated initializer.",
     NSStringFromSelector(_cmd)];

    return nil;
}

- (instancetype)initWithLayers:(NSArray *)layers
{
    NSParameterAssert([layers count]); // TODO use exceptions.

    self = [super init];
    if (self != nil)
    {
        // Layers.
        self.mutableLayers = [NSMutableArray array];
        [self.mutableLayers addObjectsFromArray:layers];
        self.layers = [NSArray arrayWithArray:self.mutableLayers];

        // Motion manager.
        self.motionManager = [CMMotionManager new];
        self.motionManager.deviceMotionUpdateInterval = kDefaultUpdateIntervalValue;

        // Calibration.
        self.needsCalibration = YES;
        self.calibrateX = kDefaultCalibrateXValue;
        self.calibrateY = kDefaultCalibrateYValue;
        self.calibrationThreshold = kDefaultCalibrationThresholdValue;
    }
    return self;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    // TODO
    return nil;
}

#pragma mark NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
    // TODO
    return nil;
}

#pragma mark NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])buffer
                                    count:(NSUInteger)len
{
    return [self.mutableLayers countByEnumeratingWithState:state
                                                   objects:buffer
                                                     count:len];
}

#pragma mark Public

- (void)setUpdateInterval:(NSTimeInterval)updateInterval
{
    self.motionManager.deviceMotionUpdateInterval = updateInterval;
}

- (NSTimeInterval)updateInterval
{
    return self.motionManager.deviceMotionUpdateInterval;
}

- (NSUInteger)count
{
    return [self.mutableLayers count];
}

- (id<AGLayer>)layerAtIndex:(NSUInteger)index
{
    NSParameterAssert(index < [self.mutableLayers count]); // TODO use exceptions.
    return self.mutableLayers[index];
}

- (BOOL)isDeviceMotionAvailable
{
    return [self.motionManager isDeviceMotionAvailable];
}

- (BOOL)isRunning
{
    return [self.motionManager isDeviceMotionActive];
}

- (BOOL)start
{
    NSParameterAssert(![self isRunning]); // TODO use exceptions.

    if ([self isDeviceMotionAvailable])
    {
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                                withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                                    [self calibrateIfNeeded:motion];
                                                    [self calculateMotion:motion];
                                                    [self updateLayers];
                                                }];

        return YES;
    }

    return NO;
}

- (void)stop
{
    NSParameterAssert([self isRunning]); // TODO use exceptions.

    [self.motionManager stopDeviceMotionUpdates];
}

#pragma mark Private

- (void)calibrateIfNeeded:(CMDeviceMotion *)deviceMotion
{
    if (self.needsCalibration)
    {
        CGPoint calibration = {
            .x = deviceMotion.attitude.pitch,
            .y = deviceMotion.attitude.roll
        };
        self.calibration = calibration;

        self.needsCalibration = NO;
    }
}

- (void)calculateMotion:(CMDeviceMotion *)deviceMotion
{
    CGPoint input = {
        .x = deviceMotion.attitude.pitch,
        .y = deviceMotion.attitude.roll
    };
    CGPoint difference = {
        .x = input.x - self.calibration.x,
        .y = input.y - self.calibration.y
    };

    // TODO
//    if (ABS(difference.x) > self.calibrationThreshold
//        || ABS(difference.y) > self.calibrationThreshold)
//    {
//        self.needsCalibration = YES;
//    }

    if (UIDeviceOrientationIsPortrait(self.orientation))
    {
        CGPoint motion = {
            .x = self.calibrateX ? difference.y : input.y,
            .y = self.calibrateY ? difference.x : input.x
        };
        self.motion = motion;
    }
    else
    {
        CGPoint motion = {
            .x = self.calibrateX ? difference.x : input.x,
            .y = self.calibrateY ? difference.y : input.y
        };
        self.motion = motion;
    }
}

- (void)updateLayers
{
    for (id<AGLayer> layer in self.layers)
    {
        if ([layer isEnabled])
        {
            CGPoint layerMotion = self.motion;

            [self transformMotion:&layerMotion forLayer:layer];
            [self scaleMotion:&layerMotion forLayer:layer];
            [self limitMotion:&layerMotion forLayer:layer];
            NSLog(@"layerMotion %@", NSStringFromCGPoint(layerMotion));
            NSLog(@"OFFset layerMotion %@", NSStringFromCGPoint(CGPointMake(60.0f * layerMotion.x, - 60.0f * layerMotion.y)));

//            CGPoint velocity = [self velocityForLayer:layer withMotion:layerMotion];
            if ([layer manuallyHandleUpdates])
            {
                [layer manuallyHandlePositionUpdate:layerMotion];
            }
            else
            {
                NSParameterAssert([layer isKindOfClass:[UIView class]]); // TODO use exceptions.
                UIView *view = (UIView *)layer;
//                view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 60.0f * layerMotion.x, - 60.0f * layerMotion.y);
                view.layer.transform = CATransform3DMakeTranslation(layerMotion.x, layerMotion.y, 0.0f);
            }
        }
    }
}

- (void)transformMotion:(CGPoint*)motion forLayer:(id<AGLayer>)layer
{
    motion->x *= layer.factor;
    motion->y *= layer.factor;
}

- (void)limitMotion:(CGPoint*)motion forLayer:(id<AGLayer>)layer
{
    BOOL limitX = [self limitXValueForLayer:layer];
    if (limitX)
    {
        CGFloat xLimit = [self xLimitValueForLayer:layer];
        motion->x = AGClamp(motion->x, -xLimit, xLimit);
    }

    BOOL limitY = [self limitYValueForLayer:layer];
    if (limitY)
    {
        CGFloat yLimit = [self yLimitValueForLayer:layer];
        motion->y = AGClamp(motion->y, -yLimit, yLimit);
    }
}

- (void)scaleMotion:(CGPoint*)motion forLayer:(id<AGLayer>)layer
{
    motion->x *= [self xScaleValueForLayer:layer];
    motion->y *= [self yScaleValueForLayer:layer];
}

//- (CGPoint)velocityForLayer:(id<AGExetendedLayer>)layer withMotion:(CGPoint)motion
//{
//    CGFloat xFriction = [self xFrictionValueForLayer:layer];
//    CGFloat yFriction = [self yFrictionValueForLayer:layer];
//
//    CGPoint velocity = {
//        .x = motion.x - layer.ag_velocity.x * xFriction,
//        .y = motion.y - layer.ag_velocity.y * yFriction
//    };
//
//}

@end

#pragma mark - AGScene (AGExtendedScene)

@implementation AGScene (AGExtendedScene)

#pragma mark Public

- (BOOL)containsLayer:(id<AGLayer>)layer
{
    return [self.mutableLayers containsObject:layer];
}

- (NSUInteger)indexOfLayer:(id<AGLayer>)layer
{
    return [self.mutableLayers indexOfObject:layer];
}

@end

#pragma mark - AGScene (AGSceneLayerValuesProviders)

@implementation AGScene (AGSceneLayerValuesProviders)

#pragma mark Layer default values

#define kDefaultInvertX     YES
#define kDefaultInvertY     YES

#define kDefaultLimitX      NO
#define kDefaultLimitY      NO

#define kDefaultXLimit      0.0f
#define kDefaultYLimit      0.0f

#define kDefaultXScale      90.0f
#define kDefaultYScale      90.0f

#define kDefaultXFriction   0.1f
#define kDefaultYFriction   0.1f

#pragma mark Providers

- (BOOL)invertXValueForLayer:(id<AGLayer>)layer
{
    return [layer respondsToSelector:@selector(invertX)] ? [layer invertX] : kDefaultInvertX;
}

- (BOOL)invertYValueForLayer:(id<AGLayer>)layer
{
    return [layer respondsToSelector:@selector(invertY)] ? [layer invertY] : kDefaultInvertY;
}

- (BOOL)limitXValueForLayer:(id<AGLayer>)layer
{
    return [layer respondsToSelector:@selector(limitX)] ? [layer limitX] : kDefaultLimitX;
}

- (BOOL)limitYValueForLayer:(id<AGLayer>)layer
{
    return [layer respondsToSelector:@selector(limitY)] ? [layer limitY] : kDefaultLimitY;
}

- (CGFloat)xLimitValueForLayer:(id<AGLayer>)layer
{
    CGFloat xLimit = [layer respondsToSelector:@selector(xLimit)] ? [layer xLimit] : kDefaultXLimit;
    return [self valueOrZeroIfNan:xLimit];
}

- (CGFloat)yLimitValueForLayer:(id<AGLayer>)layer
{
    CGFloat yLimit = [layer respondsToSelector:@selector(yLimit)] ? [layer invertX] : kDefaultYLimit;
    return [self valueOrZeroIfNan:yLimit];
}

- (CGFloat)xScaleValueForLayer:(id<AGLayer>)layer
{
    CGFloat xScale = [layer respondsToSelector:@selector(xScale)] ? [layer invertX] : kDefaultXScale;
    return [self valueOrZeroIfNan:xScale];
}

- (CGFloat)yScaleValueForLayer:(id<AGLayer>)layer
{
    CGFloat yScale = [layer respondsToSelector:@selector(yScale)] ? [layer invertX] : kDefaultYScale;
    return [self valueOrZeroIfNan:yScale];
}

- (CGFloat)xFrictionValueForLayer:(id<AGLayer>)layer
{
    CGFloat xFriction = [layer respondsToSelector:@selector(xFriction)] ? [layer invertX] : kDefaultXFriction;
    return [self sanitizedValue:xFriction];
}

- (CGFloat)yFrictionValueForLayer:(id<AGLayer>)layer
{
    CGFloat yFriction = [layer respondsToSelector:@selector(yFriction)] ? [layer invertX] : kDefaultYFriction;
    return [self sanitizedValue:yFriction];
}

#pragma mark Sanitization

- (CGFloat)valueOrZeroIfNan:(CGFloat)value
{
    return !isnan(value) ? value : 0.0f;
}

- (CGFloat)sanitizedValue:(CGFloat)value
{
    CGFloat validValue = [self valueOrZeroIfNan:value];
    return validValue > 0.0f ? (validValue < 1.0f ? validValue : 1.0f) : 0.0f;
}

@end

@implementation NSObject (AGExetendedLayer)

static void * AGVelocityKey;

- (void)setAg_velocity:(CGPoint)ag_velocity
{
    objc_setAssociatedObject(self,
                             AGVelocityKey,
                             NSStringFromCGPoint(ag_velocity),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)ag_velocity
{
    NSString *velocityString =  objc_getAssociatedObject(self,
                                                         AGVelocityKey);
    return CGPointFromString(velocityString);
}

@end

#pragma mark - AGMutableScene

@implementation AGMutableScene

#pragma mark Public

- (void)addLayer:(id<AGLayer>)layer
{
    NSParameterAssert(![self.mutableLayers containsObject:layer]); // TODO use exceptions.
    [self.mutableLayers addObject:layer];
    self.layers = [NSArray arrayWithArray:self.mutableLayers];
}

- (void)removeLayer:(id<AGLayer>)layer
{
    NSParameterAssert([self.mutableLayers containsObject:layer]);  // TODO use exceptions.
    [self.mutableLayers removeObject:layer];
    self.layers = [NSArray arrayWithArray:self.mutableLayers];
}

- (void)replaceLayer:(id<AGLayer>)layer
           withLayer:(id<AGLayer>)replaceLayer
{
    NSParameterAssert([self.mutableLayers containsObject:layer]); // TODO use exceptions.
    NSParameterAssert(![self.mutableLayers containsObject:replaceLayer]);  // TODO use exceptions.
    [self.mutableLayers replaceObjectAtIndex:[self indexOfLayer:layer] withObject:replaceLayer];
    self.layers = [NSArray arrayWithArray:self.mutableLayers];
}

@end
