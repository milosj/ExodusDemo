//
//  SatelliteNode.m
//  ExodusDemo
//
//  Created by Milos Jovanovic on 2016-03-17.
//  Copyright © 2016 abvgd. All rights reserved.
//

#import "SatelliteNode.h"

@interface SatelliteNode()

@property (strong, nonatomic) SKLabelNode* label;
@property (strong, nonatomic) SKShapeNode* shape;


@end

@implementation SatelliteNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:1];
        self.physicsBody.affectedByGravity = NO;
        self.label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        [self addChild:self.label];
        self.shape = [SKShapeNode shapeNodeWithCircleOfRadius:5];
        [self addChild:self.shape];
        self.isShowingSymbol = NO;
        self.shape.strokeColor = [UIColor clearColor];
    }
    return self;
}

- (NSString*)text {
    return self.label.text;
}

- (void)setText:(NSString *)text {
    self.label.text = text;
}

- (CGFloat)mass {
    return self.physicsBody.mass;
}

- (void)setMass:(CGFloat)mass {
    self.physicsBody.mass = mass;
    self.label.fontSize = MIN(MAX(20, 45*mass), 90);
    self.label.position = CGPointMake(0, -CGRectGetMidY(self.label.calculateAccumulatedFrame));
}

- (UIColor*)colour {
    return self.shape.fillColor;
}

- (void)setColour:(UIColor *)colour {
    self.shape.fillColor = colour;
    self.label.fontColor = colour;
}

- (CGFloat)solarMass {
    return self.physicsBody.mass / 333000.0f;
}

- (BOOL)isShowingSymbol {
    return !self.label.hidden;
}
- (void)setIsShowingSymbol:(BOOL)isShowingSymbol {
    self.label.hidden = !isShowingSymbol;
    self.shape.hidden = isShowingSymbol;
}

- (instancetype)copy {
    SatelliteNode* clone = [SatelliteNode new];
    clone.text = self.text;
    clone.colour = self.colour;
    clone.mass = self.mass;
    clone.name = self.name;
    clone.position = self.position;
    clone.isShowingSymbol = self.isShowingSymbol;
    return clone;
}
@end
