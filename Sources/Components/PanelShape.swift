import SwiftUI

struct PanelShape: Shape {
    var isExpanded: Bool = false

    func path(in rect: CGRect) -> Path {
        isExpanded ? flushPath(in: rect) : bumpPath(in: rect)
    }

    private func flushPath(in rect: CGRect) -> Path {
        Path(roundedRect: rect, cornerRadius: 16)
    }

    private func bumpPath(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let tb = PanelController.tabWidth
        let cr: CGFloat = 16
        let crvR: CGFloat = 20
        let tabH = PanelController.tabHeight
        let tabCY = (PanelController.titleBarHeight + h) / 2
        let tabTop = tabCY - tabH / 2
        let tabBot = tabCY + tabH / 2

        var p = Path()

        p.move(to: CGPoint(x: tb + cr, y: 0))

        p.addLine(to: CGPoint(x: w - cr, y: 0))

        p.addArc(center: CGPoint(x: w - cr, y: cr),
                 radius: cr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)

        p.addLine(to: CGPoint(x: w, y: h - cr))

        p.addArc(center: CGPoint(x: w - cr, y: h - cr),
                 radius: cr, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)

        p.addLine(to: CGPoint(x: tb + cr, y: h))

        p.addArc(center: CGPoint(x: tb + cr, y: h - cr),
                 radius: cr, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)

        p.addLine(to: CGPoint(x: tb, y: tabBot + crvR))

        p.addCurve(to: CGPoint(x: 0, y: tabBot),
                   control1: CGPoint(x: tb, y: tabBot),
                   control2: CGPoint(x: 0, y: tabBot + crvR))

        p.addLine(to: CGPoint(x: 0, y: tabTop))

        p.addCurve(to: CGPoint(x: tb, y: tabTop - crvR),
                   control1: CGPoint(x: 0, y: tabTop - crvR),
                   control2: CGPoint(x: tb, y: tabTop))

        p.addLine(to: CGPoint(x: tb, y: cr))

        p.addArc(center: CGPoint(x: tb + cr, y: cr),
                 radius: cr, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)

        p.closeSubpath()
        return p
    }
}
