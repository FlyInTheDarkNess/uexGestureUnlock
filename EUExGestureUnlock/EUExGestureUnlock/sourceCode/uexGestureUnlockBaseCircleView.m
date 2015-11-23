/**
 *
 *	@file   	: uexGestureUnlockBaseCircleView.m  in EUExGestureUnlock Project
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

#import "uexGestureUnlockBaseCircleView.h"
#import "uexGestureUnlockCircle.h"
#import "uexGestureUnlockViewController.h"
@implementation uexGestureUnlockBaseCircleView



- (instancetype)initWithSideLength:(CGFloat)sideLength
{
    self = [super init];
    if (self) {
        self.sideLength=sideLength;
        self.circles=[NSMutableArray array];
        self.selectedCircles=[NSMutableArray array];
    }
    return self;
}

-(void)combineWithViewController:(uexGestureUnlockViewController *)controller{
    self.config=controller.config;
    self.backgroundColor=[UIColor clearColor];
    for (int i=0; i<9; i++) {
        [self addSubview:[self getCircle]];
    }
}


-(uexGestureUnlockCircle *)getCircle{
    return [[uexGestureUnlockCircle alloc] init];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat radius=self.sideLength/12;
    
    @weakify(self);
    //排列9个圆，并将他们添加到circles数组中
    [[[self.subviews rac_sequence]
      filter:^BOOL(id value) {
          return [value isKindOfClass:[uexGestureUnlockCircle class]];
      }]
     all:^BOOL(uexGestureUnlockCircle * circle) {
         @strongify(self);
         NSInteger index=[self circles].count;
         circle.tag=index+1;
         NSUInteger row=index/3;
         NSUInteger col=index%3;
         CGFloat x=radius*(1+4*row);
         CGFloat y=radius*(1+4*col);
         CGRect frame = CGRectMake(x, y, radius*2, radius*2);
         circle.frame=frame;
         circle.showArrow=self.showArrow;
         [self.circles addObject:circle];
         return YES;
     }];
    
}
@end
