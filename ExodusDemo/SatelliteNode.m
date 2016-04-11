//
//  SatelliteNode.m
//  ExodusDemo
//
//  Created by Milos Jovanovic on 2016-03-17.
//  Copyright © 2016 abvgd. All rights reserved.
//

#import "SatelliteNode.h"

#define kG 0.0172021
#define kSquared kG*kG
#define unitsPerAU 1000
#define timeResolution 1


@interface SatelliteNode()

@property (strong, nonatomic) SKLabelNode* label;
@property (strong, nonatomic) SKShapeNode* shape;
@property (strong, nonatomic) SKShapeNode* shadow;

@end

@implementation SatelliteNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:1];
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.dynamic = NO;
        self.label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        self.label.fontColor = [UIColor blackColor];
        [self addChild:self.label];
        self.shape = [SKShapeNode shapeNodeWithCircleOfRadius:5];
        [self addChild:self.shape];
        self.shadow = [self.shape copy];
        self.shadow.yScale = 0.75;
        self.shadow.xScale = 1.25;
        self.shadow.fillColor = [UIColor lightGrayColor];
        self.isCastingShadow = YES;
//        self.shadow.position = CGPointMake(self.shape.position.x-5,self.shape.position.y+5);
        [self addChild:self.shadow];
        self.isShowingSymbol = NO;
        self.shape.strokeColor = [UIColor clearColor];
        self.satellites = [NSMutableArray new];
        self.positions = [NSMutableArray new];
        self.inertialVectors = [NSMutableArray new];

        self.overlayShape = [SKLabelNode labelNodeWithText:@"?"];
        ((SKLabelNode*)self.overlayShape).fontColor = [UIColor blackColor];
    }
    return self;
}

- (NSString*)text {
    return self.label.text;
}

- (void)setText:(NSString *)text {
    self.label.text = text;
    ((SKLabelNode*)self.overlayShape).text = text;
}

- (CGFloat)mass {
    return self.physicsBody.mass;
}

- (void)setMass:(CGFloat)mass {
    self.physicsBody.mass = mass;
    
    self.label.fontSize = MIN(MAX(unitsPerAU*4, unitsPerAU/2*mass), 7*unitsPerAU/3);
    self.label.position = CGPointMake(0, -CGRectGetMidY(self.label.calculateAccumulatedFrame));
    
    SKShapeNode* oldShape = self.shape;
    self.shape = [SKShapeNode shapeNodeWithCircleOfRadius:[self spriteRadius]];
    self.shape.fillColor = oldShape.fillColor;
    self.shape.strokeColor = [UIColor clearColor];
    [self.shape removeFromParent];
    [self addChild:self.shape];
    
//    SKShapeNode* oldOverlayShape = self.overlayShape;
//    SKNode* cameraNode = oldOverlayShape.parent;
//    self.overlayShape = [SKShapeNode shapeNodeWithCircleOfRadius:[self spriteRadius]];
//    self.overlayShape.strokeColor = [UIColor blackColor];
//    [oldOverlayShape removeFromParent];
//    [cameraNode addChild:self.overlayShape];
    
    SKNode* oldShadow = self.shadow;
    self.shadow = [self.shape copy];
    self.shadow.yScale = 0.95;
    self.shadow.xScale = 0.95;
    self.shadow.hidden = oldShadow.hidden;
    self.shadow.fillColor = [UIColor darkGrayColor];
    self.shadow.strokeColor = [UIColor lightGrayColor];
    self.shadow.position = CGPointMake(self.shape.position.x-self.spriteRadius,self.shape.position.y-self.spriteRadius);
    self.shadow.zPosition = -10;
    self.shadow.alpha = 0.15;
        [oldShadow removeFromParent];
    [self addChild:self.shadow];

    
}

- (CGFloat)spriteRadius {
    return MIN(4*unitsPerAU/10,MAX(5, 5*unitsPerAU/100+unitsPerAU/100*log(self.mass)));
}

- (UIColor*)colour {
    return self.shape.fillColor;
}

