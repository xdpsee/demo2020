//
//  UIImage+Utils.h
//  xinamp
//
//  Created by chen zhenhui on 2020/5/4.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#ifndef UIImage_Utils_h
#define UIImage_Utils_h

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

+ (UIImage*) imageFromFile:(NSString *)filePath;

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *) screenshot;

- (UIImage*)blur:(CGFloat)blurAmount;

+ (UIImage *) imageWithView:(UIView *)view;

+ (UIImage *)imageByDrawingText:(NSString *)text color:(UIColor*)color size:(CGSize)size fontSize:(CGFloat)fontSize;

@end

#endif /* UIImage_Utils_h */
