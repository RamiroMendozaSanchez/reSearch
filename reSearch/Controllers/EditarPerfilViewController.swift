//
//  EditarPerfilViewController.swift
//  reSearch
//
//  Created by Jennifer Ruiz on 01/07/21.
//

import UIKit
import Firebase
import FirebaseStorage


class EditarPerfilViewController: UIViewController {

    @IBOutlet weak var imagen: UIImageView!
    @IBOutlet weak var nombreTF: UITextField!
    @IBOutlet weak var biografiaTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    let db = Firestore.firestore()
    var uidImagen: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestura = UITapGestureRecognizer(target: self, action: #selector(clickImagen))
        gestura.numberOfTapsRequired = 1
        gestura.numberOfTouchesRequired = 1
        imagen.addGestureRecognizer(gestura)
        imagen.isUserInteractionEnabled = true
        loadProfile()
        
    }
    
    func loadProfile(){
        guard let email = Auth.auth().currentUser?.email else { return }
        let query = Firestore.firestore().collection("users").whereField("id", isEqualTo: email)
        query.getDocuments { (snapshot, error) in
            if let err = error {
                print("Error al descargar imagen: \(err.localizedDescription)")
            }
            guard let snapshot = snapshot,
                  let data = snapshot.documents.first?.data(),
                  let urlString = data["url"] as? String,
                  let url = URL(string: urlString)
            else { return }
            
           DispatchQueue.global().async { [weak self] in
               if let data = try? Data(contentsOf: url) {
                   if let image = UIImage(data: data) {
                       DispatchQueue.main.async {
                        self?.imagen.image = image
                       }
                   }
               }
           }
        }
        db.collection("users").document(email).addSnapshotListener(){ (querySnapshot, err) in
            
            if let e = err {
                print("Error al obtener los datos del perfil \(e.localizedDescription)")
            }else{
                if let data = querySnapshot?.data(){
                    print(data)
                    guard  let userName = data["userName"] as? String else { return }
                    guard let biografia = data["biografia"] as? String else {return}
                    self.nombreTF.text = userName
                    self.biografiaTF.text = biografia
                }
            }
        }
        
    }
    
    @objc func clickImagen(gestura: UITapGestureRecognizer){
        print("Cambiar imagen")
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
    
    func actualizarPerfil() {
        guard let email = Auth.auth().currentUser?.email else { return }
        guard let name = nombreTF.text else{return}
        guard let biografia = biografiaTF.text else{return}
        
        guard let image = imagen.image, let datosImagen = image.jpegData(compressionQuality: 1.0) else {
            print("Error")
            return
        }
        //asignar un id unico para esos datos
        let imageNombre = UUID().uuidString
        uidImagen = imageNombre
        
        let imageReferencia = Storage.storage()
            .reference()
            .child("users")
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
                
                let dataReferencia = Firestore.firestore().collection("users").document(email)
                let documentoID = dataReferencia.documentID
                
                let urlString = url.absoluteString
                
                let datosEnviar = ["id": documentoID,
                                   "userName": name,
                                   "biografia": biografia,
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
    
    func actualizarContrasena(){
        if let password = passwordTF.text {
            Auth.auth().currentUser?.updatePassword(to: password) { (error) in
                if let e = error{
                    print("Error al actualizar contraseña \(e.localizedDescription)")
                }else{
                    print("Contraseña actualizada corectamente")
                }
            }
        }
    }
    
    
    @IBAction func actualizarBtn(_ sender: UIButton) {
        actualizarPerfil()
        actualizarContrasena()
        navigationController?.popViewController(animated: true)
    }
    
}

extension EditarPerfilViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
