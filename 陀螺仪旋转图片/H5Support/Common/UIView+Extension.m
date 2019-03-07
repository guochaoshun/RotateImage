//
//  UIView+Extension.m
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}



- (CGFloat)maxX
{
    return self.frame.origin.x + self.frame.size.width ;
}
- (void)setMaxX:(CGFloat)maxX {
    CGRect frame = self.frame;
    frame.origin.x = maxX-frame.size.width;
    self.frame = frame;
}

- (CGFloat)maxY
{
    return self.frame.origin.y + self.frame.size.height;
}
- (void)setMaxY:(CGFloat)maxY {
    CGRect frame = self.frame;
    frame.origin.y = maxY-frame.size.height;
    self.frame = frame;
    
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius ;
    self.clipsToBounds = YES ;
}


- (CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}
- (void)setBoardCorner:(UIColor *)boardCorner{
    self.layer.borderColor = boardCorner.CGColor;
    if (self.layer.borderWidth == 0) {
        self.layer.borderWidth = 1;
    }
}

- (UIColor *)boardCorner{
    return [UIColor colorWithCGColor: self.layer.borderColor];
}

+ (instancetype)zwyl_viweFromXib
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}


@end
