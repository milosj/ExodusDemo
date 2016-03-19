//
//  GameScene.m
//  ExodusDemo
//
//  Created by Milos Jovanovic on 2016-03-03.
//  Copyright (c) 2016 abvgd. All rights reserved.
//

#import "GameScene.h"
#import "SatelliteNode.h"

#define kG 0.0172021
#define kGinCentiAUs kG
#define kSquared kGinCentiAUs*kGinCentiAUs


@interface GameScene()

@property (strong, nonatomic) SatelliteNode* sun;
@property (strong, nonatomic) SatelliteNode* mercury;
@property (strong, nonatomic) SatelliteNode* venus;
@property (strong, nonatomic) SatelliteNode* earth;
@property (strong, nonatomic) SatelliteNode* mars;

@property (strong, nonatomic) SKLabelNode* label;
@property (assign, atomic) CFTimeInterval nextUpdateTime;
@property (assign, atomic) CGFloat scale;

@property (strong, nonatomic) NSMutableArray<SatelliteNode*>* satellites;
@property (strong, nonatomic) NSMutableDictionary<NSString*, NSValue*>* vectors;
@property (strong, nonatomic) NSMutableDictionary<NSString*, NSMutableArray<SatelliteNode*>*>* trails;

@property (assign, atomic) long int time;

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    self.backgroundColor = [UIColor whiteColor];
    
    SKCameraNode* cameraNode = [SKCameraNode new];
    cameraNode.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    [self addChild:cameraNode];
    self.camera = cameraNode;
    
    self.scale = 1.0f;
    self.zoom = 0.5f;
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Ariel"];
    
    myLabel.text = @"Hello, World!";
    myLabel.fontSize = 25;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame)/2);
    self.label = myLabel;
    
    [self addChild:myLabel];

    self.satellites = [NSMutableArray new];
    self.vectors = [NSMutableDictionary new];
    self.trails = [NSMutableDictionary new];
    
    SatelliteNode *mercury = [SatelliteNode new];
    mercury.name = @"Mercury";
    mercury.text = @"☿";
    mercury.position = CGPointMake(CGRectGetMidX(self.frame)-39,
                                 CGRectGetMidY(self.frame));
    mercury.initialPosition = mercury.position;
    mercury.mass = 0.055f;
    mercury.orbitLength = 88;
    mercury.colour = [UIColor colorWithRed:0.77 green:0.66 blue:0.56 alpha:1.0];
    [self addChild:mercury];
    [self.satellites addObject:mercury];
    mercury.initialVector = CGVectorMake(0, -2.73f); //2.74
    self.vectors[mercury.name] = [NSValue valueWithCGVector:mercury.initialVector];
    self.mercury = mercury;
    self.trails[mercury.name] = [NSMutableArray new];
    
    SatelliteNode *venus = [SatelliteNode new];
    venus.text = @"♀";
    venus.name = @"Venus";
    venus.position = CGPointMake(CGRectGetMidX(self.frame)-72.3,
                                 CGRectGetMidY(self.frame));
    venus.initialPosition = venus.position;
    venus.mass = 0.815f;
    venus.orbitLength = 225;
    venus.colour = [UIColor colorWithRed:0.96 green:0.95 blue:0.57 alpha:1.0];
    [self addChild:venus];
    [self.satellites addObject:venus];
    venus.initialVector = CGVectorMake(0, -2.02f);
    self.vectors[venus.name] = [NSValue valueWithCGVector:venus.initialVector]; //2.02
    self.venus = venus;
    self.trails[venus.name] = [NSMutableArray new];
    
    SatelliteNode *earth = [SatelliteNode new];
    CGFloat earthD = 101.67;
    earth.text = @"♁";
    earth.name = @"Earth";
    earth.orbitLength = 365;
    earth.position = CGPointMake(CGRectGetMidX(self.frame)-earthD,
                                   CGRectGetMidY(self.frame));
    earth.initialPosition = earth.position;
    earth.mass = 1.0f;
    earth.colour = [UIColor colorWithRed:0.03 green:0.84 blue:1.00 alpha:1.0];
    [self addChild:earth];
    self.earth = earth;
    earth.initialVector = CGVectorMake(0, -1.692);
    self.vectors[earth.name] = [NSValue valueWithCGVector:earth.initialVector];//sqrt(kSquared/earthD))]; //1.721
    [self.satellites addObject:self.earth];
    self.trails[earth.name] = [NSMutableArray new];
    
    
    SatelliteNode *mars = [SatelliteNode new];
    mars.text = @"♂";
    mars.name = @"Mars";
    mars.orbitLength = 687;
    mars.position = CGPointMake(CGRectGetMidX(self.frame)-152.4,
                                 CGRectGetMidY(self.frame));
    mars.initialPosition = mars.position;
    mars.mass = 0.107f;
    mars.colour = [UIColor colorWithRed:0.83 green:0.34 blue:0.30 alpha:1.0];
    [self addChild:mars];
    self.mars = mars;
    mars.initialVector = CGVectorMake(0, -1.390);
    self.vectors[mars.name] = [NSValue valueWithCGVector:mars.initialVector];//sqrt(kSquared/earthD))]; //1.721
    [self.satellites addObject:self.mars];
    self.trails[mars.name] = [NSMutableArray new];
    
    
    SatelliteNode *sun = [SatelliteNode new];
    sun.text = @"☉";
    sun.position = CGPointMake(CGRectGetMidX(self.frame),
                                 CGRectGetMidY(self.frame));
    sun.mass = 333000.0f;
    sun.colour = [UIColor colorWithRed:0.97 green:1.00 blue:0.16 alpha:1.0];
    [self addChild:sun];
    self.sun = sun;
    self.sun.zPosition = -1;
    
    self.time = 1;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        
