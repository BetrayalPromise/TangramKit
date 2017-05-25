//
//  TGFloatLayout.swift
//  TangramKit
//
//  Created by apple on 16/4/26.
//  Copyright © 2016年 youngsoft. All rights reserved.
//

import UIKit

extension UIView
{
    /**
     *是否反方向浮动，默认是false表示正向浮动，正向浮动和反向浮动的意义根据所在的父浮动布局视图的方向的不同而不同：
     1.如果父视图是垂直浮动布局则默认正向浮动是向左浮动的，而反向浮动则是向右浮动。
     2.如果父视图是水平浮动布局则默认正向浮动是向上浮动的，而反向浮动则是向下浮动。
     
     下面是垂直浮动布局中的正向浮动和反向浮动的效果图(正向浮动:A,B,D; 反向浮动:C,E,F)：
     
     |<--A-- <---B---    -C->|
     |<-----D---- -F-> --E-->|
     
     
     下面是水平浮动布局中的正向浮动和反向浮动的效果图(正向浮动:A,B,D; 反向浮动:C,E,F):
     
     -----------
     ↑   ↑
     |   |
     A   |
     |   D
     |
     ↑   |
     B
     |   F
     ↓
     |   |
     C   E
     ↓   ↓
     ------------
     
     */
    public var tg_reverseFloat:Bool
        {
        get
        {
            return self.tgCurrentSizeClass.tg_reverseFloat
        }
        set
        {
            let sc = self.tgCurrentSizeClass
            if sc.tg_reverseFloat != newValue
            {
                
                sc.tg_reverseFloat = newValue
                if let sView = self.superview
                {
                    sView.setNeedsLayout()
                }
            }
        }
    }
    
    /**
     *清除浮动，默认是false。这个属性的意义也跟父浮动布局视图的方向相关。如果设置为了清除浮动属性则表示本视图不会在浮动方向上紧跟在前一个浮动视图的后面，而是会另外新起一行或者一列来重新排列。tg_reverseFloat和tg_clearFloat这两个属性的定义是完全参考CSS样式表中浮动布局中的float和clear这两个属性。
     
     
     垂直浮动布局下的浮动和清除浮动
     
     |<--A-- <---B--- <-C--|
     |<----D---            |
     |<--E-- <---F--       |
     |<-----G----          |
     |      ---I---> --H-->|
     |                -J-> |
     
     A(正向浮动);B(正向浮动);C(正向浮动);D(正向浮动);E(正向浮动);F(正向浮动);G(正向浮动，清除浮动);H(反向浮动);I(反向浮动);J(反向浮动，清除浮动)
     
     */
    public var tg_clearFloat:Bool
        {
        get
        {
            return self.tgCurrentSizeClass.tg_clearFloat
        }
        set
        {
            let sc = self.tgCurrentSizeClass
            if sc.tg_clearFloat != newValue
            {
                
                sc.tg_clearFloat = newValue
                if let sView = self.superview
                {
                    sView.setNeedsLayout()
                }
            }
        }
    }

}

/**
 * 浮动布局是一种里面的子视图按照约定的方向浮动停靠，当浮动布局的剩余空间不足容纳子视图的尺寸时会自动寻找最佳的位置进行浮动停靠的布局视图。
 *浮动布局的理念源于HTML/CSS中的浮动定位技术,因此浮动布局可以专门用来实现那些不规则布局或者图文环绕的布局。
 *根据浮动的方向不同，浮动布局可以分为左右浮动布局和上下浮动布局。我们称左右浮动的浮动布局为垂直浮动布局，因为左右浮动时最终整个方向是从上到下的；称上下浮动的浮动布局为水平浮动布局，因为上下浮动时最终整个方向是从左到右的。
 */
open class TGFloatLayout: TGBaseLayout,TGFloatLayoutViewSizeClass {
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    public convenience init(_ orientation:TGOrientation = .vert)
    {
        self.init(frame:.zero, orientation:orientation)
    }
    
    public init(frame: CGRect, orientation:TGOrientation = .vert) {
        
        super.init(frame: frame)
        
        (self.tgCurrentSizeClass as! TGFloatLayoutViewSizeClass).tg_orientation = orientation
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    /**
     *浮动布局的方向。
     *如果是.vert则表示里面的子视图可以进行左右的浮动，整体从上到下进行排列的布局方式，这个方式是默认方式。
     *如果是.horz则表示里面的子视图可以进行上下的浮动，整体从左到右进行排列的布局方式，这个方式是默认方式。
     */
    public var tg_orientation:TGOrientation
        {
        get
        {
            return (self.tgCurrentSizeClass as! TGFloatLayoutViewSizeClass).tg_orientation
        }
        set
        {
            let lsc = self.tgCurrentSizeClass as! TGFloatLayoutViewSizeClass
            if lsc.tg_orientation != newValue
            {
                lsc.tg_orientation = newValue
                setNeedsLayout()
            }
        }
    }
    
    
    /**
     *不做布局边界尺寸的限制，子视图不会自动换行，因此当设置为true时，子视图需要设置tg_clearFloat来实现主动换行的处理。默认为false。
     *当布局的orientation为.vert并且tg_width.equal(.wrap)时,这个属性设置为true才生效。
     *当布局的orientation为.horz并且tg_height.equal(.wrap)时，这个属性设置为true才生效。
     *当属性设置为true时，子视图不能将扩展属性tg_reverseFloat设置为true，否则将导致结果异常。
     *这个属性设置为true时，在左右浮动布局中，子视图只能向左浮动，并且没有右边界的限制，因此如果子视图没有tg_clearFloat时则总是排列在前一个子视图的右边，并不会自动换行,因此为了让这个属性生效，布局视图必须要同时设置tg_width.equal(.wrap)。
     *这个属性设置为true时，在上下浮动布局中，子视图只能向上浮动，并且没有下边界的限制，因此如果子视图没有设置tg_clearFloat时则总是排列在前一个子视图的下边，并不会自动换行，因此为了让这个属性生效，布局视图必须要同时设置tg_height.equal(.wrap).
     */
    public var tg_noBoundaryLimit:Bool
    {
        get
        {
            return (self.tgCurrentSizeClass as! TGFloatLayoutViewSizeClass).tg_noBoundaryLimit
        }
        set
        {
            let lsc = self.tgCurrentSizeClass as! TGFloatLayoutViewSizeClass
            if lsc.tg_noBoundaryLimit != newValue
            {
                lsc.tg_noBoundaryLimit = newValue
                setNeedsLayout()
            }
        }
    }
    
    /**
     *根据浮动布局视图的方向设置子视图的固定尺寸和视图之间的最小间距。在一些应用场景我们有时候希望某些子视图的宽度是固定的情况下，子视图的间距是浮动的而不是固定的，这样就可以尽可能的容纳更多的子视图。比如每个子视图的宽度是固定80，那么在小屏幕下每行只能放3个，而我们希望大屏幕每行能放4个或者5个子视图。因此您可以通过如下方法来设置浮动间距。这个方法会根据您当前布局的orientation方向不同而意义不同：
     1.如果您的布局方向是MyLayoutViewOrientation_Vert表示设置的是子视图的水平间距，其中的subviewSize指定的是子视图的宽度，minSpace指定的是最小的水平间距，maxSpace指定的是最大的水平间距，如果指定的subviewSize计算出的间距大于这个值则会调整subviewSize的宽度。
     2.如果您的布局方向是MyLayoutViewOrientation_Horz表示设置的是子视图的垂直间距，其中的subviewSize指定的是子视图的高度，minSpace指定的是最小的垂直间距，maxSpace指定的是最大的垂直间距，如果指定的subviewSize计算出的间距大于这个值则会调整subviewSize的高度。
     3.如果您不想使用浮动间距则请将subviewSize设置为0就可以了。
     */
    public func tg_setSubviews(size:CGFloat, minSpace:CGFloat, maxSpace:CGFloat = .greatestFiniteMagnitude, inSizeClass type:TGSizeClassType = .default)
    {
        let lsc = self.tg_fetchSizeClass(with: type) as! TGFloatLayoutViewSizeClassImpl
        lsc.subviewSize = size
        lsc.minSpace = minSpace
        lsc.maxSpace = maxSpace
        
        self.setNeedsLayout()
    }
    

    //MARK: override method

    override internal func tgCalcLayoutRect(_ size:CGSize, isEstimate:Bool, sbs:[UIView]!, type :TGSizeClassType) ->(selfSize:CGSize, hasSubLayout:Bool)
    {
        var (selfSize, hasSubLayout) = super.tgCalcLayoutRect(size, isEstimate:isEstimate, sbs:sbs, type:type)
        
        var sbs:[UIView]! = sbs
        if sbs == nil
        {
            sbs = self.tgGetLayoutSubviews()
        }
        
        let lsc = self.tgCurrentSizeClass as! TGFloatLayoutViewSizeClassImpl
        
        for sbv in sbs
        {
            let (sbvtgFrame, sbvsc) = self.tgGetSubviewFrameAndSizeClass(sbv)
            
            if (!isEstimate)
            {
                sbvtgFrame.frame = sbv.bounds;
                self.tgCalcSizeFromSizeWrapSubview(sbv, sbvsc:sbvsc, sbvtgFrame: sbvtgFrame)
                
            }
            
            if let sbvl:TGBaseLayout = sbv as? TGBaseLayout
            {
                 if sbvsc.isSomeSizeWrap
                {
                   hasSubLayout = true
                }
                
                if isEstimate && (sbvsc.isSomeSizeWrap)
                {
                    _ = sbvl.tg_sizeThatFits(sbvtgFrame.frame.size,inSizeClass:type)
                    if sbvtgFrame.multiple
                    {
                        sbvtgFrame.sizeClass = sbv.tgMatchBestSizeClass(type)  //因为estimateLayoutRect执行后会还原，所以这里要重新设置
                    }
                }
            }
        }
        
        
        if (lsc.tg_orientation == .vert)
        {
            selfSize = self.tgLayoutSubviewsForVert(selfSize,sbs:sbs, isEstimate:isEstimate, lsc:lsc);
        }
        else
        {
            selfSize = self.tgLayoutSubviewsForHorz(selfSize,sbs:sbs, isEstimate:isEstimate, lsc:lsc);
        }
        
        
        
        
        tgAdjustLayoutSelfSize(selfSize: &selfSize, lsc: lsc)
        
        tgAdjustSubviewsRTLPos(sbs: sbs, selfWidth: selfSize.width)
        
        
        return (self.tgAdjustSizeWhenNoSubviews(size: selfSize, sbs: sbs, lsc:lsc),hasSubLayout)
    }
    
    
    
    internal override func tgCreateInstance() -> AnyObject
    {
        return TGFloatLayoutViewSizeClassImpl(view:self)
    }
    
    
    
}


extension TGFloatLayout
{
    
    
    
