//
//  HomeViewController.swift
//  reSearch
//
//  Created by Jennifer Ruiz on 01/07/21.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    @IBOutlet weak var tablaPublicaciones: UITableView!
    var post = [Publicaciones]()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "PublicacionTableViewCell", bundle: nil)
        tablaPublicaciones.register(nib, forCellReuseIdentifier: "publicacionCell")
        cargarPublicaciones()
        
        if let email = Auth.auth().currentUser?.email {
            let defaults = UserDefaults.standard
            defaults.set(email, forKey: "email")
            defaults.synchronize()
        }
        
    }
    
    func cargarPublicaciones(){
        db.collection("publicacion").order(by: "date").addSnapshotListener(){ (querySnapshot, err) in
            self.post = []
            if let e = err {
                print("Error al obtener los mensajes: \(e.localizedDescription)")
            }else{
                if let snapshotDocuments = querySnapshot?.documents{
                    for document in snapshotDocuments{
                        let data = document.data()
                        print(data)
                        
                        guard let id = data["id"] as? String  else { return }
                        guard let userName = data["userName"] as? String  else { return }
                        guard let date = data["date"] as? String  else { return }
                        guard let photoUser = data["photouser"] as? String  else { return }
                        guard let url = data["url"] as? String  else { return }
                        
                        let posting = Publicaciones(id: id, usuario: userName, fecha: date, fotoUsuario: photoUser, publicacion: url)
                        
                        self.post.append(posting)
                        DispatchQueue.main.async {
                            self.tablaPublicaciones.reloadData()
                        }
                    }
                }
            }
            
        }
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tablaPublicaciones.dequeueReusableCell(withIdentifier: "publicacionCell", for: indexPath) as! PublicacionTableViewCell
        if let email = post[indexPath.row].id as? String{
            let query = Firestore.firestore().collection("publicacion").whereField("id", isEqualTo: email)
            query.getDocuments{ (snapshot, error) in
                if let err = error {
                    print("Error al descragar imagen: \(err.localizedDescription)")
                }
                guard let snapshot = snapshot,
                      let data = snapshot.documents.first?.data(),
                      let urlString = data["url"] as? String,
                      let url = URL(string: urlString)
                else { return }
                DispatchQueue.global().async { [weak self] in
                    if let data = try? Data(contentsOf: url){
                        if let image = UIImage(data: data){
                            DispatchQueue.main.async {
                                celda.perfilImage.image = image
                            }
                        }
                    }
                }
            }
        }
        
        celda.nameLabel.text = post[indexPath.row].usuario
        celda.fechaLabel.text = post[indexPath.row].fecha
        
        if let email = post[indexPath.row].id as? String{
            let query = Firestore.firestore().collection("publicacion").whereField("id", isEqualTo: email)
            query.getDocuments{ (snapshot, error) in
                if let err = error {
                    print("Error al descragar imagen: \(err.localizedDescription)")
                }
                guard let snapshot = snapshot,
                      let data = snapshot.documents.first?.data(),
                      let urlString = data["url"] as? String,
                      let url = URL(string: urlString)
                else { return }
                DispatchQueue.global().async { [weak self] in
                    if let data = try? Data(contentsOf: url){
                        if let image = UIImage(data: data){
                            DispatchQueue.main.async {
                                celda.puublishImage.image = image
                            }
                        }
                    }
                }
            }
        }
        
        return celda
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
}
