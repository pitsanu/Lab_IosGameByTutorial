//
//  MyScene.m
//  ZombieConga
//
//  Created by Main Account on 8/28/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

/*
 
 Challenge 1 answers:
 
 1) [SKAction followPath:... duration:...]
 2) [SKAction fadeAlphaTo:... duration:...]
 3) Explanation follows:
 
 Custom actions allow you to easily make a node do soemthing over time that there isn't already an action for. The ActionsCatalog demonstrates three kinds of custom actions: making a node blink, jump, or follow a sin wave.
 
 Custom actions give you a node to work with, and how much time has elapsed. Your job is to update something on the node, based on the percentage of how much time has elapsed vs. the passed in duration.
 
 As an example, here's an explanation of the blink action demo in ActionsCatalog:
 
 1) Divide the duration by the number of blinks the desired in that time period. Call that a "slice" of time. In each slice, the node should be visible for half the time, and invisible for the other half. That is what will make the node appear to blink.
 
 2) fmodf is like the normal modulus operator (%), except it works with fractions instead of integers. It basically returns the remainder of the first parameter (elapsedTime) after being divided by the second parameter (slice). So in this example, it gives you the amount of time that has elapsed in this "slice" calculated ealrier.
 
 3) The hidden property on a node controls whether it is rendered or not. If the remainder calculated above is in the second half of the slice, it should be hidden (invisible). Otherwise it will be visible. Hence, the blink effect!
 
 */

@import AVFoundation;

#import "MyScene.h"
#import "GameOverScene.h"

