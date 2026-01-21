import UIKit



class HorizontalPagingFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
            super.prepare()
            
            guard let collectionView = collectionView else { return }
            
            let availableWidth = collectionView.bounds.width
            let itemWidth = availableWidth * 0.93 // Adjust the item width to leave space for neighboring cells
            itemSize = CGSize(width: availableWidth, height: collectionView.bounds.height)
            scrollDirection = .horizontal
            minimumLineSpacing = 10 // Adjust spacing between cells
            
            // No section inset in the prepare method
        }
        
        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            let attributes = super.layoutAttributesForElements(in: rect)
            return attributes?.map { attribute in
                let frame = attribute.frame
                if attribute.indexPath.row == 0 {
                    attribute.frame = CGRect(x: 0, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
                }
                return attribute
            }
        }
        
        override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
            guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
            
            let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height)
            let layoutAttributes = super.layoutAttributesForElements(in: targetRect) ?? []
            
            let horizontalCenter = proposedContentOffset.x + collectionView.bounds.width / 2
            let closestAttribute = layoutAttributes.min(by: { abs($0.center.x - horizontalCenter) < abs($1.center.x - horizontalCenter) })
            
            guard let closest = closestAttribute else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
            
            let proposedContentOffsetX: CGFloat
            if closest.indexPath.row == 0 {
                proposedContentOffsetX = closest.frame.origin.x - 10
            } else {
                proposedContentOffsetX = closest.center.x - collectionView.bounds.width / 2
            }
            
            return CGPoint(x: proposedContentOffsetX, y: proposedContentOffset.y)
        }
}

