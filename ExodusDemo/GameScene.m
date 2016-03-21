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
@property (strong, nonatomic) NSMutableDictionary<NSString*, NSMutableArray<SKNode*>*>* trails;

@property (assign, atomic) long int time;

@property (assign, atomic) BOOL privateShowTrails;
@property (assign, nonatomic) long int trailTime;

@property (strong, nonatomic) NSMutableArray<SKAction*>* zoomQueue;

@property (weak, nonatomic) SatelliteNode* selectedNode;


@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    self.backgroundColor = [UIColor whiteColor];
    self.showTrails = YES;
    self.zoomQueue = [NSMutableArray new];
    
    SKCameraNode* cameraNode = [SKCameraNode new];
    [self addChild:cameraNode];
    self.camera = cameraNode;
    cameraNode.position = CGPointZero;//CGPointMake(self.size.width / 2, self.size.height / 2);

    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Ariel"];
    
    myLabel.text = @"";
    myLabel.fontSize = 25;
    myLabel.position = CGPointZero;
    self.label = myLabel;
    
//    [self addChild:myLabel];

    self.satellites = [NSMutableArray new];
    self.trails = [NSMutableDictionary new];
    
    
    SatelliteNode *sun = [SatelliteNode new];
    sun.isCastingShadow = NO;
    sun.text = @"☉";
    sun.position = CGPointZero;//CGPointMake(CGRectGetMidX(self.view.frame),
                               //CGRectGetMidY(self.view.frame));
    sun.mass = 333000.0f;
    sun.colour = [UIColor colorWithRed:0.97 green:1.00 blue:0.16 alpha:1.0];
    [self addChild:sun];
    self.sun = sun;
    self.sun.zPosition = -1;
    self.sun.satellites = self.satellites;
    self.time = 1;
    
    
    
    SatelliteNode *mercury = [SatelliteNode new];
    mercury.name = @"Mercury";
    mercury.text = @"☿";
    mercury.mass = 0.055f;
    mercury.orbitLength = 88;
    mercury.orbitRadius = 390;
    mercury.position = CGPointMake(self.sun.position.x-mercury.orbitRadius,
                                 self.sun.position.y);
    mercury.initialPosition = mercury.position;
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
    venus.mass = 0.815f;
    venus.orbitLength = 225;
    venus.orbitRadius = 723;
    venus.position = CGPointMake(self.sun.position.x-venus.orbitRadius,
                                 self.sun.position.y);
    venus.initialPosition = venus.position;
    venus.colour = [UIColor colorWithRed:0.96 green:0.95 blue:0.57 alpha:1.0];
    [self addChild:venus];
    [self.satellites addObject:venus];
    venus.initialVector = CGVectorMake(0, -20.2f);
    venus.inertialVector = venus.initialVector;
    self.venus = venus;
    self.trails[venus.name] = [NSMutableArray new];
    
    SatelliteNode* earth = [SatelliteNode new];
    earth.orbitRadius = 1016.7;
    earth.text = @"♁";
    earth.name = @"Earth";
    earth.orbitLength = 365;
    earth.position = CGPointMake(self.sun.position.x-earth.orbitRadius,
                                   self.sun.position.y);
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
    luna.orbitRadius = 2.654;
    luna.position = CGPointMake(earth.position.x-luna.orbitRadius, earth.position.y);
    luna.initialPosition = luna.position;
    luna.mass = 0.0123;
    luna.colour = [UIColor colorWithRed:0.80 green:0.85 blue:0.89 alpha:1.0];
