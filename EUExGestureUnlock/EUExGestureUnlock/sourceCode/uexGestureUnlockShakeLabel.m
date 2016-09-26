/**
 *
 *	@file   	: uexGestureUnlockShakeLabel.m  in EUExGestureUnlock Project
 *
 *	@author 	: CeriNo
 *
 *	@date   	: Created on 15/11/21
 *
 *	@copyright 	: 2015 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "uexGestureUnlockShakeLabel.h"
#import "uexGestureUnlockViewController.h"

static CGFloat kUexGestureUnlockShakeDuration=0.8;
static NSString *const kUexGestureUnlockShakeAnimationKey=@"kUexGestureUnlockShakeAnimationKey";

@interface uexGestureUnlockShakeLabel()<CAAnimationDelegate>
@property (nonatomic,weak)uexGestureUnlockConfiguration *config;
@end
@implementation uexGestureUnlockShakeLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)combineWithViewController:(uexGestureUnlockViewController *)controller{
    self.config=controller.config;
    self.backgroundColor=[UIColor clearColor];
    @weakify(self);
    [controller.verifyResultCommand.executionSignals subscribeNext:^(RACSignal *execution) {
        [execution subscribeNext:^(id x){
            @strongify(self);
             BOOL verifyResult=[x boolValue];
            if(verifyResult){
                [self setTextColor:self.config.normalThemeColor];
            }else{
                [self setTextColor:self.config.errorThemeColor];
                [self shake];
            }
         }];
    }];
    [controller.touchStartStream subscribeNext:^(id x) {
        @strongify(self);
        [self setTextColor:self.config.normalThemeColor];
        [self.layer removeAllAnimations];

    }];
    [self setTextColor:self.config.normalThemeColor];
    RAC(self,text)=[RACObserve(controller, prompt) distinctUntilChanged];
}



-(void)shake{
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    CGFloat currentTx = self.transform.tx;
    
    animation.delegate = self;
    animation.duration = kUexGestureUnlockShakeDuration;
    animation.values = @[ @(currentTx), @(currentTx + 10), @(currentTx-8), @(currentTx + 8), @(currentTx -5), @(currentTx + 5), @(currentTx) ];
    animation.keyTimes = @[ @(0), @(0.225), @(0.425), @(0.6), @(0.75), @(0.875), @(1) ];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:animation forKey:kUexGestureUnlockShakeAnimationKey];
}


@end
