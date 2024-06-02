//
//  UIKitReactiveController.swift
//  SwiftUIIntergrationProject
//
//  Created by Yuchen Nie on 4/5/24.
//

import Foundation
import UIKit
import Combine
import ReactiveSwift
import ReactiveCocoa
import SnapKit

// TODO: Create UIKit View that either pre-selects address or user enters address, and retrieves current weather plus weather forecast
class UIKitController: UIViewController {

    
    // Define the UI components
    let addressesHorizontalStackView = UIStackView()
    
    let curntWeatherVerticalStackView = UIStackView()
    var addressPrimary: UILabel = {
        let label = UILabel()
        label.text = "Current Select Primary Address"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    var secondary: UILabel = {
        let label = UILabel()
        label.text = "Current secondary info"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    var currentTemp: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Current temprature"
        return label
    }()
    
    let weatherListView = UITableView()

    // AVINASH_TODO: Move to Coordinator
    let viewModel = UIKitViewModel(weatherService: Environment.current.weatherServiceReactive, addressService: Environment.current.addressService)
    var cancelBag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Setup Addresses Horizontal Stack View
        configureAddressesHorizontalStackView()

        // Setup Vertical Stack View
        configureCurrentWeatherStackView()

        // Setup TableView
        configureWeatherListView()

        // Add constraints
        setupConstraints()
        
        viewModel.$viewData.sink { [weak self] viewData in
            guard let self else { return }
            self.render(viewData: viewData)
        }.store(in: &cancelBag)
    }

    @MainActor
    func render(viewData: UIKitViewModel.ViewData) {
        addressPrimary.text = viewData.selectedAddress.name
        secondary.text = viewData.selectedAddress.secondary
        currentTemp.text = viewData.selectedAddress.currentTemperature
    }
    
    // MARK: Header view
    
    func configureAddressesHorizontalStackView() {
        addressesHorizontalStackView.axis = .horizontal
        addressesHorizontalStackView.distribution = .fillEqually
        addressesHorizontalStackView.alignment = .fill
        addressesHorizontalStackView.spacing = 10

        // AVINASH_TODO: This should be dynamic, and horizontal collectionView not a horizontal stack view.
        // For time crunhc have kept it like this
        for address in viewModel.viewData.addresses {
            let button = UIButton()
            button.setTitle(address, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .systemBlue
            button.addAction(UIAction(handler: { [weak self] _ in
                guard let self else {return}
                // AVINASH_TODO: Weakify this
                self.viewModel.onSelectAddress(name: button.currentTitle ?? "Default")
                    }), for: .touchUpInside)
            addressesHorizontalStackView.addArrangedSubview(button)
        }

        view.addSubview(addressesHorizontalStackView)
        addressesHorizontalStackView.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: Current Weather Section
    func configureCurrentWeatherStackView() {
        curntWeatherVerticalStackView.axis = .vertical
        curntWeatherVerticalStackView.distribution = .fillEqually
        curntWeatherVerticalStackView.alignment = .fill
        curntWeatherVerticalStackView.spacing = 10

        // Add sample labels to the vertical stack view
        curntWeatherVerticalStackView.addArrangedSubview(addressPrimary)
        curntWeatherVerticalStackView.addArrangedSubview(secondary)
        curntWeatherVerticalStackView.addArrangedSubview(currentTemp)

        view.addSubview(curntWeatherVerticalStackView)
        curntWeatherVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: Forecast weather list
    func configureWeatherListView() {
        weatherListView.dataSource = self
        weatherListView.delegate = self

        view.addSubview(weatherListView)
        weatherListView.translatesAutoresizingMaskIntoConstraints = false
    }

    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Horizontal Stack View constraints
            addressesHorizontalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            addressesHorizontalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            addressesHorizontalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            addressesHorizontalStackView.heightAnchor.constraint(equalToConstant: 50),

            // Vertical Stack View constraints
            curntWeatherVerticalStackView.topAnchor.constraint(equalTo: addressesHorizontalStackView.bottomAnchor, constant: 10),
            curntWeatherVerticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            curntWeatherVerticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            curntWeatherVerticalStackView.heightAnchor.constraint(equalToConstant: 150),

            // Table View constraints
            weatherListView.topAnchor.constraint(equalTo: curntWeatherVerticalStackView.bottomAnchor, constant: 10),
            weatherListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weatherListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weatherListView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}


extension UIKitController:  UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20 // Example number of rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = "Row \(indexPath.row + 1)"
        return cell
    }
    
}

