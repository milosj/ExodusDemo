//
//  SatelliteNode.m
//  ExodusDemo
//
//  Created by Milos Jovanovic on 2016-03-17.
//  Copyright © 2016 abvgd. All rights reserved.
//

#import "SatelliteNode.h"

#define kG 0.0172021
#define kGinCentiAUs kG
#define kSquared kGinCentiAUs*kGinCentiAUs


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
        self.physicsBody.dynamic = NO;
        self.label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        [self addChild:self.label];
        self.shape = [SKShapeNode shapeNodeWithCircleOfRadius:5];
        [self addChild:self.shape];
        self.isShowingSymbol = NO;
        self.shape.strokeColor = [UIColor clearColor];
        self.satellites = [NSMutableArray new];
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
    SKShapeNode* oldShape = self.shape;
    [self.shape removeFromParent];
    self.shape = [SKShapeNode shapeNodeWithCircleOfRadius:[self spriteRadius]];
    self.shape.fillColor = oldShape.fillColor;
    self.shape.strokeColor = [UIColor clearColor];
    [self addChild:self.shape];
}

- (CGFloat)spriteRadius {
    return MIN(40,MAX(2, 5+log(self.mass)));
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

- (void)update:(long int)time {
    for (SatelliteNode* satellite in self.satellites) {
        [self update:time forBody:self andSatellite:satellite];
    }
}

- (void)update:(long int)time forBody:(SatelliteNode*)body andSatellite:(SatelliteNode*)satellite {
    
    CGFloat d = [self distanceBetween:body and:satellite];
    
    if (d < 0.01 || d > 1000) {
        NSLog(@"crazy orbit %@ in %@", satellite, self);
        return;
    }
    if (time+1 % satellite.orbitLength == 0  ) {
        satellite.position = CGPointMake(0.5*(satellite.initialPosition.x+satellite.position.x),0.5*(satellite.initialPosition.y+satellite.position.y));
        satellite.inertialVector = satellite.initialVector;
    }
    
    CGVector dv = satellite.inertialVector;
    CGFloat g = kSquared/pow(d/100,3); //gaussian gravitational constant squared times 1 solar mass over radius in AU cubed
    
    CGFloat gx = g*(body.position.x-satellite.position.x)/100;
    CGFloat gy = g*(body.position.y-satellite.position.y)/100;
    
    if (isnan(gy)) {
        gy = 0;
    }
    if (isnan(gx)) {
        gx = 0;
    }
    
    CGFloat ex = satellite.position.x;
    CGFloat ey = satellite.position.y;
    
    
    CGFloat dx = 100*gx + dv.dx;
    CGFloat dy = 100*gy + dv.dy;
    
    CGFloat newex = ex + dx;
    CGFloat newey = ey + dy;
    
    
    
    satellite.position = CGPointMake(newex, newey);
    satellite.inertialVector = CGVectorMake(dx, dy);
    
    
    //        NSLog([NSString stringWithFormat:@"d %.6f g %.6f g(%.6f, %.6f), e'(%.6f, %.6f), v'(%.6f, %.6f)",d, g, gx, gy, newex, newey, dx, dy]);
}

-(CGFloat)distanceBetween:(SKNode*)objectA and:(SKNode*)objectB {
    return sqrt(pow(objectA.position.x-objectB.position.x, 2) + pow(objectA.position.y-objectB.position.y, 2));
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