//        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
//        
//        sprite.xScale = 0.5;
//        sprite.yScale = 0.5;
//        sprite.position = location;
//        
//        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
//        
//        [sprite runAction:[SKAction repeatActionForever:action]];
//        
//        [self addChild:sprite];
//    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (currentTime > self.nextUpdateTime) {
        self.nextUpdateTime = currentTime + 0.05f;
        for (SatelliteNode* satellite in self.satellites) {
            [self update:currentTime forBody:self.sun andSatellite:satellite];
        }
        self.time++;
    }
}

- (void)update:(NSTimeInterval)currentTime forBody:(SatelliteNode*)body andSatellite:(SatelliteNode*)satellite {
    
    CGFloat d = [self distanceBetween:body and:satellite];
    
    if (d < 0.01 || d > 1000) {
        return;
    }
    if (self.time+1 % satellite.orbitLength == 0  ) {
        satellite.position = CGPointMake(0.5*(satellite.initialPosition.x+satellite.position.x),0.5*(satellite.initialPosition.y+satellite.position.y));
        self.vectors[satellite.name] = [NSValue valueWithCGVector:satellite.initialVector];
    }
    
    CGVector dv = [self.vectors[satellite.name] CGVectorValue];
    CGFloat g = kSquared/pow(d/100,3); //gaussian gravitational constant squared times 1 solar mass

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
    
    SatelliteNode* previousTrail = [self.trails[satellite.name] firstObject];
    if (!previousTrail || (sqrt(pow(previousTrail.position.x-newex,2)+pow(previousTrail.position.y-newey,2))>15 && self.time < satellite.orbitLength)) {
        SatelliteNode* trail = [satellite copy];
        trail.alpha = 0.15f;
        [self addChild:trail];
        trail.isShowingSymbol = NO;
        [self.trails[satellite.name] insertObject:trail atIndex:0];
        if (self.trails[satellite.name].count > 80) {
            [[self.trails[satellite.name] lastObject] removeFromParent];
            [self.trails[satellite.name] removeLastObject];
        }
    }
    
    satellite.position = CGPointMake(newex, newey);
    self.vectors[satellite.name] = [NSValue valueWithCGVector:CGVectorMake(dx, dy)];
    
    
//    self.label.text = [NSString stringWithFormat:@"d %.6f g %.6f g(%.6f, %.6f), e'(%.6f, %.6f), v'(%.6f, %.6f)",d, g, gx, gy, newex, newey, dx, dy];
    if (satellite == self.earth) {
//        NSLog([NSString stringWithFormat:@"d %.6f g %.6f g(%.6f, %.6f), e'(%.6f, %.6f), v'(%.6f, %.6f)",d, g, gx, gy, newex, newey, dx, dy]);
    }
 
    
}

-(CGFloat)distanceBetween:(SKNode*)objectA and:(SKNode*)objectB {
    return sqrt(pow(objectA.position.x-objectB.position.x, 2) + pow(objectA.position.y-objectB.position.y, 2));
}

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

- (CGFloat)zoom {
    return self.scale;
}

- (void)setZoom:(CGFloat)zoom {
    CGFloat oldScale = self.scale;
    self.scale = zoom;
    SKAction* zoomInAction =  [SKAction scaleTo:zoom duration:fabs(oldScale - zoom)];
    [self.camera runAction:zoomInAction];
}

- (void)setShowSymbols:(BOOL)showSymbols {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.sun.isShowingSymbol = showSymbols;
        for (SatelliteNode* satellite in self.satellites) {
            satellite.isShowingSymbol = showSymbols;
        }
    });
}
@end
