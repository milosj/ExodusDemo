//
//  GameScene.h
//  ExodusDemo
//

//  Copyright (c) 2016 abvgd. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "TimeControlViewController.h"

@interface GameScene : SKScene<TimeSliderDelegate>

@property (assign, nonatomic) CGFloat zoom;
@property (assign, atomic) BOOL showTrails;

- (void)setShowSymbols:(BOOL)showSymbols;

@end
