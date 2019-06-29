//  Copyright © 2019 zscao. All rights reserved.

import Foundation
import KidsDrawingGame

public class DrawingStore {
    
    let id: String
    
    let fileName: String = "lines.dat"
    
    init(id: String) {
        self.id = id
    }
    
    func saveLines(lines: [Line]) {
        guard let baseUrl = getBaseFolder() else { return }
        
        let url = baseUrl.appendingPathComponent(fileName);
        
        #if DEBUG
        print("saving drawing lines to device...")
        print(url)
        print("line count: \(lines.count)")
        #endif
        
        var wrappers = [LineWrapper]()
        for line in lines {
            wrappers.append(LineWrapper(line: line))
        }
       
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: wrappers, requiringSecureCoding: false) else {
            print("failed to get data")
            return
        }
        
        do {
            try data.write(to: url)
            print("saved")
        }
        catch {
            print("Failed to write data to file. Error: \(error.localizedDescription)")
        }
        
    }
    
    func loadLines() -> [Line] {
        var lines = [Line]()
        
        guard let baseUrl = getBaseFolder() else { return lines }
        let url = baseUrl.appendingPathComponent(fileName)
        
        #if DEBUG
        print("loading drawing lines from device")
        print(url)
        #endif
        
        guard let data = try? Data(contentsOf: url) else { return lines }
        do {
            let wrappers = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [LineWrapper]
            if let wrappers = wrappers {
                for wrapper in wrappers {
                    lines.append(wrapper.line)
                }
            }
            return lines
            
        }
        catch{
            print("Failed to load data from device. Error: \(error.localizedDescription)")
            return lines
        }
    }
    
    func getBaseFolder() -> URL? {
        let folderName = "drawing"
        
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

