/**
 *
 *	@file   	: uexGestureUnlockConfiguration.m  in EUExGestureUnlock Project
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

#import "uexGestureUnlockConfiguration.h"
#import "UIColor+HtmlColor.h"

NSString *const kUexGestureUnlockConfigurationSaveGestureCodeKey=@"kUexGestureUnlockConfigurationSaveGestureCodeKey";
@implementation uexGestureUnlockConfiguration



+(instancetype)defaultConfiguration{
    uexGestureUnlockConfiguration *config=[[self alloc] init];
    if(config) {
        config.minimumCodeLength=4;
        config.maximubAllowTrialTimes=5;
        
        config.normalThemeColor=[UIColor uexGU_ColorFromHtmlString:@"#F1F1F1"];
        config.selectedThemeColor=[UIColor uexGU_ColorFromHtmlString:@"#22B2F6"];
        config.errorThemeColor=[UIColor uexGU_ColorFromHtmlString:@"#FE525C"];
        config.backgroundColor=[UIColor uexGU_ColorFromHtmlString:@"#0D3459"];
        
        
        config.initialInputPrompt=@"请设置手势密码";//设置手势密码前的提示文字
        config.codeLengthErrorPrompt=@"请至少连续绘制%ld个点";//密码长度低于最短长度的错误提示文字
        config.checkInputPrompt=@"请再次绘制手势密码";//确认手势手势密码，要求再次绘制的提示文字
        config.checkErrorPrompt=@"与首次绘制不一致，请再次绘制";//再次绘制的图案不一致的提示文字
        config.setSuccessPrompt=@"手势密码设置成功";//设置成功的提示文字
        config.verifyBeginPrompt=@"请验证手势密码";//验证手势前的提示文字
        config.verifyErrorPrompt=@"验证错误!您还可以尝试%ld次";//验证手势密码失败的提示文字
        config.verifySuccessPrompt=@"验证通过";//验证手势密码成功的提示文字
        
        
        config.errorRemainInterval=1;//错误状态，保留1s
        config.successRemainInterval=0.2;
        config.showIcon=YES;
        
        config.backgroundImage=nil;
        config.iconImage=nil;

    }
    return config;
}
@end
