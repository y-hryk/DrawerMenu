//
//  DrawerMenu.swift
//  DrawerMenu
//

import UIKit

public extension UIViewController {
    func drawer() -> DrawerMenu? {
        var viewController: UIViewController? = self
        while viewController != nil {
            if viewController is DrawerMenu {
                return viewController as? DrawerMenu
            }
            viewController = viewController?.parent
        }
        return nil
    }
}

public class DrawerMenu: UIViewController, UIGestureRecognizerDelegate {

    public enum PanGestureType { case pan, screenEdge, none }
    public enum Side { case left, right }
    public enum AutomaticallyOpenClose {
        case none, low, middle, high, custom(CGFloat) // custom: 0 - 100
        func percentage() -> CGFloat {
            switch self {
            case .none: return 0
            case .low: return 15 / 100
            case .middle: return 50 / 100
            case .high: return 75 / 100
            case .custom(let percentage): return percentage / 100
            }
        }
    }

    public var leftMenuWidth: CGFloat = UIScreen.main.bounds.width * 0.8 {
        didSet { changeLeftMenuWidth() }
    }
    public var rightMenuWidth: CGFloat = UIScreen.main.bounds.width * 0.8 {
        didSet { changeRightMenuWidth() }
    }
    public var style: DrawerMenuStyle = Slide() {
        didSet { changeStyle(style: style) }
    }
    public var shouldRecognizeSimultaneously: Bool = false
    public var automaticallyOpenClose: AutomaticallyOpenClose = .low
    public var animationDuration: CGFloat = 0.2
    public var closeTapGesturesEnabled: Bool = true
    public var panGestureType: PanGestureType = .pan {
        didSet {
            removeGesture()
            addPanGesture(type: panGestureType)
        }
    }
    public private(set) var isOpenLeft: Bool = false
    public private(set) var isOpenRight: Bool = false

    public var centerViewController: UIViewController
    public var leftViewController: UIViewController?
    public var rightViewContoller: UIViewController?

    internal var centerContainerView = UIView(frame: .zero)
    internal var leftContainerView: UIView?
    internal var rightContainerView: UIView?
    internal let opacityView = UIView(frame: .zero)

    private enum MenuStatus: Int { case open = 1, close = 0 }
    private var startLocation: CGPoint = .zero
    private var leftBeganStatus: Bool = false
    private var rightBeganStatus: Bool = false
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var leftEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    private var rightEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?

    private var leftProgress: CGFloat {
        get {
            if leftViewController == nil { return 0 }
            return style.leftProgress(menuWidth: leftMenuWidth, drawer: self)
        }
        set {
            if leftViewController == nil { return }
            let ratio = min(max(newValue, 0), 1)
            style.leftTransition(menuWidth: leftMenuWidth, progress: ratio, drawer: self)
        }
    }

    private var rightProgress: CGFloat {
        get {
            if rightViewContoller == nil { return 0 }
            return style.rightProgress(menuWidth: rightMenuWidth, drawer: self)
        }
        set {
            if rightViewContoller == nil { return }
            let ratio = min(max(newValue, 0), 1)
            style.rightTransition(menuWidth: rightMenuWidth, progress: ratio, drawer: self)
        }
    }

    public init(center: UIViewController, left: UIViewController? = nil, right: UIViewController? = nil) {

        centerViewController = center
        leftViewController = left
        rightViewContoller = right
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addTapGesture()
        addPanGesture(type: panGestureType)
        changeStyle(style: style)

    }

    // MARK: Public
    public func replace(center controller: UIViewController) {

        centerViewController.view.removeFromSuperview()
        centerViewController.removeFromParent()
        centerViewController.willMove(toParent: self)

        centerViewController = controller

        addChild(centerViewController)
        centerContainerView.addSubview(centerViewController.view)
        centerViewController.didMove(toParent: self)

        centerContainerView.addSubview(opacityView)

        close(to: .left)
        close(to: .right)
    }

