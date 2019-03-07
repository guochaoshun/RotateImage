//
//  CoverView.m
//  H5Support
//
//  Created by apple on 2019/3/4.
//  Copyright © 2019 apple. All rights reserved.
//

#import "CoverView.h"

@implementation CoverView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addCoverView];
    }
    return self;
}

- (void)addCoverView {
    
    // 添加毛玻璃效果
    UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView * effectView = [[UIVisualEffectView alloc]initWithEffect:effect];
    effectView.frame = self.bounds;
    [self insertSubview:effectView atIndex:0];
    
    //贝塞尔曲线 画一个带有圆角的矩形
    UIBezierPath *bpath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:0];
    //贝塞尔曲线 画一个圆形
    CGPoint centerPoint = CGPointMake(Screen_Width*0.5, Screen_Height*0.45) ;
    CGFloat width = Screen_Width*0.4;
    [bpath appendPath:[UIBezierPath bezierPathWithArcCenter:centerPoint
                                                     radius:width startAngle:0 endAngle:2*M_PI clockwise:NO]];
    
    //创建一个CAShapeLayer 图层
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = bpath.CGPath;
    
    //添加图层蒙板
    effectView.layer.mask = shapeLayer;
    
    // 给中间的view添加阴影和圆角
    UIView * shadowBackView = [[UIView alloc]init];
    shadowBackView.x = centerPoint.x-width;
    shadowBackView.y = centerPoint.y-width;
    
    shadowBackView.width = width*2;
    shadowBackView.height = width*2;
    shadowBackView.layer.cornerRadius = width;
    shadowBackView.layer.borderColor = [UIColor redColor].CGColor;
    shadowBackView.layer.borderWidth = 3;
    
    // 不加颜色看不见阴影,神奇啊
    UIView * shadowView = [[UIView alloc]initWithFrame:shadowBackView.bounds];
    shadowView.layer.cornerRadius = width;
    shadowView.layer.shadowColor = [UIColor cyanColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    shadowView.layer.shadowOpacity = 0.8;
    shadowView.layer.shadowRadius = 30;
    
    [shadowBackView addSubview:shadowView];
    [self addSubview:shadowBackView];

}


@end
