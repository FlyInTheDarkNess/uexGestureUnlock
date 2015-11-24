/**
 *
 *	@file   	: uexGestureUnlockViewController.h  in EUExGestureUnlock Project
 *
 *	@author 	: CeriNo
 *
 *	@date   	: Created on 15/11/20
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

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "uexGestureUnlockConfiguration.h"




typedef NS_ENUM(NSInteger,uexGestureUnlockMode) {
    uexGestureUnlockModeCreateCode,//设置新密码
    uexGestureUnlockModeVerifyCode,//验证密码
    uexGestureUnlockModeVerifyThenCreateCode,//先验证密码再设置新密码
};

typedef NS_ENUM(NSInteger,uexGestureUnlockEvent) {
    uexGestureUnlockInitialized,
    uexGestureUnlockCodeVerificationBegin,
    uexGestureUnlockCodeVerificationFailed,
    uexGestureUnlockCodeVerificationCancelled,
    uexGestureUnlockCodeVerificationSucceed,
    uexGestureUnlockCodeCreationBegin,
    uexGestureUnlockCodeCreationInputInvalid,
    uexGestureUnlockCodeCreationCheckInput,
    uexGestureUnlockCodeCreationCheckFailed,
    uexGestureUnlockCodeCreationCancelled,
    uexGestureUnlockCodeCreationCompleted
    
};

typedef void (^uexGestureUnlockProgressBlock)(uexGestureUnlockEvent event);
typedef void (^uexGestureUnlockCompletionBlock)(BOOL isFinished,NSError *error);


@interface uexGestureUnlockViewController : UIViewController

@property (nonatomic,assign)uexGestureUnlockMode mode;
@property (nonatomic,strong)__block NSString *prompt;


@property (nonatomic,strong)uexGestureUnlockConfiguration *config;

/**
 *  execute  : NSArray<NSNumber *>* code
 *  sendNext : BOOL verifyResult;
 */
@property (nonatomic,strong)RACCommand *verifyResultCommand;


/**
 *  sendNext NSNull when a new touch event start
 */
@property (nonatomic,strong)RACSubject *touchStartStream;



- (instancetype)initWithConfiguration:(uexGestureUnlockConfiguration *)config
                                 mode:(uexGestureUnlockMode)mode
                             progress:(uexGestureUnlockProgressBlock)progressBlock
                           completion:(uexGestureUnlockCompletionBlock)completionBlock;
- (void)cancel;
+ (BOOL)isGestureCodeSet;
+ (void)removeGestureCode;



@end
