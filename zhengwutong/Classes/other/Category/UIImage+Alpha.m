// UIImage+Alpha.m
// Created by Trevor Harmon on 9/20/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

#import "UIImage+Alpha.h"

// Private helper methods
@interface UIImage ()
- (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size;
@end

@implementation UIImage (Alpha)

// Returns true if the image has an alpha layer
- (BOOL)hasAlpha {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

// Returns a copy of the given image, adding an alpha channel if it doesn't already have one
- (UIImage *)imageWithAlpha {
    if ([self hasAlpha]) {
        return self;
    }
    
    CGImageRef imageRef = self.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL,
                                                          width,
                                                          height,
                                                          8,
                                                          0,
                                                          CGImageGetColorSpace(imageRef),
                                                          kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];
    
    // Clean up
    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithAlpha);
    
    return imageWithAlpha;
}

// Returns a copy of the image with a transparent border of the given size added around its edges.
// If the image has no alpha layer, one will be added to it.
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize {
    // If the image does not have an alpha layer, add one
    UIImage *image = [self imageWithAlpha];
    
    CGRect newRect = CGRectMake(0, 0, image.size.width + borderSize * 2, image.size.height + borderSize * 2);
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(self.CGImage),
                                                0,
                                                CGImageGetColorSpace(self.CGImage),
                                                CGImageGetBitmapInfo(self.CGImage));
    
    // Draw the image in the center of the context, leaving a gap around the edges
    CGRect imageLocation = CGRectMake(borderSize, borderSize, image.size.width, image.size.height);
    CGContextDrawImage(bitmap, imageLocation, self.CGImage);
    CGImageRef borderImageRef = CGBitmapContextCreateImage(bitmap);
    
    // Create a mask to make the border transparent, and combine it with the image
    CGImageRef maskImageRef = [self newBorderMask:borderSize size:newRect.size];
    CGImageRef transparentBorderImageRef = CGImageCreateWithMask(borderImageRef, maskImageRef);
    UIImage *transparentBorderImage = [UIImage imageWithCGImage:transparentBorderImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(borderImageRef);
    CGImageRelease(maskImageRef);
    CGImageRelease(transparentBorderImageRef);
    
    return transparentBorderImage;
}