    public func open(to side: Side, animated: Bool = true, completion: (() -> Void)? = nil) {
        if side == .left {
            updateLeftProgress(status: .open, animated: animated) { [weak self] in
                completion?()
                self?.isOpenLeft = true
                self?.isOpenRight = false
            }
        }
        if side == .right {
            updateRightProgress(status: .open, animated: animated) { [weak self] in
                completion?()
                self?.isOpenRight = true
                self?.isOpenLeft = false
            }
        }
    }

    public func close(to side: Side, animated: Bool = true, completion: (() -> Void)? = nil) {
        if side == .left {
            updateLeftProgress(status: .close, animated: animated) { [weak self] in
                completion?()
                self?.isOpenLeft = false
                self?.isOpenRight = false
            }
        }
        if side == .right {
            updateRightProgress(status: .close, animated: animated) { [weak self] in
                completion?()
                self?.isOpenRight = false
                self?.isOpenLeft = false
            }
        }
    }

    // MAKR: Private
    private func setupViews() {

        view.backgroundColor = .white

        // MainViewController
        centerContainerView.frame = view.frame
        centerContainerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(centerContainerView)

        addChild(centerViewController)
        centerContainerView.addSubview(centerViewController.view)
        centerViewController.didMove(toParent: self)

        // LeftViewController
        if let left = leftViewController {
            var frame = left.view.bounds
            frame.size.width = leftMenuWidth
            left.view.frame = frame
            left.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]

            leftContainerView = UIView()
            leftContainerView?.frame = frame
            leftContainerView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.addSubview(leftContainerView!)

            addChild(left)
            leftContainerView?.addSubview(left.view)
            left.didMove(toParent: self)

            close(to: .left, animated: false, completion: nil)
        }

        // RightViewContoller
        if let right = rightViewContoller {

            var frame = right.view.bounds
            frame.size.width = rightMenuWidth
            right.view.frame = frame
            right.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]

            rightContainerView = UIView()
            rightContainerView?.frame = frame
            rightContainerView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.addSubview(rightContainerView!)

            addChild(right)
            rightContainerView?.addSubview(right.view)
            right.didMove(toParent: self)

