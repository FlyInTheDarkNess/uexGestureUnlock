/**
 *
 *	@file   	: uexGestureUnlockBaseCircleView.h  in EUExGestureUnlock Project
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

@class uexGestureUnlockCircle;
@class uexGestureUnlockViewController;
@class uexGestureUnlockConfiguration;
/**
 *  @abstract 包含9个uexGestureCircle的view
 *  @note 这个view的frame是个正方形
 */
@interface uexGestureUnlockBaseCircleView : UIView
@property (nonatomic,strong)NSMutableArray<uexGestureUnlockCircle *> *circles;
@property (nonatomic,strong)NSMutableArray<uexGestureUnlockCircle *> *selectedCircles;
@property (nonatomic,weak)uexGestureUnlockConfiguration *config;
@property (nonatomic,assign)CGFloat sideLength;//需要知道边长，用于排列圆



- (instancetype)initWithSideLength:(CGFloat)sideLength;
- (void)combineWithViewController:(uexGestureUnlockViewController *)controller;

//覆写这个方法以定制放到view中的circle;
- (uexGestureUnlockCircle *)getCircle;
@end