-(UIImage *)imageWithShadow:(UIColor*)_shadowColor 
				 shadowSize:(CGSize)_shadowSize
					   blur:(CGFloat)_blur {
	if (_blur == 0 && _shadowSize.width == 0 && _shadowSize.height == 0) {
		return self;
	}
	_shadowColor = _shadowColor ? _shadowColor : [UIColor blackColor];

	CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
	CGFloat w = _shadowSize.width > 0 ? _shadowSize.width : -_shadowSize.width;
	CGFloat h = _shadowSize.height > 0 ? _shadowSize.height : -_shadowSize.height;
	CGFloat x = _shadowSize.width > 0 ? 0 : -_shadowSize.width;
	CGFloat y = _shadowSize.height > 0 ? 0 : -_shadowSize.height;
	if (w < _blur * 2) {
		w = _blur * 2;
	}
	if (h < _blur * 2) {
		h = _blur * 2;
	}
	if (x < _blur) {
		x = _blur;
	}
	if (y < _blur) {
		y = _blur;
	}
	
	CGSize imageSize = self.size;
    CGContextRef shadowContext = CGBitmapContextCreate(NULL, self.size.width + w, self.size.height + h, CGImageGetBitsPerComponent(self.CGImage), 0, 
													   colourSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
	
    CGContextSetShadowWithColor(shadowContext, _shadowSize, _blur, _shadowColor.CGColor);
    CGContextDrawImage(shadowContext, CGRectMake(x, y, imageSize.width, imageSize.height), self.CGImage);
	
    CGImageRef shadowedCGImage = CGBitmapContextCreateImage(shadowContext);
    CGContextRelease(shadowContext);
	
    UIImage * shadowedImage = [UIImage imageWithCGImage:shadowedCGImage];
    CGImageRelease(shadowedCGImage);
	
    return shadowedImage;	
}

#pragma mark -
#pragma mark Private helper methods

// Creates a mask that makes the outer edges transparent and everything else opaque
// The size must include the entire mask (opaque part + transparent border)
// The caller is responsible for releasing the returned reference by calling CGImageRelease
//- (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size {
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
//    
//    // Build a context that's the same dimensions as the new size
//    CGContextRef maskContext = CGBitmapContextCreate(NULL,
//                                                     size.width,
//                                                     size.height,
//                                                     8, // 8-bit grayscale
//                                                     0,
//                                                     colorSpace,
//                                                     kCGBitmapByteOrderDefault | kCGImageAlphaNone);
//    
//    // Start with a mask that's entirely transparent
//    CGContextSetFillColorWithColor(maskContext, [UIColor blackColor].CGColor);
//    CGContextFillRect(maskContext, CGRectMake(0, 0, size.width, size.height));
//    
//    // Make the inner part (within the border) opaque
//    CGContextSetFillColorWithColor(maskContext, [UIColor whiteColor].CGColor);
//    CGContextFillRect(maskContext, CGRectMake(borderSize, borderSize, size.width - borderSize * 2, size.height - borderSize * 2));
//    
//    // Get an image of the context
//    CGImageRef maskImageRef = CGBitmapContextCreateImage(maskContext);
//    
//    // Clean up
//    CGContextRelease(maskContext);
//    CGColorSpaceRelease(colorSpace);
//    
//    return maskImageRef;
//}

- (UIImage *)maskWithColor:(UIColor *)color {
	return [self maskWithColor:color shadowColor:[UIColor blackColor] shadowOffset:CGSizeZero shadowBlur:0];
}

- (UIImage *)maskWithColor:(UIColor *)color 
		   shadowColor:(UIColor *)shadowColor
		  shadowOffset:(CGSize)shadowOffset
			shadowBlur:(CGFloat)shadowBlur
{
	UIImage *resultImage;
	CGColorRef cgColor = [color CGColor];
    CGColorRef cgShadowColor = [shadowColor CGColor];
	
	CGRect contextRect;
	contextRect.origin.x = 0.0f;
	contextRect.origin.y = 0.0f;
	contextRect.size = CGSizeMake([self size].width + 10, [self size].height + 10);
	// Retrieve source image and begin image context
	CGSize itemImageSize = [self size];
	CGPoint itemImagePosition; 
	itemImagePosition.x = ceilf((contextRect.size.width - itemImageSize.width) / 2);
	itemImagePosition.y = ceilf((contextRect.size.height - itemImageSize.height) / 2);
	UIGraphicsBeginImageContext(contextRect.size);
	CGContextRef c = UIGraphicsGetCurrentContext();
	// Setup shadow
	CGContextSetShadowWithColor(c, shadowOffset, shadowBlur, cgShadowColor);
	// Setup transparency layer and clip to mask
	CGContextBeginTransparencyLayer(c, NULL);
	CGContextScaleCTM(c, 1.0, -1.0);
	CGContextClipToMask(c, CGRectMake(itemImagePosition.x, -itemImagePosition.y, itemImageSize.width, -itemImageSize.height)
						, [self CGImage]);
	// Fill and end the transparency layer
	CGContextSetFillColorWithColor(c, cgColor);
	contextRect.size.height = -contextRect.size.height;
	CGContextFillRect(c, contextRect);
	CGContextEndTransparencyLayer(c);
	// Set selected image and end context
	resultImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return resultImage;
}

#define DEGREES_TO_RADIANS_(degrees)  ((3.14159265359 * degrees)/ 180)
+ (void)rectangleInPath:(UIBezierPath *)path
              WithWidth:(CGFloat)width
                 Height:(CGFloat)height
                 Radius:(CGFloat)radius
                 Offset:(CGFloat)offset
{
    
    [path moveToPoint:(CGPoint){offset, offset+radius}];
    [path addArcWithCenter:CGPointMake(offset+radius, offset+radius) radius:radius startAngle:DEGREES_TO_RADIANS_(0) endAngle:DEGREES_TO_RADIANS_(270) clockwise:YES];
    //    CGPathAddArcToPoint(path, NULL, offset, offset, offset+radius, offset, radius);
    [path addLineToPoint:(CGPoint){width-radius-offset, offset}];
    
    [path addArcWithCenter:CGPointMake(width-offset-radius, offset+radius) radius:radius startAngle:DEGREES_TO_RADIANS_(90) endAngle:DEGREES_TO_RADIANS_(0) clockwise:YES];
    //    CGPathAddArcToPoint(path, NULL, width-offset, offset, width-offset, radius+offset, radius);
    [path addLineToPoint:(CGPoint){width-offset, height-radius-offset}];
    
    [path addArcWithCenter:CGPointMake(width-offset-radius, height-radius-offset) radius:radius startAngle:DEGREES_TO_RADIANS_(180) endAngle:DEGREES_TO_RADIANS_(90) clockwise:YES];
    //    CGPathAddArcToPoint(path, NULL, width-offset, height-offset, width-radius-offset, height-offset, radius);
    [path addLineToPoint:(CGPoint){radius+offset, height-offset}];
    
    [path addArcWithCenter:CGPointMake(offset+radius, height-radius-offset) radius:radius startAngle:DEGREES_TO_RADIANS_(270) endAngle:DEGREES_TO_RADIANS_(180) clockwise:YES];
    //    CGPathAddArcToPoint(path, NULL, offset, height-offset, offset, height-radius-offset, radius);
    [path addLineToPoint:(CGPoint){offset, offset+radius}];
}

CGFloat edgeSizeFromCornerRadius(CGFloat cornerRadius){
    return cornerRadius * 2 + 1;
}

+ (UIImage *)imageWithColor:(UIColor *)color
                     bounds:(CGSize)bounds
                     radius:(CGFloat)cornerRadius
{
    CGFloat minEdgeSize = edgeSizeFromCornerRadius(cornerRadius);
    CGRect rc = CGRectMake(0, 0, bounds.width, bounds.height);
    if (CGRectEqualToRect(rc, CGRectZero))
        rc = CGRectMake(0, 0, minEdgeSize, minEdgeSize);
    
    UIBezierPath *bPath = [[UIBezierPath alloc] init];
    if (&UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(rc.size, NO, 0.0f);
    } else {
        UIGraphicsBeginImageContext(rc.size);
    }
    [color setFill];
//    [self rectangleInPath:bPath WithWidth:rc.size.width Height:rc.size.height Radius:cornerRadius Offset:0];
    bPath = [UIBezierPath bezierPathWithRoundedRect:rc cornerRadius:cornerRadius];
    bPath.lineWidth = 0;
    [bPath fill];
    [bPath stroke];
    [bPath addClip];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)aColor andBounds:(CGSize)bounds radius:(CGFloat)radius {
    
    UIImage *originImg = [UIImage imageWithColor:aColor bounds:bounds radius:radius];
    //抗锯齿神器 ca, what`s the fucking stufff..f.f.f..f.f.
//    UIImage *output = [originImg antiAlias];
    
    return [originImg resizableImageWithCapInsets:UIEdgeInsetsMake(radius, radius, radius, radius)];
}

//抗锯齿
- (UIImage *)antiAlias
{
    CGFloat border = 1.f;
    CGRect rect = CGRectMake(border, border, self.size.width-2*border, self.size.height-2*border);
    
    UIImage *img = nil;
    if (&UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(rect.size.width,rect.size.height), NO, 0.0f);
    } else {
        UIGraphicsBeginImageContext(CGSizeMake(rect.size.width,rect.size.height));
    }
    [self drawInRect:CGRectMake(-1, -1, self.size.width, self.size.height)];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (&UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    } else {
        UIGraphicsBeginImageContext(self.size);
    }
    [img drawInRect:rect];
    UIImage* antiImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return antiImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color withRect:(CGRect)rect
{
    CGRect rc = CGRectZero;
    if (CGRectEqualToRect(rect, CGRectZero))
        rc = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    else
        rc = rect;
    
    UIGraphicsBeginImageContext(rc.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rc);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
