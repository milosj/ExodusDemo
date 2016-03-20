//
//  SatelliteNode.h
//  ExodusDemo
//
//  Created by Milos Jovanovic on 2016-03-17.
//  Copyright © 2016 abvgd. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SatelliteNode : SKNode

@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) UIColor* colour;
@property (assign, atomic) BOOL isShowingSymbol;
@property (assign, readonly, nonatomic) CGFloat spriteRadius;
@property (weak, readonly, nonatomic) SKNode* trailNode;
@property (assign, nonatomic) BOOL isCastingShadow;

@property (assign, nonatomic) CGFloat mass;
@property (assign, readonly, nonatomic) CGFloat solarMass;
@property (assign, nonatomic) CGVector inertialVector;
@property (assign, nonatomic) CGPoint initialPosition;
@property (assign, nonatomic) CGVector initialVector;
@property (assign, nonatomic) int orbitLength;
@property (assign, nonatomic) CGFloat orbitRadius;

@property (strong, nonatomic) NSMutableArray<SatelliteNode*>* satellites;;

- (void)update:(long int)time;

@end