    fileprivate func tgFindTrailingCandidatePoint(_ leadingCandidateRect:CGRect, width:CGFloat, trailingBoundary:CGFloat, trailingCandidateRects:[CGRect], hasWeight:Bool, lsc:TGFloatLayoutViewSizeClassImpl) ->CGPoint
    {
        
        var retPoint = CGPoint(x: trailingBoundary,y: CGFloat.greatestFiniteMagnitude)
        
        var lastHeight = lsc.tg_topPadding;
        
        var i = trailingCandidateRects.count - 1
        while i >= 0
        {
            //CGFloat
            let trailingCandidateRect = trailingCandidateRects[i]
            //如果有比重则不能相等只能小于。
            if (hasWeight ? leadingCandidateRect.maxX + width < trailingCandidateRect.minX : _tgCGFloatLessOrEqual(leadingCandidateRect.maxX + width, trailingCandidateRect.minX)) &&
                leadingCandidateRect.maxY > lastHeight
            {
                
                retPoint.y = max(leadingCandidateRect.minY,lastHeight);
                retPoint.x = trailingCandidateRect.minX;
                break;
            }
            
            lastHeight = trailingCandidateRect.maxY;
            i-=1
        }
        
        if retPoint.y == CGFloat.greatestFiniteMagnitude
        {
            if (hasWeight ? leadingCandidateRect.maxX + width < trailingBoundary : _tgCGFloatLessOrEqual(leadingCandidateRect.maxX + width, trailingBoundary) ) &&
                leadingCandidateRect.maxY > lastHeight
            {
                retPoint.y =  max(leadingCandidateRect.minY,lastHeight);
            }
        }
        
        return retPoint;
    }
    
    
    fileprivate func tgFindBottomCandidatePoint(_ topCandidateRect:CGRect, height:CGFloat, bottomBoundary:CGFloat, bottomCandidateRects:[CGRect], hasWeight:Bool, lsc:TGFloatLayoutViewSizeClassImpl) ->CGPoint
    {
        
        var  retPoint = CGPoint(x: CGFloat.greatestFiniteMagnitude,y: bottomBoundary)
        
        var lastWidth = lsc.tg_leadingPadding;
        var i = bottomCandidateRects.count - 1
        while i >= 0
        {
            
            let bottomCandidateRect = bottomCandidateRects[i]
            
            if (hasWeight ? topCandidateRect.maxY + height < bottomCandidateRect.minY :  _tgCGFloatLessOrEqual(topCandidateRect.maxY + height, bottomCandidateRect.minY) ) &&
                topCandidateRect.maxX > lastWidth
            {
                retPoint.x = max(topCandidateRect.minX,lastWidth);
                retPoint.y = bottomCandidateRect.minY;
                break;
            }
            
            lastWidth = bottomCandidateRect.maxX;
            i -= 1
        }
        
        if (retPoint.x == CGFloat.greatestFiniteMagnitude)
        {
            if ((hasWeight ? topCandidateRect.maxY + height < bottomBoundary :  _tgCGFloatLessOrEqual(topCandidateRect.maxY + height, bottomBoundary) ) &&
                topCandidateRect.maxX > lastWidth)
            {
                retPoint.x =  max(topCandidateRect.minX,lastWidth);
            }
        }
        
        return retPoint;
    }
    
    
    fileprivate func tgFindLeadingCandidatePoint(_ trailingCandidateRect:CGRect, width:CGFloat, leadingBoundary:CGFloat, leadingCandidateRects:[CGRect], hasWeight:Bool, lsc:TGFloatLayoutViewSizeClassImpl) ->CGPoint
    {
        
        var retPoint = CGPoint(x: leadingBoundary,y: CGFloat.greatestFiniteMagnitude)
        
        var lastHeight = lsc.tg_topPadding;
        var i = leadingCandidateRects.count - 1
        while i >= 0
        {
            
            let  leadingCandidateRect = leadingCandidateRects[i]
            if ((hasWeight ? trailingCandidateRect.minX - width > leadingCandidateRect.maxX :  _tgCGFloatGreatOrEqual(trailingCandidateRect.minX - width, leadingCandidateRect.maxX)) &&
                trailingCandidateRect.maxY > lastHeight)
            {
                retPoint.y = max(trailingCandidateRect.minY,lastHeight);
                retPoint.x = leadingCandidateRect.maxX;
                break;
            }
            
            lastHeight = leadingCandidateRect.maxY;
            i -= 1
            
        }
        
        if (retPoint.y == CGFloat.greatestFiniteMagnitude)
        {
            if ((hasWeight ? trailingCandidateRect.minX - width > leadingBoundary : _tgCGFloatGreatOrEqual(trailingCandidateRect.minX - width, leadingBoundary)) &&
                trailingCandidateRect.maxY > lastHeight)
            {
                retPoint.y =  max(trailingCandidateRect.minY,lastHeight);
            }
        }
        
        return retPoint;
    }
    
