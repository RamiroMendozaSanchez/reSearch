//
//  RegistroViewController.swift
//  reSearch
//
//  Created by Jennifer Ruiz on 01/07/21.
//

import UIKit
import Firebase
import FirebaseStorage

class RegistroViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var correo: UITextField!
    @IBOutlet weak var contrasena: UITextField!
    let db = Firestore.firestore()
    var uidImagen: String?
    override func viewDidLoad() {
        super.viewDidLoad()

      
    }
    
    func alerta(msj:String){
        let alerta = UIAlertController(title: "ERROR", message: msj, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
        present(alerta, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func registrarBtn(_ sender: UIButton) {
        if let email = correo.text, let password = contrasena.text, let name = userName.text{
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                            
                //MARK:Imagen
                let imageTmp = UIImageView(image:  #imageLiteral(resourceName: "usuario"))
                
                //Convertir la imagen en datos()
                guard let image = imageTmp.image, let datosImagen = image.jpegData(compressionQuality: 1.0) else {
                    print("Error")
                    return
                }
                //asignar un id unico para esos datos
                let imageNombre = UUID().uuidString
                self.uidImagen = imageNombre
                
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
                                           "url": urlString]
                        
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
                //MARK: if de errores
                if let e = error {
                    print("Error al crear usuario \(e.localizedDescription)")
                    if e.localizedDescription == "The email address is already in use by another account." {
                        self.alerta(msj: "Ese correo ya esta en uso, favor de crear otro")
                    } else if e.localizedDescription == "The email address is badly formatted." {
                        self.alerta(msj: "Verifica el formato de tu email")
                    } else if e.localizedDescription == "The password must be 6 characters long or more." {
                        self.alerta(msj: "Tu contraseña debe de ser de 6 caracteres o mas")
                    }
                    
                } else {
                    //Navegar al siguiente VC
                    self.performSegue(withIdentifier: "registroInicio", sender: self)
                }
                
            }
            
        }
    }
}
