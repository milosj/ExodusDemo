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
@property (assign, nonatomic) CGFloat mass;
@property (strong, nonatomic) UIColor* colour;
@property (assign, readonly, nonatomic) CGFloat solarMass;
@property (assign, nonatomic) CGPoint initialPosition;
@property (assign, nonatomic) CGVector initialVector;
@property (assign, nonatomic) int orbitLength;
@property (assign, atomic) BOOL isShowingSymbol;


@end
