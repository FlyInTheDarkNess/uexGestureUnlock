/**
 *
 *	@file   	: uexGestureUnlockError.m  in EUExGestureUnlock Project
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 15/11/23
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

#import "uexGestureUnlockError.h"

@implementation uexGestureUnlockError
+(NSError *)errorWithCode:(NSInteger)code description:(NSString *)desc{
    return [NSError errorWithDomain:desc code:code userInfo:nil];
}

+(NSError *)codeNotSetError{
    return [self errorWithCode:1 description:@"密码未设置"];
}
+(NSError *)creationCancelledError{
    return [self errorWithCode:2 description:@"用户取消了创建密码过程"];
}
+(NSError *)verificationCancelledError{
    return [self errorWithCode:3 description:@"用户取消了验证密码过程"];
}
+(NSError *)maxTrialTimesExceededError{
    return [self errorWithCode:4 description:@"尝试密码次数过多"];
}
+(NSError *)forcedCancalError{
    return [self errorWithCode:5 description:@"插件被cancel接口强制关闭"];
}
+(NSError *)unknownAccidentHappenedError{
    return [self errorWithCode:6 description:@"发生未知错误"];
}
@end
