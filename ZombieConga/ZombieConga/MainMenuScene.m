//
//  MainMenuScene.m
//  ZombieConga
//
//  Created by Nu on 4/12/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "MainMenuScene.h"
#import "MyScene.h"

@implementation MainMenuScene
-(id)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size])
    {
        self.backgroundColor = [SKColor whiteColor];
        
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"MainMenu.png"];
        bg.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:bg];
    }
    
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    SKScene *myscene = [[MyScene alloc]initWithSize:self.size];
    SKTransition *doorway = [SKTransition doorsCloseHorizontalWithDuration:0.5];
    [self.view presentScene:myscene transition:doorway];
}
@end