- (void)setColour:(UIColor *)colour {
    self.shape.fillColor = colour;
//    self.label.fontColor = colour;
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

- (BOOL)isCastingShadow {
    return !self.shadow.isHidden;
}

- (void)setIsCastingShadow:(BOOL)isCastingShadow {
    self.shadow.hidden = !isCastingShadow;
}
- (void)update:(CFTimeInterval)time {
    for (SatelliteNode* satellite in self.satellites) {
        [self update:time forBody:self andSatellite:satellite];
    }
}

- (void)update:(CFTimeInterval)time forBody:(SatelliteNode*)body andSatellite:(SatelliteNode*)satellite {
//    satellite.shadow.position = satellite.shape.position;
//    satellite.shadow.zRotation = atan((satellite.position.y-body.position.y)/(satellite.position.x-body.position.x));
    
    if (satellite.orbitalPeriod == 0) {
        return;
    }
    
    int timeIndex = (int)fmod(floorf(time*timeResolution), satellite.orbitalPeriod);
    int nextTimeIndex = timeIndex+1;
    if (nextTimeIndex > satellite.orbitalPeriod) {
        nextTimeIndex = 0;
    }

    CGFloat d = [self distanceBetween:body and:satellite];
    CGFloat xcos = (satellite.position.x-body.position.x)/d;
    CGFloat ycos = (satellite.position.y-body.position.y)/d;
    satellite.shadow.position = CGPointMake(0.9*satellite.spriteRadius*(xcos), 0.8*satellite.spriteRadius*(ycos-1));
    satellite.shadow.zRotation = atan((satellite.position.y-body.position.y)/(satellite.position.x-body.position.x));
//    satellite.shadow.xScale = MAX(0.25,xcos);
    satellite.shadow.yScale = MIN(0.85,MAX(0.25,ABS(ycos)));
    
    if (satellite.positions.count > timeIndex) {
        satellite.position = [satellite.positions[timeIndex] CGPointValue];
        satellite.inertialVector = [satellite.inertialVectors[timeIndex] CGVectorValue];
        return;
    }
    
    if (d < 0.01 || d > 100*unitsPerAU) {
        NSLog(@"crazy orbit %@ in %@", satellite, self);
        return;
    }
    if (time+1 % satellite.orbitalPeriod == 0  ) {
        satellite.position = CGPointMake(0.5*(satellite.initialPosition.x+satellite.position.x),0.5*(satellite.initialPosition.y+satellite.position.y));
        satellite.inertialVector = satellite.initialVector;
    }
    
    CGVector dv = satellite.inertialVector;
    CGFloat g = kSquared/pow(d/unitsPerAU,3); //gaussian gravitational constant squared times 1 solar mass over radius in AU cubed
    
    CGFloat gx = g*(body.position.x-satellite.position.x)/unitsPerAU;
    CGFloat gy = g*(body.position.y-satellite.position.y)/unitsPerAU;
    
    if (isnan(gy)) {
        gy = 0;
    }
    if (isnan(gx)) {
        gx = 0;
    }
    
    CGFloat ex = satellite.position.x;
    CGFloat ey = satellite.position.y;
    
    
    CGFloat dx = unitsPerAU*gx + dv.dx;
    CGFloat dy = unitsPerAU*gy + dv.dy;
    
    CGFloat newex = ex + dx;
    CGFloat newey = ey + dy;
    
    
    
    satellite.position = CGPointMake(newex, newey);
    satellite.inertialVector = CGVectorMake(dx, dy);
    
    [satellite.positions addObject:[NSValue valueWithCGPoint:satellite.position]];
    [satellite.inertialVectors addObject:[NSValue valueWithCGVector:satellite.inertialVector]];
    
    NSLog(@"time %f orbital day %d (%.2f,%.2f)", time, timeIndex, satellite.position.x, satellite.position.y);
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

- (SKNode*)trailNode {
    SKShapeNode* trailNode = [self.shape copy];
    trailNode.position = self.position;
    trailNode.hidden = NO;
    trailNode.alpha = 0.5f;
    return trailNode;
}
@end
