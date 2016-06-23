/**
 *
 *	@file   	: uexGestureUnlockInfoView.m  in EUExGestureUnlock Project
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

#import "uexGestureUnlockInfoView.h"
#import "uexGestureUnlockCircle.h"
#import "uexGestureUnlockViewController.h"
@implementation uexGestureUnlockInfoView

-(void)combineWithViewController:(uexGestureUnlockViewController *)controller{
    [super combineWithViewController:controller];
    @weakify(self);
    [controller.verifyResultCommand.executionSignals subscribeNext:^(RACSignal *execution) {
        [[execution
          filter:^BOOL(id value) {
              return ![value boolValue];
          }]
         subscribeNext:^(id x){
             @strongify(self);
             [self setSelectedCirclesStatus:uexGestureUnlockCircleStatusError];
             [[RACScheduler scheduler] afterDelay:controller.config.errorRemainInterval schedule:^{
                 [self setSelectedCirclesStatus:uexGestureUnlockCircleStatusSelected];
             }];
             
         }];
    }];
    [controller.touchStartStream subscribeNext:^(id x) {
        @strongify(self);
        [self setSelectedCirclesStatus:uexGestureUnlockCircleStatusSelected];
    }];
}

-(uexGestureUnlockCircle *)getCircle{
    uexGestureUnlockCircle *circle = [[uexGestureUnlockCircle alloc]
                                      initWithType:uexGestureUnlockCircleTypeInfoCircle
                                      configuration:self.config];
    return circle;
}
-(void)SelectCircles:(NSArray<NSNumber *> *)indices{
    [self deselectAll];
    for (NSNumber *index in indices) {
        [self.selectedCircles addObject:[self.circles objectAtIndex:[index integerValue]-1]];
    }
    [self setSelectedCirclesStatus:uexGestureUnlockCircleStatusSelected];

         
}
-(void)setSelectedCirclesStatus:(uexGestureUnlockCircleStatus)status{
    [self.selectedCircles.rac_sequence all:^BOOL(uexGestureUnlockCircle *circle) {
        circle.status=status;
        return YES;
    }];
}
-(void)deselectAll{
    if([self.selectedCircles count] == 0){
        return;
    }
    [self setSelectedCirclesStatus:uexGestureUnlockCircleStatusNormal];
    [self.selectedCircles removeAllObjects];
}
@end
