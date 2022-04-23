//
//  ColumnFlowLayout.swift
//  ImportExportIOSApp
//
//  Created by Usama on 7/4/20.
//  Copyright © 2020 Usama. All rights reserved.
//

import UIKit

class ColumnFlowLayout: UICollectionViewFlowLayout {
    let cellsPerRow: Int

    init(cellsPerRow: Int, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero) {
        self.cellsPerRow = cellsPerRow
        super.init()

        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }
        if #available(iOS 11.0, *) {
            let marginsAndInsets = sectionInset.left + sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
            let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
            print(UIScreen.main.nativeBounds.height)
            if screenType == .iPhones_5_5s_5c_SE || screenType == .iPhones_4_4S || screenType == .iPhones_6_6s_7_8{

                itemSize = CGSize(width: itemWidth, height: 150)

            }else{
                itemSize = CGSize(width: itemWidth, height: itemWidth+5)

            }
        } else {
            // Fallback on earlier versions
        }
        
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
    
    enum ScreenType: String {
           case iPhones_4_4S = "iPhone 4 or iPhone 4S"
           case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
           case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
           case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
           case iPhones_X_XS = "iPhone X or iPhone XS"
           case iPhone_XR = "iPhone XR"
           case iPhone_XSMax = "iPhone XS Max"
           case unknown
       }

       var screenType: ScreenType {
           switch UIScreen.main.nativeBounds.height {
           case 960:
               return .iPhones_4_4S
           case 1136:
               return .iPhones_5_5s_5c_SE
           case 1334:
               return .iPhones_6_6s_7_8
           case 1792:
               return .iPhone_XR
           case 1920, 2208:
               return .iPhones_6Plus_6sPlus_7Plus_8Plus
           case 2436:
               return .iPhones_X_XS
           case 2688:
               return .iPhone_XSMax
           default:
               return .unknown
           }
       }
}
