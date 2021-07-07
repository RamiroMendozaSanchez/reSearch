//
//  OnboardingCollectionViewCell.swift
//  reSearch
//
//  Created by Jennifer Ruiz on 05/07/21.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imagenDiapositiva: UIImageView!
    @IBOutlet weak var tituloDiapositiva: UILabel!
    @IBOutlet weak var descripcionDiapositiva: UILabel!
    
    func configurar(diapositiva: OnboardingDiapositiva){
        imagenDiapositiva.image = diapositiva.imagen
        tituloDiapositiva.text = diapositiva.titulo
        descripcionDiapositiva.text = diapositiva.descripcion
    }
    
}
