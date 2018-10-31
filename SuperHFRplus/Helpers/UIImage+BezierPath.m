
#import "UIImage+BezierPath.h"

@implementation UIImage (BezierPath)

+ (UIImage *)checkmarkImage
{
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(21.84, 9.35)];
    [bezier2Path addLineToPoint: CGPointMake(12.89, 18.3)];
    [bezier2Path addLineToPoint: CGPointMake(8.13, 13.55)];
    [bezier2Path addCurveToPoint: CGPointMake(7.8, 13.55) controlPoint1: CGPointMake(8.04, 13.45) controlPoint2: CGPointMake(7.9, 13.45)];
    [bezier2Path addLineToPoint: CGPointMake(5.81, 15.54)];
    [bezier2Path addCurveToPoint: CGPointMake(5.74, 15.69) controlPoint1: CGPointMake(5.77, 15.58) controlPoint2: CGPointMake(5.75, 15.64)];
    [bezier2Path addCurveToPoint: CGPointMake(5.81, 15.87) controlPoint1: CGPointMake(5.74, 15.75) controlPoint2: CGPointMake(5.76, 15.82)];
    [bezier2Path addLineToPoint: CGPointMake(12.73, 22.78)];
    [bezier2Path addCurveToPoint: CGPointMake(13.05, 22.78) controlPoint1: CGPointMake(12.82, 22.87) controlPoint2: CGPointMake(12.96, 22.87)];
    [bezier2Path addLineToPoint: CGPointMake(24.16, 11.67)];
    [bezier2Path addCurveToPoint: CGPointMake(24.16, 11.34) controlPoint1: CGPointMake(24.26, 11.58) controlPoint2: CGPointMake(24.26, 11.44)];
    [bezier2Path addLineToPoint: CGPointMake(22.17, 9.35)];
    [bezier2Path addCurveToPoint: CGPointMake(21.84, 9.35) controlPoint1: CGPointMake(22.08, 9.26) controlPoint2: CGPointMake(21.94, 9.26)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(30, 15)];
    [bezier2Path addCurveToPoint: CGPointMake(15, 30) controlPoint1: CGPointMake(30, 23.28) controlPoint2: CGPointMake(23.28, 30)];
    [bezier2Path addCurveToPoint: CGPointMake(0, 15) controlPoint1: CGPointMake(6.72, 30) controlPoint2: CGPointMake(0, 23.28)];
    [bezier2Path addCurveToPoint: CGPointMake(5.97, 3.02) controlPoint1: CGPointMake(0, 10.11) controlPoint2: CGPointMake(2.34, 5.76)];
    [bezier2Path addCurveToPoint: CGPointMake(15, 0) controlPoint1: CGPointMake(8.48, 1.13) controlPoint2: CGPointMake(11.61, 0)];
    [bezier2Path addCurveToPoint: CGPointMake(30, 15) controlPoint1: CGPointMake(23.28, 0) controlPoint2: CGPointMake(30, 6.72)];
    [bezier2Path closePath];
    
    return [self imageWithBezierPath:bezier2Path
                                fill:YES
                              stroke:NO
                               scale:[[UIScreen mainScreen] scale]];
}

+ (UIImage *)imageWithBezierPathFill:(UIBezierPath *)bezierPath
{
    return [self imageWithBezierPath:bezierPath
                                fill:YES
                              stroke:NO
                               scale:[[UIScreen mainScreen] scale]];
}

+ (UIImage *)imageWithBezierPathStroke:(UIBezierPath *)bezierPath
{
    return [self imageWithBezierPath:bezierPath
                                fill:NO
                              stroke:YES
                               scale:[[UIScreen mainScreen] scale]];
}

+ (UIImage *)imageWithBezierPath:(UIBezierPath *)bezierPath
                            fill:(BOOL)fill
                          stroke:(BOOL)stroke
                           scale:(CGFloat)scale
{
    UIImage *image = nil;
    if (bezierPath) {
        UIGraphicsBeginImageContextWithOptions(bezierPath.bounds.size, NO, scale);
        if (fill) {
            [bezierPath fill];
        }
        if (stroke) {
            [bezierPath stroke];
        }
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

@end
