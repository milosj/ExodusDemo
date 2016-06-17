//
//  GameScene.m
//  ExodusDemo
//
//  Created by Milos Jovanovic on 2016-03-03.
//  Copyright (c) 2016 abvgd. All rights reserved.
//

#import "GameScene.h"
#import "SatelliteNode.h"

#define timeCompressionMinimalChangeFactor 0.1

@interface GameScene()

@property (assign, atomic) BOOL isRunning;

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
@property (assign, atomic) CFTimeInterval startingTime;

@property (assign, atomic) BOOL privateShowTrails;
@property (assign, nonatomic) long int trailTime;

@property (strong, nonatomic) NSMutableArray<SKAction*>* zoomQueue;

@property (weak, nonatomic) SatelliteNode* selectedNode;
@property (assign, atomic) BOOL isPositioningCamera;

@property (strong, nonatomic) SKNode* overlay;
@property (strong, nonatomic) NSMutableArray<SKNode*>* overlaySatellites;

@property (assign, nonatomic) CGFloat actualTimeCompression;
@property (assign, nonatomic) CGFloat targetTimeCompression;


@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    
    self.startingTime = 0;
    
    /* Setup your scene here */
    self.backgroundColor = [UIColor whiteColor];
    self.showTrails = NO;
    self.zoomQueue = [NSMutableArray new];
    
    SKCameraNode* cameraNode = [SKCameraNode new];
    [self addChild:cameraNode];
    self.camera = cameraNode;
    cameraNode.position = CGPointZero;//CGPointMake(self.size.width / 2, self.size.height / 2);

    
    self.overlay = [SKNode new];
    [cameraNode addChild:self.overlay];
    self.overlay.position = CGPointZero;
    self.overlay.zPosition = 1;
    self.overlaySatellites = [NSMutableArray new];
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    self.label = [SKLabelNode labelNodeWithText:@"--"];
    self.label.fontColor = [UIColor blackColor];
    self.label.position = CGPointMake(CGRectGetMidX(self.overlay.frame), CGRectGetMaxY(self.overlay.frame));
    self.label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    [self.overlay addChild:self.label];
    self.label.hidden = YES;

    self.satellites = [NSMutableArray new];
    self.trails = [NSMutableDictionary new];
    
    
    SatelliteNode *sun = [SatelliteNode new];
    sun.isCastingShadow = NO;
    sun.text = @"☉";
    sun.name = @"Sun";
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
    mercury.orbitalPeriod = 88;
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
    venus.orbitalPeriod = 225;
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
    earth.orbitalPeriod = 365;
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
    luna.orbitalPeriod = 20;
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
    mars.orbitalPeriod = 687;
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
    jupiter.orbitalPeriod = 4333;
    jupiter.orbitRadius = 5430;
    jupiter.position = CGPointMake(self.sun.position.x-jupiter.orbitRadius, self.sun.position.y);
    jupiter.initialPosition = jupiter.position;
    jupiter.mass = 317.828;
    jupiter.colour = [UIColor colorWithRed:0.87 green:0.46 blue:0.00 alpha:1.0];
    [self addChild:jupiter];
    jupiter.initialVector = CGVectorMake(0, -7.54);
    jupiter.inertialVector = jupiter.initialVector;
//    [self.satellites addObject:jupiter];
    self.trails[jupiter.name] = [NSMutableArray new];
    
    SatelliteNode* saturn = [SatelliteNode new];
    saturn.text = @"♄";
    saturn.name = @"Saturn";
    saturn.orbitalPeriod = 107556;
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
    uranus.orbitalPeriod = 30687;
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
    neptune.orbitalPeriod = 60190;
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
    
    
//    [self.satellites removeAllObjects];
    SatelliteNode* pluto = [SatelliteNode new];
    pluto.text = @"♇";
    pluto.name = @"Pluto";
    pluto.orbitalPeriod = 90553;
    pluto.orbitRadius = 49305;
    pluto.position = CGPointMake(self.sun.position.x-pluto.orbitRadius, self.sun.position.y);
    pluto.initialPosition = pluto.position;
    pluto.mass = 0.002192;
    pluto.colour = [UIColor colorWithRed:0.80 green:0.85 blue:0.00 alpha:1.0];
    pluto.initialVector = CGVectorMake(0, -2.143);
    pluto.inertialVector = pluto.initialVector;
    [self addChild:pluto];
