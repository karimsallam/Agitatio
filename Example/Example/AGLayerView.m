//
//  AGLayerView.m
//  Example
//
//  Created by Karim Sallam on 12/12/2013.
//  Copyright (c) 2013 K-Apps. All rights reserved.
//

#import "AGLayerView.h"

@implementation AGLayerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark AGLayer

- (BOOL)isEnabled
{
    return YES;
}

- (CGFloat)factor
{
    return 1.0f;
}

- (BOOL)manuallyHandleUpdates
{
    return NO;
}

@end
