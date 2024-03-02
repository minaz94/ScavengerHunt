//
//  ScavengerHuntDetailViewController.swift
//  ScavengerHunt
//
//  Created by Mina on 3/1/24.
//

import UIKit
import MapKit
import PhotosUI

class ScavengerHuntDetailViewController: UIViewController {
    
    var scavengerHunt: ScavengerHunt!
    
    @IBOutlet weak var completedImageView: UIImageView!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var attachPhotoButton: UIButton!
    
    @IBOutlet weak var treasureMapView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    var onComposeScavengerHunt: ((ScavengerHunt) -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
        updateViews()
        updateMapView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let scavengerHunt {
            onComposeScavengerHunt?(scavengerHunt)
        }
    }
    
    
    
    func setupMapView() {
      
        mapView.delegate = self
        mapView.register(TaskAnnotationView.self, forAnnotationViewWithReuseIdentifier: TaskAnnotationView.identifier)
        mapView.layer.cornerRadius = 12
    }
    
    
    func updateViews() {
        titleLabel.text = "Title: \(scavengerHunt.title)"
        descriptionLabel.text = "Description: \(scavengerHunt.description)"

        let completedImage = UIImage(systemName: scavengerHunt.isComplete ? "circle.inset.filled" : "circle")
        
        completedImageView.image = completedImage?.withRenderingMode(.alwaysTemplate)
        completedLabel.text = scavengerHunt.isComplete ? "Complete" : "Incomplete"

        let color: UIColor = scavengerHunt.isComplete ? .systemBlue : .tertiaryLabel
        completedImageView.tintColor = color
        completedLabel.textColor = color

        mapView.isHidden = !scavengerHunt.isComplete
        attachPhotoButton.isHidden = scavengerHunt.isComplete
        treasureMapView.isHidden = scavengerHunt.isComplete
        
    }

    
    @IBAction func attachPhotoButtonPressed(_ sender: Any) {

        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
            
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        self?.presentImagePicker()
                    }
                case .denied:
                    DispatchQueue.main.async {
                        self?.presentGoToSettingsAlert()
                    }
                default:
                    DispatchQueue.main.async {
                        self?.presentGoToSettingsAlert()
                    }
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.presentImagePicker()
            }
        }
    }
    
    func presentImagePicker() {

        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self

        present(picker, animated: true)
    }
    
    
    func updateMapView() {
        guard let imageLocation = scavengerHunt.imageLocation else { return }

        // https://developer.apple.com/documentation/mapkit/mkmapview
        let coordinate = imageLocation.coordinate

        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func presentGoToSettingsAlert() {
        let alertController = UIAlertController (
            title: "Photo Access Required",
            message: "In order to post a photo to complete a task, we need access to your photo library. You can allow access in Settings",
            preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }

        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }


    func showAlert(for error: Error? = nil) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: "\(error?.localizedDescription ?? "Please try again...")",
            preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)

        present(alertController, animated: true)
    }
}

extension ScavengerHuntDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: TaskAnnotationView.identifier, for: annotation) as? TaskAnnotationView else {
            fatalError("Unable to dequeue TaskAnnotationView")
        }

        annotationView.configure(with: scavengerHunt.image)
        return annotationView
    }
    
}

extension ScavengerHuntDetailViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)


        let result = results.first

        guard let assetId = result?.assetIdentifier,
              let location = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location else {
            return
        }

        print("📍 Image location coordinate: \(location.coordinate)")
        

        guard let provider = result?.itemProvider,
       
              provider.canLoadObject(ofClass: UIImage.self) else { return }


        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in


            if let error = error {
              DispatchQueue.main.async { [weak self] in self?.showAlert(for:error) }
            
            }


            guard let image = object as? UIImage else { return }

            DispatchQueue.main.async { [weak self] in


                self?.scavengerHunt.set(image, with: location)
                self?.updateViews()
                self?.updateMapView()
            }
        }
    }
    
    
}
