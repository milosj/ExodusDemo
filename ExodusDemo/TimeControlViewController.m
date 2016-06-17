//
//  TimeControlViewController.m
//  ExodusDemo
//
//  Created by Milos Jovanovic on 2016-04-14.
//  Copyright © 2016 abvgd. All rights reserved.
//

#import "TimeControlViewController.h"

@interface TimeControlViewController()

@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (assign, atomic) BOOL slideEnabled;
@property (strong, nonatomic) NSMutableArray<NSObject<TimeSliderDelegate>*>* delegates;

@end

@implementation TimeControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.timeSlider setMaximumValueImage:[UIImage new]];
    [self.timeSlider setMinimumValueImage:[UIImage new]];
    [self.timeSlider setThumbImage:[UIImage imageNamed:@"ic_play_circle"] forState:UIControlStateNormal];
}

- (IBAction)sliderDidChange:(UISlider *)sender {
    [self didSlide];
}

- (IBAction)sliderTouchDown:(UISlider *)sender {
    [self slidingDidStart];
}

- (IBAction)sliderTouchUpInside:(UISlider *)sender {
    [self slidingDidStop];
}

- (IBAction)sliderTouchUpOutside:(UISlider *)sender {
    [self slidingDidStop];
}

- (void)didSlide {
    if (self.slideEnabled) {
        for (NSObject<TimeSliderDelegate>* delegate in self.delegates) {
            [delegate timeSliderValueDidChange:MAX(self.timeSlider.value, 1.0f)];
        }
    }
}

- (void)slidingDidStart {
    self.slideEnabled = YES;
    [self didSlide];
}

- (void)slidingDidStop {
    self.slideEnabled = NO;
    self.timeSlider.value = self.timeSlider.minimumValue;
    for (NSObject<TimeSliderDelegate>* delegate in self.delegates) {
        [delegate timeSliderValueDidChange:0];
    }
}

- (void)addDelegate:(NSObject<TimeSliderDelegate>*)delegate {
    if (!self.delegates) {
        self.delegates = [NSMutableArray new];
    }
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];    
    }
    
}

@end