static inline CGPoint CGPointAdd(const CGPoint a,
                                 const CGPoint b)
{
  return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointSubtract(const CGPoint a,
                                      const CGPoint b)
{
  return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a,
                                            const CGFloat b)
{
  return CGPointMake(a.x * b, a.y * b);
}

static inline CGFloat CGPointLength(const CGPoint a)
{
  return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGPoint CGPointNormalize(const CGPoint a)
{
  CGFloat length = CGPointLength(a);
  return CGPointMake(a.x / length, a.y / length);
}

static inline CGFloat CGPointToAngle(const CGPoint a)
{
  return atan2f(a.y, a.x);
}

static inline CGFloat ScalarSign(CGFloat a)
{
  return a >= 0 ? 1 : -1;
}

// Returns shortest angle between two angles,
// between -M_PI and M_PI
static inline CGFloat ScalarShortestAngleBetween(
                                                 const CGFloat a, const CGFloat b)
{
  CGFloat difference = b - a;
  CGFloat angle = fmodf(difference, M_PI * 2);
  if (angle >= M_PI) {
    angle -= M_PI * 2;
  }
  return angle;
}

#define ARC4RANDOM_MAX      0x100000000
static inline CGFloat ScalarRandomRange(CGFloat min,
                                        CGFloat max)
{
  return floorf(((double)arc4random() / ARC4RANDOM_MAX) *
                (max - min) + min);
}

static const int TRAIN_COUNT = 30;
static const int LIVES = 5;

static const float ZOMBIE_MOVE_POINTS_PER_SEC = 120.0;
static const float ZOMBIE_ROTATE_RADIANS_PER_SEC = 4 * M_PI;
static const float CAT_MOVE_POINTS_PER_SEC = 120.0;
static const float BG_POINTS_PER_SEC = 50;


@implementation MyScene
{
    SKSpriteNode *_zombie;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    CGPoint _velocity;
    CGPoint _lastTouchLocation;
    SKAction *_zombieAnimation;
    SKAction *_catCollisionSound;
    SKAction *_enemyCollisionSound;
    BOOL _invincible;
    int _lives;
    BOOL _gameOver;
    AVAudioPlayer *_backgroundMusicPlayer;
    SKNode *_bgLayer;
}

- (void)spawnEnemy
{
  SKSpriteNode *enemy =
  [SKSpriteNode spriteNodeWithImageNamed:@"enemy"];
  enemy.name = @"enemy";
  CGPoint enemyScenePos = CGPointMake(
                               self.size.width + enemy.size.width/2,
                               ScalarRandomRange(enemy.size.height/2,
                                                 self.size.height-enemy.size.height/2));
    enemy.position = [_bgLayer convertPoint:enemyScenePos fromNode:self];
  [_bgLayer addChild:enemy];
  
    CGPoint actionMoveScenePos = CGPointMake(-enemy.size.width/2, 0);
    CGPoint actionMoveBg = [self convertPoint:actionMoveScenePos toNode:_bgLayer];
    
  SKAction *actionMove =
    [SKAction moveToX:actionMoveBg.x duration:2.0];
  SKAction *actionRemove = [SKAction removeFromParent];
  [enemy runAction:
   [SKAction sequence:@[actionMove, actionRemove]]];

}

-(id)initWithSize:(CGSize)size
{
  if (self = [super initWithSize:size]) {
      _bgLayer = [SKNode node];
      [self addChild:_bgLayer];
      
      self.backgroundColor = [SKColor whiteColor];
      [self playBackgroundMusic:@"bgMusic.mp3"];
      _lives = LIVES;
      _gameOver = false;
      
      // Background
      for(int i=0; i<2; i++)
      {   
          SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
          bg.anchorPoint = CGPointZero;
          bg.position = CGPointMake(i*bg.size.width, 0);
          bg.name = @"bg";
          [_bgLayer addChild:bg];
      }
      
      
      
    //CGSize mySize = bg.size;
    //NSLog(@"Size: %@", NSStringFromCGSize(mySize));
    
    _zombie = [SKSpriteNode spriteNodeWithImageNamed:@"zombie1"];
    _zombie.position = CGPointMake(100, 100);
    _zombie.zPosition = 100;
    [_bgLayer addChild:_zombie];
    
    // 1
    NSMutableArray *textures =
    [NSMutableArray arrayWithCapacity:10];
    // 2
    for (int i = 1; i < 4; i++) {
      NSString *textureName =
      [NSString stringWithFormat:@"zombie%d", i];
      SKTexture *texture =
      [SKTexture textureWithImageNamed:textureName];
      [textures addObject:texture];
    }
    // 3
    for (int i = 4; i > 1; i--) {
      NSString *textureName =
      [NSString stringWithFormat:@"zombie%d", i];
      SKTexture *texture =
      [SKTexture textureWithImageNamed:textureName];
      [textures addObject:texture];
    }
    // 4
    _zombieAnimation =
    [SKAction animateWithTextures:textures timePerFrame:0.1];
    // 5
    //[_zombie runAction:
    // [SKAction repeatActionForever:_zombieAnimation]];
    
    //[_zombie setScale:2.0]; // SKNode method
    
    [self runAction:[SKAction repeatActionForever:
    [SKAction sequence:@[
      [SKAction performSelector:@selector(spawnEnemy)
                       onTarget:self],
      [SKAction waitForDuration:2.0]]]]];
    
    [self runAction:[SKAction repeatActionForever:
      [SKAction sequence:@[
        [SKAction performSelector:@selector(spawnCat)
                         onTarget:self],
        [SKAction waitForDuration:1.0]]]]];
    
    _catCollisionSound = [SKAction playSoundFileNamed:@"hitCat.wav"
                                    waitForCompletion:NO];
    _enemyCollisionSound =
      [SKAction playSoundFileNamed:@"hitCatLady.wav"
               waitForCompletion:NO];
    
  }
  return self;
}

//// Gesture recognizer example
//// Uncomment this, and comment the touchesBegan/Moved/Ended methods to test
//- (void)didMoveToView:(SKView *)view
//{
//  UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//  [self.view addGestureRecognizer:tapRecognizer];
//}
//
//- (void)handleTap:(UITapGestureRecognizer *)recognizer {
//  CGPoint touchLocation = [recognizer locationInView:self.view];
//  touchLocation = [self convertPointFromView:touchLocation];
//  [self moveZombieToward:touchLocation];
//}

- (void)update:(NSTimeInterval)currentTime
{
  if (_lastUpdateTime) {
    _dt = currentTime - _lastUpdateTime;
  } else {
    _dt = 0;
  }
  _lastUpdateTime = currentTime;
  //NSLog(@"%0.2f milliseconds since last update", _dt * 1000);
  
  /*CGPoint offset = CGPointSubtract(_lastTouchLocation, _zombie.position);
  float distance = CGPointLength(offset);
  if (distance < ZOMBIE_MOVE_POINTS_PER_SEC * _dt) {
    _zombie.position = _lastTouchLocation;
    _velocity = CGPointZero;
    [self stopZombieAnimation];
  } else {
   */
      
    [self moveSprite:_zombie velocity:_velocity];
    [self boundsCheckPlayer];
    [self rotateSprite:_zombie toFace:_velocity rotateRadiansPerSec:ZOMBIE_ROTATE_RADIANS_PER_SEC];
      
  //}
  
    [self moveTrain];
    //[self checkCollisions];
    
    [self moveBg];
    
    if(_lives <= 0 && !_gameOver)
    {
        _gameOver = true;
        NSLog(@"You lose!");
        [_backgroundMusicPlayer stop];
        
        SKScene *gameOverScene = [[GameOverScene alloc]initWithSize:self.size won:NO];
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        [self.view presentScene:gameOverScene transition:reveal];
    }
    
    // Loggins section
    //NSString *logstr = "
    //NSLog(@"%f:%f", _bgLayer.position.x, _bgLayer.position.y);
}

- (void)didEvaluateActions {
  [self checkCollisions];
}

- (void)moveSprite:(SKSpriteNode *)sprite
          velocity:(CGPoint)velocity
{
  // 1
  CGPoint amountToMove = CGPointMultiplyScalar(velocity, _dt);
  //NSLog(@"Amount to move: %@",
  //      NSStringFromCGPoint(amountToMove));
  
  // 2
  sprite.position = CGPointAdd(sprite.position, amountToMove);
}

- (void)moveZombieToward:(CGPoint)location
{
  [self startZombieAnimation];
  _lastTouchLocation = location;
  CGPoint offset = CGPointSubtract(location, _zombie.position);
  
  CGPoint direction = CGPointNormalize(offset);
  _velocity = CGPointMultiplyScalar(direction, ZOMBIE_MOVE_POINTS_PER_SEC);
  
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint touchLocation = [touch locationInNode:_bgLayer];
  [self moveZombieToward:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint touchLocation = [touch locationInNode:_bgLayer];
  [self moveZombieToward:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint touchLocation = [touch locationInNode:_bgLayer];
  [self moveZombieToward:touchLocation];
}

- (void)boundsCheckPlayer
{
  // 1
  CGPoint newPosition = _zombie.position;
  CGPoint newVelocity = _velocity;
  
  // 2
  CGPoint bottomLeft = [_bgLayer convertPoint:CGPointZero fromNode:self];
  CGPoint topRight = [_bgLayer convertPoint: CGPointMake(self.size.width,
                                                         self.size.height)
                                   fromNode:self];
  
  // 3
  if (newPosition.x <= bottomLeft.x) {
    newPosition.x = bottomLeft.x;
    newVelocity.x = -newVelocity.x;
  }
  if (newPosition.x >= topRight.x) {
    newPosition.x = topRight.x;
    newVelocity.x = -newVelocity.x;
  }
  if (newPosition.y <= bottomLeft.y) {
    newPosition.y = bottomLeft.y;
    newVelocity.y = -newVelocity.y;
  }
  if (newPosition.y >= topRight.y) {
    newPosition.y = topRight.y;
    newVelocity.y = -newVelocity.y;
  }
  
  // 4
  _zombie.position = newPosition;
  _velocity = newVelocity;
}

- (void)rotateSprite:(SKSpriteNode *)sprite
              toFace:(CGPoint)velocity
 rotateRadiansPerSec:(CGFloat)rotateRadiansPerSec
{
  float targetAngle = CGPointToAngle(velocity);
  float shortest = ScalarShortestAngleBetween(sprite.zRotation, targetAngle);
  float amtToRotate = rotateRadiansPerSec * _dt;
  if (ABS(shortest) < amtToRotate) {
    amtToRotate = ABS(shortest);
  }
  sprite.zRotation += ScalarSign(shortest) * amtToRotate;
}

- (void)startZombieAnimation
{
  if (![_zombie actionForKey:@"animation"]) {
    [_zombie runAction:
     [SKAction repeatActionForever:_zombieAnimation]
               withKey:@"animation"];
  }
}

- (void)stopZombieAnimation
{
  [_zombie removeActionForKey:@"animation"];
}

- (void)spawnCat
{
  // 1
  SKSpriteNode *cat =
    [SKSpriteNode spriteNodeWithImageNamed:@"cat"];
  cat.name = @"cat";
  CGPoint catScenePos = CGPointMake(
                             ScalarRandomRange(0, self.size.width),
                             ScalarRandomRange(0, self.size.height));
    cat.position = [_bgLayer convertPoint:catScenePos fromNode:self];
    
  cat.xScale = 0;
  cat.yScale = 0;
  [_bgLayer addChild:cat];
  
  // 2
  cat.zRotation = -M_PI / 16;
  
  SKAction *appear = [SKAction scaleTo:1.0 duration:0.5];
  
  SKAction *leftWiggle = [SKAction rotateByAngle:M_PI / 8
                                        duration:0.5];
  SKAction *rightWiggle = [leftWiggle reversedAction];
  SKAction *fullWiggle =[SKAction sequence:
                         @[leftWiggle, rightWiggle]];
  //SKAction *wiggleWait =
  //  [SKAction repeatAction:fullWiggle count:10];
  //SKAction *wait = [SKAction waitForDuration:10.0];
  
  SKAction *scaleUp = [SKAction scaleBy:1.2 duration:0.25];
  SKAction *scaleDown = [scaleUp reversedAction];
  SKAction *fullScale = [SKAction sequence:
                         @[scaleUp, scaleDown, scaleUp, scaleDown]];
  
  SKAction *group = [SKAction group:@[fullScale, fullWiggle]];
  SKAction *groupWait = [SKAction repeatAction:group count:10];
  
  SKAction *disappear = [SKAction scaleTo:0.0 duration:0.5];
  SKAction *removeFromParent = [SKAction removeFromParent];
  [cat runAction:
   [SKAction sequence:@[appear, groupWait, disappear,
                        removeFromParent]]];
}

- (void)checkCollisions
{
  [_bgLayer enumerateChildNodesWithName:@"cat"
                         usingBlock:^(SKNode *node, BOOL *stop){
                           SKSpriteNode *cat = (SKSpriteNode *)node;
                           if (CGRectIntersectsRect(cat.frame, _zombie.frame)) {
                             //[cat removeFromParent];
                             [self runAction:_catCollisionSound];
                             cat.name = @"train";
                             [cat removeAllActions];
                             [cat setScale:1];
                             cat.zRotation = 0;
                             [cat runAction:[SKAction colorizeWithColor:[SKColor greenColor] colorBlendFactor:1.0 duration:0.2]];
                           }
                         }];
  
  if (_invincible) return;
  
  [_bgLayer enumerateChildNodesWithName:@"enemy"
                         usingBlock:^(SKNode *node, BOOL *stop){
                           SKSpriteNode *enemy = (SKSpriteNode *)node;
                           CGRect smallerFrame = CGRectInset(enemy.frame, 20, 20);
                           if (CGRectIntersectsRect(smallerFrame, _zombie.frame)) {
                             //[enemy removeFromParent];
                             [self runAction:_enemyCollisionSound];
                               
                               [self loseCats];
                               _lives--;
                               
                             _invincible = YES;
                             float blinkTimes = 10;
                             float blinkDuration = 3.0;
                             SKAction *blinkAction =
                             [SKAction customActionWithDuration:blinkDuration
                                                    actionBlock:
                              ^(SKNode *node, CGFloat elapsedTime) {
                                float slice = blinkDuration / blinkTimes;
                                float remainder = fmodf(elapsedTime, slice);
                                node.hidden = remainder > slice / 2;
                              }];
                              SKAction *sequence = [SKAction sequence:@[blinkAction, [SKAction runBlock:^{
                               _zombie.hidden = NO;
                               _invincible = NO;
                              }]]];
                              [_zombie runAction:sequence];
                           }
                         }];
}

- (void)moveTrain
{
    NSLog(@"moveTrain");
  __block int trainCount = 0;
  __block CGPoint targetPosition = _zombie.position;
  [_bgLayer enumerateChildNodesWithName:@"train"
                         usingBlock:^(SKNode *node, BOOL *stop){
                             
                             trainCount++;
                             NSLog(@"in usingBlock");
                             
                           if (!node.hasActions) {
                             float actionDuration = 0.3;
                             CGPoint offset = CGPointSubtract(targetPosition, node.position);
                               
                               NSLog(@"(%f:%f)(%f:%f)", targetPosition.x, targetPosition.y, node.position.x, node.position.y);
                               
                             CGPoint direction = CGPointNormalize(offset);
                             CGPoint amountToMovePerSec = CGPointMultiplyScalar(direction, CAT_MOVE_POINTS_PER_SEC);
                             CGPoint amountToMove = CGPointMultiplyScalar(amountToMovePerSec, actionDuration);
                             SKAction *moveAction = [SKAction moveByX:amountToMove.x y:amountToMove.y duration:actionDuration];
                             [node runAction:moveAction];
                           }
                           targetPosition = node.position;
                         }];
    if(trainCount >= TRAIN_COUNT && !_gameOver)
    {
        _gameOver = true;
        NSLog(@"You win!");
        [_backgroundMusicPlayer stop];
        
        // Move to winner scene
        SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:YES];
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        [self.view presentScene:gameOverScene transition:reveal];
    }
}

-(void)loseCats
{
    __block int loseCount = 0;
    [_bgLayer enumerateChildNodesWithName:@"train" usingBlock:^(SKNode *node, BOOL *stop) {
        CGPoint randomSpot = node.position;
        randomSpot.x += ScalarRandomRange(-100, 100);
        randomSpot.y += ScalarRandomRange(-100, 100);
        
        node.name = @"";
        [node runAction:[SKAction sequence:@[
                            [SKAction group:@[
                                [SKAction rotateByAngle:M_PI*4 duration:1.0],
                                [SKAction moveTo:randomSpot duration:1.0],
                                [SKAction scaleTo:0 duration:1.0]
                            ]],
                            [SKAction removeFromParent]
                            ]]];
        loseCount++;
        if(loseCount>2)
        {
            *stop = true;
        }
    }];
}

-(void)playBackgroundMusic:(NSString *)filename
{
    NSError *error;
    NSURL *backgroundMusicURL = [[NSBundle mainBundle]URLForResource:filename withExtension:nil];
    _backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    _backgroundMusicPlayer.numberOfLoops = -1;
    [_backgroundMusicPlayer prepareToPlay];
    [_backgroundMusicPlayer play];
}

-(void)moveBg
{
    CGPoint bgVelocity = CGPointMake(-BG_POINTS_PER_SEC, 0);
    CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity, _dt);
    _bgLayer.position = CGPointAdd(_bgLayer.position, amtToMove);

    [_bgLayer enumerateChildNodesWithName:@"bg" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *bg = (SKSpriteNode *)node;
        CGPoint bgScreenPos = [_bgLayer convertPoint:bg.position toNode:self];
        if(bgScreenPos.x <= -bg.size.width)
        {
            bg.position = CGPointMake(bg.position.x + bg.size.width*2, bg.position.y);
            //NSLog(@"backgroud re-positioned!");
        }
    }];
}
@end
