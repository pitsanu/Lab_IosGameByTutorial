//
//  MyScene.m
//  XBlaster
//
//  Created by Nu on 4/13/14.
//  Copyright (c) 2014 The Big Round Mud. All rights reserved.
//

#import "MyScene.h"
#import "PlayerShip.h"
#import "Bullet.h"

NSString * const FONT_DEFAULT = @"Thirteen Pixel Fonts";

@implementation MyScene
{
    PlayerShip *_playerShip;
    SKNode *_playerLayerNode;
    SKLabelNode *_playerHealthLabel;
    NSString *_healthBar;
    
    SKNode *_hudLayerNode;
    SKAction *_scoreFlashAction;
    
    CGPoint _deltaPoint;
    
    float _bulletInterval;
    CFTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;

}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        [self setupSceneLayers];
        [self setupUI];
        [self setupEntities];
    }
    
    return self;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint currentPoint = [[touches anyObject]locationInNode:self];
    CGPoint previousPoint = [[touches anyObject]previousLocationInNode:self];
    _deltaPoint = CGPointSubtract(currentPoint, previousPoint);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _deltaPoint = CGPointZero;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _deltaPoint = CGPointZero;
}

-(void)update:(CFTimeInterval)currentTime {
    CGPoint newPoint = CGPointAdd(_playerShip.position, _deltaPoint);
    newPoint.x = Clamp(newPoint.x, _playerShip.size.width/2, self.size.width - _playerShip.size.width/2);
    newPoint.y = Clamp(newPoint.y, _playerShip.size.height/2, self.size.height - _playerShip.size.height/2);
    _playerShip.position = newPoint;
    _deltaPoint = CGPointZero;
    
    if(_lastUpdateTime)
    {
        _dt = currentTime - _lastUpdateTime;
    }
    else
    {
        _dt = 0;
    }
    
    _lastUpdateTime = currentTime;
    _bulletInterval += _dt;
    if(_bulletInterval > 0.15)
    {
        _bulletInterval = 0;
        
        // 1: Create bullet
        Bullet *bullet = [[Bullet alloc]initWithPosition:_playerShip.position];
        
        // 2: Add to scene
        [_playerLayerNode addChild:bullet];
        
        // 3: Sequence: Move up screen, remove from parent
        SKAction *moveUp = [SKAction moveByX:0 y:self.size.height duration:2.0];
        SKAction *remove = [SKAction removeFromParent];
        [bullet runAction:[SKAction sequence:@[moveUp,remove]]];
    }
}

// ############################################################################
// HELPER METHODS HERE
#pragma mark Helper Methods
-(void)setupSceneLayers
{
    _playerLayerNode = [SKNode node];
    [self addChild:_playerLayerNode];
    
    _hudLayerNode = [SKNode node];
    [self addChild:_hudLayerNode];
}

-(void)setupUI
{
    int barHeight = 45;
    CGSize backgroundSize = CGSizeMake(self.size.width, barHeight);
    
    SKColor *backgroundColor = [SKColor colorWithRed:0 green:0 blue:0.05 alpha:1.0];
    SKSpriteNode *hudBarBackground = [SKSpriteNode spriteNodeWithColor:backgroundColor
                                                                  size:backgroundSize];
    
    hudBarBackground.position = CGPointMake(0, self.size.height - barHeight);
    hudBarBackground.anchorPoint = CGPointZero;
    
    [_hudLayerNode addChild:hudBarBackground];
    
    // Score
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:FONT_DEFAULT];
    scoreLabel.fontSize = 20.0;
    scoreLabel.text = @"Score: 0";
    scoreLabel.name = @"scoreLabel";
    scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    scoreLabel.position = CGPointMake(self.size.width/2, self.size.height - scoreLabel.frame.size.height + 3);
    [_hudLayerNode addChild:scoreLabel];
    
    _scoreFlashAction = [SKAction sequence:@[[SKAction scaleTo:1.5 duration:0.1],
                                             [SKAction scaleTo:1 duration:0.1]]];
    [scoreLabel runAction:[SKAction repeatAction:_scoreFlashAction count:10]];
    
    // Player healthbar
    _healthBar = @"===================================================";
    float testHealth = 75;
    NSString *actualHealth = [_healthBar substringToIndex:(testHealth/100*_healthBar.length)];
    
    SKLabelNode *playerHealthBackground = [SKLabelNode labelNodeWithFontNamed:FONT_DEFAULT];
    playerHealthBackground.name = @"playerHealthBackground";
    playerHealthBackground.fontColor = [SKColor darkGrayColor];
    playerHealthBackground.fontSize = 10.0f;
    playerHealthBackground.text = _healthBar;
    
    playerHealthBackground.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    playerHealthBackground.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    playerHealthBackground.position = CGPointMake(0, self.size.height - barHeight + playerHealthBackground.frame.size.height);
    [_hudLayerNode addChild:playerHealthBackground];
    
    _playerHealthLabel = [SKLabelNode labelNodeWithFontNamed:FONT_DEFAULT];
    _playerHealthLabel.name = @"playerHealth";
    _playerHealthLabel.fontColor = [SKColor whiteColor];
    _playerHealthLabel.fontSize = 10.0f;
    _playerHealthLabel.text = actualHealth;
    _playerHealthLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _playerHealthLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    _playerHealthLabel.position = CGPointMake(0, self.size.height - barHeight + _playerHealthLabel.frame.size.height);
    [_hudLayerNode addChild:_playerHealthLabel];
}

-(void)setupEntities
{
    _playerShip = [[PlayerShip alloc]initWithPosition:CGPointMake(self.size.width/2, 100)];
    [_playerLayerNode addChild:_playerShip];
}
@end
