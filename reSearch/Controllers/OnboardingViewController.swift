//
//  OnboardingViewController.swift
//  reSearch
//
//  Created by Jennifer Ruiz on 05/07/21.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var botonSiguiente: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var diapositivas: [OnboardingDiapositiva] = []
    
    
    var paginaActual = 0 {
        didSet {
            pageControl.currentPage = paginaActual
            if paginaActual == diapositivas.count - 1 {
                botonSiguiente.setTitle("Empezar", for: .normal)
            } else {
                botonSiguiente.setTitle("Siguiente", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        diapositivas = [OnboardingDiapositiva(titulo: "Inicia sesión", descripcion: "Al iniciar sesión conectas con toda nuestra comunidad", imagen: #imageLiteral(resourceName: "logueate")), OnboardingDiapositiva(titulo: "Postea tus mejores fotos", descripcion: "Postea tus fotos para que todos las vean", imagen: #imageLiteral(resourceName: "posting")), OnboardingDiapositiva(titulo: "Crea tu propia galeria", descripcion: "Guarda tus fotos en tu galeria personal", imagen: #imageLiteral(resourceName: "gallery"))]
        
        CollectionView.delegate = self
        CollectionView.dataSource = self
    }

    @IBAction func siguienteBtn(_ sender: UIButton) {
        if paginaActual == diapositivas.count - 1{
            let controlador = storyboard?.instantiateViewController(identifier: "login") as! UIViewController
            controlador.modalPresentationStyle = .fullScreen
            controlador.modalTransitionStyle = .crossDissolve
            
            present(controlador, animated: true, completion: nil)
        }else{
            paginaActual += 1
            let indexPath = IndexPath(item: paginaActual, section: 0)
            CollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diapositivas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celda = CollectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCollectionViewCell", for: indexPath) as! OnboardingCollectionViewCell
        celda.configurar(diapositiva: diapositivas[indexPath.row])
        return celda

    }
    
    
}


extension OnboardingViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CollectionView.frame.width, height: CollectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let ancho = scrollView.frame.width
        paginaActual = Int(scrollView.contentOffset.x/ancho)
        
    }
}
