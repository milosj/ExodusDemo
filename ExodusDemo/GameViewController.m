//
//  GameViewController.m
//  ExodusDemo
//
//  Created by Milos Jovanovic on 2016-03-03.
//  Copyright (c) 2016 abvgd. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@interface GameViewController()

@property (strong, nonatomic) GameScene* scene;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    GameScene *scene = [GameScene nodeWithFileNamed:@"GameScene"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    self.scene = scene;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (IBAction)sliderDidSlide:(UISlider *)sender {
    self.scene.zoom = sender.maximumValue - sender.value;
}
- (IBAction)switchDidSwitch:(UISwitch *)sender {
    [self.scene setShowSymbols:sender.isOn];
}

@end