//    [self addChild:luna];
//    [earth.satellites addObject:luna];
    luna.initialVector = CGVectorMake(0, -1000*5.88e-4);
    luna.inertialVector = luna.initialVector;

    
    SatelliteNode* mars = [SatelliteNode new];
    mars.text = @"♂";
    mars.name = @"Mars";
    mars.orbitLength = 687;
    mars.orbitRadius = 1524;
    mars.position = CGPointMake(self.sun.position.x-mars.orbitRadius,
                                 self.sun.position.y);
    mars.initialPosition = mars.position;
    mars.mass = 0.107f;
    mars.colour = [UIColor colorWithRed:0.83 green:0.34 blue:0.30 alpha:1.0];
    [self addChild:mars];
    self.mars = mars;
    mars.initialVector = CGVectorMake(0, -13.90);
    mars.inertialVector = mars.initialVector;
    [self.satellites addObject:self.mars];
    self.trails[mars.name] = [NSMutableArray new];
    
    
    SatelliteNode* jupiter = [SatelliteNode new];
    jupiter.text = @"♃";
    jupiter.name = @"Jupiter";
    jupiter.orbitLength = 4333;
    jupiter.orbitRadius = 5430;
    jupiter.position = CGPointMake(self.sun.position.x-jupiter.orbitRadius, self.sun.position.y);
    jupiter.initialPosition = jupiter.position;
    jupiter.mass = 317.828;
    jupiter.colour = [UIColor colorWithRed:0.87 green:0.46 blue:0.00 alpha:1.0];
    [self addChild:jupiter];
    jupiter.initialVector = CGVectorMake(0, -7.54);
    jupiter.inertialVector = jupiter.initialVector;
    [self.satellites addObject:jupiter];
    self.trails[jupiter.name] = [NSMutableArray new];
    
    SatelliteNode* saturn = [SatelliteNode new];
    saturn.text = @"♄";
    saturn.name = @"Saturn";
    saturn.orbitLength = 107556;
    saturn.orbitRadius = 10020;
    saturn.position = CGPointMake(self.sun.position.x-saturn.orbitRadius, self.sun.position.y);
    saturn.initialPosition = saturn.position;
    saturn.mass = 95.16;
    saturn.colour = [UIColor colorWithRed:0.84 green:0.78 blue:0.50 alpha:1.0];
    saturn.initialVector = CGVectorMake(0, -5.57);
    saturn.inertialVector = saturn.initialVector;
    [self addChild:saturn];
    [self.satellites addObject:saturn];
    self.trails[saturn.name] = [NSMutableArray new];
    
    SatelliteNode* uranus = [SatelliteNode new];
    uranus.text = @"♅";
    uranus.name = @"Uranus";
    uranus.orbitLength = 30687;
    uranus.orbitRadius = 19970;
    uranus.position = CGPointMake(self.sun.position.x-uranus.orbitRadius, self.sun.position.y);
    uranus.initialPosition = uranus.position;
    uranus.mass = 14.535;
    uranus.colour = [UIColor colorWithRed:0.36 green:0.78 blue:0.92 alpha:1.0];
    uranus.initialVector = CGVectorMake(0, -3.92);
    uranus.inertialVector = uranus.initialVector;
    [self addChild:uranus];
    [self.satellites addObject:uranus];
    self.trails[uranus.name] = [NSMutableArray new];
    
    SatelliteNode* neptune = [SatelliteNode new];
    neptune.text = @"♆";
    neptune.name = @"Neptune";
    neptune.orbitLength = 60190;
    neptune.orbitRadius = 29960;
    neptune.position = CGPointMake(self.sun.position.x-neptune.orbitRadius, self.sun.position.y);
    neptune.initialPosition = neptune.position;
    neptune.mass = 17.14878;
    neptune.colour = [UIColor colorWithRed:0.23 green:0.22 blue:1.00 alpha:1.0];
    neptune.initialVector = CGVectorMake(0, -3.14);
    neptune.inertialVector = neptune.initialVector;
    [self addChild:neptune];
    [self.satellites addObject:neptune];
    self.trails[neptune.name] = [NSMutableArray new];
    
    self.scale = 0.128;
    self.zoom = 5;

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    if (event.type == UIEventTypeTouches && touches.count == 1) {
        UITouch* touch = touches.anyObject;
        CGPoint point = [touch locationInNode:self];
        NSArray<SKNode*>* touchedNodes = [self nodesAtPoint:point];
        BOOL found = NO;
        for (SKNode* node in touchedNodes) {
            if (!found && [node isKindOfClass:[SatelliteNode class]]) {
                self.camera.position = node.position;
                self.selectedNode = (SatelliteNode*)node;
                found = YES;
                
                if ([self.satellites containsObject:(SatelliteNode*)node]) {
                    int i = (int)[self.satellites indexOfObject:(SatelliteNode*)node];
                    self.zoom = i+1;
                }
            }
        }
        if (!found) {
            self.selectedNode = nil;
            self.camera.position = self.sun.position;
            self.zoom = self.satellites.count;
        }
    }
    
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
            SKNode* previousTrail = [self.trails[satellite.name] firstObject];

            if (self.showTrails && (!previousTrail || ( self.trailTime < satellite.orbitLength && sqrt(pow(previousTrail.position.x-satellite.position.x,2)+pow(previousTrail.position.y-satellite.position.y,2))>2*satellite.spriteRadius))) {
                SKNode* trail = satellite.trailNode;
                [self addChild:trail];
                [self.trails[satellite.name] insertObject:trail atIndex:0];
//                if (self.trails[satellite.name].count > satellite.orbitLength) {
//                    [[self.trails[satellite.name] lastObject] removeFromParent];
//                    [self.trails[satellite.name] removeLastObject];
//                }
            }
        }
        [self.sun update:self.time];
        
        if (self.selectedNode) {
            self.camera.position = self.selectedNode.position;
        }
        
        self.time++;
        if (self.showTrails) {
            self.trailTime++;
        }
    }
}



