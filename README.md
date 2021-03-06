# RxInfinitePicker

[![CI Status](https://img.shields.io/travis/lm2343635/InfinitePicker.svg?style=flat)](https://travis-ci.org/lm2343635/RxInfinitePicker)
[![Version](https://img.shields.io/cocoapods/v/InfinitePicker.svg?style=flat)](https://cocoapods.org/pods/InfinitePicker)
[![License](https://img.shields.io/cocoapods/l/InfinitePicker.svg?style=flat)](https://cocoapods.org/pods/InfinitePicker)
[![Platform](https://img.shields.io/cocoapods/p/InfinitePicker.svg?style=flat)](https://cocoapods.org/pods/InfinitePicker)

`InfinitePicker` is an customized infinite picker for iOS, it helps you to create a infinite picker using a customized cell.
`InfinitePicker` also supports using with the `RxSwift` (https://github.com/ReactiveX/RxSwift) extension.

<div>
	<img src="https://raw.githubusercontent.com/lm2343635/InfinitePicker/master/screenshot/demo1.png">
	<img src="https://raw.githubusercontent.com/lm2343635/InfinitePicker/master/screenshot/demo2.png">
</div>

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Documentation

InfinitePicker is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'InfinitePicker'
```

#### Customized cell

The following code is a demo of a customized cell.
A customized cell class `NumberPickerCell` is a subclass of the generic class InfinitePickerCell.
`Int` is the model type of this customized cell.

The following property shoudl be overrided:

- `model`: Override the model property to set data for the cell.
- `isSelected`: Override the isSelected property to set a selected effect.


```Swift
class NumberPickerCell: InfinitePickerCell<Int> {
    
    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        return label
    }()
   	
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(containerView)
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Override the model property to set data for the cell.
    override var model: Int? {
        didSet {
            guard let number = model else {
                return
            }
            numberLabel.text = String(number)
        }
    }
    
    // Override the isSelected property to set a selected effect.
    override var isSelected: Bool {
        didSet {
            numberLabel.textColor = isSelected ? .yellow : . white
        }
    }
    
    // ...
    
}
```

#### Using InfinitePicker

Create a picker in your view controller class.
The generic type must be same as which in your customized class.

```Swift
private lazy var numberPicker: RxInfinitePicker<Int> = {
    let picker = RxInfinitePicker<Int>(
        itemSize: CGSize(width: 50, height: 50),
        scrollDirection: .vertical,
        spacing: 10,
        cellType: NumberPickerCell.self
    )
    picker.delegate = self
    return picker
}()
```

Set your data to the picker. 

```Swift
override func viewDidLoad() {
    super.viewDidLoad()
    //...

    numberPicker.items = Array(1 ... 9)
}
```

Get the selected item in the delegate `InfinitePickerDelegate`.

```Swift
extension CustomizedViewController: InfinitePickerDelegate {
    func didSelectItem(at index: Int) {
        numberLabel.text = "didSelectItem \(index)"
    }
}
```

#### Using with the RxSwift extension.

```Swift
picker.rx.itemSelected.subscribe(onNext: { [unowned self] in
    self.viewModel.pick(at: $0)
}).disposed(by: disposeBag)

viewModel.items.bind(to: picker.rx.items).disposed(by: disposeBag)
viewModel.selectedIndex.bind(to: picker.rx.selectedIndex).disposed(by: disposeBag)
```

## Author

lm2343635, lm2343635@126.com

## License

InfinitePicker is available under the MIT license. See the LICENSE file for more info.
