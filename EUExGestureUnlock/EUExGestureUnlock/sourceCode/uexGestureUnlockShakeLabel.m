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

@interface uexGestureUnlockShakeLabel()
@property (nonatomic,weak)uexGestureUnlockConfiguration *config;
@property (nonatomic,strong)RACDisposable *shakeAnimationDisposable;
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
    self.backgroundColor=self.config.backgroundColor;
    @weakify(self,controller);
    [controller.verifyResultCommand.executionSignals subscribeNext:^(RACSignal *execution) {
        [execution subscribeNext:^(id x){
            @strongify(self,controller);
             BOOL verifyResult=[x boolValue];
            if(verifyResult){
                [self verifySuccessInMode:controller.mode];
            }else{
                [self verifyFailInMode:controller.mode];
            }
         }];
    }];
    [controller.touchStartStream subscribeNext:^(id x) {
        @strongify(self);
        [self setText:[self getTouchingTextFromUnlockMode:controller.mode] color:self.config.normalThemeColor];
        if(self.shakeAnimationDisposable){
            [self.shakeAnimationDisposable dispose];
            self.shakeAnimationDisposable=nil;
        }
    }];
}





-(void)verifySuccessInMode:(uexGestureUnlockMode)mode{
    switch (mode) {
        case uexGestureUnlockModeSettingInitialInput: {
            [self setText:self.config.checkInputPrompt color:self.config.normalThemeColor];
            break;
        }
        case uexGestureUnlockModeSettingCheckingInput: {
            [self setText:self.config.setSuccessText color:self.config.normalThemeColor];
            break;
        }
        case uexGestureUnlockModeVerifying: {
            [self setText:self.config.verifySuccessText color:self.config.normalThemeColor];
            break;
        }
    }
}

-(void)verifyFailInMode:(uexGestureUnlockMode)mode{
     NSString *errorText=[self getErrorTextFromUnlockMode:mode];
     [self setText:errorText color:self.config.errorThemeColor];
     [self shake];
    @weakify(self);
    RACSignal *errorRemainSignal=[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [[RACScheduler scheduler] afterDelay:self.config.errorRemainInterval schedule:^{
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{
            [self.layer removeAllAnimations];
        }];
    }];
    self.shakeAnimationDisposable=[errorRemainSignal subscribeCompleted:^{
        @strongify(self);
         [self setText:[self getTouchingTextFromUnlockMode:mode] color:self.config.normalThemeColor];
    }];
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

-(void)setText:(NSString *)text color:(UIColor *)color{
    self.text=text;
    self.textColor=color;
}
-(NSString *)getErrorTextFromUnlockMode:(uexGestureUnlockMode)mode{
    switch (mode) {
        case uexGestureUnlockModeSettingInitialInput: {
            return self.config.codeLengthErrorPrompt;
            break;
        }
        case uexGestureUnlockModeSettingCheckingInput: {
            return self.config.checkErrorPrompt;
            break;
        }
        case uexGestureUnlockModeVerifying: {
            return self.config.verifyErrorPrompt;
            break;
        }

    }
}
-(NSString *)getTouchingTextFromUnlockMode:(uexGestureUnlockMode)mode{
    switch (mode) {
        case uexGestureUnlockModeSettingInitialInput: {
            return self.config.initialInputPrompt;
            break;
        }
        case uexGestureUnlockModeSettingCheckingInput: {
            return self.config.checkInputPrompt;
            break;
        }
        case uexGestureUnlockModeVerifying: {
            return self.config.verifyPrompt;
            break;
        }
    }
}
@end
