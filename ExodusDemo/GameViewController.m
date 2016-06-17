//
//  GameViewController.m
//  ExodusDemo
//
//  Created by Milos Jovanovic on 2016-03-03.
//  Copyright (c) 2016 abvgd. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "TimeControlViewController.h"

@interface GameViewController()

@property (strong, nonatomic) GameScene* scene;
@property (weak, nonatomic) TimeControlViewController* timeControl;

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
    
    if (self.timeControl) {
        [self.timeControl addDelegate:scene];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scene.size = self.view.bounds.size;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.destinationViewController isKindOfClass:[TimeControlViewController class]]) {
        TimeControlViewController* tcvc = (TimeControlViewController*)segue.destinationViewController;
        self.timeControl = tcvc;
        if (self.scene) {
            [tcvc addDelegate:self.scene];
        }
        
    }
}

- (IBAction)sliderDidSlide:(UISlider *)sender {
    self.scene.zoom = sender.value;
    NSLog(@"z %f", sender.value);
}
- (IBAction)didSwitchSymbols:(UISwitch *)sender {
    [self.scene setShowSymbols:sender.isOn];
}
- (IBAction)didSwitchTrails:(UISwitch *)sender {
    self.scene.showTrails = sender.isOn;
}

@end
