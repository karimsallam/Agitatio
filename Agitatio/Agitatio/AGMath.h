//
//  AGMath.h
//  Agitatio
//
//  Created by Karim Sallam on 12/12/2013.
//  Copyright (c) 2013 K-Apps. All rights reserved.
//

#ifndef AGITATIO_AGMATH
#define AGITATIO_AGMATH

static inline CGFloat AGClamp(CGFloat value, CGFloat min, CGFloat max)
{
    return MIN(MAX(value, min), max);
}

#endif