//    [self.satellites addObject:pluto];
    self.trails[pluto.name] = [NSMutableArray new];
    

    SKShapeNode* (^createOrbitalCircle)(SatelliteNode*) = ^(SatelliteNode* satellite){
        SKShapeNode* orbit = [SKShapeNode shapeNodeWithCircleOfRadius:satellite.orbitRadius];
        orbit.position = sun.position;
        orbit.strokeColor = satellite.colour;
        orbit.alpha = 0.2f;
        orbit.fillColor = [UIColor clearColor];
        orbit.lineWidth = MAX(100,4*satellite.spriteRadius);
        return orbit;
    };
    
    for (SatelliteNode* satellite in self.satellites) {
//        [self addChild:createOrbitalCircle(satellite)];
        [self.overlaySatellites addObject:satellite.overlayShape];
        [self.overlay addChild:satellite.overlayShape];
    }
    [self.overlay addChild:sun.overlayShape];
    
    self.scale = 0.128;
    self.zoom = 5;
    self.actualTimeCompression = 0.0f;
    self.targetTimeCompression = self.actualTimeCompression;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.sun precalculateOrbits];
        self.isRunning = YES;
        [self updateModelForTime:0];
    });
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    if (!self.isPositioningCamera && event.type == UIEventTypeTouches && touches.count == 1) {
        UITouch* touch = touches.anyObject;
        CGPoint point = [touch locationInNode:self];
        NSArray<SKNode*>* touchedNodes = [self nodesAtPoint:point];
        NSLog(@"Touched %f, %f", point.x, point.y);
        NSLog(@"Touched nodes %@", touchedNodes);
        BOOL found = NO;
        SKNode* targetNode = nil;
        int targetZoomLevel = 0;
        for (SKNode* node in touchedNodes) {
            if (!found && [node isKindOfClass:[SatelliteNode class]] && node != self.selectedNode) {
                
                found = YES;
                targetNode = node;
                targetZoomLevel = 4;
                
                if ([self.satellites containsObject:(SatelliteNode*)node]) {
                    self.zoom = (int)[self.satellites indexOfObject:(SatelliteNode*)node]+1;
                }
                NSLog(@"Selected %@", node);
                break;
            }
        }
        if (!found) {
            self.selectedNode = nil;
            targetNode = self.sun;
            targetZoomLevel = self.zoom;
            self.zoom = self.satellites.count;
            NSLog(@"Deselecting");
        }
        self.isPositioningCamera = YES;
        SKAction* positionCamera = [SKAction moveTo:targetNode.position duration:0.6f];
        [self.camera runAction:positionCamera completion:^{
            self.zoom = targetZoomLevel;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.selectedNode = (SatelliteNode*)targetNode;
                self.isPositioningCamera = NO;
            });
        }];
        
    }

}

-(void)update:(CFTimeInterval)currentTime {
    if (self.isRunning) {
        
        if (self.startingTime == 0) {
            self.startingTime = currentTime;
        }
        /* Called before each frame is rendered */
        if (currentTime > self.nextUpdateTime && self.actualTimeCompression > 0) {
            self.nextUpdateTime = currentTime;

            [self updateModelForTime:self.time];
            
            if (fabs(self.targetTimeCompression-self.actualTimeCompression) < 1) {
                self.actualTimeCompression = self.targetTimeCompression;
            } else {
                if (self.actualTimeCompression < self.targetTimeCompression) {
                    self.actualTimeCompression += MAX(timeCompressionMinimalChangeFactor*self.actualTimeCompression, 0.1f);
                } else if (self.actualTimeCompression > self.targetTimeCompression) {
                    self.actualTimeCompression -= MAX(timeCompressionMinimalChangeFactor*self.actualTimeCompression, 0.1f);
                }
            }
            self.label.text = [NSString stringWithFormat:@"%.6f", self.actualTimeCompression];

        }
    }
}

