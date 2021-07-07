//
//  PhotoViewController.swift
//  reSearch
//
//  Created by Jennifer Ruiz on 01/07/21.
//

import UIKit
import Firebase
import FirebaseStorage

class PhotoViewController: UIViewController {

    @IBOutlet weak var imagen: UIImageView!
    let db = Firestore.firestore()
    var uidImagen: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func buscarFotoBtn(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .savedPhotosAlbum
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func publicarBtn(_ sender: UIButton) {
        guard let email = Auth.auth().currentUser?.email else { return }
        
        db.collection("users").document(email).getDocument { [self] (documentSnapshot, err) in
            if let document = documentSnapshot, err == nil {
                if let user = document.get("userName"){
                    if let photo = document.get("url"){
                        guard let image = imagen.image, let datosImagen = image.jpegData(compressionQuality: 1.0) else {
                                   print("Error")
                                   return
                               }
                               //asignar un id unico para esos datos
                               let imageNombre = UUID().uuidString
                               uidImagen = imageNombre
                               
                               let imageReferencia = Storage.storage()
                                   .reference()
                                   .child("publicacion")
                                   .child(imageNombre)
                               
                               //Poner los datos en Firestore
                               imageReferencia.putData(datosImagen, metadata: nil) { (metaData, error) in
                                   if let err = error {
                                       print("Error al subir imagen \(err.localizedDescription)")
                                   }
                                   
                                   imageReferencia.downloadURL { (url, error) in
                                       if let err = error {
                                           print("Error al subir imagen \(err.localizedDescription)")
                                           return
                                       }
                                       
                                       guard let url = url else {
                                           print("Error al crear url de la imagen")
                                           return
                                       }
                                       
                                       let dataReferencia = Firestore.firestore().collection("publicacion").document()
                                       let documentoID = dataReferencia.documentID
                                       
                                       let urlString = url.absoluteString
                                       
                                    let datosEnviar = ["id": email,
                                                          "userName": user,
                                                          "date": Date().timeIntervalSince1970,
                                                          "photouser": photo,
                                                          "url": urlString
                                       ]
                                       
                                       dataReferencia.setData(datosEnviar) { (error) in
                                           if let err = error {
                                               print("Error al mandar datos de imagen \(err.localizedDescription)")
                                               return
                                           } else {
                                               //Se subio a Firestore
                                               print("Se guardó correctamente en FS")
                                               //Ahora que harás cuando se guarde ?
                                           }
                                           
                                           
                                       }
                                   }
                               }
                    }
                }
            }
        }
        
    }
    
}

extension PhotoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //Que vamos a hacer cuando el usuario selecciona una imagen
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagenSeleccionada = info [UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage{
            imagen.image = imagenSeleccionada
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
