//
//  GameScene.m
//  ExodusDemo
//
//  Created by Milos Jovanovic on 2016-03-03.
//  Copyright (c) 2016 abvgd. All rights reserved.
//

#import "GameScene.h"

@interface GameScene()

@property (strong, nonatomic) SKNode* earth;
@property (strong, nonatomic) SKNode* sun;
@property (assign, nonatomic) CGVector earthV;
@property (strong, nonatomic) UILabel* label;
@property (assign, atomic) CFTimeInterval nextUpdateTime;
@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Ariel"];
    
    myLabel.text = @"Hello, World!";
    myLabel.fontSize = 25;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame)/2);
    self.label = myLabel;
    
    [self addChild:myLabel];
    
    
    SKLabelNode *earth = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    earth.text = @"♁";
    earth.fontSize = 45;
    earth.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame)-100);
    earth.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:1];
    earth.physicsBody.mass = 1.0f;
    earth.physicsBody.affectedByGravity = NO;
    [self addChild:earth];
    self.earth = earth;
    
    SKLabelNode *sun = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    sun.text = @"☉";
    sun.fontSize = 45;
    sun.position = CGPointMake(CGRectGetMidX(self.frame),
                                 CGRectGetMidY(self.frame));
    sun.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:1];
    sun.physicsBody.mass = 333000.0f;
    sun.physicsBody.affectedByGravity = NO;
    [self addChild:sun];
    self.sun = sun;
    
//    CGMutablePathRef circle = CGPathCreateMutable();
//    CGPathAddArc(circle, NULL, 25, 25, 25, 0, 2*M_PI, true);
//    CGPathCloseSubpath(circle);
//    SKAction *revolve = [SKAction repeatActionForever:[SKAction followPath:circle asOffset:YES orientToPath:NO duration:5.0]];
//    
//    [earth runAction:revolve];

//    self.earthV = CGVectorMake(self.earth.position.x-10, self.earth.position.y);
    self.earthV = CGVectorMake(-5, 0);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        
        sprite.xScale = 0.5;
        sprite.yScale = 0.5;
        sprite.position = location;
        
        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
        
        [sprite runAction:[SKAction repeatActionForever:action]];
        
        [self addChild:sprite];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    static BOOL stop = NO;
    if (!stop) {//(currentTime > self.nextUpdateTime) {
//        self.nextUpdateTime = currentTime + 0.1;
        
        CGFloat d = [self distanceBetween:self.earth and:self.sun];
        
        if (d > 200) {
            stop = YES;
        }
        
        CGFloat g = -0.001;//*self.sun.physicsBody.mass * self.earth.physicsBody.mass/pow(d, 2);
        
        //    CGFloat cotan = self.earth.position.y/self.earth.position.x;
        
        //    CGFloat gx =  g * cotan * pow(1 + pow(cotan, 2), 0.5f);
        //    CGFloat gy = pow(pow(g, 2) - pow(gx, 2), 0.5f);
        
//        CGFloat gx = g * self.earth.position.x/d;
//        CGFloat gy = g * self.earth.position.y/d;
        

        CGFloat gx = g*(self.earth.position.x-self.sun.position.x);
        CGFloat gy = g*(self.earth.position.y-self.sun.position.y);
        
        if (isnan(gy)) {
            gy = 0;
        }
        if (isnan(gx)) {
            gx = 0;
        }
        
        CGFloat ex = self.earth.position.x;
        CGFloat ey = self.earth.position.y;
        
        CGFloat dx = gx + self.earthV.dx;
        CGFloat dy = gy + self.earthV.dy;

        CGFloat newex = ex + dx;
        CGFloat newey = ey + dy;
        

        
        self.earth.position = CGPointMake(newex, newey);
        self.earthV = CGVectorMake(dx, dy);
        
        self.label.text = [NSString stringWithFormat:@"d %.6f g %.6f g(%.6f, %.6f), e'(%.6f, %.6f), v'(%.6f, %.6f)",d, g, gx, gy, newex, newey, dx, dy];
        NSLog(self.label.text);
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

@end