- (CGFloat)zoom {
    return self.scale;
}

- (void)setZoom:(CGFloat)zoom {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        int i = (int)zoom;
        SatelliteNode* satellite = self.satellites[i-1];
        CGFloat lesserDimension = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
        CGFloat zoomRatio = 2*satellite.orbitRadius/lesserDimension+1;
        if (self.scale != zoomRatio) {
            CGFloat oldScale = self.scale;
            self.scale = zoomRatio;
            SKAction* zoomInAction =  [SKAction scaleTo:zoomRatio duration:MIN(0.5f,fabs(oldScale - zoomRatio)/10)];
//            NSLog(@"z %f-%f %f in %@", oldScale, zoomRatio, fabs(oldScale - zoomRatio)/10, zoomInAction);
            if (self.zoomQueue.count == 0) {
                [self.zoomQueue addObject:zoomInAction];
                [self performNextActionInQueue:self.zoomQueue withCamera:self.camera];
//                NSLog(@"p-- %@", zoomInAction);
            } else {
                [self.zoomQueue addObject:zoomInAction];
            }
        }
    });
}

- (void)performNextActionInQueue:(NSMutableArray<SKAction*>*)queue withCamera:(SKCameraNode*)zoomCamera {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (queue.count) {
            SKAction* lastAction = queue.lastObject;
            [queue removeAllObjects];
            [queue addObject:lastAction];
            [zoomCamera runAction:lastAction completion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [queue removeObject:lastAction];
//                    NSLog(@"p- %@", lastAction);
                    [self performNextActionInQueue:queue withCamera:zoomCamera];
                });
            }];
        }
    });
};

- (void)setShowSymbols:(BOOL)showSymbols {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.sun.isShowingSymbol = showSymbols;
        for (SatelliteNode* satellite in self.satellites) {
            satellite.isShowingSymbol = showSymbols;
            satellite.isCastingShadow = !showSymbols;
        }
    });
}

- (BOOL)showTrails {
    return self.privateShowTrails;
}

- (void)setShowTrails:(BOOL)showTrails {
    self.privateShowTrails = showTrails;
    self.trailTime = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!showTrails) {
            for (NSArray* satelliteTrails in self.trails.allValues) {
                for (SKNode* trail in satelliteTrails) {
                    [trail removeFromParent];
                }
            }
            NSMutableDictionary* newTrails = [NSMutableDictionary new];
            for (NSString* key in self.trails.allKeys) {
                newTrails[key] = [NSMutableArray new];
            }
            self.trails = newTrails;
        }
    });
}
@end
