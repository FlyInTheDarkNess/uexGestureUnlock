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

//Colors
@property (nonatomic,strong)UIColor *backgroundColor;//手势解锁界面的背景色
@property (nonatomic,strong)UIColor *normalThemeColor;//普通状态下的主题颜色
@property (nonatomic,strong)UIColor *selectedThemeColor;//选中状态下的主题颜色
@property (nonatomic,strong)UIColor *errorThemeColor;//错误状态下的主题颜色

//Texts

@property (nonatomic,strong)NSString *beforeSetCodeText;//设置手势密码前的提示文字
@property (nonatomic,strong)NSString *codeLengthErrorText;//密码长度低于最短长度的错误提示文字
@property (nonatomic,strong)NSString *drawAgainText;//确认手势手势密码，要求再次绘制的提示文字
@property (nonatomic,strong)NSString *drawAgainErrorText;//再次绘制的图案不一致的提示文字
@property (nonatomic,strong)NSString *setSuccessText;//设置成功的提示文字
@property (nonatomic,strong)NSString *verifyErrorText;//验证手势密码失败的提示文字


+(instancetype)defaultConfiguration;
@end
