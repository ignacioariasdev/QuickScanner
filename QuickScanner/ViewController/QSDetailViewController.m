//
//  QSDetailViewController.m
//  QuickScanner
//
//  Created by Ignacio Arias on 2024-08-08.
//

#import "QSDetailViewController.h"

@interface QSDetailViewController ()

@property (nonatomic, strong) NSDictionary *receiptData;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *detailsLabel;

@end

@implementation QSDetailViewController

- (instancetype)initWithReceiptData:(NSDictionary *)receiptData {
    self = [super init];
    if (self) {
        _receiptData = receiptData;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    
    // Add a back button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped)];
}

- (void)setupUI {
    // Image View
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    // Details Label
    self.detailsLabel = [[UILabel alloc] init];
    self.detailsLabel.numberOfLines = 0;
    [self.view addSubview:self.detailsLabel];
    
    // Auto Layout
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.detailsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.imageView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.imageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.imageView.heightAnchor constraintEqualToConstant:200],
        
        [self.detailsLabel.topAnchor constraintEqualToAnchor:self.imageView.bottomAnchor constant:20],
        [self.detailsLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.detailsLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.detailsLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.bottomAnchor constant:-20]
    ]];
    
    [self populateData];
}

- (void)populateData {
    // Load image
    NSString *imagePath = self.receiptData[@"imagePath"];
    if (imagePath) {
        self.imageView.image = [UIImage imageWithContentsOfFile:imagePath];
    }
    
    // Set details text
    NSString *detailsText = [NSString stringWithFormat:@"Vendor: %@\nTax: %@\nTotal: %@\nAddress: %@",
                             self.receiptData[@"vendor"] ?: @"N/A",
                             self.receiptData[@"tax"] ?: @"N/A",
                             self.receiptData[@"total"] ?: @"N/A",
                             self.receiptData[@"address"] ?: @"N/A"];
    self.detailsLabel.text = detailsText;
}

- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