            close(to: .right, animated: false, completion: nil)
        }

        // opacityView
        opacityView.frame = centerViewController.view.frame
        opacityView.backgroundColor = .black
        opacityView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        centerContainerView.addSubview(opacityView)
        opacityView.alpha = 0.0
    }

    private func changeLeftMenuWidth() {

        if let left = leftContainerView {
            var frame = left.bounds
            frame.size.width = leftMenuWidth
            UIView.animate(withDuration: TimeInterval(animationDuration),
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: {
                            left.frame = frame
            }, completion: nil)
            isOpenLeft ? open(to: .left) : close(to: .left)
        }
    }

    private func changeRightMenuWidth() {

        if let right = rightContainerView {
            var frame = right.bounds
            frame.size.width = rightMenuWidth
            UIView.animate(withDuration: TimeInterval(animationDuration),
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: {
                            right.frame = frame
            }, completion: nil)
            isOpenRight ? open(to: .right) : close(to: .right)
        }
    }

    private func changeStyle(style: DrawerMenuStyle) {

        centerContainerView.transform = CGAffineTransform.identity

        style.removeShadow(view: centerContainerView)
        style.removeShadow(view: leftContainerView)
        style.removeShadow(view: rightContainerView)
        style.setup(drawer: self)
        close(to: .left, animated: false)
        close(to: .right, animated: false)
    }

    private func addTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(opacityViewPressed))
        opacityView.addGestureRecognizer(tapGestureRecognizer)
    }

    private func addPanGesture(type: PanGestureType) {

        switch type {
        case .pan:
            if panGestureRecognizer == nil {
                panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureCallback(gestureRecognizer:)))
                panGestureRecognizer?.minimumNumberOfTouches = 1
                panGestureRecognizer?.maximumNumberOfTouches = 1
                panGestureRecognizer?.delegate = self
                view.addGestureRecognizer(panGestureRecognizer!)
            }
        case .screenEdge:

            if leftEdgePanGestureRecognizer == nil {
                leftEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self,
                                                                                action: #selector(leftEdgePanGestureCallback(gestureRecognizer:)))
                leftEdgePanGestureRecognizer?.edges = [.left]
                leftEdgePanGestureRecognizer?.minimumNumberOfTouches = 1
                leftEdgePanGestureRecognizer?.maximumNumberOfTouches = 1
                leftEdgePanGestureRecognizer?.delegate = self
                view.addGestureRecognizer(leftEdgePanGestureRecognizer!)
            }

            if rightEdgePanGestureRecognizer == nil {
                rightEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self,
                                                                                 action: #selector(rightEdgePanGestureCallback(gestureRecognizer:)))
                rightEdgePanGestureRecognizer?.edges = [.right]
                rightEdgePanGestureRecognizer?.minimumNumberOfTouches = 1
                rightEdgePanGestureRecognizer?.maximumNumberOfTouches = 1
                rightEdgePanGestureRecognizer?.delegate = self
                view.addGestureRecognizer(rightEdgePanGestureRecognizer!)
            }
        case .none: break
        }
    }

    private func removeGesture() {

        if leftEdgePanGestureRecognizer != nil {
            view.removeGestureRecognizer(leftEdgePanGestureRecognizer!)
            leftEdgePanGestureRecognizer = nil
        }
        if rightEdgePanGestureRecognizer != nil {
            view.removeGestureRecognizer(rightEdgePanGestureRecognizer!)
            rightEdgePanGestureRecognizer = nil
        }
        if panGestureRecognizer != nil {
            view.removeGestureRecognizer(panGestureRecognizer!)
            panGestureRecognizer = nil
        }
    }

    private func updateLeftProgress(status: MenuStatus, animated: Bool, completion: (() -> Void)? = nil) {

        let isAppearing = status == .open ? true : false
        let callLifeCycle = callViewControllerLifeCycle(side: .left, status: status)
        if callLifeCycle {
            leftViewController?.beginAppearanceTransition(isAppearing, animated: false)
        }
        if animated {

            UIView.animate(withDuration: TimeInterval(animationDuration),
                           delay: 0.0, options: .curveEaseInOut,
                           animations: { [weak self] in
                       self?.leftProgress = CGFloat(status.rawValue)
            }, completion: { [weak self] _ in
                completion?()
                if callLifeCycle {
                    self?.leftViewController?.endAppearanceTransition()
                }
            })

        } else {
            leftProgress = CGFloat(status.rawValue)
            completion?()
            if callLifeCycle {
                leftViewController?.endAppearanceTransition()
            }
        }
    }

    private func updateRightProgress(status: MenuStatus, animated: Bool, completion: (() -> Void)? = nil) {

        let isAppearing = status == .open ? true : false
        let callLifeCycle = callViewControllerLifeCycle(side: .right, status: status)
        if callLifeCycle {
            rightViewContoller?.beginAppearanceTransition(isAppearing, animated: false)
        }
        if animated {
            UIView.animate(withDuration: TimeInterval(animationDuration),
                           delay: 0.0, options: .curveEaseInOut,
                           animations: { [weak self] in
                            self?.rightProgress = CGFloat(status.rawValue)
                }, completion: { [weak self] _ in
                    completion?()
                    if callLifeCycle {
                        self?.rightViewContoller?.endAppearanceTransition()
                    }
            })
        } else {
            rightProgress = CGFloat(status.rawValue)
            completion?()
            if callLifeCycle {
                rightViewContoller?.endAppearanceTransition()
            }
        }
    }

    private func callViewControllerLifeCycle(side: Side, status: MenuStatus) -> Bool {
        var isOpen: Bool = false
        if side == .left { isOpen = isOpenLeft }
        if side == .right { isOpen = isOpenRight }

        if status == .open {
            return !(isOpen && status == .open)
        } else {
            return !(!isOpen && status == .close)
        }
    }

    private func rightMenuGestureHandle(gesture: UIPanGestureRecognizer) {

        if isOpenLeft { return }
        let location = gesture.location(in: view)

        switch gesture.state {
        case .changed:
            let distance = rightBeganStatus ? location.x - startLocation.x : startLocation.x - location.x
            if distance >= 0 {
                let ratio = distance / rightMenuWidth
                let progress = rightBeganStatus ? 1 - ratio : ratio
                rightProgress = progress
            }
            if distance < 0 && !isOpenRight {
                gesture.state = .ended
            }
        case .ended, .cancelled, .failed:
            if rightBeganStatus {
                rightProgress >= (1.0 - automaticallyOpenClose.percentage()) ? open(to: .right) : close(to: .right)
            } else {
                rightProgress >= automaticallyOpenClose.percentage() ? open(to: .right) : close(to: .right)
            }
            startLocation = .zero
            rightBeganStatus = false
        default: break
        }
    }

    private func leftMenuGestureHandle(gesture: UIPanGestureRecognizer) {

        if isOpenRight { return }

        let location = gesture.location(in: view)
        switch gesture.state {
        case .changed:

            let distance = leftBeganStatus ? startLocation.x - location.x : location.x - startLocation.x
            if distance >= 0 {
                let ratio = distance / leftMenuWidth
                let progress = leftBeganStatus ? 1 - ratio : ratio
                leftProgress = progress
            }
            if distance < 0 && !isOpenLeft {
                gesture.state = .ended
            }

        case .ended, .cancelled, .failed:
            if leftBeganStatus {
                leftProgress >= (1 - automaticallyOpenClose.percentage()) ? open(to: .left) : close(to: .left)
            } else {
                leftProgress >= automaticallyOpenClose.percentage() ? open(to: .left) : close(to: .left)
            }
            startLocation = .zero
            leftBeganStatus = false
        default: break
        }
    }

    private func setupGestureBegan(gestureRecognizer: UIPanGestureRecognizer) {
        let location = gestureRecognizer.location(in: view)
        switch gestureRecognizer.state {
        case .began:
            startLocation = location
            leftBeganStatus = leftProgress == 1
            rightBeganStatus = rightProgress == 1
        default: break
        }
    }

    // MARK: Selector
    @objc private func opacityViewPressed() {

        if !closeTapGesturesEnabled { return }
        if isOpenLeft || isOpenRight {
            close(to: .left)
            close(to: .right)
        }
    }

    @objc private func leftEdgePanGestureCallback(gestureRecognizer: UIPanGestureRecognizer) {

        setupGestureBegan(gestureRecognizer: gestureRecognizer)
        leftMenuGestureHandle(gesture: gestureRecognizer)
    }

    @objc private func rightEdgePanGestureCallback(gestureRecognizer: UIPanGestureRecognizer) {

        setupGestureBegan(gestureRecognizer: gestureRecognizer)
        rightMenuGestureHandle(gesture: gestureRecognizer)
    }

    @objc private func panGestureCallback(gestureRecognizer: UIPanGestureRecognizer) {

        setupGestureBegan(gestureRecognizer: gestureRecognizer)

        let location = gestureRecognizer.location(in: view)
        let diff = location.x - startLocation.x

        // Swipe right
        if diff > 0 {
            if rightProgress > 0 {
                rightMenuGestureHandle(gesture: gestureRecognizer)
            } else {
                leftMenuGestureHandle(gesture: gestureRecognizer)
            }
        }
        // Swipe left
        if diff < 0 {
            if leftProgress > 0 {
                leftMenuGestureHandle(gesture: gestureRecognizer)
            } else {
                rightMenuGestureHandle(gesture: gestureRecognizer)
            }
        }
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return shouldRecognizeSimultaneously
    }

    // MARK: Override
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.centerViewController.preferredStatusBarStyle
    }
}
