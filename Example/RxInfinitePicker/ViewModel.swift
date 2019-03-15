//
//  ViewModel.swift
//  RxInfinitePicker_Example
//
//  Created by Meng Li on 2019/03/15.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import RxSwift

class ViewModel {
    
    var items: Observable<[Int]> {
        return Observable.just(Array(1 ... 10))
    }
    
}
