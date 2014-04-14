//
//  Entity.h
//  XBlaster
//
//  Created by Nu on 4/14/14.
//  Copyright (c) 2014 The Big Round Mud. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Entity : SKSpriteNode
@property (assign, nonatomic) CGPoint   direction;
@property (assign, nonatomic) float     health;
@property (assign, nonatomic) float     maxHealth;
+(SKTexture *)generateTexture;
-(instancetype)initWithPosition:(CGPoint)position;
-(void)update:(CFTimeInterval)delta;
@end
