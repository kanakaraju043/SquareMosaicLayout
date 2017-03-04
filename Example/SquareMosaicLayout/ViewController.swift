import SquareMosaicLayout
import UIKit

class ViewController: UIViewController {

    lazy var viewCollection: UICollectionView = self.getViewCollection()
    lazy var viewControl: UISegmentedControl = self.getViewControl()
    lazy var viewLayout: SquareMosaicLayout = self.getViewLayout()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = viewControl
        self.view.backgroundColor = UIColor.groupTableViewBackground
        self.view.addSubview(viewCollection)
        self.viewCollection.alwaysBounceVertical = true
    }
    
    @objc fileprivate func changeLayout() {
        viewCollection.setCollectionViewLayout(getViewLayout(), animated: true)
    }
}

fileprivate extension ViewController {
    
    func getViewCollection() -> UICollectionView {
        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.viewLayout)
        view.backgroundColor = UIColor.groupTableViewBackground
        view.contentInset = UIEdgeInsets(top: 0.0, left: 50.0, bottom: 0.0, right: 50.0)
        view.register(CellView.self)
        view.register(SupplementaryView.self, identifier: SquareMosaicLayoutSectionFooter, kind: SquareMosaicLayoutSectionFooter)
        view.register(SupplementaryView.self, identifier: SquareMosaicLayoutSectionHeader, kind: SquareMosaicLayoutSectionHeader)
        view.register(DecorationView.self, identifier: SquareMosaicLayoutSectionBacker, kind: SquareMosaicLayoutSectionBacker)
        view.dataSource = self
        view.delegate = self
        return view
    }
    
    func getViewControl() -> UISegmentedControl {
        let view = UISegmentedControl(items: ["Mosaic Layout", "Grid Layout", "Single Layout"])
        view.addTarget(self, action: #selector(changeLayout), for: UIControlEvents.valueChanged)
        view.selectedSegmentIndex = 0
        return view
    }
    
    func getViewLayout() -> SquareMosaicLayout {
        switch viewControl.selectedSegmentIndex {
        case 0:     return Layout(SnakeSquareMosaicPattern())
        case 1:     return Layout(TripleSquareMosaicPattern())
        default:    return Layout(SingleSquareMosaicPattern())
        }
    }
}

final class Layout: SquareMosaicLayout, SquareMosaicDataSource {
    
    let pattern: SquareMosaicPattern
    
    required init(_ pattern: SquareMosaicPattern) {
        self.pattern = pattern
        super.init()
        self.dataSource = self
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func background(section: Int) -> Bool {
        return true
    }
    
    func footer(section: Int) -> SquareMosaicSupplementary? {
        return SnakeSquareMosaicSupplementary()
    }
    
    func header(section: Int) -> SquareMosaicSupplementary? {
        return SnakeSquareMosaicSupplementary()
    }
    
    func pattern(section: Int) -> SquareMosaicPattern {
        switch section {
        case 2:     return SingleSquareMosaicPattern()
        default:    return pattern
        }
    }
    
    func separator(_ type: SquareMosaicSeparatorType) -> CGFloat {
        return offset
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 2:     return 1
        default:    return 6
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CellView = collectionView.dequeueCell(indexPath: indexPath)
        switch indexPath.section {
        case 0:     cell.imageView.image = UIImage(named: "golf_\(indexPath.row).jpeg")
        case 1:     cell.imageView.image = UIImage(named: "scirocco_\(indexPath.row).jpeg")
        default:    cell.imageView.image = nil
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case SquareMosaicLayoutSectionBacker:
            let view: DecorationView = collectionView.dequeueSupplementary(kind, indexPath: indexPath, kind: kind)
            return view
        case SquareMosaicLayoutSectionFooter:
            let view: SupplementaryView = collectionView.dequeueSupplementary(kind, indexPath: indexPath, kind: kind)
            view.label.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
            switch indexPath.section {
            case 2:     view.label.text = "Tap to add!"
            default:    view.label.text = "View more..."
            }
            return view
        case SquareMosaicLayoutSectionHeader:
            let view: SupplementaryView = collectionView.dequeueSupplementary(kind, indexPath: indexPath, kind: kind)
            view.label.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
            switch indexPath.section {
            case 0:     view.label.text = "Golf VI"
            case 1:     view.label.text = "Scirocco"
            default:    view.label.text = "Your car?"
            }
            return view
        default:
            fatalError()
        }
    }
}
