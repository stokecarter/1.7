//
//  UIImageExtension.swift
//  WashApp
//
//  Created by Saurabh Shukla on 19/09/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//


import Foundation
import UIKit
import QuartzCore
import CoreGraphics
import Accelerate
import SDWebImage
import ImageIO

// MARK:- UIIMAGEVIEW
//=====================
extension UIImageView {
    
//    func setImage_kf(imageString: String, placeHolderImage: UIImage) {
//        setImageWithIndicator(with: URL(string: imageString), placeholderImage: placeHolderImage)
//    }
    
    func setImageWithIndicator(with url: URL?, placeholderImage: UIImage? = nil) {
        // Set image if the url passed is the valid one, else set placeholder image
        if let unwrappedUrl = url {
            self.sd_setImage(with: unwrappedUrl, placeholderImage: placeholderImage)
        }else{
            self.image = placeholderImage
        }
    }
}

extension UIImage{
    
    enum UIImageContentMode {
        case scaleToFill, scaleAspectFit, scaleAspectFill
    }
    
    ///Returns the image by fixing the orientation
    var imageByfixingOrientation:UIImage{
        
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch self.imageOrientation {
        case .up,.downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case .left,.leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
        case .right,.rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi/2))
        default:
            break
        }
        switch self.imageOrientation {
        case .upMirrored,.downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored,.rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up,.down,.left,.right:
            break
        }
        let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!
        ctx.concatenate(transform)
        switch self.imageOrientation {
        case .left,.leftMirrored,.right,.rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        let cgimg: CGImage = ctx.makeImage()!
        let img: UIImage = UIImage(cgImage: cgimg)
        return img
    }
    
    ///Rotates the image by the given angle and returns updated image
    func rotateBy(angleDegree:Float) -> UIImage {
        
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let angleRadians: CGFloat = CGFloat(angleDegree * Float((Double.pi / 180.0)))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: angleRadians)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        bitmap.rotate(by: angleRadians)
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    ///Saves the image into the given directory and retruns the path
    func saveAs(fileName path:NSString, directory:FileManager.SearchPathDirectory = FileManager.SearchPathDirectory.documentDirectory) -> String{
        
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(directory, nsUserDomainMask, true)
        
        if paths.count > 0 {
            
            let dirPath = paths[0]
            let writePath = (dirPath as NSString).appendingPathComponent("\(path).png")
            try? self.pngData()!.write(to: URL(fileURLWithPath: writePath), options: [.atomic])
            return writePath
        }
        return ""
    }
    
    
    // MARK: Image from solid color
    /**
     Creates a new solid color image.
     
     - Parameter color: The color to fill the image with.
     - Parameter size: Image size (defaults: 10x10)
     
     - Returns A new image
     */
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 10, height: 10)) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        self.init(cgImage:(UIGraphicsGetImageFromCurrentImageContext()?.cgImage!)!)
        UIGraphicsEndImageContext()
    }
    
    // MARK: Image from gradient colors
    /**
     Creates a gradient color image.
     
     - Parameter gradientColors: An array of colors to use for the gradient.
     - Parameter size: Image size (defaults: 10x10)
     
     - Returns A new image
     */
    convenience init?(gradientColors:[UIColor], size:CGSize = CGSize(width: 10, height: 10), locations: [Float] = [] )
    {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = gradientColors.map {(color: UIColor) -> AnyObject? in return color.cgColor as AnyObject? } as NSArray
        let gradient: CGGradient
        if locations.count > 0 {
            let cgLocations = locations.map { CGFloat($0) }
            gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: cgLocations)!
        } else {
            gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil)!
        }
        context!.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: size.height), options: CGGradientDrawingOptions(rawValue: 0))
        self.init(cgImage:(UIGraphicsGetImageFromCurrentImageContext()?.cgImage!)!)
        UIGraphicsEndImageContext()
    }
    
    /**
     Applies gradient color overlay to an image.
     - Parameter gradientColors: An array of colors to use for the gradient.
     - Parameter locations: An array of locations to use for the gradient.
     - Parameter blendMode: The blending type to use.
     - Returns A new image
     */
    func apply(gradientColors: [UIColor], locations: [Float] = [], blendMode: CGBlendMode = CGBlendMode.normal) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(blendMode)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        context?.draw(self.cgImage!, in: rect)
        // Create gradient
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = gradientColors.map {(color: UIColor) -> AnyObject? in return color.cgColor as AnyObject? } as NSArray
        let gradient: CGGradient
        if locations.count > 0 {
            let cgLocations = locations.map { CGFloat($0) }
            gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: cgLocations)!
        } else {
            gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil)!
        }
        // Apply gradient
        context?.clip(to: rect, mask: self.cgImage!)
        context?.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: size.height), options: CGGradientDrawingOptions(rawValue: 0))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return image!;
    }
    
    // MARK: Image with Text
    /**
     Creates a text label image.
     - Parameter text: The text to use in the label.
     - Parameter font: The font (default: System font of size 18)
     - Parameter color: The text color (default: White)
     - Parameter backgroundColor: The background color (default:Gray).
     - Parameter size: Image size (default: 10x10)
     - Parameter offset: Center offset (default: 0x0)
     
     - Returns A new image
     */
    convenience init?(text: String, font: UIFont = UIFont.systemFont(ofSize: 18), color: UIColor = UIColor.white, backgroundColor: UIColor = UIColor.gray, size: CGSize = CGSize(width: 100, height: 100), offset: CGPoint = CGPoint(x: 0, y: 0)) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        label.font = font
        label.text = text
        label.textColor = color
        label.textAlignment = .center
        label.backgroundColor = backgroundColor
        
        let image = UIImage(fromView: label)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        self.init(cgImage:(UIGraphicsGetImageFromCurrentImageContext()?.cgImage!)!)
        UIGraphicsEndImageContext()
    }
    
    // MARK: Image from UIView
    /**
     Creates an image from a UIView.
     
     - Parameter fromView: The source view.
     
     - Returns A new image
     */
    convenience init?(fromView view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        //view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        self.init(cgImage:(UIGraphicsGetImageFromCurrentImageContext()?.cgImage!)!)
        UIGraphicsEndImageContext()
    }
    
    /**
     Creates a radial gradient.
     
     - Parameter startColor: The start color
     - Parameter endColor: The end color
     - Parameter radialGradientCenter: The gradient center (default:0.5,0.5).
     - Parameter radius: Radius size (default: 0.5)
     - Parameter size: Image size (default: 100x100)
     
     - Returns A new image
     */
    convenience init?(startColor: UIColor, endColor: UIColor, radialGradientCenter: CGPoint = CGPoint(x: 0.5, y: 0.5), radius: Float = 0.5, size: CGSize = CGSize(width: 100, height: 100)) {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        
        let num_locations: Int = 2
        let locations: [CGFloat] = [0.0, 1.0] as [CGFloat]
        
        let startComponents = startColor.cgColor.components!
        let endComponents = endColor.cgColor.components!
        
        let components: [CGFloat] = [startComponents[0], startComponents[1], startComponents[2], startComponents[3], endComponents[0], endComponents[1], endComponents[2], endComponents[3]]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: num_locations)
        
        // Normalize the 0-1 ranged inputs to the width of the image
        let aCenter = CGPoint(x: radialGradientCenter.x * size.width, y: radialGradientCenter.y * size.height)
        let aRadius = CGFloat(min(size.width, size.height)) * CGFloat(radius)
        
        // Draw it
        UIGraphicsGetCurrentContext()?.drawRadialGradient(gradient!, startCenter: aCenter, startRadius: 0, endCenter: aCenter, endRadius: aRadius, options: CGGradientDrawingOptions.drawsAfterEndLocation)
        self.init(cgImage:(UIGraphicsGetImageFromCurrentImageContext()?.cgImage!)!)
        
        // Clean up
        UIGraphicsEndImageContext()
    }
    
    // MARK: Alpha
    /**
     Returns true if the image has an alpha layer.
     */
    var hasAlpha: Bool {
        let alpha: CGImageAlphaInfo = self.cgImage!.alphaInfo
        switch alpha {
        case .first, .last, .premultipliedFirst, .premultipliedLast:
            return true
        default:
            return false
        }
    }
    
    /**
     Returns a copy of the given image, adding an alpha channel if it doesn't already have one.
     */
    func applyAlpha() -> UIImage? {
        
        if hasAlpha {
            return self
        }
        
        let imageRef = self.cgImage;
        let width = imageRef?.width;
        let height = imageRef?.height;
        let colorSpace = imageRef?.colorSpace
        
        // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo().rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let offscreenContext = CGContext(data: nil, width: width!, height: height!, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace!, bitmapInfo: bitmapInfo.rawValue)
        
        // Draw the image into the context and retrieve the new image, which will now have an alpha layer
        let rect: CGRect = CGRect(x: 0, y: 0, width: CGFloat(width!), height: CGFloat(height!))
        offscreenContext?.draw(imageRef!, in: rect)
        let imageWithAlpha = UIImage(cgImage: (offscreenContext?.makeImage()!)!)
        return imageWithAlpha
    }
    
    /**
     Returns a copy of the image with a transparent border of the given size added around its edges. i.e. For rotating an image without getting jagged edges.
     
     - Parameter padding: The padding amount.
     
     - Returns A new image.
     */
    func apply(padding: CGFloat) -> UIImage? {
        // If the image does not have an alpha layer, add one
        let image = self.applyAlpha()
        if image == nil {
            return nil
        }
        let rect = CGRect(x: 0, y: 0, width: size.width + padding * 2, height: size.height + padding * 2)
        
        // Build a context that's the same dimensions as the new size
        let colorSpace = self.cgImage?.colorSpace
        let bitmapInfo = self.cgImage?.bitmapInfo
        let bitsPerComponent = self.cgImage?.bitsPerComponent
        let context = CGContext(data: nil, width: Int(rect.size.width), height: Int(rect.size.height), bitsPerComponent: bitsPerComponent!, bytesPerRow: 0, space: colorSpace!, bitmapInfo: (bitmapInfo?.rawValue)!)
        
        // Draw the image in the center of the context, leaving a gap around the edges
        let imageLocation = CGRect(x: padding, y: padding, width: image!.size.width, height: image!.size.height)
        context?.draw(self.cgImage!, in: imageLocation)
        
        // Create a mask to make the border transparent, and combine it with the image
        let transparentImage = UIImage(cgImage: (context?.makeImage()?.masking(imageRef(withPadding: padding, size: rect.size))!)!)
        return transparentImage
    }
    
    /**
     Creates a mask that makes the outer edges transparent and everything else opaque. The size must include the entire mask (opaque part + transparent border).
     
     - Parameter padding: The padding amount.
     - Parameter size: The size of the image.
     
     - Returns A Core Graphics Image Ref
     */
    fileprivate func imageRef(withPadding padding: CGFloat, size: CGSize) -> CGImage {
        // Build a context that's the same dimensions as the new size
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo().rawValue | CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        // Start with a mask that's entirely transparent
        context?.setFillColor(UIColor.black.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // Make the inner part (within the border) opaque
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(CGRect(x: padding, y: padding, width: size.width - padding * 2, height: size.height - padding * 2))
        
        // Get an image of the context
        let maskImageRef = context?.makeImage()
        return maskImageRef!
    }
    
    
    // MARK: Crop
    
    /**
     Creates a cropped copy of an image.
     
     - Parameter bounds: The bounds of the rectangle inside the image.
     
     - Returns A new image
     */
    func crop(bounds: CGRect) -> UIImage? {
        return UIImage(cgImage: (self.cgImage?.cropping(to: bounds)!)!,
                       scale: 0.0, orientation: self.imageOrientation)
    }
    
    func cropToSquare() -> UIImage? {
        let size = CGSize(width: self.size.width * self.scale, height: self.size.height * self.scale)
        let shortest = min(size.width, size.height)
        
        let left: CGFloat = (size.width > shortest) ? (size.width - shortest) / 2 : 0
        let top: CGFloat = (size.height > shortest) ? (size.height - shortest) / 2 : 0
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let insetRect = rect.insetBy(dx: left, dy: top)
        
        return crop(bounds: insetRect)
    }
    
    // MARK: Resize
    
    /**
     Creates a resized copy of an image.
     
     - Parameter size: The new size of the image.
     - Parameter contentMode: The way to handle the content in the new size.
     
     - Returns A new image
     */
    func resize(toSize: CGSize, contentMode: UIImageContentMode = .scaleToFill) -> UIImage? {
        let horizontalRatio = size.width / self.size.width;
        let verticalRatio = size.height / self.size.height;
        var ratio: CGFloat!
        
        switch contentMode {
        case .scaleToFill:
            ratio = 1
        case .scaleAspectFill:
            ratio = max(horizontalRatio, verticalRatio)
        case .scaleAspectFit:
            ratio = min(horizontalRatio, verticalRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: size.width * ratio, height: size.height * ratio)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(rect.size.width), height: Int(rect.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        let transform = CGAffineTransform.identity
        
        // Rotate and/or flip the image if required by its orientation
        context?.concatenate(transform);
        
        // Set the quality level to use when rescaling
        context!.interpolationQuality = CGInterpolationQuality(rawValue: 3)!
        
        //CGContextSetInterpolationQuality(context, CGInterpolationQuality(kCGInterpolationHigh.value))
        
        // Draw into the context; this scales the image
        context?.draw(self.cgImage!, in: rect)
        
        // Get the resized image from the context and a UIImage
        let newImage = UIImage(cgImage: (context?.makeImage()!)!, scale: self.scale, orientation: self.imageOrientation)
        return newImage;
    }
    
    
    // MARK: Corner Radius
    
    /**
     Creates a new image with rounded corners.
     
     - Parameter cornerRadius: The corner radius.
     
     - Returns A new image
     */
    func roundCorners(cornerRadius: CGFloat) -> UIImage? {
        // If the image does not have an alpha layer, add one
        let imageWithAlpha = applyAlpha()
        if imageWithAlpha == nil {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let width = imageWithAlpha?.cgImage?.width
        let height = imageWithAlpha?.cgImage?.height
        let bits = imageWithAlpha?.cgImage?.bitsPerComponent
        let colorSpace = imageWithAlpha?.cgImage?.colorSpace
        let bitmapInfo = imageWithAlpha?.cgImage?.bitmapInfo
        let context = CGContext(data: nil, width: width!, height: height!, bitsPerComponent: bits!, bytesPerRow: 0, space: colorSpace!, bitmapInfo: (bitmapInfo?.rawValue)!)
        let rect = CGRect(x: 0, y: 0, width: CGFloat(width!)*scale, height: CGFloat(height!)*scale)
        
        context?.beginPath()
        if (cornerRadius == 0) {
            context?.addRect(rect)
        } else {
            context?.saveGState()
            context?.translateBy(x: rect.minX, y: rect.minY)
            context?.scaleBy(x: cornerRadius, y: cornerRadius)
            let fw = rect.size.width / cornerRadius
            let fh = rect.size.height / cornerRadius
            context?.move(to: CGPoint(x: fw, y: fh/2))
            context?.addArc(tangent1End: CGPoint(x: fw, y: fh), tangent2End: CGPoint(x: fw/2, y: fh), radius: 1)
            context?.addArc(tangent1End: CGPoint(x: 0, y: fh), tangent2End: CGPoint(x: 0, y: fh/2), radius: 1)
            context?.addArc(tangent1End: CGPoint(x: 0, y: 0), tangent2End: CGPoint(x: fw/2, y: 0), radius: 1)
            context?.addArc(tangent1End: CGPoint(x: fw, y: 0), tangent2End: CGPoint(x: fw, y: fh/2), radius: 1)
            context?.restoreGState()
        }
        context?.closePath()
        context?.clip()
        
        context?.draw(imageWithAlpha!.cgImage!, in: rect)
        let image = UIImage(cgImage: (context?.makeImage()!)!, scale:scale, orientation: .up)
        UIGraphicsEndImageContext()
        return image
    }
    
    /**
     Creates a new image with rounded corners and border.
     
     - Parameter cornerRadius: The corner radius.
     - Parameter border: The size of the border.
     - Parameter color: The color of the border.
     
     - Returns A new image
     */
    func roundCorners(cornerRadius: CGFloat, border: CGFloat, color: UIColor) -> UIImage? {
        return roundCorners(cornerRadius: cornerRadius)?.apply(border: border, color: color)
    }
    
    /**
     Creates a new circle image.
     
     - Returns A new image
     */
    func roundCornersToCircle() -> UIImage? {
        let shortest = min(size.width, size.height)
        return cropToSquare()?.roundCorners(cornerRadius: shortest/2)
    }
    
    /**
     Creates a new circle image with a border.
     
     - Parameter border :CGFloat The size of the border.
     - Parameter color :UIColor The color of the border.
     
     - Returns UIImage?
     */
    func roundCornersToCircle(withBorder border: CGFloat, color: UIColor) -> UIImage? {
        let shortest = min(size.width, size.height)
        return cropToSquare()?.roundCorners(cornerRadius: shortest/2, border: border, color: color)
    }
    
    // MARK: Border
    
    /**
     Creates a new image with a border.
     
     - Parameter border: The size of the border.
     - Parameter color: The color of the border.
     
     - Returns A new image
     */
    func apply(border: CGFloat, color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let width = self.cgImage?.width
        let height = self.cgImage?.height
        let bits = self.cgImage?.bitsPerComponent
        let colorSpace = self.cgImage?.colorSpace
        let bitmapInfo = self.cgImage?.bitmapInfo
        let context = CGContext(data: nil, width: width!, height: height!, bitsPerComponent: bits!, bytesPerRow: 0, space: colorSpace!, bitmapInfo: (bitmapInfo?.rawValue)!)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: alpha)
        context?.setLineWidth(border)
        
        let rect = CGRect(x: 0, y: 0, width: size.width*scale, height: size.height*scale)
        let inset = rect.insetBy(dx: border*scale, dy: border*scale)
        
        context?.strokeEllipse(in: inset)
        context?.draw(self.cgImage!, in: inset)
        
        let image = UIImage(cgImage: (context?.makeImage()!)!)
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: Image Effects
    
    /**
     Applies a light blur effect to the image
     
     - Returns New image or nil
     */
//    func applyLightEffect() -> UIImage? {
//        return applyBlur(withRadius: 30, tintColor: UIColor(white: 1.0, alpha: 0.3), saturationDeltaFactor: 1.8)
//    }
//
//    /**
//     Applies a extra light blur effect to the image
//
//     - Returns New image or nil
//     */
//    func applyExtraLightEffect() -> UIImage? {
//        return applyBlur(withRadius: 20, tintColor: UIColor(white: 0.97, alpha: 0.82), saturationDeltaFactor: 1.8)
//    }
//
//    /**
//     Applies a dark blur effect to the image
//
//     - Returns New image or nil
//     */
//    func applyDarkEffect() -> UIImage? {
//        return applyBlur(withRadius: 20, tintColor: UIColor(white: 0.11, alpha: 0.73), saturationDeltaFactor: 1.8)
//    }
    
    /**
     Applies a color tint to an image
     
     - Parameter color: The tint color
     
     - Returns New image or nil
     */
//    func applyTintEffect(tintColor: UIColor) -> UIImage? {
//        let effectColorAlpha: CGFloat = 0.6
//        var effectColor = tintColor
//        let componentCount = tintColor.cgColor.numberOfComponents
//        if componentCount == 2 {
//            var b: CGFloat = 0
//            if tintColor.getWhite(&b, alpha: nil) {
//                effectColor = UIColor(white: b, alpha: effectColorAlpha)
//            }
//        } else {
//            var red: CGFloat = 0
//            var green: CGFloat = 0
//            var blue: CGFloat = 0
//            
//            if tintColor.getRed(&red, green: &green, blue: &blue, alpha: nil) {
//                effectColor = UIColor(red: red, green: green, blue: blue, alpha: effectColorAlpha)
//            }
//        }
//        return applyBlur(withRadius: 10, tintColor: effectColor, saturationDeltaFactor: -1.0)
//    }
    
    /**
     Applies a blur to an image based on the specified radius, tint color saturation and mask image
     
     - Parameter blurRadius: The radius of the blur.
     - Parameter tintColor: The optional tint color.
     - Parameter saturationDeltaFactor: The detla for saturation.
     - Parameter maskImage: The optional image for masking.
     
     - Returns New image or nil
     */
//    func applyBlur(withRadius blurRadius: CGFloat, tintColor: UIColor?, saturationDeltaFactor: CGFloat, maskImage: UIImage? = nil) -> UIImage? {
//        
//        guard size.width > 0 && size.height > 0 && cgImage != nil else {
//            return nil
//        }
//        if maskImage != nil {
//            guard maskImage?.cgImage != nil else {
//                return nil
//            }
//        }
//        let imageRect = CGRect(origin: CGPoint.zero, size: size)
//        var effectImage = self
//        let hasBlur = blurRadius > CGFloat(Float.ulpOfOne)
//        let hasSaturationChange = fabs(saturationDeltaFactor - 1.0) > CGFloat(Float.ulpOfOne)
//        if (hasBlur || hasSaturationChange) {
//            
//            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
//            let effectInContext = UIGraphicsGetCurrentContext()
//            effectInContext?.scaleBy(x: 1.0, y: -1.0)
//            effectInContext?.translateBy(x: 0, y: -size.height)
//            effectInContext?.draw(cgImage!, in: imageRect)
//            
//            var effectInBuffer = vImage_Buffer(
//                data: effectInContext?.data,
//                height: UInt((effectInContext?.height)!),
//                width: UInt((effectInContext?.width)!),
//                rowBytes: (effectInContext?.bytesPerRow)!)
//            
//            UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
//            let effectOutContext = UIGraphicsGetCurrentContext()
//            
//            var effectOutBuffer = vImage_Buffer(
//                data: effectOutContext?.data,
//                height: UInt((effectOutContext?.height)!),
//                width: UInt((effectOutContext?.width)!),
//                rowBytes: (effectOutContext?.bytesPerRow)!)
//            
//            if hasBlur {
//                let inputRadius = blurRadius * UIScreen.main.scale
//                let sqrtPi: CGFloat = CGFloat(sqrt(Double.pi * 2.0))
//                var radius = UInt32(floor(inputRadius * 3.0 * sqrtPi / 4.0 + 0.5))
//                if radius % 2 != 1 {
//                    radius += 1 // force radius to be odd so that the three box-blur methodology works.
//                }
//                let imageEdgeExtendFlags = vImage_Flags(kvImageEdgeExtend)
//                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
//                vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
//                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
//            }
//            
//            var effectImageBuffersAreSwapped = false
//            
//            if hasSaturationChange {
//                let s: CGFloat = saturationDeltaFactor
//                let floatingPointSaturationMatrix: [CGFloat] = [
//                    0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
//                    0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
//                    0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
//                    0,                    0,                    0,  1
//                ]
//                
//                let divisor: CGFloat = 256
//                let matrixSize = floatingPointSaturationMatrix.count
//                var saturationMatrix = [Int16](repeating: 0, count: matrixSize)
//                
//                for i: Int in 0 ..< matrixSize {
//                    saturationMatrix[i] = Int16(round(floatingPointSaturationMatrix[i] * divisor))
//                }
//                
//                if hasBlur {
//                    vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, Int32(divisor), nil, nil, vImage_Flags(kvImageNoFlags))
//                    effectImageBuffersAreSwapped = true
//                } else {
//                    vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, Int32(divisor), nil, nil, vImage_Flags(kvImageNoFlags))
//                }
//            }
//            
//            if !effectImageBuffersAreSwapped {
//                effectImage = UIGraphicsGetImageFromCurrentImageContext()!
//            }
//            
//            UIGraphicsEndImageContext()
//            
//            if effectImageBuffersAreSwapped {
//                effectImage = UIGraphicsGetImageFromCurrentImageContext()!
//            }
//            
//            UIGraphicsEndImageContext()
//        }
//        
//        // Set up output context.
//        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
//        let outputContext = UIGraphicsGetCurrentContext()
//        outputContext?.scaleBy(x: 1.0, y: -1.0)
//        outputContext?.translateBy(x: 0, y: -size.height)
//        
//        // Draw base image.
//        outputContext?.draw(self.cgImage!, in: imageRect)
//        
//        // Draw effect image.
//        if hasBlur {
//            outputContext?.saveGState()
//            if let image = maskImage {
//                outputContext?.clip(to: imageRect, mask: image.cgImage!);
//            }
//            outputContext?.draw(effectImage.cgImage!, in: imageRect)
//            outputContext?.restoreGState()
//        }
//        
//        // Add in color tint.
//        if let color = tintColor {
//            outputContext?.saveGState()
//            outputContext?.setFillColor(color.cgColor)
//            outputContext?.fill(imageRect)
//            outputContext?.restoreGState()
//        }
//        
//        // Output image is ready.
//        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return outputImage
//        
//    }
}

extension UIImageView{
    
    var makeItScaleAndFit:UIImage?{
        if let i = self.image{
            self.contentMode = .scaleAspectFill
            return i.scalePreservingAspectRatio(targetSize: self.size)
        }else{
            return nil
        }
    }
    
}


extension UIImage {
    
    
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
    
    
    
    
    
    public class func gifImageWithData(data: NSData) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data, nil) else {
            printDebug("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source: source)
    }
    
    public class func gifImageWithURL(gifUrl:String) -> UIImage? {
        guard let bundleURL = NSURL(string: gifUrl)
            else {
                printDebug("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = NSData(contentsOf: bundleURL as URL) else {
            printDebug("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(data: imageData)
    }
    
    public class func gifImageWithName(name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                printDebug("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        
        guard let imageData = NSData(contentsOf: bundleURL) else {
            printDebug("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(data: imageData)
    }
    
    class func delayForImageAtIndex(index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(CFDictionaryGetValue(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()), to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()), to: AnyObject.self)
        
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a! < b! {
            let c = a!
            a = b!
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b!
                b = rest
            }
        }
    }
    
    class func gcdForArray(array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(a: val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(index: Int(i), source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(array: delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames, duration: Double(duration) / 1000.0)
        
        return animation
    }
}

