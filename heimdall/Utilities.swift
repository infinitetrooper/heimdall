import UIKit

extension UIImage {
    func averageColor(for segment: CGRect) -> UIColor? {
        // Ensure the segment is within the image bounds
        guard let inputCGImage = self.cgImage,
              let croppedCGImage = inputCGImage.cropping(to: segment) else { return nil }

        let context = CIContext(options: nil)
        let inputCroppedCIImage = CIImage(cgImage: croppedCGImage)
        let extent = inputCroppedCIImage.extent
        let output = context.createCGImage(inputCroppedCIImage, from: extent)

        let bitmap = UnsafeMutablePointer<UInt8>.allocate(capacity: 4)
        defer { bitmap.deallocate() }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: bitmap, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }

        context.draw(output!, in: CGRect(x: 0, y: 0, width: 1, height: 1))

        let red = CGFloat(bitmap[0]) / 255.0
        let green = CGFloat(bitmap[1]) / 255.0
        let blue = CGFloat(bitmap[2]) / 255.0
        let alpha = CGFloat(bitmap[3]) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

func getSegmentedColors(from image: UIImage) -> [UIColor] {
    let imageSize = image.size
    let segmentSize = CGSize(width: imageSize.width, height: imageSize.height / 8)

    var colors: [UIColor] = []

    for i in 0..<8 {
        let segmentOrigin = CGPoint(x: 0, y: CGFloat(i) * segmentSize.height)
        let segmentRect = CGRect(origin: segmentOrigin, size: segmentSize)
        
        if let averageColor = image.averageColor(for: segmentRect) {
            colors.append(averageColor)
        }
    }

    return colors
}

extension UIColor {
    func colorTemperature() -> Float {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Simple metric: higher red and lower blue indicate warmth
        return Float(red - blue)
    }
}


func mapColorToNote(_ color: UIColor) -> Float {
    let temperature = color.colorTemperature()
    let index = max(0, min(noteFrequencies.count - 1, Int(temperature * Float(noteFrequencies.count))))
    return Float(noteFrequencies[index])
}

