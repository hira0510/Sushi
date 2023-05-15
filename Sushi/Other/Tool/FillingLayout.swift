//
//  FillingLayout.swift
//  Sushi
//
//  Created by admin on 2023/5/11.
//

import Foundation
import UIKit

import UIKit

protocol FillingLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, sizeForViewAtIndexPath indexPath: IndexPath) -> CGSize
    func collectionView(_ collectionView: UICollectionView, sizeScale indexPath: IndexPath) -> Int
    //  Returns the amount of columns that have to display at that moment
    func numberOfColumnsInCollectionView(collectionView: UICollectionView) -> Int
}

class FillingLayout: UICollectionViewLayout {
    weak var delegate: FillingLayoutDelegate!

    fileprivate var cellPadding: CGFloat = 10

    fileprivate var cache = [UICollectionViewLayoutAttributes]()

    fileprivate var contentHeight: CGFloat = 0
    private var columsHeights: [CGFloat] = []
    private var avaiableSpaces: [(Int, CGFloat)] = []

    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    var columnsQuantity: Int {
        get {
            if(self.delegate != nil)
            {
                return (self.delegate?.numberOfColumnsInCollectionView(collectionView: self.collectionView!))!
            }
            return 0
        }
    }

    //MARK: PRIVATE METHODS
    private func shortestColumnIndex() -> Int {
        var retVal: Int = 0
        var shortestValue = MAXFLOAT

        var i = 0
        for columnHeight in columsHeights {
            //debugPrint("Column Height: \(columnHeight) index: \(i)")
            if(Float(columnHeight) < shortestValue)
            {
                shortestValue = Float(columnHeight)
                retVal = i
            }
            i += 1
        }
        //debugPrint("shortest Column index: \(retVal)")
        return retVal
    }

    //MARK: PRIVATE METHODS
    private func largestColumnIndex() -> Int {
        var retVal: Int = 0
        var largestValue: Float = 0.0

        var i = 0
        for columnHeight in columsHeights {
            //debugPrint("Column Height: \(columnHeight) index: \(i)")
            if(Float(columnHeight) > largestValue)
            {
                largestValue = Float(columnHeight)
                retVal = i
            }
            i += 1
        }
        //debugPrint("shortest Column index: \(retVal)")
        return retVal
    }

    private func canUseBigColumnOnIndex(columnIndex: Int, size: Int) -> Bool
    {
        if(columnIndex < self.columnsQuantity - (size-1))
        {
            let firstColumnHeight = columsHeights[columnIndex]
            for i in columnIndex..<columnIndex + size {
                if(firstColumnHeight != columsHeights[i]) {
                    return false
                }
            }
            return true
        }

        return false
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        // Check if cache is empty
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }

        //  Set all column heights to 0
        self.columsHeights = []
        for _ in 0..<self.columnsQuantity {
            self.columsHeights.append(0)
        }

        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {

            let indexPath = IndexPath(item: item, section: 0)

            let sizeScale: Int = delegate.collectionView(collectionView, sizeScale: indexPath)
            let block = delegate.collectionView(collectionView, sizeForViewAtIndexPath: indexPath)
            let width = block.width * CGFloat(sizeScale) + CGFloat(sizeScale - 1) * cellPadding
            let height = block.height * CGFloat(sizeScale) + CGFloat(sizeScale - 1) * cellPadding

            var columIndex = self.shortestColumnIndex()
            var xOffset = (contentWidth / CGFloat(columnsQuantity)) * CGFloat(columIndex)
            var yOffset = self.columsHeights[columIndex]

            if(sizeScale > 1) { //Big Cell
                if(!self.canUseBigColumnOnIndex(columnIndex: columIndex, size: sizeScale)) {
                    //  Set column height
                    for i in columIndex..<columIndex + sizeScale {
                        if(i < columnsQuantity) {
                            self.avaiableSpaces.append((i, yOffset))
                            self.columsHeights[i] += block.height
                        }
                    }
                    //  Set column height
                    yOffset = columsHeights[largestColumnIndex()]
                    xOffset = 0
                    columIndex = 0
                }

                for i in columIndex..<columIndex + sizeScale {
                    if(i < columnsQuantity) {
                        //current height
                        let currValue = self.columsHeights[i]
                        //new column height with the update
                        let newValue = yOffset + height
                        //space that will remaing in blank, this must be 0 if its ok
                        let remainder = (newValue - currValue) - CGFloat(sizeScale) * block.width
                        if(remainder > 0) {
                            debugPrint("Its bigger remainder is \(remainder)")
                            //number of spaces to fill
                            let spacesTofillInColumn = Int(remainder / block.width)
                            //we need to add those spaces as avaiableSpaces
                            for j in 0..<spacesTofillInColumn {
                                self.avaiableSpaces.append((i, currValue + (CGFloat(j) * block.width)))
                            }
                        }
                        self.columsHeights[i] = yOffset + height
                    }
                }
            } else {
                //if there is not avaiable space
                if(self.avaiableSpaces.count == 0)
                {
                    //  Set column height
                    self.columsHeights[columIndex] += height
                } else { //if there is some avaiable space
                    yOffset = self.avaiableSpaces.first!.1
                    xOffset = CGFloat(self.avaiableSpaces.first!.0) * width
                    self.avaiableSpaces.remove(at: 0)
                }
            }

            print("🤢\(width)/\(height)")

            let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
