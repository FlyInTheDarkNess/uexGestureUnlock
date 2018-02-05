/**
 *
 *	@file   	: uexGestureUnlockConfiguration.h  in EUExGestureUnlock Project
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


#import <Foundation/Foundation.h>


extern NSString *const kUexGestureUnlockConfigurationSaveGestureCodeKey;

@interface uexGestureUnlockConfiguration : NSObject


@property (nonatomic,assign)NSInteger minimumCodeLength;//密码最短长度
@property (nonatomic,assign)NSInteger maximumAllowTrialTimes;//最大尝试次数
//Colors
@property (nonatomic,strong)UIColor *backgroundColor;//手势解锁界面的背景色
@property (nonatomic,strong)UIColor *normalThemeColor;//普通状态下的主题颜色
@property (nonatomic,strong)UIColor *selectedThemeColor;//选中状态下的主题颜色
@property (nonatomic,strong)UIColor *errorThemeColor;//错误状态下的主题颜色

//Strings
@property (nonatomic,strong)NSString *creationBeginPrompt;//设置手势密码前的提示文字
@property (nonatomic,strong)NSString *codeLengthErrorPrompt;//密码长度低于最短长度的错误提示文字
@property (nonatomic,strong)NSString *codeCheckPrompt;//确认手势手势密码，要求再次绘制的提示文字
@property (nonatomic,strong)NSString *checkErrorPrompt;//再次绘制的图案不一致的提示文字
@property (nonatomic,strong)NSString *creationSucceedPrompt;//设置成功的提示文字
@property (nonatomic,strong)NSString *verificationBeginPrompt;//验证手势前的提示文字
@property (nonatomic,strong)NSString *verificationErrorPrompt;//验证手势密码失败的提示文字
@property (nonatomic,strong)NSString *verificationSucceedPrompt;//验证手势密码成功的提示文字

//buttonTitle
@property (nonatomic,strong)NSString *cancelVerificationButtonTitle;//取消手势验证按钮的显示文字
@property (nonatomic,strong)NSString *cancelCreationButtonTitle;//取消设置手势密码按钮的显示文字
@property (nonatomic,strong)NSString *restartCreationButtonTitle;//重新设置手势密码按钮的显示文字

//Times
@property (nonatomic,assign)NSTimeInterval errorRemainInterval;//错误状态的保留时间
@property (nonatomic,assign)NSTimeInterval successRemainInterval;//成功状态的保留时间

//Image
@property (nonatomic,strong)UIImage *backgroundImage;//手势解锁界面的背景图;
@property (nonatomic,strong)UIImage *iconImage;//头像
    
@property (nonatomic,assign)BOOL isShowTrack;//是否显示轨迹




+ (instancetype)defaultConfiguration;
@end
