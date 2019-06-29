//  Copyright © 2019 zscao. All rights reserved.

public class MaskImageStore {
    
    let id: String
    
    init(id: String) {
        self.id = id
    }
    
    func saveMaskImage(mask: MaskImage) {
        let fileName = "mask-" + mask.rect.toString()
        guard let baseUrl = getBaseFolder() else { return }
        
        let url = baseUrl.appendingPathComponent(fileName).appendingPathExtension("png");
        
        #if DEBUG
        print("saving mask image to device...")
        print(url)
        #endif
        
        if let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) {
            CGImageDestinationAddImage(dest, mask.image, nil)
            if CGImageDestinationFinalize(dest) {
                print("saved")
            }
            else {
                print("failed")
            }
        }
    }
    
    func loadMaskImages() -> [MaskImage] {
        var images = [MaskImage]()
        
        guard let urls = getMaskImageUrls() else { return images }
        for url in urls {
            let filename = url.lastPathComponent
            guard let rect = getRectFromFilename(filename: filename) else { continue }
            
            if let dataProvider = CGDataProvider.init(url: url as CFURL), let image = CGImage.init(pngDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) {
                    if image.width == Int(rect.width) && image.height == Int(rect.height) {
                        images.append(MaskImage(image: image, rect: rect))
                    }
                }
        }
        
        return images
    }
    
    func getRectFromFilename(filename: String) -> CGRect? {
        if !filename.hasPrefix("mask-") || !filename.hasSuffix(".png") { return nil }
        
        let rectString = filename.replacingOccurrences(of: "mask-", with: "").replacingOccurrences(of: ".png", with: "")
        return CGRect.fromString(string: rectString)
    }
    
    func getMaskImageUrls() -> [URL]? {
        guard let baseUrl = getBaseFolder() else { return nil }
        
        let fileManager = FileManager.default
        do {
            let fileUrls = try fileManager.contentsOfDirectory(at: baseUrl, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
            return fileUrls
        }
        catch {
            print("Failed to read path of image files. Error: \(error.localizedDescription)")
        }
        return nil
    }
    
    func getBaseFolder() -> URL? {
        let folderName = "masks"
        
        let fileManager = FileManager.default
        let dir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let url = dir?.appendingPathComponent(self.id).appendingPathComponent(folderName) {
            if !fileManager.fileExists(atPath: url.path) {
                do {
                    try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    #if DEBUG
                    print("Failed to create folder for masks. Error: \(error.localizedDescription)")
                    #endif
                    return nil
                }
            }
            return url
        }
        return nil
    }
}

extension CGRect {
    func toString() -> String {
        return "\(self.origin.x)-\(self.origin.y)-\(self.width)-\(self.height)"
    }
    
    static func fromString(string: String) -> CGRect? {
        let rectValues = string.split(separator: "-")
        if rectValues.count != 4 { return nil }
        
        guard let x = NumberFormatter().number(from: String(rectValues[0])) else { return nil }
        guard let y = NumberFormatter().number(from: String(rectValues[1])) else { return nil }
        guard let width = NumberFormatter().number(from: String(rectValues[2])) else { return nil }
        guard let height = NumberFormatter().number(from: String(rectValues[3])) else { return nil }
        
        return CGRect(x: CGFloat(truncating: x), y: CGFloat(truncating: y), width: CGFloat(truncating: width), height: CGFloat(truncating: height))
    }
}
