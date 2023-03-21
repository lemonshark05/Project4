//
//  DetailViewController.swift
//  scavenger
//
//  Created by lemonshark on 2023/3/14.
//

import UIKit
import MapKit
import PhotosUI

class DetailViewController: UIViewController {
    
    @IBOutlet weak var completedImageView: UIImageView!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var attachPhotoButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var image: Image!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register custom annotation view
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: ImageAnnotationView.identifier)

        // Set mapView delegate
        mapView.delegate = self
        
        // UI Candy
        mapView.layer.cornerRadius = 12

        updateUI()
        updateMapView()
    }
    
    private func updateUI() {
        titleLabel.text = image.title
        descriptionLabel.text = image.description

        let completedImage = UIImage(systemName: image.isComplete ? "circle.inset.filled" : "circle")

        // calling `withRenderingMode(.alwaysTemplate)` on an image allows for coloring the image via it's `tintColor` property.
        completedImageView.image = completedImage?.withRenderingMode(.alwaysTemplate)
        completedLabel.text = image.isComplete ? "Complete" : "Incomplete"

        let color: UIColor = image.isComplete ? .systemBlue : .tertiaryLabel
        completedImageView.tintColor = color
        completedLabel.textColor = color

        mapView.isHidden = !image.isComplete
        attachPhotoButton.isHidden = image.isComplete
    }

    @IBAction func didTapAttachPhotoButton(_ sender: Any) {
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
                    // Request photo library access
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                        switch status {
                        case .authorized:
                            // The user authorized access to their photo library
                            // show picker (on main thread)
                            DispatchQueue.main.async {
                                self?.presentImagePicker()
                            }
                        default:
                            // show settings alert (on main thread)
                            DispatchQueue.main.async {
                                // Helper method to show settings alert
                                self?.presentGoToSettingsAlert()
                            }
                        }
                    }
                } else {
                    // Show photo picker
                    presentImagePicker()
                }
    }
    
    private func presentImagePicker() {
        // Create a configuration object
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())

        // Set the filter to only show images as options (i.e. no videos, etc.).
        config.filter = .images

        // Request the original file format. Fastest method as it avoids transcoding.
        config.preferredAssetRepresentationMode = .current

        // Only allow 1 image to be selected at a time.
        config.selectionLimit = 1

        // Instantiate a picker, passing in the configuration.
        let picker = PHPickerViewController(configuration: config)

        // Set the picker delegate so we can receive whatever image the user picks.
        picker.delegate = self

        // Present the picker.
        present(picker, animated: true)

    }

    func updateMapView() {
        // Make sure the task has image location.
        guard let imageLocation = image.imageLocation else { return }

        // Get the coordinate from the image location. This is the latitude / longitude of the location.
        // https://developer.apple.com/documentation/mapkit/mkmapview
        let coordinate = imageLocation.coordinate

        // Set the map view's region based on the coordinate of the image.
        // The span represents the maps's "zoom level". A smaller value yields a more "zoomed in" map area, while a larger value is more "zoomed out".
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        // Add an annotation to the map view based on image location.
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
}

// Conform to PHPickerViewControllerDelegate + implement required method(s)
extension DetailViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Dismiss the picker
        picker.dismiss(animated: true)

        // Get the selected image asset (we can grab the 1st item in the array since we only allowed a selection limit of 1)
        let result = results.first

        // Get image location
        // PHAsset contains metadata about an image or video (ex. location, size, etc.)
        guard let assetId = result?.assetIdentifier,
              let location = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location else {
            return
        }

        print("📍 Image location coordinate: \(location.coordinate)")
        // Make sure we have a non-nil item provider
        guard let provider = result?.itemProvider,
              // Make sure the provider can load a UIImage
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        // Load a UIImage from the provider
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in

            // Handle any errors
            if let error = error {
              DispatchQueue.main.async { [weak self] in self?.showAlert(for:error) }
            
            }

            // Make sure we can cast the returned object to a UIImage
            guard let image = object as? UIImage else { return }

            print("🌉 We have an image!")

            // UI updates should be done on main thread, hence the use of `DispatchQueue.main.async`
            DispatchQueue.main.async { [weak self] in

                // Set the picked image and location on the task
                self?.image.set(image, with: location)

                // Update the UI since we've updated the task
                self?.updateUI()

                // Update the map view since we now have an image an location
                self?.updateMapView()
            }
        }
    }
}
// Conform to MKMapKitDelegate + implement mapView(_:viewFor:) delegate method.
extension DetailViewController: MKMapViewDelegate {
    // Implement mapView(_:viewFor:) delegate method.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        // Dequeue the annotation view for the specified reuse identifier and annotation.
        // Cast the dequeued annotation view to your specific custom annotation view class, `TaskAnnotationView`
        // 💡 This is very similar to how we get and prepare cells for use in table views.
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ImageAnnotationView.identifier, for: annotation) as? ImageAnnotationView else {
            fatalError("Unable to dequeue ImageAnnotationView")
        }

        // Configure the annotation view, passing in the task's image.
        annotationView.configure(with: image.image)
        return annotationView
    }
}
// Helper methods to present various alerts
extension DetailViewController {

    /// Presents an alert notifying user of photo library access requirement with an option to go to Settings in order to update status.
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

    /// Show an alert for the given error
    private func showAlert(for error: Error? = nil) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: "\(error?.localizedDescription ?? "Please try again...")",
            preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)

        present(alertController, animated: true)
    }
}

