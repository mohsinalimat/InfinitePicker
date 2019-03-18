
import UIKit
import InfiniteLayout
import RxSwift
import RxCocoa

public class RxInfinitePicker<Model>: UIView {
    
    private let itemSize: CGSize
    private let scrollDirection: UICollectionView.ScrollDirection
    private let cellType: RxInfinitePickerCell<Model>.Type
    
    private lazy var collectionView: RxInfiniteCollectionView = {
        let collectionView = RxInfiniteCollectionView(frame: .zero, collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.itemSize = itemSize
            layout.scrollDirection = scrollDirection
            return layout
        }())
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isItemPagingEnabled = true
        collectionView.register(cellType, forCellWithReuseIdentifier: "id")
        collectionView.rx.itemSelected.bind { [unowned self] in
            switch self.scrollDirection {
            case .vertical:
                collectionView.scrollToItem(at: $0, at: .centeredVertically, animated: true)
            case .horizontal:
                collectionView.scrollToItem(at: $0, at: .centeredHorizontally, animated: true)
            }
        }.disposed(by: disposeBag)
        collectionView.rx.itemCentered.filter { $0 != nil }.map { $0! }.skip(1).bind { [unowned self] in
            self.pick(at: $0.row)
        }.disposed(by: disposeBag)
        return collectionView
    }()
    
    private lazy var dataSource = InfiniteCollectionViewSingleSectionDataSource<Model>(configureCell: { (_, collectionView, indexPath, model) in
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "id", for: indexPath) as? RxInfinitePickerCell<Model> else {
            return UICollectionViewCell()
        }
        cell.model = model
        return cell
    })
    
    public let items = BehaviorRelay<[Model]>(value: [])
    public let itemSelected = PublishSubject<Model>()
    
    private let disposeBag = DisposeBag()
    
    public init(
        frame: CGRect = .zero,
        itemSize: CGSize,
        scrollDirection: UICollectionView.ScrollDirection,
        cellType: RxInfinitePickerCell<Model>.Type
    ) {
        self.itemSize = itemSize
        self.scrollDirection = scrollDirection
        self.cellType = cellType
        super.init(frame: frame)

        addSubview(collectionView)
        createConstraints()
        
        items.map { SingleSection.create($0) }
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func pick(at index: Int) {
        let itemIndex = index % items.value.count
        guard 0 ..< items.value.count ~= itemIndex else {
            return
        }
        itemSelected.onNext(items.value[itemIndex])
    }
}