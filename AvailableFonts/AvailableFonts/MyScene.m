//
//  MyScene.m
//  AvailableFonts
//
//  Created by Nu on 4/13/14.
//  Copyright (c) 2014 The Big Round Mud. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene
{
    int _familyIdx;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        [self showCurFamily];
    }
    return self;
}

-(void)showCurFamily
{
    [self removeAllChildren];
    
    NSString *familyName = [UIFont familyNames][_familyIdx];
    NSLog(@"%@",familyName);
    
    NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
    
    [fontNames enumerateObjectsUsingBlock:^(NSString *fontName, NSUInteger idx, BOOL *stop) {
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:fontName];
        label.text = fontName;
        label.position = CGPointMake(self.size.width/2, (self.size.height * (idx+1)/(fontNames.count+1)));
        label.fontSize = 20.0;
        label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [self addChild:label];
    }];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _familyIdx++;
    
    if(_familyIdx >= [UIFont familyNames].count)
    {
        _familyIdx = 0;
    }
    [self showCurFamily];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