    fileprivate func tgFindTopCandidatePoint(_ bottomCandidateRect:CGRect, height:CGFloat, topBoundary:CGFloat, topCandidateRects:[CGRect], hasWeight:Bool, lsc:TGFloatLayoutViewSizeClassImpl) ->CGPoint
    {
        
        var retPoint = CGPoint(x: CGFloat.greatestFiniteMagnitude, y: topBoundary)
        
        var lastWidth = lsc.tg_leadingPadding;
        var i = topCandidateRects.count - 1
        while i >= 0
        {
            
            let topCandidateRect = topCandidateRects[i]
            if ((hasWeight ? bottomCandidateRect.minY - height > topCandidateRect.maxY :  _tgCGFloatGreatOrEqual(bottomCandidateRect.minY - height, topCandidateRect.maxY)) &&
                bottomCandidateRect.maxX > lastWidth)
            {
                retPoint.x = max(bottomCandidateRect.minX,lastWidth);
                retPoint.y = topCandidateRect.maxY;
                break;
            }
            
            lastWidth = topCandidateRect.maxX;
            i -= 1
            
        }
        
        if (retPoint.x == CGFloat.greatestFiniteMagnitude)
        {
            if ((hasWeight ? bottomCandidateRect.minY - height > topBoundary :  _tgCGFloatGreatOrEqual(bottomCandidateRect.minY - height, topBoundary)) &&
                bottomCandidateRect.maxX > lastWidth)
            {
                retPoint.x =  max(bottomCandidateRect.minX,lastWidth);
            }
        }
        
        return retPoint;
    }
    
    
    fileprivate func tgLayoutSubviewsForVert(_ selfSize:CGSize, sbs:[UIView], isEstimate:Bool, lsc:TGFloatLayoutViewSizeClassImpl) -> CGSize
    {
        var selfSize = selfSize
        var hasBoundaryLimit = true
        if lsc.width.isWrap && lsc.tg_noBoundaryLimit
        {
            hasBoundaryLimit = false
        }
        
        if !hasBoundaryLimit
        {
            selfSize.width = CGFloat.greatestFiniteMagnitude
        }
        
        
        //遍历所有的子视图，查看是否有子视图的宽度会比视图自身要宽，如果有且有包裹属性则扩充自身的宽度
        if (lsc.width.isWrap && hasBoundaryLimit)
        {
            var maxContentWidth = selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding;
            for sbv in sbs
            {
                let (sbvtgFrame, sbvsc) = self.tgGetSubviewFrameAndSizeClass(sbv)
                let leadingSpace = sbvsc.leading.absPos
                let trailingSpace = sbvsc.trailing.absPos
                var rect = sbvtgFrame.frame;
                
                //这里有可能设置了固定的宽度
                if sbvsc.width.numberVal != nil
                {
                    rect.size.width = sbvsc.width.measure
                }
                
                //有可能宽度是和他的高度相等。
                if sbvsc.width.isRelaSizeEqualTo(sbvsc.height)
                {
                    if (sbvsc.height.numberVal != nil)
                    {
                        rect.size.height = sbvsc.height.measure;
                    }
                    
                    if sbvsc.height.isRelaSizeEqualTo(lsc.height)
                    {
                        rect.size.height = sbvsc.height.measure(selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding)
                    }
                    
                    rect.size.height = self.tgValidMeasure(sbvsc.height, sbv: sbv, calcSize: rect.size.height, sbvSize: rect.size, selfLayoutSize: selfSize)
                    
                    rect.size.width = sbvsc.width.measure(rect.size.height)
                }
                
                rect.size.width = self.tgValidMeasure(sbvsc.width, sbv: sbv, calcSize: rect.size.width, sbvSize: rect.size, selfLayoutSize: selfSize)
                
                if (leadingSpace + rect.size.width + trailingSpace > maxContentWidth &&
                    (sbvsc.width.sizeVal == nil || sbvsc.width.sizeVal !== lsc.width.realSize) &&
                    sbvsc.width.weightVal == nil &&
                    !sbvsc.width.isFill)
                {
                    maxContentWidth = leadingSpace + rect.size.width + trailingSpace;
                }
            }
            
            selfSize.width = lsc.tg_leadingPadding + maxContentWidth + lsc.tg_trailingPadding;
        }
        
        let vertSpace = lsc.tg_vspace;
        var horzSpace = lsc.tg_hspace;
        var subviewSize = lsc.subviewSize
        if (subviewSize != 0)
        {
            #if DEBUG
                //异常崩溃：当布局视图设置了tg_noBoundaryLimit为true时，不能设置最小垂直间距。
                assert(hasBoundaryLimit, "Constraint exception！！, vertical float layout:\(self) can not set tg_noBoundaryLimit to true when call  tg_setSubviews(size:CGFloat,minSpace:CGFloat,maxSpace:CGFloat)  method")
            #endif
            
            let minSpace = lsc.minSpace
            let maxSpace = lsc.maxSpace

            
            let rowCount =  floor((selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding  + minSpace) / (subviewSize + minSpace));
            if (rowCount > 1)
            {
                horzSpace = (selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding - subviewSize * rowCount)/(rowCount - 1);
                
                if horzSpace > maxSpace
                {
                    horzSpace = maxSpace
                    
                    subviewSize = (selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding -  horzSpace * (rowCount - 1)) / rowCount
                }
            }
        }
        
        
        //左边候选区域数组，保存的是CGRect值。
        var leadingCandidateRects:[CGRect] = [CGRect]()
        //为了计算方便总是把最左边的个虚拟区域作为一个候选区域
        leadingCandidateRects.append(CGRect(x: lsc.tg_leadingPadding, y: lsc.tg_topPadding, width: 0, height: CGFloat.greatestFiniteMagnitude));
        
        //右边候选区域数组，保存的是CGRect值。
        var trailingCandidateRects:[CGRect] = [CGRect]()
        //为了计算方便总是把最右边的个虚拟区域作为一个候选区域
        trailingCandidateRects.append(CGRect(x: selfSize.width - lsc.tg_trailingPadding, y: lsc.tg_topPadding, width: 0, height: CGFloat.greatestFiniteMagnitude));
        
        //分别记录左边和右边的最后一个视图在Y轴的偏移量
        var leadingLastYOffset = lsc.tg_topPadding
        var trailingLastYOffset = lsc.tg_topPadding
        
        //分别记录左右边和全局浮动视图的最高占用的Y轴的值
        var leadingMaxHeight = lsc.tg_topPadding
        var trailingMaxHeight = lsc.tg_topPadding
        var maxHeight = lsc.tg_topPadding
        var maxWidth = lsc.tg_leadingPadding
        
        for sbv in sbs
        {
            let (sbvtgFrame, sbvsc) = self.tgGetSubviewFrameAndSizeClass(sbv)
            let topSpace = sbvsc.top.absPos
            let leadingSpace = sbvsc.leading.absPos
            let bottomSpace = sbvsc.bottom.absPos
            let trailingSpace = sbvsc.trailing.absPos
            var rect = sbvtgFrame.frame;
            let isWidthWeight = sbvsc.width.weightVal != nil || sbvsc.width.isFill
            let isHeightWeight = sbvsc.height.weightVal != nil || sbvsc.height.isFill
            
            
            if subviewSize != 0
            {
                rect.size.width = subviewSize
            }
            
            if sbvsc.width.numberVal != nil
            {
                rect.size.width = sbvsc.width.measure;
            }
            
            if (sbvsc.height.numberVal != nil)
            {
                rect.size.height = sbvsc.height.measure;
            }
            
            if isHeightWeight && !lsc.height.isWrap
            {

                rect.size.height = sbvsc.height.measure((selfSize.height - maxHeight - lsc.tg_bottomPadding) * (sbvsc.height.isFill ? 1.0 : sbvsc.height.weightVal.rawValue/100) - topSpace - bottomSpace)
            }
            
            if sbvsc.height.isRelaSizeEqualTo(lsc.height) && !lsc.height.isWrap
            {
                rect.size.height = sbvsc.height.measure(selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding)
            }
            
            if sbvsc.width.isRelaSizeEqualTo(lsc.width)
            {
                rect.size.width = sbvsc.width.measure(selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding)
            }
            
            rect.size.width = self.tgValidMeasure(sbvsc.width, sbv: sbv, calcSize: rect.size.width, sbvSize: rect.size, selfLayoutSize: selfSize)
            
            if sbvsc.height.isRelaSizeEqualTo(sbvsc.width)
            {
                rect.size.height = sbvsc.height.measure(rect.size.width)
            }
            
            rect.size.height = self.tgValidMeasure(sbvsc.height, sbv: sbv, calcSize: rect.size.height, sbvSize: rect.size, selfLayoutSize: selfSize)
            
            if sbvsc.width.isRelaSizeEqualTo(sbvsc.height)
            {
                rect.size.width = sbvsc.width.measure(rect.size.height)
            }
            
            if let t = sbvsc.width.sizeVal, t.view != nil &&  t.view !== self && t.view != sbv
            {
                rect.size.width = sbvsc.width.measure(t.view.tgFrame.width)
            }
            
            if let t = sbvsc.height.sizeVal, t.view != nil &&  t.view !== self && t.view != sbv
            {
                rect.size.height = sbvsc.height.measure(t.view.tgFrame.height)
            }
            
            rect.size.width = self.tgValidMeasure(sbvsc.width, sbv: sbv, calcSize: rect.size.width, sbvSize: rect.size, selfLayoutSize: selfSize)
            
            //如果高度是浮动的则需要调整高度。
            if sbvsc.height.isFlexHeight
            {
                rect.size.height = self.tgCalcHeightFromHeightWrapView(sbv, sbvsc:sbvsc, width: rect.size.width)
            }
            
            rect.size.height = self.tgValidMeasure(sbvsc.height, sbv: sbv, calcSize: rect.size.height, sbvSize: rect.size, selfLayoutSize: selfSize)
            
            if (sbvsc.tg_reverseFloat)
            {
                #if DEBUG
                    //异常崩溃：当布局视图设置了tg_noBoundaryLimit为true时子视图不能设置逆向浮动
                    assert(hasBoundaryLimit, "Constraint exception！！, vertical float layout:\(self) can not set tg_noBoundaryLimit to true when the subview:\(sbv) set tg_reverseFloat to true.")
                #endif
                
                var nextPoint = CGPoint(x: selfSize.width - lsc.tg_trailingPadding, y: leadingLastYOffset);
                var leadingCandidateXBoundary = lsc.tg_leadingPadding;
                if (sbvsc.tg_clearFloat)
                {
                    
                    //找到最底部的位置。
                    nextPoint.y = max(trailingMaxHeight, leadingLastYOffset);
                    let leftPoint = self.tgFindLeadingCandidatePoint(CGRect(x: selfSize.width - lsc.tg_trailingPadding, y: nextPoint.y, width: 0, height: CGFloat.greatestFiniteMagnitude), width:leadingSpace + (isWidthWeight ? 0 : rect.size.width) + trailingSpace,leadingBoundary:lsc.tg_leadingPadding,leadingCandidateRects:leadingCandidateRects,hasWeight:false, lsc:lsc)
                    if (leftPoint.y != CGFloat.greatestFiniteMagnitude)
                    {
                        nextPoint.y = max(trailingMaxHeight, leftPoint.y);
                        leadingCandidateXBoundary = leftPoint.x;
                    }
                }
                else
                {
                    //依次从后往前，每个都比较右边的。
                    var i = trailingCandidateRects.count - 1
                    while i >= 0
                    {
                        let candidateRect = trailingCandidateRects[i]
                        let leftPoint = self.tgFindLeadingCandidatePoint(candidateRect,width:leadingSpace + (isWidthWeight ? 0 : rect.size.width) + trailingSpace,leadingBoundary:lsc.tg_leadingPadding, leadingCandidateRects:leadingCandidateRects,hasWeight:isWidthWeight, lsc:lsc)
                        if (leftPoint.y != CGFloat.greatestFiniteMagnitude)
                        {
                            nextPoint = CGPoint(x: candidateRect.minX, y: max(nextPoint.y, leftPoint.y));
                            leadingCandidateXBoundary = leftPoint.x;
                            break;
                        }
                        
                        nextPoint.y = candidateRect.maxY;
                        i -= 1
                    }
                }
                
                //重新设置宽度
                if isWidthWeight
                {
                    var widthWeight:CGFloat = 1.0
                    if let t = sbvsc.width.weightVal
                    {
                        widthWeight = t.rawValue / 100
                    }
                    
                    rect.size.width =  self.tgValidMeasure(sbvsc.width, sbv: sbv, calcSize: (nextPoint.x - leadingCandidateXBoundary + sbvsc.width.increment) * widthWeight - leadingSpace - trailingSpace, sbvSize: rect.size, selfLayoutSize: selfSize)
                    
                    if sbvsc.height.isRelaSizeEqualTo(sbvsc.width)
                    {
                        rect.size.height = sbvsc.height.measure(rect.size.width)
                    }
                    
                    if sbvsc.height.isFlexHeight
                    {
                        
                        rect.size.height = self.tgCalcHeightFromHeightWrapView(sbv, sbvsc:sbvsc, width: rect.size.width)
                    }
                    
                    rect.size.height = self.tgValidMeasure(sbvsc.height, sbv: sbv, calcSize: rect.size.height, sbvSize: rect.size, selfLayoutSize: selfSize)
                }
                
                
                rect.origin.x = nextPoint.x - trailingSpace - rect.size.width;
                rect.origin.y = min(nextPoint.y, maxHeight) + topSpace;
                
                //如果有智能边界线则找出所有智能边界线。
                if (!isEstimate && self.tg_intelligentBorderline != nil)
                {
                    //优先绘制左边和上边的。绘制左边的和上边的。
                    if let sbvl = sbv as? TGBaseLayout
                    {
                        if (!sbvl.tg_notUseIntelligentBorderline)
                        {
                            sbvl.tg_bottomBorderline = nil;
                            sbvl.tg_topBorderline = nil;
                            sbvl.tg_trailingBorderline = nil;
                            sbvl.tg_leadingBorderline = nil;
                            
                            if (rect.origin.x + rect.size.width + trailingSpace < selfSize.width - lsc.tg_trailingPadding)
                            {
                                sbvl.tg_trailingBorderline = self.tg_intelligentBorderline;
                            }
                            
                            if (rect.origin.y + rect.size.height + bottomSpace < selfSize.height - lsc.tg_bottomPadding)
                            {
                                sbvl.tg_bottomBorderline = self.tg_intelligentBorderline;
                            }
                            
                            if (rect.origin.x > leadingCandidateXBoundary && sbvl == sbs.last)
                            {
                                sbvl.tg_leadingBorderline = self.tg_intelligentBorderline;
                            }
                        }
                        
                    }
                }
                
                
                
                //这里有可能子视图本身的宽度会超过布局视图本身，但是我们的候选区域则不存储超过的宽度部分。
                let cRect = CGRect(x: max(rect.origin.x - leadingSpace - horzSpace,lsc.tg_leadingPadding), y: rect.origin.y - topSpace, width: min((rect.size.width + leadingSpace + trailingSpace),(selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding)), height: rect.size.height + topSpace + bottomSpace + vertSpace);
                
                
                //把新的候选区域添加到数组中去。并删除高度小于新候选区域的其他区域
                trailingCandidateRects = trailingCandidateRects.filter({$0.maxY > cRect.maxY})
                
                
                //删除左边高度小于新添加区域的顶部的候选区域
                leadingCandidateRects = leadingCandidateRects.filter({$0.maxY > cRect.minY})
               
            
                trailingCandidateRects.append(cRect)
                trailingLastYOffset = rect.origin.y - topSpace;
                
                if (rect.origin.y + rect.size.height + bottomSpace + vertSpace > trailingMaxHeight)
                {
                    trailingMaxHeight = rect.origin.y + rect.size.height + bottomSpace + vertSpace;
                }
            }
            else
            {
                var nextPoint = CGPoint(x: lsc.tg_leadingPadding, y: trailingLastYOffset)
                var trailingCandidateXBoundary = selfSize.width - lsc.tg_trailingPadding;
                
                //如果是清除了浮动则直换行移动到最下面。
                if (sbvsc.tg_clearFloat)
                {
                    //找到最低点。
                    nextPoint.y = max(leadingMaxHeight, trailingLastYOffset);
                    
                    let rightPoint = self.tgFindTrailingCandidatePoint(CGRect(x: lsc.tg_leadingPadding, y: nextPoint.y, width: 0, height: CGFloat.greatestFiniteMagnitude), width:leadingSpace + (isWidthWeight ? 0 : rect.size.width) + trailingSpace, trailingBoundary:trailingCandidateXBoundary, trailingCandidateRects:trailingCandidateRects, hasWeight:false, lsc:lsc)
                    if (rightPoint.y != CGFloat.greatestFiniteMagnitude)
                    {
                        nextPoint.y = max(leadingMaxHeight, rightPoint.y);
                        trailingCandidateXBoundary = rightPoint.x;
                    }
                }
                else
                {
                    
                    //依次从后往前，每个都比较右边的。
                    var i = leadingCandidateRects.count - 1
                    while i >= 0
                    {
                        let candidateRect = leadingCandidateRects[i]
                        let rightPoint = self.tgFindTrailingCandidatePoint(candidateRect, width:leadingSpace + (isWidthWeight ? 0 : rect.size.width) + trailingSpace,trailingBoundary:selfSize.width - lsc.tg_trailingPadding,trailingCandidateRects:trailingCandidateRects,hasWeight:isWidthWeight,lsc:lsc)
                        if (rightPoint.y != CGFloat.greatestFiniteMagnitude)
                        {
                            nextPoint = CGPoint(x: candidateRect.maxX, y: max(nextPoint.y, rightPoint.y));
                            trailingCandidateXBoundary = rightPoint.x;
                            break;
                        }
                        
                        nextPoint.y = candidateRect.maxY;
                        i -= 1
                    }
                }
                
                //重新设置宽度
                if isWidthWeight
                {
                    #if DEBUG
                        //异常崩溃：当布局视图设置了tg_noBoundaryLimit为true时子视图不能设置tg_width为TGWeight类型和.fill类型
                        assert(hasBoundaryLimit, "Constraint exception！！, vertical float layout:\(self) can not set tg_noBoundaryLimit to true when the subview:\(sbv) set tg_width to TGWeight or .fill type value.")
                    #endif
                    
                    
                    var widthWeight:CGFloat = 1.0
                    if let t = sbvsc.width.weightVal
                    {
                        widthWeight = t.rawValue / 100
                    }

                    
                    rect.size.width =  self.tgValidMeasure(sbvsc.width, sbv: sbv, calcSize: (trailingCandidateXBoundary - nextPoint.x + sbvsc.width.increment) * widthWeight - leadingSpace - trailingSpace, sbvSize: rect.size, selfLayoutSize: selfSize)
                    
                    if sbvsc.height.isRelaSizeEqualTo(sbvsc.width)
                    {
                        rect.size.height = sbvsc.height.measure(rect.size.width)
                    }
                    
                    if sbvsc.height.isFlexHeight
                    {
                        
                        rect.size.height = self.tgCalcHeightFromHeightWrapView(sbv, sbvsc:sbvsc,width: rect.size.width)
                    }
                    
                    rect.size.height = self.tgValidMeasure(sbvsc.height, sbv: sbv, calcSize: rect.size.height, sbvSize: rect.size, selfLayoutSize: selfSize)
                    
                }
                
                rect.origin.x = nextPoint.x + leadingSpace;
                rect.origin.y = min(nextPoint.y,maxHeight) + topSpace;
                
                
                if (!isEstimate && self.tg_intelligentBorderline != nil)
                {
                    //优先绘制左边和上边的。绘制左边的和上边的。
                    if let sbvl = sbv as? TGBaseLayout
                    {
                        if (!sbvl.tg_notUseIntelligentBorderline)
                        {
                            sbvl.tg_bottomBorderline = nil;
                            sbvl.tg_topBorderline = nil;
                            sbvl.tg_trailingBorderline = nil;
                            sbvl.tg_leadingBorderline = nil;
                            
                            //如果自己的上边和左边有子视图。
                            if (rect.origin.x - leadingSpace > lsc.tg_leadingPadding)
                            {
                                sbvl.tg_leadingBorderline = self.tg_intelligentBorderline;
                            }
                            
                            if (rect.origin.y - topSpace > lsc.tg_topPadding)
                            {
                                sbvl.tg_topBorderline = self.tg_intelligentBorderline;
                            }
                        }
                        
                    }
                }
                
                
                
                let cRect = CGRect(x: rect.origin.x - leadingSpace, y: rect.origin.y - topSpace, width: min((rect.size.width + leadingSpace + trailingSpace + horzSpace),(selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding)), height: rect.size.height + topSpace + bottomSpace + vertSpace);
                
                
                //把新添加到候选中去。并删除高度小于的候选键。和高度
                leadingCandidateRects = leadingCandidateRects.filter({$0.maxY > cRect.maxY})
                //删除右边高度小于新添加区域的顶部的候选区域
                trailingCandidateRects = trailingCandidateRects.filter({$0.maxY > cRect.minY})
               
                
                leadingCandidateRects.append(cRect);
                leadingLastYOffset = rect.origin.y - topSpace;
                
                if (rect.origin.y + rect.size.height + bottomSpace + vertSpace > leadingMaxHeight)
                {
                    leadingMaxHeight = rect.origin.y + rect.size.height + bottomSpace + vertSpace;
                }
                
            }
            
            if rect.origin.y + rect.size.height + bottomSpace + vertSpace > maxHeight
            {
                maxHeight = rect.origin.y + rect.size.height + bottomSpace + vertSpace;
            }
            
            if rect.origin.x + rect.size.width + trailingSpace + horzSpace > maxWidth
            {
                maxWidth = rect.origin.x + rect.size.width + trailingSpace + horzSpace
            }
            
            sbvtgFrame.frame = rect;
            
        }
        
        if sbs.count > 0
        {
            maxHeight -= vertSpace
            maxWidth -= horzSpace
        }
        
        maxHeight += lsc.tg_bottomPadding
        maxWidth += lsc.tg_trailingPadding
        
        if !hasBoundaryLimit
        {
            selfSize.width = maxWidth
        }
        
        if lsc.height.isWrap
        {
            selfSize.height = maxHeight
        }
        else
        {
            var addYPos:CGFloat = 0;
            let mgvert = lsc.tg_gravity & TGGravity.horz.mask;
            if (mgvert == TGGravity.vert.center)
            {
                addYPos = (selfSize.height - maxHeight) / 2;
            }
            else if (mgvert == TGGravity.vert.bottom)
            {
                addYPos = selfSize.height - maxHeight;
            }
            
            if (addYPos != 0)
            {
                for i in 0 ..< sbs.count
                {
                    sbs[i].tgFrame.top += addYPos
                }
            }
            
        }
        
        return selfSize;
    }
    
