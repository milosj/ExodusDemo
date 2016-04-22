//
//  TimeControlViewController.h
//  ExodusDemo
//
//  Created by Milos Jovanovic on 2016-04-14.
//  Copyright © 2016 abvgd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeSliderDelegate <NSObject>

- (void)timeSliderValueDidChange:(CGFloat)timeSliderValue;

@end

@interface TimeControlViewController : UIViewController<UIGestureRecognizerDelegate>
- (void)addDelegate:(NSObject<TimeSliderDelegate>*)delegate;

@end
