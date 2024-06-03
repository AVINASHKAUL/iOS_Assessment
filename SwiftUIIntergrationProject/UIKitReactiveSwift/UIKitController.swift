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
    let addressesHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.accessibilityValue = "addressesHorizontalStackView"
        return stackView
    }()
    
    let curntWeatherVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.accessibilityValue = "curntWeatherVerticalStackView"
        return stackView
    }()
    
    var addressPrimary: UILabel = {
        let label = UILabel()
        label.text = "Current Select Primary Address"
        label.accessibilityValue = "primaryAddressLabel"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    var secondary: UILabel = {
        let label = UILabel()
        label.text = "Current secondary info"
        label.textAlignment = .center
        label.accessibilityValue = "secondaryLabel"
        label.numberOfLines = 0
        return label
    }()
    
    var currentTemp: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.accessibilityValue = "currentTemperatureLabel"
        label.text = "Current temprature"
        return label
    }()
    
    let weatherListView: UITableView = {
        let tableView = UITableView()
        tableView.accessibilityValue = "weatherListView"
        return tableView
    }()
    // AVINASH_TODO: Move to Coordinator
    let viewModel: UIKitViewModel
    var cancelBag = Set<AnyCancellable>()
    
    init( viewModel: UIKitViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        viewModel.onSelectAddress(name: viewModel.viewData.selectedAddress.name)
    }

    func render(viewData: UIKitViewModel.ViewData) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            addressPrimary.text = viewData.selectedAddress.name
            secondary.text = viewData.selectedAddress.secondary
            currentTemp.text = viewData.selectedAddress.currentTemperature
            weatherListView.reloadData()
        }
        
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
        curntWeatherVerticalStackView.spacing = 6

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

            // Table View constraints
            weatherListView.topAnchor.constraint(equalTo: curntWeatherVerticalStackView.bottomAnchor, constant: 3),
            weatherListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weatherListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weatherListView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}


extension UIKitController:  UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.viewData.weathers?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if let weather = self.viewModel.viewData.weathers?[indexPath.row] {
            // AVINASH_TODO: Move the cell to it's own Subclass of UITableViewCell
            let verticalStackView = UIStackView()
            verticalStackView.axis = .vertical
            verticalStackView.distribution = .fill
            verticalStackView.alignment = .leading
            verticalStackView.spacing = 4
            verticalStackView.translatesAutoresizingMaskIntoConstraints = false
            
            let dateLabel = UILabel()
            dateLabel.text = weather.date
            dateLabel.font = UIFont.systemFont(ofSize: 16)
                    
            let rainLabel = UILabel()
            rainLabel.text = "LightRain"
            rainLabel.font = UIFont.systemFont(ofSize: 14)
            
            let tempratureLabel = UILabel()
            tempratureLabel.text = weather.temprature
            tempratureLabel.font = UIFont.systemFont(ofSize: 14)
            
            verticalStackView.addArrangedSubview(dateLabel)
            verticalStackView.addArrangedSubview(rainLabel)
            verticalStackView.addArrangedSubview(tempratureLabel)
            
            cell.contentView.addSubview(verticalStackView)
            
            NSLayoutConstraint.activate([
                        verticalStackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 15),
                        verticalStackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
                        verticalStackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
                        verticalStackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10)
                    ])
    
            
            
            return cell
        }
        cell.textLabel?.text = "Row"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // AVINASH_TODO: On click of row open the detail modal for it.
    }
}

