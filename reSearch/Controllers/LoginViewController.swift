//
//  ViewController.swift
//  reSearch
//
//  Created by Jennifer Ruiz on 30/06/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var contraseña: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        let defaults = UserDefaults.standard
        if let email = defaults.value(forKey: "email") as? String {
            //Utilizar un segue hasta inicio Chat
            performSegue(withIdentifier: "loginInicio", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func alerta(msj:String){
        let alerta = UIAlertController(title: "ERROR", message: msj, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
        present(alerta, animated: true, completion: nil)
    }

    @IBAction func loginBtn(_ sender: UIButton) {
        if let email = userName.text, let password = contraseña.text{
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    switch e.localizedDescription {
                        case "There is no user record corresponding to this identifier. The user may have been deleted.":
                            self.alerta(msj: "Este usuario no está registrado o ha sido borrado")
                        case "The password is invalid or the user does not have a password.":
                            self.alerta(msj: "La contrseña es incorrecta.")
                        case "The email address is badly formatted.":
                            self.alerta(msj: "El formato del correo es incorrecto")
                    default:
                        self.alerta(msj: "El correo y contraaseña no coinciden")
                    }
                } else {
                    //NAvegar al inicio
                    self.performSegue(withIdentifier: "loginInicio", sender: self)
                }
                
            }
        }
    }
    
}

