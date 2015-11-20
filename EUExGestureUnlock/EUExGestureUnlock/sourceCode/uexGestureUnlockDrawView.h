/**
 *
 *	@file   	: uexGestureUnlockDrawView.h  in EUExGestureUnlock Project
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


#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "uexGestureUnlockBaseView.h"
@class uexGestureUnlockConfiguration;



@interface uexGestureUnlockDrawView : uexGestureUnlockBaseView



//这个command会在触摸事件结束后exeute密码数组，sendNext验证结果(YES/NO)
@property (nonatomic,weak)RACCommand *verifyResultCommand;




-(instancetype)initWithConfiguration:(uexGestureUnlockConfiguration *)config
                         isShowArrow:(BOOL)showArrow
                          sideLength:(CGFloat)sideLength //frame的边长，计算圆的大小需要
                 verifyResultCommand:(RACCommand *)verifyResultCommand;

@end