-(void)updateModelForTime:(CFTimeInterval)currentTime {
    //            self.label.text = [NSString stringWithFormat:@"%.2f", currentTime];
    
    //            for (SatelliteNode* satellite in self.satellites) {
    //    //            SKNode* previousTrail = [self.trails[satellite.name] firstObject];
    //    //            if (self.showTrails && (!previousTrail || ( self.trailTime < satellite.orbitLength && sqrt(pow(previousTrail.position.x-satellite.position.x,2)+pow(previousTrail.position.y-satellite.position.y,2))>2*satellite.spriteRadius))) {
    //    //                SKNode* trail = satellite.trailNode;
    //    //                [self addChild:trail];
    //    //                [self.trails[satellite.name] insertObject:trail atIndex:0];
    //    ////                if (self.trails[satellite.name].count > satellite.orbitLength) {
    //    ////                    [[self.trails[satellite.name] lastObject] removeFromParent];
    //    ////                    [self.trails[satellite.name] removeLastObject];
    //    ////                }
    //    //            }
    //            }
    [self.sun updateModelForTime:self.time];
    
    [self updateOverlay];
    
    if (self.selectedNode) {
        self.camera.position = self.selectedNode.position;
    }
    
    self.time += self.actualTimeCompression;
    if (self.showTrails) {
        self.trailTime += self.actualTimeCompression;
    }

}

- (void)updateOverlay {
    for (SatelliteNode* satellite in self.satellites) {
        if (self.scale < 60) {
            satellite.overlayShape.hidden = YES;
        } else {
            satellite.overlayShape.hidden = NO;
            CGPoint convertedPosition = [self convertPoint:satellite.position toNode:self.camera];
            satellite.overlayShape.position = CGPointMake(convertedPosition.x, convertedPosition.y-12.0f);
        }
    }
    if (self.scale < 30) {
        self.sun.overlayShape.hidden = YES;
    } else {
        self.sun.overlayShape.hidden = NO;
        CGPoint convertedPosition = [self convertPoint:self.sun.position toNode:self.camera];
        self.sun.overlayShape.position = CGPointMake(convertedPosition.x, convertedPosition.y-12.0f);
    }
    
}

- (CGFloat)zoom {
    return self.scale;
}

- (void)setZoom:(CGFloat)zoom {
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        int i = (int)zoom;
//        if (i > self.satellites.count) {
//            i = (int)self.satellites.count;
//        }
//        if (i < 1) {
//            i = 1;
//        }
//        SatelliteNode* satellite = self.satellites[i-1];
//        CGFloat lesserDimension = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
//        CGFloat zoomRatio = 2*satellite.orbitRadius/lesserDimension+1;
//        if (self.scale != zoomRatio) {
//            CGFloat oldScale = self.scale;
//            self.scale = zoomRatio;
//            SKAction* zoomInAction =  [SKAction scaleTo:zoomRatio duration:MIN(0.5f,fabs(oldScale - zoomRatio)/10)];
////            NSLog(@"z %f-%f %f in %@", oldScale, zoomRatio, fabs(oldScale - zoomRatio)/10, zoomInAction);
//            if (self.zoomQueue.count == 0) {
//                [self.zoomQueue addObject:zoomInAction];
//                [self performNextActionInQueue:self.zoomQueue withCamera:self.camera];
////                NSLog(@"p-- %@", zoomInAction);
//            } else {
//                [self.zoomQueue addObject:zoomInAction];
//            }
//        }
        SKAction* zoomInAction = [SKAction scaleTo:zoom duration:0.1f];
        [self.zoomQueue addObject:zoomInAction];
        [self performNextActionInQueue:self.zoomQueue withCamera:self.camera];
        [self updateOverlay];
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

#pragma mark TimeSliderDelegate

- (void)timeSliderValueDidChange:(CGFloat)timeSliderValue {
    if (timeSliderValue >= 0.0f) {
        self.targetTimeCompression = timeSliderValue;
    }
}
@end
