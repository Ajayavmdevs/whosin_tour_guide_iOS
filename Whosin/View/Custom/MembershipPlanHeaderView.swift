//
//  MembershipPlanHeaderView.swift
//  Whosin
//
//  Created by Samir Makadia on 28/07/23.
//

import UIKit

protocol MembershipPlanHeaderViewDelegate: class {
    func didSelectTab(at index: Int)
}

class MembershipPlanHeaderView: UIView {
    weak var delegate: MembershipPlanHeaderViewDelegate?
    private var tabLabels: [UILabel] = []
    private var tabbgView: [GradientView] = []
    private var selectIndicator: GradientView!
    private let containerView = UIView()
    private let stackView = UIStackView()

    public var selectedIndex: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGrayBackground()
        setupTabLabels()
        setupSelectIndicator()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGrayBackground() {
        self.backgroundColor = .black
        containerView.backgroundColor = UIColor(hexString: "#22222C")
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 9
        addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupTabLabels() {
        let tabTitles = ["POPULAR", "MORE PLANS"]
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10

        for (index, title) in tabTitles.enumerated() {
            let gradientBackground = GradientView()
            gradientBackground.diagonalMode = true
            gradientBackground.translatesAutoresizingMaskIntoConstraints = false
            gradientBackground.startColor = .clear
            gradientBackground.endColor = .clear
            gradientBackground.layer.cornerRadius = 9

            let label = UILabel()
            label.textAlignment = .center
            label.text = title
            label.textColor = ColorBrand.white
            label.font = FontBrand.SFsemiboldFont(size: 14)
            label.tag = index
            label.isUserInteractionEnabled = true
            label.sizeToFit()

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabTapped(_:)))
            label.addGestureRecognizer(tapGesture)

            gradientBackground.addSubview(label)

            label.translatesAutoresizingMaskIntoConstraints = false
            label.centerXAnchor.constraint(equalTo: gradientBackground.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: gradientBackground.centerYAnchor).isActive = true
            stackView.addArrangedSubview(gradientBackground)
            tabLabels.append(label)
            tabbgView.append(gradientBackground)
        }

        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
                stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5)
            ])
    }


    private func setupSelectIndicator() {
        tabbgView[selectedIndex].startColor =  UIColor.init(hexString: "#1333DE")
        tabbgView[selectedIndex].endColor = UIColor.init(hexString: "#8F55EE")
        tabbgView[selectedIndex].diagonalMode = true
    }

    public func setupData(_ index: Int) {
        selectedIndex = index
        moveSelectIndicator(to: index)
    }


    @objc private func tabTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedLabel = sender.view as? UILabel else { return }
        let selectedIndex = selectedLabel.tag

        moveSelectIndicator(to: selectedIndex)
        delegate?.didSelectTab(at: selectedIndex)
    }

    private func moveSelectIndicator(to index: Int) {
        for (i, bgView) in tabbgView.enumerated() {
            if i == index {
                bgView.startColor = UIColor(hexString: "#1333DE")
                bgView.endColor = UIColor(hexString: "#8F55EE")
                bgView.diagonalMode = true
            } else {
                bgView.startColor = .clear
                bgView.endColor = .clear
                bgView.diagonalMode = true
            }
        }
        
        selectedIndex = index
    }

}
