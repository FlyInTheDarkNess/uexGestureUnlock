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
    uexGestureUnlockModeUnknown,
    uexGestureUnlockModeSettingInitialInput,//设置新密码，首次输入
    uexGestureUnlockModeSettingCheckingInput,//设置新密码，第二次输入
    uexGestureUnlockModeVerifying,//验证密码
};

typedef NS_ENUM(NSInteger,uexGestureUnlockCodeSettingProgress) {
    uexGestureUnlockCodeSettingBeginInitialInput,
    uexGestureUnlockCodeSettingErrorLengthInput,
    uexGestureUnlockCodeSettingCheckInput,
    uexGestureUnlockCodeSettingCheckError,
    uexGestureUnlockCodeSettingSuccess,
    uexGestureUnlockCodeSettingCancel,
};

typedef void (^uexGestureUnlockSettingCodeProgressBlock)(uexGestureUnlockCodeSettingProgress pregress);
typedef void (^uexGestureUnlockVerifyingCodeResultBlock)(BOOL isSuccess,NSInteger trialTimes);
@interface uexGestureUnlockViewController : UIViewController


@property (nonatomic,strong)uexGestureUnlockConfiguration *config;
@property (nonatomic,assign)uexGestureUnlockMode mode;

/**
 *  execute  : NSArray<NSNumber *>* code
 *  sendNext : BOOL verifyResult;
 */
@property (nonatomic,strong)RACCommand *verifyResultCommand;


/**
 *  sendNext NSNull when a new touch event start
 */
@property (nonatomic,strong)RACSubject *touchStartStream;

//设置密码用的初始化方法
-(instancetype)initWithConfiguration:(uexGestureUnlockConfiguration*)config
                            progress:(uexGestureUnlockSettingCodeProgressBlock)callback;
//验证密码用的初始化方法
-(instancetype)initWithWithConfiguration:(uexGestureUnlockConfiguration*)config
                                  result:(uexGestureUnlockVerifyingCodeResultBlock)callback;
+(BOOL)isGestureCodeSet;
@end
