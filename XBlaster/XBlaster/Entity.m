//
//  Entity.m
//  XBlaster
//
//  Created by Nu on 4/14/14.
//  Copyright (c) 2014 The Big Round Mud. All rights reserved.
//

#import "Entity.h"

@implementation Entity
-(instancetype)initWithPosition:(CGPoint)position
{
    if(self = [super init])
    {
        self.texture = [[self class]generateTexture];
        self.size = self.texture.size;
        self.position = position;
        _direction = CGPointZero;
    }
    return self;
}

-(void)update:(CFTimeInterval)delta
{
    // Overriden by subclasses
}

+(SKTexture *)generateTexture
{
    // Overriden by subclasses
    return nil;
}
@end
