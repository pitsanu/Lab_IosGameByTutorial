//
//  PlayerShip.m
//  XBlaster
//
//  Created by Nu on 4/14/14.
//  Copyright (c) 2014 The Big Round Mud. All rights reserved.
//

#import "PlayerShip.h"

@implementation PlayerShip
-(instancetype)initWithPosition:(CGPoint)position
{
    if(self = [super initWithPosition:position])
    {
        self.name = @"shipSprite";
    }
    return self;
}

+(SKTexture *)generateTexture
{
    static SKTexture *texture = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        SKLabelNode *mainShip = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        mainShip.name = @"mainship";
        mainShip.fontSize = 20.0f;
        mainShip.fontColor = [SKColor whiteColor];
        mainShip.text = @"▲";
        
        SKLabelNode *wings = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        wings.name = @"wings";
        wings.fontSize = 20.0f;
        wings.text = @"< >";
        wings.fontColor = [SKColor whiteColor];
        wings.position = CGPointMake(0, 7);
        
        wings.zRotation = DegreesToRadians(180);
        
        [mainShip addChild:wings];
        
        SKView *textureView = [SKView new];
        texture = [textureView textureFromNode:mainShip];
        texture.filteringMode = SKTextureFilteringNearest;
    });
    
    return texture;
}
@end
