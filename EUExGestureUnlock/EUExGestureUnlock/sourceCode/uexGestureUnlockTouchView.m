/**
 *
 *	@file   	: uexGestureUnlockTouchView.m  in EUExGestureUnlock Project
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

#import "uexGestureUnlockTouchView.h"
#import "uexGestureUnlockCircle.h"
#import "uexGestureUnlockViewController.h"


static CGFloat kCircleConnectLineWidth = 1;//连线宽度



@interface uexGestureUnlockTouchView ()
@property (nonatomic,assign)BOOL needReset;//触摸事件结束之后才需要reset
@property (nonatomic,assign)CGPoint currentPoint;
//这个command会在触摸事件结束后exeute密码数组，sendNext验证结果(YES/NO)
@property (nonatomic,strong)RACSignal *touchStartSignal;
@property (nonatomic,weak)uexGestureUnlockViewController *controller;
@end
@implementation uexGestureUnlockTouchView



#pragma mark - 绑定ViewController


- (void)combineWithViewController:(uexGestureUnlockViewController *)controller{
    [super combineWithViewController:controller];
    self.controller = controller;
    //配置verifyResultCommand
    @weakify(self);
    [[self.controller.verifyResultCommand executionSignals] subscribeNext:^(RACSignal *execution) {
        [execution subscribeNext:^(id x) {
            @strongify(self);
            BOOL verifyResult = [x boolValue];
            if(verifyResult){
                //验证成功，直接回到初始状态
                [self reset];
            }else{
                //验证失败，显示错误情况
                [[self.selectedCircles rac_sequence]
                 all:^BOOL(uexGestureUnlockCircle *circle) {//把所有选中的圆置为error
                     circle.status = uexGestureUnlockCircleStatusError;
                     return YES;
                 }];
                [self setNeedsDisplay];
                //经过错误保留时间后，回到初始状态
                [[RACScheduler scheduler] afterDelay:self.config.errorRemainInterval schedule:^{
                    [self reset];
                }];
            }
        }];
    }];
}

- (uexGestureUnlockCircle *)getCircle{
    uexGestureUnlockCircle *circle = [[uexGestureUnlockCircle alloc]
            initWithType:uexGestureUnlockCircleTypeGestureCircle
            configuration:self.config];
    return circle;
}

#pragma mark - 画线
- (void)drawRect:(CGRect)rect{
    if(!self.selectedCircles || [self.selectedCircles count] < 1){
        return;//没有任何圆被选择
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddRect(ctx, rect);
    [[self.circles rac_sequence]
     all:^BOOL(uexGestureUnlockCircle *circle) {
        CGContextAddEllipseInRect(ctx, circle.frame);
         return YES;
    }];
    CGContextEOClip(ctx);
    for (int index = 0; index < self.selectedCircles.count; index++) {

        // 取出选中按钮
        uexGestureUnlockCircle *circle = self.selectedCircles[index];

        if (index == 0) { // 起点按钮
            CGContextMoveToPoint(ctx, circle.center.x, circle.center.y);//移动到第一个圆
        }else{
            CGContextAddLineToPoint(ctx, circle.center.x, circle.center.y); // 连接这些圆
        }
    }
    if (!CGPointEqualToPoint(self.currentPoint, CGPointZero) && self.selectedCircles.firstObject.status != uexGestureUnlockCircleStatusError){//错误状态下不画最后一根线
        CGContextAddLineToPoint(ctx, self.currentPoint.x, self.currentPoint.y);//连接到当前点
    }
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    
    // 设置绘图的属性
    CGContextSetLineWidth(ctx, kCircleConnectLineWidth);
    
    if (self.config.isShowTrack) {
        [self.selectedCircles.firstObject.themeColor set];//线和圆的颜色一致
    }else {
        [[UIColor clearColor] set];
    }
    // 线条颜色

    //渲染路径
    CGContextStrokePath(ctx);
}
#pragma mark - 触摸事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self reset];//开始触摸事件时，先重置
    [self.controller.touchStartStream sendNext:nil];
    [self dealWithTouchs:touches];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self dealWithTouchs:touches];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.needReset=YES;
    NSArray *codeArray=[[[self.selectedCircles rac_sequence]
                        map:^id(uexGestureUnlockCircle *circle) {
                            return @(circle.tag);
                        }]
                        array];
    [self.controller.verifyResultCommand execute:codeArray];
}
- (void)dealWithTouchs:(NSSet<UITouch *> *)touches{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];//触摸点
    self.currentPoint=point;
    [[self.subviews rac_sequence]
     any:^BOOL(uexGestureUnlockCircle *circle) {
         if(CGRectContainsPoint(circle.frame, point)){//触摸点在某个圆中
             [self addSelectedCircle:circle];
             return YES;
         }else{
             return NO;
         }
     }];
    
    [self setNeedsDisplay];


}


#pragma mark - 添加圆到已选择中
- (void)addSelectedCircle:(uexGestureUnlockCircle *)circle{
    if(!circle || [self.selectedCircles containsObject:circle]){
        return;//如果圆已经被添加，直接返回
    }
    circle.status=uexGestureUnlockCircleStatusSelected;
    [self.selectedCircles addObject:circle];
    if([self.selectedCircles count]<2){
        return;
    }
    //计算arrowAngle
    uexGestureUnlockCircle *lastButOneCircle = [self.selectedCircles objectAtIndex:[self.selectedCircles count]-2];//倒数第二个圆
    CGFloat last_1_x = circle.center.x;
    CGFloat last_1_y = circle.center.y;
    CGFloat last_2_x = lastButOneCircle.center.x;
    CGFloat last_2_y = lastButOneCircle.center.y;
    CGFloat angle = atan2(last_1_y - last_2_y, last_1_x - last_2_x) + M_PI_2;
    [lastButOneCircle setArrowAngle:angle];
    lastButOneCircle.showArrow=YES;
    
    //处理连线经过其他圆的情况，把这个圆也加入已选择中
    CGPoint midCenterPoint=CGPointMake((last_1_x+last_2_x)/2, (last_1_y+last_2_y)/2);
    //只需判断倒数2个圆的连线中点是否在别的圆中
    @weakify(self);
    [[self.circles rac_sequence]
     any:^BOOL(uexGestureUnlockCircle * circle) {
         if (CGRectContainsPoint(circle.frame, midCenterPoint)) {//经过了某个圆
             @strongify(self);
             
             if(![self.selectedCircles containsObject:circle]){//如果这个圆没被选择
                 circle.arrowAngle = lastButOneCircle.arrowAngle;//更新这个圆的arrowAngle
                 circle.status = uexGestureUnlockCircleStatusSelected;
                 circle.showArrow = YES;
                 [self.selectedCircles insertObject:circle atIndex:self.selectedCircles.count-1];
                 //插入到倒数第二的位置
             }
             return YES;
         }
         return NO;
    }];
}
//返回2个点的中点

#pragma mark - 回到初始状态 准备下一次触摸事件
- (void)reset{
    if(!self.needReset){
        return;
    }
    self.needReset = NO;
    [self.selectedCircles removeAllObjects];
    [[self.circles rac_sequence]
     all:^BOOL(uexGestureUnlockCircle * circle) {
        circle.status = uexGestureUnlockCircleStatusNormal;
        circle.arrowAngle = 0;
        circle.showArrow = NO;
         
        return YES;
    }];
    self.currentPoint = CGPointZero;
    [[RACScheduler mainThreadScheduler] schedule:^{
        [self setNeedsDisplay];
    }];
    
    
}
@end
