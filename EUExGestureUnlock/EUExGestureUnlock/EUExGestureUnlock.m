/**
 *
 *	@file   	: EUExGestureUnlock.m  in EUExGestureUnlock Project
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 15/11/19
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

#import "EUExGestureUnlock.h"
#import "uexGestureUnlockViewController.h"
#import <AppCanKit/AppCanKit.h>

@interface EUExGestureUnlock()
@property (nonatomic,strong)uexGestureUnlockConfiguration *config;
@property (nonatomic,strong)uexGestureUnlockViewController *controller;
@end


@implementation EUExGestureUnlock

#pragma mark - Life Cycle

- (instancetype)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine
{
    self = [super initWithWebViewEngine:engine];
    if (self) {
        _config = [uexGestureUnlockConfiguration defaultConfiguration];
    }
    return self;
}


- (void)clean{
    [self dismissController];
}
- (void)dealloc{
    [self clean];
}

#pragma mark - uex API
- (UEX_BOOL)isGestureCodeSet:(NSMutableArray *)inArguments{
    BOOL isGestureCodeSet=[uexGestureUnlockViewController isGestureCodeSet];
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexGestureUnlock.cbIsGestureCodeSet"
                                          arguments:ACArgsPack(@{@"result":@(isGestureCodeSet)}.ac_JSONFragment)];
    
    return isGestureCodeSet ? UEX_TRUE : UEX_FALSE;
}

- (void)config:(NSMutableArray *)inArguments{
    self.config = [uexGestureUnlockConfiguration defaultConfiguration];
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSArray<NSString *> *stringKeys = @[
                                        @"creationBeginPrompt",
                                        @"codeLengthErrorPrompt",
                                        @"codeCheckPrompt",
                                        @"checkErrorPrompt",
                                        @"creationSucceedPrompt",
                                        @"verificationBeginPrompt",
                                        @"verificationErrorPrompt",
                                        @"verificationSucceedPrompt",
                                        @"cancelVerificationButtonTitle",
                                        @"cancelCreationButtonTitle",
                                        @"restartCreationButtonTitle"
                                        ];
    for (NSString *aKey in stringKeys) {
        NSString *value = stringArg(info[aKey]);
        if (value) {
            [self.config setValue:value forKeyPath:aKey];
        }
    }
    NSArray<NSString *> *intervalKeys = @[
                                          @"errorRemainInterval",
                                          @"successRemainInterval",
                                      ];
    for (NSString *aKey in intervalKeys) {
        if(![info objectForKey:aKey]){
            continue;
        }
        [self.config setValue:@([info[aKey] doubleValue]/1000) forKeyPath:aKey];
    }
    NSArray<NSString *> *integerKeys = @[
                                         @"minimumCodeLength",
                                         @"maximumAllowTrialTimes",
                                         @"isShowTrack"
                                         ];
    for (NSString *aKey in integerKeys) {
        if(![info objectForKey:aKey]){
            continue;
        }
        [self.config setValue:@([info[aKey] integerValue]) forKeyPath:aKey];
    }
    NSArray<NSString *> *imageKeys = @[
                                       @"backgroundImage",
                                       @"iconImage",
                                       ];
    for (NSString *aKey in imageKeys) {
        if(![info objectForKey:aKey]){
            continue;
        }
        UIImage *image = [UIImage imageWithContentsOfFile:[self absPath:info[aKey]]];
        if(!image){
            continue;
        }
        [self.config setValue:image forKeyPath:aKey];
    }
    NSArray<NSString *> *colorKeys = @[@"backgroundColor",
                                     @"normalThemeColor",
                                     @"selectedThemeColor",
                                     @"errorThemeColor",
                                     ];
    for (NSString *aKey in colorKeys) {
        if(![info objectForKey:aKey]){
            continue;
        }
        UIColor *color = [UIColor ac_ColorWithHTMLColorString:info[aKey]];
        if(!color){
            continue;
        }
        [self.config setValue:color forKeyPath:aKey];
    }
}

- (void)verify:(NSMutableArray *)inArguments{
    
    if (self.controller) {
        return;
    }
    ACJSFunctionRef *cb = JSFunctionArg(inArguments.lastObject);
    ACArgsUnpack(NSDictionary *info) = inArguments;
    
    @weakify(self);
    self.controller = [[uexGestureUnlockViewController alloc]
                     initWithConfiguration:self.config
                     mode:uexGestureUnlockModeVerifyCode
                     progress:^(uexGestureUnlockEvent event) {
                         @strongify(self);
                         [self.webViewEngine callbackWithFunctionKeyPath:@"uexGestureUnlock.onEventOccur"
                                                               arguments:ACArgsPack(@{@"eventCode":@(event)}.ac_JSONFragment)];
                     }
                     completion:^(BOOL isFinished, NSError *error) {
                         @strongify(self);
                         UEX_ERROR err = kUexNoError;
                         NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                         [dict setValue:@(isFinished) forKey:@"isFinished"];
                         if(error){
                             err = uexErrorMake(error.code,error.localizedDescription);
                             [dict setValue:@(error.code) forKey:@"errorCode"];
                             [dict setValue:error.localizedDescription forKey:@"errorString"];
                         }
                         
                         [self.webViewEngine callbackWithFunctionKeyPath:@"uexGestureUnlock.cbVerify"
                                                               arguments:ACArgsPack(dict.ac_JSONFragment)];
                         [cb executeWithArguments:ACArgsPack(err,dict)];
                         [self dismissController];
                     }];
    self.controller.promptStr = [info objectForKey:@"promptStr"];
    [[self.webViewEngine viewController]presentViewController:self.controller animated:YES completion:nil];
}

- (void)create:(NSMutableArray *)inArguments{
    if (self.controller) {
        return;
    }
    
    uexGestureUnlockMode mode = uexGestureUnlockModeVerifyThenCreateCode;
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    ACJSFunctionRef *cb =  JSFunctionArg(inArguments.lastObject);
    
    if (info && info[@"isNeedVerifyBeforeCreate"]) {
        BOOL isNeedVerifyBeforeCreate =[[info objectForKey:@"isNeedVerifyBeforeCreate"] boolValue];
        if(!isNeedVerifyBeforeCreate){
            mode = uexGestureUnlockModeCreateCode;
            
        }
    }

    if(![uexGestureUnlockViewController isGestureCodeSet]){
        mode = uexGestureUnlockModeCreateCode;
    }
    @weakify(self);
    self.controller = [[uexGestureUnlockViewController alloc]
                     initWithConfiguration:self.config
                     mode:mode
                     progress:^(uexGestureUnlockEvent event) {
                         @strongify(self);
                         [self.webViewEngine callbackWithFunctionKeyPath:@"uexGestureUnlock.onEventOccur"
                                                               arguments:ACArgsPack(@{@"eventCode":@(event)}.ac_JSONFragment)];
                         
                     }
                     completion:^(BOOL isFinished, NSError *error) {
                         @strongify(self);
                         UEX_ERROR err = kUexNoError;
                         NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                         [dict setValue:@(isFinished) forKey:@"isFinished"];
                         if(error || !isFinished){
                             err = uexErrorMake(error.code,error.localizedDescription);
                             [dict setValue:@(error.code) forKey:@"errorCode"];
                             [dict setValue:error.localizedDescription forKey:@"errorString"];
                         }
                         
                         [self.webViewEngine callbackWithFunctionKeyPath:@"uexGestureUnlock.cbCreate"
                                                               arguments:ACArgsPack(dict.ac_JSONFragment)];
                         [cb executeWithArguments:ACArgsPack(err,dict)];
                         [self dismissController];
                         
                     }];
    self.controller.promptStr = [info objectForKey:@"promptStr"];
    [[self.webViewEngine viewController]presentViewController:self.controller animated:YES completion:nil];
}

- (void)cancel:(NSMutableArray *)inArguments{
    if(self.controller){
        [self.controller cancel];
    }
}
- (void)resetGestureCode:(NSMutableArray *)inArguments{
    [uexGestureUnlockViewController removeGestureCode];
}

#pragma mark - Private Methods
- (void)dismissController{
    if(self.controller){
        [self.controller dismissViewControllerAnimated:YES completion:^{
            self.controller = nil;
        }];
    }
}

@end
