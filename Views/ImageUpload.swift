//
//  ImageUpload.swift
//  MyAccess
//
//  Created by Manisha Basnet on 11/27/24.
//

import FirebaseStorage
import UIKit

struct ImageUploader {
    static func uploadImage(image: UIImage, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("Error: Could not convert UIImage to JPEG data.")
            return
        }
        let fileName = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_images/\(fileName)")
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error: Failed to upload image - \(error.localizedDescription)")
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    print("Error: Failed to retrieve download URL - \(error.localizedDescription)")
                    return
                }
                guard let imageURL = url?.absoluteString else {
                    print("Error: Download URL is nil.")
                    return
                }
                print("Success: Image uploaded with URL - \(imageURL)")
                completion(imageURL)
            }
        }
    }
    
    
    static func uploadMultipleImages(images: [UIImage], completion: @escaping ([String]) -> Void) {
        // Create a dispatch group to handle multiple image uploads
        let dispatchGroup = DispatchGroup()
        var uploadedImageURLs: [String] = []
        
        for image in images {
            // Enter the dispatch group for each image upload
            dispatchGroup.enter()
            
            guard let imageData = image.jpegData(compressionQuality: 0.75) else {
                print("Error: Could not convert UIImage to JPEG data.")
                dispatchGroup.leave()
                continue
            }
            
            let fileName = NSUUID().uuidString
            let ref = Storage.storage().reference(withPath: "/place_images/\(fileName)")
            
            ref.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error: Failed to upload image - \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }
                
                ref.downloadURL { url, error in
                    if let error = error {
                        print("Error: Failed to retrieve download URL - \(error.localizedDescription)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    guard let imageURL = url?.absoluteString else {
                        print("Error: Download URL is nil.")
                        dispatchGroup.leave()
                        return
                    }
                    
                    print("Success: Image uploaded with URL - \(imageURL)")
                    uploadedImageURLs.append(imageURL)
                    dispatchGroup.leave()
                }
            }
        }
        
        // Notify when all uploads are complete
        dispatchGroup.notify(queue: .main) {
            completion(uploadedImageURLs)
        }
    }
}

