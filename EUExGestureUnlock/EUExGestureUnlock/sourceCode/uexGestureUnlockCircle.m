/**
 *
 *	@file   	: uexGestureUnlockCircle.m  in EUExGestureUnlock Project
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

#import "uexGestureUnlockCircle.h"
#import "uexGestureUnlockConfiguration.h"
#import <ReactiveObjC/ReactiveObjC.h>

static CGFloat kCircleEdgeWidth = 1;//圆环线宽
static CGFloat kInnerCircleRatio = 0.6;//内部实心圆所占的比例

@interface uexGestureUnlockCircle()

@end



@implementation uexGestureUnlockCircle
- (instancetype)initWithType:(uexGestureUnlockCircleType)type
              configuration:(uexGestureUnlockConfiguration *)config{
    self = [super init];
    if(self){
        self.type = type;
        self.config = config;
        [self setup];
    }
    return self;
}

- (void)setup{
    self.backgroundColor = [UIColor clearColor];
    self.status = uexGestureUnlockCircleStatusNormal;
    @weakify(self);
    RACSignal *arrowNeedRedrawSignal = [RACObserve(self, arrowAngle)
                                      filter:^BOOL(id value) {
        @strongify(self);
        return self.showArrow;
    }];
    RACSignal *statusChangeSignal = [[RACObserve(self, status)
                                      distinctUntilChanged]
                                     doNext:^(id value) {
        @strongify(self);
        uexGestureUnlockCircleStatus status = (uexGestureUnlockCircleStatus)[value integerValue];
        switch (status) {
            case uexGestureUnlockCircleStatusNormal: {
                self.themeColor = self.config.normalThemeColor;
                break;
            }
            case uexGestureUnlockCircleStatusSelected: {
               if (self.config.isShowTrack) {
                    self.themeColor = self.config.selectedThemeColor;
                }else {
                    self.themeColor = self.config.normalThemeColor;
                }
                break;
            }
            case uexGestureUnlockCircleStatusError: {

                self.themeColor = self.config.errorThemeColor;
                break;
            }
        }
    }];
    [[[RACSignal merge:@[statusChangeSignal,arrowNeedRedrawSignal,RACObserve(self,showArrow)]]
      deliverOnMainThread]
     subscribeNext:^(id x) {
         @strongify(self);
        [self setNeedsDisplay];
     }];
}

- (void)drawRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat ratio;
    CGRect circleRect = CGRectMake(kCircleEdgeWidth, kCircleEdgeWidth, rect.size.width - 2 * kCircleEdgeWidth, rect.size.height - 2 * kCircleEdgeWidth);
    
    switch (self.type) {
        case uexGestureUnlockCircleTypeGestureCircle: {
            ratio=kInnerCircleRatio;
            break;
        }
        case uexGestureUnlockCircleTypeInfoCircle: {
            ratio=1;
            break;
        }
    }
    CGFloat translateXY = rect.size.width * 0.5;

    CGContextTranslateCTM(ctx, translateXY, translateXY);
    CGContextRotateCTM(ctx, self.arrowAngle);
    CGContextTranslateCTM(ctx, -translateXY, -translateXY);

    [self drawOuterCircleWithContext:ctx rect:circleRect];
    [self drawInnerCircleWithContext:ctx rect:rect ratio:ratio];
    if(self.showArrow){
        CGFloat arrowRt=(1.0/6 < (1.0-ratio)/3)?1.0/6:(1.0-ratio)/3;

        CGFloat arrowLength= rect.size.width*arrowRt;
        [self drawArrowWithContext:ctx topPoint:CGPointMake(rect.size.width/2, rect.size.width/2*(1.0-ratio)-arrowLength*2/3) length:arrowLength];
    }

}

- (void)drawOuterCircleWithContext:(CGContextRef)ctx rect:(CGRect)rect{
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddEllipseInRect(circlePath, NULL, rect);
    CGContextAddPath(ctx, circlePath);
    [self.themeColor set];
    CGContextSetLineWidth(ctx, kCircleEdgeWidth);
    CGContextStrokePath(ctx);
    CGPathRelease(circlePath);
}

- (void)drawInnerCircleWithContext:(CGContextRef)ctx rect:(CGRect)rect ratio:(CGFloat)ratio{
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddEllipseInRect(circlePath, NULL, CGRectMake(rect.size.width/2 * (1 - ratio) + kCircleEdgeWidth, rect.size.height/2 * (1 - ratio) + kCircleEdgeWidth, rect.size.width * ratio - kCircleEdgeWidth * 2, rect.size.height * ratio - kCircleEdgeWidth * 2));
    if(self.status == uexGestureUnlockCircleStatusNormal){
        [[UIColor clearColor] set];//普通状态下为透明色
    } else if (self.status == uexGestureUnlockCircleStatusError){
        [self.themeColor set];
    } else{
        if(self.config.isShowTrack) {
            [self.themeColor set];
        } else {
            [[UIColor clearColor] set];
        }
      
    }
    CGContextAddPath(ctx, circlePath);
    CGContextFillPath(ctx);
    CGPathRelease(circlePath);
}
- (void)drawArrowWithContext:(CGContextRef)ctx topPoint:(CGPoint)point length:(CGFloat)length{
    CGMutablePathRef trianglePathM = CGPathCreateMutable();
    CGPathMoveToPoint(trianglePathM, NULL, point.x, point.y);
    CGPathAddLineToPoint(trianglePathM, NULL, point.x - length/2, point.y + length/2);
    CGPathAddLineToPoint(trianglePathM, NULL, point.x + length/2, point.y + length/2);
    CGContextAddPath(ctx, trianglePathM);
    if(self.status == uexGestureUnlockCircleStatusNormal){
        [[UIColor clearColor] set];//普通状态下为透明色
    } else if (self.status == uexGestureUnlockCircleStatusError){
        [self.themeColor set];
    }else{
        if(self.config.isShowTrack) {
            [self.themeColor set];
        } else {
            [[UIColor clearColor] set];
        }
    }
    CGContextFillPath(ctx);
    CGPathRelease(trianglePathM);
}
@end
