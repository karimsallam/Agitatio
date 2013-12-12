//
//  AGScene.h
//  Agitatio
//
//  Created by Karim Sallam on 20/09/2013.
//  Copyright (c) 2013 K-Apps. All rights reserved.
//

@import Foundation;

@protocol AGLayer;

@interface AGScene : NSObject <NSCopying, NSMutableCopying, NSFastEnumeration>

- (instancetype)initWithLayers:(NSArray *)layers;

@property (nonatomic) NSTimeInterval    updateInterval; // Default 0.5f
@property (nonatomic) BOOL              calibrateX;     // Default NO
@property (nonatomic) BOOL              calibrateY;     // Default YES

- (NSArray *)layers;
- (NSUInteger)count;
- (id<AGLayer>)layerAtIndex:(NSUInteger)index;

- (BOOL)isDeviceMotionAvailable;
- (BOOL)isRunning;
- (BOOL)start;
- (void)stop;

@end

@interface AGScene (AGExtendedScene)

- (BOOL)containsLayer:(id<AGLayer>)layer;
- (NSUInteger)indexOfLayer:(id<AGLayer>)layer;

@end

@interface AGMutableScene : AGScene

- (void)addLayer:(id<AGLayer>)layer;
- (void)removeLayer:(id<AGLayer>)layer;
- (void)replaceLayer:(id<AGLayer>)layer
           withLayer:(id<AGLayer>)replaceLayer;

@end

@interface AGMutableScene (AGExtendedMutableScene)


@end