    fileprivate func tgLayoutSubviewsForHorz(_ selfSize:CGSize, sbs:[UIView], isEstimate:Bool, lsc:TGFloatLayoutViewSizeClassImpl) ->CGSize
    {
        
        var selfSize = selfSize
        
        var hasBoundaryLimit = true
        if (lsc.height.isWrap && lsc.tg_noBoundaryLimit)
        {
            hasBoundaryLimit = false
        }
        
        if !hasBoundaryLimit
        {
            selfSize.height = CGFloat.greatestFiniteMagnitude
        }
        
        //遍历所有的子视图，查看是否有子视图的宽度会比视图自身要宽，如果有且有包裹属性则扩充自身的宽度
        if (lsc.height.isWrap && hasBoundaryLimit)
        {
            var maxContentHeight = selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding;
            for sbv in sbs
            {
                let (sbvtgFrame, sbvsc) = self.tgGetSubviewFrameAndSizeClass(sbv)
                let topSpace = sbvsc.top.absPos
                let bottomSpace = sbvsc.bottom.absPos
                var rect = sbvtgFrame.frame;
                
                
                //这里有可能设置了固定的高度
                if (sbvsc.height.numberVal != nil)
                {
                    rect.size.height = sbvsc.height.measure
                }
                
                rect.size.width = self.tgValidMeasure(sbvsc.width, sbv: sbv, calcSize: rect.size.width, sbvSize: rect.size, selfLayoutSize: selfSize)
                
                //有可能高度是和他的宽度相等。
                if sbvsc.height.isRelaSizeEqualTo(sbvsc.width)
                {
                    
                    if sbvsc.width.numberVal != nil
                    {
                        rect.size.width = sbvsc.width.measure;
                    }
                    
                    if sbvsc.width.isRelaSizeEqualTo(lsc.width)
                    {
                        rect.size.width = sbvsc.width.measure(selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding)
                    }
                    
                    rect.size.width = self.tgValidMeasure(sbvsc.width, sbv: sbv, calcSize: rect.size.width, sbvSize: rect.size, selfLayoutSize: selfSize)
                    
                    
                    rect.size.height = sbvsc.height.measure(rect.size.width)
                }
                
                if sbvsc.height.isFlexHeight
                {
                    
                    rect.size.height = self.tgCalcHeightFromHeightWrapView(sbv, sbvsc:sbvsc, width: rect.size.width)
                }
                
                rect.size.height = self.tgValidMeasure(sbvsc.height, sbv: sbv, calcSize: rect.size.height, sbvSize: rect.size, selfLayoutSize: selfSize)
                
                if (topSpace + rect.size.height + bottomSpace > maxContentHeight &&
                    (sbvsc.height.sizeVal == nil || sbvsc.height.sizeVal !== lsc.height.realSize) &&
                    sbvsc.height.weightVal == nil &&
                    !sbvsc.height.isFill)
                {
                    maxContentHeight = topSpace + rect.size.height + bottomSpace;
                }
            }
            
            selfSize.height = lsc.tg_topPadding + maxContentHeight + lsc.tg_bottomPadding;
        }
        
        
        //支持浮动垂直间距。
        let horzSpace = lsc.tg_hspace
        var vertSpace = lsc.tg_vspace
        var subviewSize = lsc.subviewSize;
        if (subviewSize != 0)
        {
            #if DEBUG
                //异常崩溃：当布局视图设置了tg_noBoundaryLimit为true时，不能设置最小垂直间距。
                assert(hasBoundaryLimit, "Constraint exception！！, horizontal float layout:\(self) can not set tg_noBoundaryLimit to true when call  tg_setSubviews(size:CGFloat,minSpace:CGFloat,maxSpace:CGFloat)  method");
            #endif
            
            let minSpace = lsc.minSpace
            let maxSpace = lsc.maxSpace

            let rowCount =  floor((selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding  + minSpace) / (subviewSize + minSpace))
            if (rowCount > 1)
            {
                vertSpace = (selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding - subviewSize * rowCount)/(rowCount - 1)
                
                if (vertSpace > maxSpace)
                {
                    vertSpace = maxSpace
                    
                    subviewSize =  (selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding -  vertSpace * (rowCount - 1)) / rowCount
                    
                }

            }
        }
        
        
        //上边候选区域数组，保存的是CGRect值。
        var topCandidateRects:[CGRect] = [CGRect]()
        
        //为了计算方便总是把最上边的个虚拟区域作为一个候选区域
        topCandidateRects.append(CGRect(x: lsc.tg_leadingPadding, y: lsc.tg_topPadding,width: CGFloat.greatestFiniteMagnitude,height: 0))
        
        //右边候选区域数组，保存的是CGRect值。
        var bottomCandidateRects:[CGRect] = [CGRect]()
        //为了计算方便总是把最下边的个虚拟区域作为一个候选区域
        bottomCandidateRects.append(CGRect(x: lsc.tg_leadingPadding, y: selfSize.height - lsc.tg_bottomPadding,width: CGFloat.greatestFiniteMagnitude, height: 0))
        
        //分别记录上边和下边的最后一个视图在X轴的偏移量
        var topLastXOffset = lsc.tg_leadingPadding;
        var bottomLastXOffset = lsc.tg_leadingPadding;
        
        //分别记录上下边和全局浮动视图的最宽占用的X轴的值
        var topMaxWidth = lsc.tg_leadingPadding
        var bottomMaxWidth = lsc.tg_leadingPadding
        var maxWidth = lsc.tg_leadingPadding
        var maxHeight = lsc.tg_topPadding
        
        for sbv in sbs
        {
            let (sbvtgFrame, sbvsc) = self.tgGetSubviewFrameAndSizeClass(sbv)
            let  topSpace = sbvsc.top.absPos
            let leadingSpace = sbvsc.leading.absPos
            let bottomSpace = sbvsc.bottom.absPos
            let trailingSpace = sbvsc.trailing.absPos
            var rect = sbvtgFrame.frame;
            let isWidthWeight = sbvsc.width.weightVal != nil || sbvsc.width.isFill
            let isHeightWeight = sbvsc.height.weightVal != nil || sbvsc.height.isFill

            
            if sbvsc.width.numberVal != nil
            {
                rect.size.width = sbvsc.width.measure;
            }
            
            if subviewSize != 0
            {
                rect.size.height = subviewSize
            }
            
            if (sbvsc.height.numberVal != nil)
            {
                rect.size.height = sbvsc.height.measure;
            }
            
            if sbvsc.height.isRelaSizeEqualTo(lsc.height)
            {
                rect.size.height = sbvsc.height.measure(selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding)
            }
            
            if sbvsc.width.isRelaSizeEqualTo(lsc.width) && !lsc.width.isWrap
            {
                rect.size.width = sbvsc.width.measure(selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding)
            }
            
            if isWidthWeight && !lsc.width.isWrap
            {
                rect.size.width = sbvsc.width.measure((selfSize.width - maxWidth - lsc.tg_trailingPadding) * (sbvsc.width.isFill ? 1.0 : sbvsc.width.weightVal.rawValue/100) - leadingSpace - trailingSpace)

            }
            
            rect.size.width = self.tgValidMeasure(sbvsc.width, sbv: sbv, calcSize: rect.size.width, sbvSize: rect.size, selfLayoutSize: selfSize)
            
            if sbvsc.height.isRelaSizeEqualTo(sbvsc.width)
            {
                rect.size.height = sbvsc.height.measure(rect.size.width)
            }
            
            rect.size.height = self.tgValidMeasure(sbvsc.height, sbv: sbv, calcSize: rect.size.height, sbvSize: rect.size, selfLayoutSize: selfSize)
            
            if sbvsc.width.isRelaSizeEqualTo(sbvsc.height)
            {
                rect.size.width = sbvsc.width.measure(rect.size.height)
            }
            
            if let t = sbvsc.width.sizeVal, t.view != nil &&  t.view !== self && t.view !== sbv
            {
                rect.size.width = sbvsc.width.measure(t.view.tgFrame.width)
            }
            
            if let t = sbvsc.height.sizeVal, t.view != nil &&  t.view !== self && t.view !== sbv
            {
                rect.size.height = sbvsc.height.measure(t.view.tgFrame.height)
            }
            
            
            //如果高度是浮动的则需要调整高度。
            if sbvsc.height.isFlexHeight
            {
                rect.size.height = self.tgCalcHeightFromHeightWrapView(sbv, sbvsc:sbvsc, width: rect.size.width)
            }
            
            rect.size.height = self.tgValidMeasure(sbvsc.height, sbv: sbv, calcSize: rect.size.height, sbvSize: rect.size, selfLayoutSize: selfSize)
            
            if (sbvsc.tg_reverseFloat)
            {
                #if DEBUG
                    //异常崩溃：当布局视图设置了tg_noBoundaryLimit为true时子视图不能设置逆向浮动
                    assert(hasBoundaryLimit, "Constraint exception！！, horizontal float layout:\(self) can not set tg_noBoundaryLimit to true when the subview:\(sbv) set tg_reverseFloat to true.")
                #endif
                
                var nextPoint = CGPoint(x: topLastXOffset, y: selfSize.height - lsc.tg_bottomPadding)
                var topCandidateYBoundary = lsc.tg_topPadding;
                if (sbvsc.tg_clearFloat)
                {
                    //找到最底部的位置。
                    nextPoint.x = max(bottomMaxWidth, topLastXOffset);
                    let topPoint = self.tgFindTopCandidatePoint(CGRect(x: nextPoint.x, y: selfSize.height - lsc.tg_bottomPadding, width: CGFloat.greatestFiniteMagnitude, height: 0), height:topSpace + (isHeightWeight ? 0 : rect.size.height) + bottomSpace,topBoundary:topCandidateYBoundary,topCandidateRects:topCandidateRects,hasWeight:false,lsc:lsc)
                    if (topPoint.x != CGFloat.greatestFiniteMagnitude)
                    {
                        nextPoint.x = max(bottomMaxWidth, topPoint.x);
                        topCandidateYBoundary = topPoint.y;
                    }
                }
                else
                {
                    //依次从后往前，每个都比较右边的。
                    var i = bottomCandidateRects.count - 1
                    while i >= 0
                    {
                        let candidateRect = bottomCandidateRects[i]
                        let topPoint = self.tgFindTopCandidatePoint(candidateRect,height:topSpace + (isHeightWeight ? 0 : rect.size.height) + bottomSpace,topBoundary:lsc.tg_topPadding,topCandidateRects:topCandidateRects,hasWeight:isHeightWeight,lsc:lsc)
                        if (topPoint.x != CGFloat.greatestFiniteMagnitude)
                        {
                            nextPoint = CGPoint(x: max(nextPoint.x, topPoint.x),y: candidateRect.minY);
                            topCandidateYBoundary = topPoint.y;
                            break;
                        }
                        
                        nextPoint.x = candidateRect.maxX;
                        i -= 1
                    }
                }
                
                if isHeightWeight
                {
                    
                    var heightWeight:CGFloat = 1.0
                    if let t = sbvsc.height.weightVal
                    {
                        heightWeight = t.rawValue/100
                    }
                    
                    rect.size.height =  self.tgValidMeasure(sbvsc.height, sbv: sbv, calcSize: (nextPoint.y - topCandidateYBoundary + sbvsc.height.increment) * heightWeight - topSpace - bottomSpace, sbvSize: rect.size, selfLayoutSize: selfSize)
                    
                    if sbvsc.width.isRelaSizeEqualTo(sbvsc.height)
                    {
                        rect.size.width = self.tgValidMeasure(sbvsc.width, sbv: sbv, calcSize: sbvsc.width.measure(rect.size.height), sbvSize: rect.size, selfLayoutSize: selfSize)
                    }
                    
                }
                
                
                rect.origin.y = nextPoint.y - bottomSpace - rect.size.height;
                rect.origin.x = min(nextPoint.x, maxWidth) + leadingSpace;
                
                //如果有智能边界线则找出所有智能边界线。
                if (!isEstimate && self.tg_intelligentBorderline != nil)
                {
                    //优先绘制左边和上边的。绘制左边的和上边的。
                    if let sbvl = sbv as? TGBaseLayout
                    {
                        
                        if (!sbvl.tg_notUseIntelligentBorderline)
                        {
                            sbvl.tg_bottomBorderline = nil;
                            sbvl.tg_topBorderline = nil;
                            sbvl.tg_trailingBorderline = nil;
                            sbvl.tg_leadingBorderline = nil;
                            
                            //如果自己的上边和左边有子视图。
                            if (rect.origin.x + rect.size.width + trailingSpace < selfSize.width - lsc.tg_trailingPadding)
                            {
                                sbvl.tg_trailingBorderline = self.tg_intelligentBorderline;
                            }
                            
                            if (rect.origin.y + rect.size.height + bottomSpace < selfSize.height - lsc.tg_bottomPadding)
                            {
                                sbvl.tg_bottomBorderline = self.tg_intelligentBorderline;
                            }
                            
                            if (rect.origin.y > topCandidateYBoundary && sbvl == sbs.last)
                            {
                                sbvl.tg_topBorderline = self.tg_intelligentBorderline;
                            }
                        }
                        
                    }
                }
                
                
                //这里有可能子视图本身的宽度会超过布局视图本身，但是我们的候选区域则不存储超过的宽度部分。
                let cRect = CGRect(x: rect.origin.x - leadingSpace, y: max(rect.origin.y - topSpace - vertSpace, lsc.tg_topPadding), width: rect.size.width + leadingSpace + trailingSpace + horzSpace, height: min((rect.size.height + topSpace + bottomSpace),(selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding)));
                
                //把新的候选区域添加到数组中去。并删除高度小于新候选区域的其他区域
                bottomCandidateRects = bottomCandidateRects.filter({$0.maxX > cRect.maxX})
                
                //删除顶部宽度小于新添加区域的顶部的候选区域
                topCandidateRects = topCandidateRects.filter({$0.maxX > cRect.minX})
                
                bottomCandidateRects.append(cRect)
                bottomLastXOffset = rect.origin.x - leadingSpace;
                
                if (rect.origin.x + rect.size.width + trailingSpace + horzSpace > bottomMaxWidth)
                {
                    bottomMaxWidth = rect.origin.x + rect.size.width + trailingSpace + horzSpace;
                }
            }
            else
            {
                var nextPoint = CGPoint(x: bottomLastXOffset,y: lsc.tg_topPadding);
                var bottomCandidateYBoundary = selfSize.height - lsc.tg_bottomPadding;
                //如果是清除了浮动则直换行移动到最下面。
                if (sbvsc.tg_clearFloat)
                {
                    //找到最低点。
                    nextPoint.x = max(topMaxWidth, bottomLastXOffset);
                    
                    let bottomPoint = self.tgFindBottomCandidatePoint(CGRect(x: nextPoint.x, y: lsc.tg_topPadding,width: CGFloat.greatestFiniteMagnitude,height: 0),height:topSpace + (isHeightWeight ? 0: rect.size.height) + bottomSpace,bottomBoundary:bottomCandidateYBoundary,bottomCandidateRects:bottomCandidateRects,hasWeight:false,lsc:lsc)
                    if (bottomPoint.x != CGFloat.greatestFiniteMagnitude)
                    {
                        nextPoint.x = max(topMaxWidth, bottomPoint.x);
                        bottomCandidateYBoundary = bottomPoint.y;
                    }
                }
                else
                {
                    
                    //依次从后往前，每个都比较右边的。
                    var i = topCandidateRects.count - 1
                    while i >= 0
                    {
                        let candidateRect = topCandidateRects[i]
                        let bottomPoint = self.tgFindBottomCandidatePoint(candidateRect,height:topSpace + (isHeightWeight ? 0: rect.size.height) + bottomSpace, bottomBoundary:selfSize.height - lsc.tg_bottomPadding,bottomCandidateRects:bottomCandidateRects, hasWeight:isHeightWeight,lsc:lsc);
                        if (bottomPoint.x != CGFloat.greatestFiniteMagnitude)
                        {
                            nextPoint = CGPoint(x: max(nextPoint.x, bottomPoint.x),y: candidateRect.maxY);
                            bottomCandidateYBoundary = bottomPoint.y;
                            break;
                        }
                        
                        nextPoint.x = candidateRect.maxX;
                        i -= 1
                    }
                }
                
                if isHeightWeight
                {
                    #if DEBUG
                        //异常崩溃：当布局视图设置了noBoundaryLimit为YES时子视图不能设置weight大于0
                        assert(hasBoundaryLimit, "Constraint exception！！, horizontal float layout:\(self) can not set tg_noBoundaryLimit to true when the subview:\(sbv) set tg_height to TGWeight type value.")
                    #endif
                    
                    
                    var heightWeight:CGFloat = 1.0
                    if let t = sbvsc.height.weightVal
                    {
                        heightWeight = t.rawValue/100
                    }
                    
                    rect.size.height =  self.tgValidMeasure(sbvsc.height, sbv: sbv, calcSize: (bottomCandidateYBoundary - nextPoint.y + sbvsc.height.increment) * heightWeight - topSpace - bottomSpace, sbvSize: rect.size, selfLayoutSize: selfSize)
                    
                    if sbvsc.width.isRelaSizeEqualTo(sbvsc.height)
                    {
                        rect.size.width = self.tgValidMeasure(sbvsc.width, sbv: sbv, calcSize: sbvsc.width.measure(rect.size.height), sbvSize: rect.size, selfLayoutSize: selfSize)
                    }
                    
                    
                }
                
                rect.origin.y = nextPoint.y + topSpace;
                rect.origin.x = min(nextPoint.x,maxWidth) + leadingSpace;
                
                //如果有智能边界线则找出所有智能边界线。
                if (!isEstimate && self.tg_intelligentBorderline != nil)
                {
                    //优先绘制左边和上边的。绘制左边的和上边的。
                    if let sbvl = sbv as? TGBaseLayout
                    {
                        if (!sbvl.tg_notUseIntelligentBorderline)
                        {
                            sbvl.tg_bottomBorderline = nil;
                            sbvl.tg_topBorderline = nil;
                            sbvl.tg_trailingBorderline = nil;
                            sbvl.tg_leadingBorderline = nil;
                            
                            //如果自己的上边和左边有子视图。
                            if (rect.origin.x - leadingSpace > lsc.tg_leadingPadding)
                            {
                                sbvl.tg_leadingBorderline = self.tg_intelligentBorderline;
                            }
                            
                            if (rect.origin.y - topSpace > lsc.tg_topPadding)
                            {
                                sbvl.tg_topBorderline = self.tg_intelligentBorderline;
                            }
                        }
                        
                    }
                }
                
                
                let cRect = CGRect(x: rect.origin.x - leadingSpace, y: rect.origin.y - topSpace,width: rect.size.width + leadingSpace + trailingSpace + horzSpace,height: min((rect.size.height + topSpace + bottomSpace + vertSpace),(selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding)));
                
                
                //把新添加到候选中去。并删除宽度小于的最新候选区域的候选区域
                topCandidateRects = topCandidateRects.filter({$0.maxX > cRect.maxX})
                
                //删除顶部宽度小于新添加区域的顶部的候选区域
                bottomCandidateRects = bottomCandidateRects.filter({$0.maxX > cRect.minX})
                
                topCandidateRects.append(cRect)
                topLastXOffset = rect.origin.x - leadingSpace;
                
                if (rect.origin.x + rect.size.width + trailingSpace + horzSpace > topMaxWidth)
                {
                    topMaxWidth = rect.origin.x + rect.size.width + trailingSpace + horzSpace;
                }
                
            }
            
            if rect.origin.y + rect.size.height + bottomSpace + vertSpace > maxHeight
            {
                maxHeight = rect.origin.y + rect.size.height + bottomSpace + vertSpace;
            }
            
            if rect.origin.x + rect.size.width + trailingSpace + horzSpace > maxWidth
            {
                maxWidth = rect.origin.x + rect.size.width + trailingSpace + horzSpace
            }

            
            
            
            sbvtgFrame.frame = rect;
            
        }
        
        if (sbs.count > 0)
        {
            maxWidth -= horzSpace
            maxHeight -= vertSpace
        }
        
        maxWidth += lsc.tg_trailingPadding;
        maxHeight += lsc.tg_bottomPadding;
        
        if !hasBoundaryLimit
        {
            selfSize.height = maxHeight
        }
        
        if lsc.width.isWrap
        {
            selfSize.width = maxWidth;
        }
        else
        {
            var addXPos:CGFloat = 0;
            let mghorz = self.tgConvertLeftRightGravityToLeadingTrailing(lsc.tg_gravity & TGGravity.vert.mask)
            
            if (mghorz == TGGravity.horz.center)
            {
                addXPos = (selfSize.width - maxWidth) / 2;
            }
            else if (mghorz == TGGravity.horz.trailing)
            {
                addXPos = selfSize.width - maxWidth;
            }
            
            if (addXPos != 0)
            {
                for i in 0 ..< sbs.count
                {
                    sbs[i].tgFrame.leading += addXPos
                    
                }
            }
            
        }
        
        
        return selfSize;
    }
    
    
}
