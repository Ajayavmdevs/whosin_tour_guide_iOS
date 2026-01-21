import UIKit
import SDWebImage
import SkeletonView
import Alamofire

extension UIImageView {
    
    private var currentImageURL: URL? {
        return sd_imageURL
    }

    
    private func _updateSkeletonLoading(isShow: Bool = true) {
        guard isShow else {
            if sk.isSkeletonActive { hideSkeleton(transition: .crossDissolve(0.5)) }
            return
        }
        if sk.isSkeletonActive { return }
        self.isSkeletonable = true
        self.showAnimatedSkeleton(animation: { (layer) -> CAAnimation in
            let darkerColor = UIColor(hexString: "#FFFFFF").withAlphaComponent(0.01)
            let lighterColor = UIColor(hexString: "#FFFFFF").withAlphaComponent(0.06)
            let animation = CABasicAnimation(keyPath: #keyPath(CALayer.backgroundColor))
            animation.fromValue = darkerColor.cgColor
            animation.toValue = lighterColor.cgColor
            animation.duration = 1
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            animation.autoreverses = true
            animation.repeatCount = .infinity
            animation.isRemovedOnCompletion = false
            return animation
        }, transition: .crossDissolve(0.25))
    }
    
    func _loadOriginalImage(url: URL, placeholder: UIImage?, callback: ((_ success: Bool) -> Void)? = nil) {
        if callback == nil {
            self.sd_setImage(with: url,placeholderImage: placeholder, options: .lowPriority)
        } else {
            self.sd_setImage(with: url, placeholderImage: placeholder, options: .lowPriority) { image, _, _, _ in
                guard let image = image else {
                    self.image = placeholder
                    callback?(false)
                    return
                }
                self.image = image
                callback?(true)
            }
        }
    }
    
    func loadWebImageWithoutSkeleton(_ url: String, placeholder: UIImage? = nil, callback: (() -> Void)? = nil) {
        let encodeUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? kEmptyString
        guard let url = URL(string: encodeUrl) else {
            if placeholder != nil {
                image = placeholder
            }
            return
        }
       
        _loadOriginalImage(url: url, placeholder: placeholder) { success in
            callback?()
        }
    }
    
    func loadWebImage(_ url: String, placeholder: UIImage? = nil, callback: (() -> Void)? = nil) {
        var encodeUrl = url
        if let originalURL = url.removingPercentEncoding {
            encodeUrl = originalURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? kEmptyString
        }
        guard let url = URL(string: encodeUrl) else {
            if placeholder != nil {
                image = placeholder
            }
            return
        }
        if let cacheKey = SDWebImageManager.shared.cacheKey(for: url) {
            SDImageCache.shared.diskImageExists(withKey: cacheKey) { isExist in
                if !isExist { self._updateSkeletonLoading() }
                self._loadOriginalImage(url: url, placeholder: placeholder) { success in
                    if success {
                        self._updateSkeletonLoading(isShow: false)
                    }
//                    else if success == false {
//                        let modifiedURLString = url.absoluteString.replacingOccurrences(of: "-150", with: "")
//                                                                  .replacingOccurrences(of: "-600", with: "")
//                                                                  .replacingOccurrences(of: "-300", with: "")
//                        if let modifiedURL = URL(string: modifiedURLString) {
//                            self._loadOriginalImage(url: url, placeholder: placeholder) { success in
//                                if success {
//                                    self._updateSkeletonLoading(isShow: false)
//                                    return
//                                }
//                            }
//                        }
//                    }
                    callback?()
                }
            }
        }
        else {
            self._updateSkeletonLoading()
            _loadOriginalImage(url: url, placeholder: placeholder) { success in
                if success {
                    self._updateSkeletonLoading(isShow: false)
                }
                else if success == false {
                    let modifiedURLString = url.absoluteString.replacingOccurrences(of: "-150", with: "")
                                                              .replacingOccurrences(of: "-600", with: "")
                                                              .replacingOccurrences(of: "-300", with: "")
                    if let modifiedURL = URL(string: modifiedURLString) {
                        self._loadOriginalImage(url: url, placeholder: placeholder) { success in
                            if success {
                                self._updateSkeletonLoading(isShow: false)
                                return
                            }
                        }
                    }
                }
                callback?()
            }
        }
    
    }
    
    func loadWebImage(_ url: String, placeholder: UIImage? = nil, name: String = kEmptyString, backgroundColor: UIColor = ColorBrand.white.withAlphaComponent(0.70), callback: (() -> Void)? = nil) {
        print("Orignal url: \(url)")
        if url.isEmpty {
            if !Utils.stringIsNullOrEmpty(name) {
                let ipimage = IPImage(text: name, radius: Double(self.layer.cornerRadius), font: FontBrand.SFboldFont(size: 35), textColor: ColorBrand.brandDarkPurple, backgroundColor: backgroundColor)
                let img = ipimage.generateImage()
                self.image = img
            }
            return
        }
        
        let encodeUrl = url
        guard let url = URL(string: encodeUrl) else {
            if !Utils.stringIsNullOrEmpty(name) {
                let ipimage = IPImage(text: name, radius: Double(self.layer.cornerRadius), font: FontBrand.SFboldFont(size: 35), textColor: ColorBrand.brandDarkPurple, backgroundColor: backgroundColor)
                let img = ipimage.generateImage()
                self.image = img
            }
            return
        }
        
        if let cacheKey = SDWebImageManager.shared.cacheKey(for: url) {
            SDImageCache.shared.diskImageExists(withKey: cacheKey) { isExist in
                if !isExist {
                    self._updateSkeletonLoading()
                }
                self._loadOriginalImage(url: url, placeholder: placeholder) { success in
                    if success {
                        self._updateSkeletonLoading(isShow: false)
                    } else {
                        let urlWithoutResolution = self.removeResolutionFromURL(urlString: encodeUrl)
                        guard let fallbackUrl = URL(string: urlWithoutResolution) else {
                            self.setFallbackImage(name: name, backgroundColor: backgroundColor)
                            return
                        }
                        self._loadOriginalImage(url: fallbackUrl, placeholder: placeholder) { success in
                            if success {
                                self._updateSkeletonLoading(isShow: false)
                            } else {
                                self.setFallbackImage(name: name, backgroundColor: backgroundColor)
                            }
                        }
                    }
                    callback?()
                }
            }
        } else {
            self._updateSkeletonLoading()
            _loadOriginalImage(url: url, placeholder: placeholder) { success in
                if success {
                    self._updateSkeletonLoading(isShow: false)
                } else {
                    // Try to remove resolution suffix and reload
                    let urlWithoutResolution = self.removeResolutionFromURL(urlString: encodeUrl)
                    print("without resolution url: \(urlWithoutResolution)")
                    guard let fallbackUrl = URL(string: urlWithoutResolution) else {
                        self.setFallbackImage(name: name, backgroundColor: backgroundColor)
                        return
                    }
                    self._loadOriginalImage(url: fallbackUrl, placeholder: placeholder) { success in
                        if success {
                            self._updateSkeletonLoading(isShow: false)
                        } else {
                            self.setFallbackImage(name: name, backgroundColor: backgroundColor)
                        }
                    }
                }
                callback?()
            }
        }
    }

    private func setFallbackImage(name: String, backgroundColor: UIColor) {
        if !Utils.stringIsNullOrEmpty(name) {
            let ipimage = IPImage(text: name, radius: Double(self.layer.cornerRadius), font: FontBrand.SFboldFont(size: 35), textColor: ColorBrand.brandDarkPurple, backgroundColor: backgroundColor)
            let img = ipimage.generateImage()
            self.image = img
        }
    }

    private func removeResolutionFromURL(urlString: String) -> String {
        let pattern = "-(150|600)(?=\\.(jpg|jpeg|png|webp))"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(urlString.startIndex..<urlString.endIndex, in: urlString)
            let result = regex.stringByReplacingMatches(in: urlString, options: [], range: range, withTemplate: "")
            return result
        } catch {
            print("Regex error: \(error)")
            return urlString
        }
    }




        
        
//        if !Utils.isImageCached(with: url) {
//            _updateSkeletonLoading()
//        }
//        _loadOriginalImage(url: url, placeholder: placeholder) {success in
//            if !success {
//                if !Utils.stringIsNullOrEmpty(name) {
//                    let ipimage = IPImage(text: name, radius: Double(self.layer.cornerRadius), font: FontBrand.SFboldFont(size: 35), textColor: ColorBrand.brandDarkPurple, backgroundColor: backgroundColor)
//                    let img = ipimage.generateImage()
//                    self.image = img
//                }
//            } else {
//                self._updateSkeletonLoading(isShow: false)
//            }
//        }
//    }


}

