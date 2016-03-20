//
//  GameScene.m
//  ExodusDemo
//
//  Created by Milos Jovanovic on 2016-03-03.
//  Copyright (c) 2016 abvgd. All rights reserved.
//

#import "GameScene.h"
#import "SatelliteNode.h"



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
    self.zoom = 5.5f;
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Ariel"];
    
    myLabel.text = @"Hello, World!";
    myLabel.fontSize = 25;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame)/2);
    self.label = myLabel;
    
    [self addChild:myLabel];

    self.satellites = [NSMutableArray new];
    self.trails = [NSMutableDictionary new];
    
    SatelliteNode *mercury = [SatelliteNode new];
    mercury.name = @"Mercury";
    mercury.text = @"☿";
    mercury.position = CGPointMake(CGRectGetMidX(self.frame)-390,
                                 CGRectGetMidY(self.frame));
    mercury.initialPosition = mercury.position;
    mercury.mass = 0.055f;
    mercury.orbitLength = 88;
    mercury.colour = [UIColor colorWithRed:0.77 green:0.66 blue:0.56 alpha:1.0];
    [self addChild:mercury];
    [self.satellites addObject:mercury];
    mercury.initialVector = CGVectorMake(0, -27.3f); //2.74
    mercury.inertialVector = mercury.initialVector;
    self.mercury = mercury;
    self.trails[mercury.name] = [NSMutableArray new];
    
    SatelliteNode *venus = [SatelliteNode new];
    venus.text = @"♀";
    venus.name = @"Venus";
    venus.position = CGPointMake(CGRectGetMidX(self.frame)-723,
                                 CGRectGetMidY(self.frame));
    venus.initialPosition = venus.position;
    venus.mass = 0.815f;
    venus.orbitLength = 225;
    venus.colour = [UIColor colorWithRed:0.96 green:0.95 blue:0.57 alpha:1.0];
    [self addChild:venus];
    [self.satellites addObject:venus];
    venus.initialVector = CGVectorMake(0, -20.2f);
    venus.inertialVector = venus.initialVector;
    self.venus = venus;
    self.trails[venus.name] = [NSMutableArray new];
    
    SatelliteNode* earth = [SatelliteNode new];
    CGFloat earthD = 1016.7;
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
    earth.initialVector = CGVectorMake(0, -16.92);
    earth.inertialVector = earth.initialVector;
    [self.satellites addObject:self.earth];
    self.trails[earth.name] = [NSMutableArray new];
    
    SatelliteNode* luna = [SatelliteNode new];
    luna.text = @"☽";
    luna.name = @"Luna";
    luna.orbitLength = 20;
    luna.position = CGPointMake(-2.654, 0);
    luna.initialPosition = luna.position;
    luna.mass = 0.0123;
    luna.colour = [UIColor colorWithRed:0.80 green:0.85 blue:0.89 alpha:1.0];
    [earth addChild:luna];
    [earth.satellites addObject:luna];
    luna.initialVector = CGVectorMake(0, -1000*5.88e-4);
    luna.inertialVector = luna.initialVector;

    
    SatelliteNode* mars = [SatelliteNode new];
    mars.text = @"♂";
    mars.name = @"Mars";
    mars.orbitLength = 687;
    mars.position = CGPointMake(CGRectGetMidX(self.frame)-1524,
                                 CGRectGetMidY(self.frame));
    mars.initialPosition = mars.position;
    mars.mass = 0.107f;
    mars.colour = [UIColor colorWithRed:0.83 green:0.34 blue:0.30 alpha:1.0];
    [self addChild:mars];
    self.mars = mars;
    mars.initialVector = CGVectorMake(0, -13.90);
    mars.inertialVector = mars.initialVector;
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
    self.sun.satellites = self.satellites;
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
            SatelliteNode* previousTrail = [self.trails[satellite.name] firstObject];
            //            if (!previousTrail || (sqrt(pow(previousTrail.position.x-satellite.position.x,2)+pow(previousTrail.position.y-satellite.position.y,2))>10 + satellite.mass*15 && self.time < satellite.orbitLength)) {

            if (!previousTrail || ( self.time < satellite.orbitLength && sqrt(pow(previousTrail.position.x-satellite.position.x,2)+pow(previousTrail.position.y-satellite.position.y,2))>2*satellite.spriteRadius)) {
                SatelliteNode* trail = [satellite copy];
                trail.alpha = 0.15f;
                [self addChild:trail];
                trail.isShowingSymbol = NO;
                [self.trails[satellite.name] insertObject:trail atIndex:0];
                if (self.trails[satellite.name].count > satellite.orbitLength) {
                    [[self.trails[satellite.name] lastObject] removeFromParent];
                    [self.trails[satellite.name] removeLastObject];
                }
            }
        }
        [self.sun update:self.time];
        self.time++;
    }
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
