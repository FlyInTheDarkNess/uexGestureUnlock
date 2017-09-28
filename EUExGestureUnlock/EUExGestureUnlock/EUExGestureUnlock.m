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
#import "JSON.h"
#import "uexGestureUnlockViewController.h"
#import "UIColor+HtmlColor.h"
#import "EUtility.h"

@interface EUExGestureUnlock()
@property (nonatomic,strong)uexGestureUnlockConfiguration *config;
@property (nonatomic,strong)uexGestureUnlockViewController *controller;
@end


@implementation EUExGestureUnlock

#pragma mark - Life Cycle
-(instancetype)initWithBrwView:(EBrowserView *)eInBrwView{
    self=[super initWithBrwView:eInBrwView];
    if(self) {
        self.config=[uexGestureUnlockConfiguration defaultConfiguration];
    }
    return self;
}

-(void)clean{
    [self dismissController];
}
-(void)dealloc{
    [self clean];
}

#pragma mark - uex API
-(void)isGestureCodeSet:(NSMutableArray *)inArguments{
    BOOL isGestureCodeSet=[uexGestureUnlockViewController isGestureCodeSet];
    [self callbackJSONwithName:@"cbIsGestureCodeSet" object:@{@"result":@(isGestureCodeSet)}];
}

-(void)config:(NSMutableArray *)inArguments{
    self.config=[uexGestureUnlockConfiguration defaultConfiguration];
    if([inArguments count] < 1){
        return;
    }
    id info = [inArguments[0] JSONValue];
    if(!info || ![info isKindOfClass:[NSDictionary class]]){
        return;
    }
    
    NSArray<NSString *> *stringKeys=@[@"creationBeginPrompt",
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
        if(![info objectForKey:aKey]||![info[aKey] isKindOfClass:[NSString class]]){
            continue;
        }
        [self.config setValue:info[aKey] forKeyPath:aKey];
    }
    NSArray<NSString *> *intervalKeys=@[@"errorRemainInterval",
                                      @"successRemainInterval",
                                      ];
    for (NSString *aKey in intervalKeys) {
        if(![info objectForKey:aKey]){
            continue;
        }
        [self.config setValue:@([info[aKey] doubleValue]/1000) forKeyPath:aKey];
    }
    NSArray<NSString *> *integerKeys=@[@"minimumCodeLength",
                                        @"maximumAllowTrialTimes",
                                        ];
    for (NSString *aKey in integerKeys) {
        if(![info objectForKey:aKey]){
            continue;
        }
        [self.config setValue:@([info[aKey] integerValue]) forKeyPath:aKey];
    }
    NSArray<NSString *> *imageKeys=@[@"backgroundImage",
                                       @"iconImage",
                                       ];
    for (NSString *aKey in imageKeys) {
        if(![info objectForKey:aKey]){
            continue;
        }
        UIImage *image=[UIImage imageWithContentsOfFile:[self absPath:info[aKey]]];
        if(!image){
            continue;
        }
        [self.config setValue:image forKeyPath:aKey];
    }
    NSArray<NSString *> *colorKeys=@[@"backgroundColor",
                                     @"normalThemeColor",
                                     @"selectedThemeColor",
                                     @"errorThemeColor",
                                     ];
    for (NSString *aKey in colorKeys) {
        if(![info objectForKey:aKey]){
            continue;
        }
        UIColor *color=[UIColor uexGU_ColorFromHtmlString:info[aKey]];
        if(!color){
            continue;
        }
        [self.config setValue:color forKeyPath:aKey];
    }
}

-(void)verify:(NSMutableArray *)inArguments{
    
    if (self.controller) {
        return;
    }
    
    @weakify(self);
    self.controller=[[uexGestureUnlockViewController alloc]
                     initWithConfiguration:self.config
                     mode:uexGestureUnlockModeVerifyCode
                     progress:^(uexGestureUnlockEvent event) {
                         @strongify(self);
                         [self callbackJSONwithName:@"onEventOccur" object:@{@"eventCode":@(event)}];
                     }
                     completion:^(BOOL isFinished, NSError *error) {
                         @strongify(self);
                         NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                         [dict setValue:@(isFinished) forKey:@"isFinished"];
                         if(error){
                             [dict setValue:@(error.code) forKey:@"errorCode"];
                             [dict setValue:error.domain forKey:@"errorString"];
                         }
                         [self callbackJSONwithName:@"cbVerify" object:dict];
                         [self dismissController];
                     }];
    
    
    [EUtility brwView:self.meBrwView presentModalViewController:self.controller animated:YES];
}

-(void)create:(NSMutableArray *)inArguments{
    uexGestureUnlockMode mode = uexGestureUnlockModeVerifyThenCreateCode;
    if([inArguments count]>0){
        id info = [inArguments[0] JSONValue];
        if(info && [info isKindOfClass:[NSDictionary class]] && [info objectForKey:@"isNeedVerifyBeforeCreate"]){
            BOOL isNeedVerifyBeforeCreate =[[info objectForKey:@"isNeedVerifyBeforeCreate"] boolValue];
            if(!isNeedVerifyBeforeCreate){
                mode = uexGestureUnlockModeCreateCode;
                
            }
        }
    }
    if(![uexGestureUnlockViewController isGestureCodeSet]){
        mode = uexGestureUnlockModeCreateCode;
    }
    if (self.controller) {
        return;
    }
    @weakify(self);
    self.controller=[[uexGestureUnlockViewController alloc]
                     initWithConfiguration:self.config
                     mode:mode
                     progress:^(uexGestureUnlockEvent event) {
                         @strongify(self);
                         [self callbackJSONwithName:@"onEventOccur" object:@{@"eventCode":@(event)}];
                     }
                     completion:^(BOOL isFinished, NSError *error) {
                         @strongify(self);
                         NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                         [dict setValue:@(isFinished) forKey:@"isFinished"];
                         if(error){
                             [dict setValue:@(error.code) forKey:@"errorCode"];
                             [dict setValue:error.domain forKey:@"errorString"];
                         }
                         [self callbackJSONwithName:@"cbCreate" object:dict];
                         [self dismissController];
                     }];
    
    [EUtility brwView:self.meBrwView presentModalViewController:self.controller animated:YES];
}

-(void)cancel:(NSMutableArray *)inArguments{
    if(self.controller){
        [self.controller cancel];
    }
}
-(void)resetGestureCode:(NSMutableArray *)inArguments{
    [uexGestureUnlockViewController removeGestureCode];
}

#pragma mark - Private Methods
-(void)dismissController{
    if(self.controller){
        [self.controller dismissViewControllerAnimated:YES completion:^{
            self.controller=nil;
        }];
    }
}
-(void)callbackJSONwithName:(NSString *)name object:(id)obj{
    [EUtility uexPlugin:@"uexGestureUnlock"
         callbackByName:name
             withObject:obj
                andType:uexPluginCallbackWithJsonString
               inTarget:self.meBrwView];
}
@end
