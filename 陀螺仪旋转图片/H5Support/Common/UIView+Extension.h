//
//  UIView+Extension.h
//

#import <UIKit/UIKit.h>

// 为什么要封装frame
// OC语法细节：不允许直接修改OC对象的结构体属性的成员


@interface UIView (Extension)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;

@property (assign, nonatomic) CGFloat    maxX;
@property (assign, nonatomic) CGFloat    maxY;
@property (assign, nonatomic) CGPoint    origin;

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, strong) IBInspectable UIColor * boardCorner;

+ (instancetype)zwyl_viweFromXib;

@end
