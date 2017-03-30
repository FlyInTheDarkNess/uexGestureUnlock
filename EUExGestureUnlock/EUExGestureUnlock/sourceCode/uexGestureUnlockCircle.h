/**
 *
 *	@file   	: uexGestureUnlockCircle.h  in EUExGestureUnlock Project
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
@class uexGestureUnlockConfiguration;
typedef NS_ENUM(NSInteger,uexGestureUnlockCircleStatus) {
    uexGestureUnlockCircleStatusNormal,
    uexGestureUnlockCircleStatusSelected,
    uexGestureUnlockCircleStatusError
};


typedef NS_ENUM(NSInteger,uexGestureUnlockCircleType) {
    uexGestureUnlockCircleTypeGestureCircle,
    uexGestureUnlockCircleTypeInfoCircle
};
@interface uexGestureUnlockCircle : UIView
@property (nonatomic,assign)uexGestureUnlockCircleStatus status;
@property (nonatomic,assign)uexGestureUnlockCircleType type;
@property (nonatomic,assign)BOOL showArrow;
@property (nonatomic,assign)CGFloat arrowAngle;
@property (nonatomic,weak)uexGestureUnlockConfiguration *config;

@property (nonatomic,strong)UIColor *themeColor;//主题颜色

- (instancetype)initWithType:(uexGestureUnlockCircleType)type
               configuration:(uexGestureUnlockConfiguration *)config;



@end
