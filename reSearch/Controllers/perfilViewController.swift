//
//  perfilViewController.swift
//  reSearch
//
//  Created by Jennifer Ruiz on 01/07/21.
//

import UIKit
import Firebase
import FirebaseStorage

class perfilViewController: UIViewController {

    @IBOutlet weak var imagen: UIImageView!
    @IBOutlet weak var biografia: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var galeria: UICollectionView!
    let db = Firestore.firestore()
    
    var gallery = [FilGaleria]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galeria.delegate = self
        galeria.dataSource = self
        galeria.collectionViewLayout = UICollectionViewFlowLayout()
        loadProfile()
        loadGallery()
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
                    self.username.text = userName
                    self.biografia.text = biografia
                }
            }
        }
        
    }
    
    @IBAction func btnSalir(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "email")
        defaults.synchronize()
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            print("Cerro sesion correctamente!")
            navigationController?.popToRootViewController(animated: true)
        } catch let error as NSError {
            print ("Error al cerrar sesion\(error.localizedDescription)")
        }
    }
    
    func loadGallery(){
        guard let email = Auth.auth().currentUser?.email else { return }
        db.collection("publicacion").addSnapshotListener(){ (querySnapshot, err) in
            self.gallery = []
            if let e = err {
                print("Error al obtener los datos del perfil \(e.localizedDescription)")
            }else{
                if let snapshotDocuments = querySnapshot?.documents{
                    for documents in snapshotDocuments{
                        if let user = documents.get("id"){
                            if user as! String == email{
                                let data = documents.data()
                                print("Datos de FS \(data)")
                                guard let id = data["id"] as? String else { return }
                                guard let url = data["url"] as? String else { return  }
                                
                                let post = FilGaleria(id: id, imagenes: url)
                                
                                self.gallery.append(post)
                                DispatchQueue.main.async {
                                    self.galeria.reloadData()
                                }
                                
                            }
                        }
                    }
                }
            }
            
        }
    }

}

extension perfilViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(gallery[indexPath.row])
    }
    
    
}

extension perfilViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 80)
    }
}

extension perfilViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celda = galeria.dequeueReusableCell(withReuseIdentifier: "GaleriaCollectionViewCell", for: indexPath) as! GaleriaCollectionViewCell
        
        if let email = gallery[indexPath.row].id as? String{
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
                                celda.imagen.image = image
                            }
                        }
                    }
                }
            }
        }
        
        return celda
    }
    
    
}
