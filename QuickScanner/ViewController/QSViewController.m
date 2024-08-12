//
//  QSViewController.m
//  QuickScanner
//
//  Created by Ignacio Arias on 2024-08-08.
//

#import "QSViewController.h"
#import "QSDetailViewController.h"
#import <Photos/Photos.h>

@interface QSViewController ()

@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIView *ocrPreviewView;
@property (nonatomic, strong) UILabel *ocrPreviewLabel;
@property (nonatomic, strong) UILabel *listTitleLabel;

@end

@implementation QSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scannedReceipts = [NSMutableArray array];
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Info Label
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.text = @"The app will take several pictures and choose the best. No images will be uploaded to any server; they will stay on your phone.";
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.infoLabel];
    
    // Scan Button
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [scanButton setTitle:@"Scan Receipt" forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(scanButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanButton];
    
    // OCR Preview View
    self.ocrPreviewView = [[UIView alloc] init];
    self.ocrPreviewView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    self.ocrPreviewView.layer.cornerRadius = 8;
    [self.view addSubview:self.ocrPreviewView];
    
    self.ocrPreviewLabel = [[UILabel alloc] init];
    self.ocrPreviewLabel.textColor = [UIColor whiteColor];
    self.ocrPreviewLabel.numberOfLines = 0;
    self.ocrPreviewLabel.text = @"OCR Preview will appear here";
    [self.ocrPreviewView addSubview:self.ocrPreviewLabel];
    
    // List Title Label
    self.listTitleLabel = [[UILabel alloc] init];
    self.listTitleLabel.text = @"List";
    self.listTitleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.listTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.listTitleLabel];
    
    // Table View
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.tableView];
    
    // Auto Layout
    self.infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    scanButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.ocrPreviewView.translatesAutoresizingMaskIntoConstraints = NO;
    self.ocrPreviewLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.listTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.infoLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.infoLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.infoLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        [scanButton.topAnchor constraintEqualToAnchor:self.infoLabel.bottomAnchor constant:20],
        [scanButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        
        [self.ocrPreviewView.topAnchor constraintEqualToAnchor:scanButton.bottomAnchor constant:20],
        [self.ocrPreviewView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.ocrPreviewView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.ocrPreviewView.heightAnchor constraintEqualToConstant:100],
        
        [self.ocrPreviewLabel.topAnchor constraintEqualToAnchor:self.ocrPreviewView.topAnchor constant:8],
        [self.ocrPreviewLabel.leadingAnchor constraintEqualToAnchor:self.ocrPreviewView.leadingAnchor constant:8],
        [self.ocrPreviewLabel.trailingAnchor constraintEqualToAnchor:self.ocrPreviewView.trailingAnchor constant:-8],
        [self.ocrPreviewLabel.bottomAnchor constraintEqualToAnchor:self.ocrPreviewView.bottomAnchor constant:-8],
        
        [self.listTitleLabel.topAnchor constraintEqualToAnchor:self.ocrPreviewView.bottomAnchor constant:20],
        [self.listTitleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.listTitleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        
        [self.tableView.topAnchor constraintEqualToAnchor:self.listTitleLabel.bottomAnchor constant:10],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)scanButtonTapped {
    VNDocumentCameraViewController *scanner = [[VNDocumentCameraViewController alloc] init];
    scanner.delegate = self;
    [self presentViewController:scanner animated:YES completion:nil];
}

- (void)documentCameraViewController:(VNDocumentCameraViewController *)controller didFinishWithScan:(VNDocumentCameraScan *)scan {
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    for (NSInteger i = 0; i < scan.pageCount; i++) {
        UIImage *image = [scan imageOfPageAtIndex:i];
        [self performOCROnImage:image];
    }
}

- (void)performOCROnImage:(UIImage *)image {
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}];
    
    VNRecognizeTextRequest *request = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        if (error) {
            NSLog(@"OCR Error: %@", error);
            return;
        }
        
        NSMutableDictionary *receiptData = [NSMutableDictionary dictionary];
        
        for (VNRecognizedTextObservation *observation in request.results) {
            VNRecognizedText *recognizedText = [observation topCandidates:1].firstObject;
            if (recognizedText) {
                NSString *text = recognizedText.string;
                
                if ([self isVendorString:text]) {
                    receiptData[@"vendor"] = text;
                } else if ([self isTaxString:text]) {
                    receiptData[@"tax"] = text;
                } else if ([self isTotalString:text]) {
                    receiptData[@"total"] = text;
                } else if ([self isAddressString:text]) {
                    receiptData[@"address"] = text;
                }
            }
        }
        
        [self updateOCRPreviewWithData:receiptData];
        [self saveReceiptData:receiptData withImage:image];
    }];
    
    request.recognitionLevel = VNRequestTextRecognitionLevelAccurate;
    
    NSError *error = nil;
    [handler performRequests:@[request] error:&error];
    if (error) {
        NSLog(@"Failed to perform OCR request: %@", error);
    }
}



- (void)updateOCRPreviewWithData:(NSDictionary *)data {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *previewText = [NSString stringWithFormat:@"Vendor: %@\nTax: %@\nTotal: %@\nAddress: %@",
                                 data[@"vendor"] ?: @"N/A",
                                 data[@"tax"] ?: @"N/A",
                                 data[@"total"] ?: @"N/A",
                                 data[@"address"] ?: @"N/A"];
        self.ocrPreviewLabel.text = previewText;
    });
}

- (BOOL)isVendorString:(NSString *)text {
    // Simple check for known vendor names
    NSArray *knownVendors = @[@"Costco", @"Walmart", @"Target", @"Safeway"];
    for (NSString *vendor in knownVendors) {
        if ([text.lowercaseString containsString:vendor.lowercaseString]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isTaxString:(NSString *)text {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"tax|gst|pst" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRange range = NSMakeRange(0, text.length);
    NSArray *matches = [regex matchesInString:text options:0 range:range];
    return matches.count > 0;
}

- (BOOL)isTotalString:(NSString *)text {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"total|sum|amount" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRange range = NSMakeRange(0, text.length);
    NSArray *matches = [regex matchesInString:text options:0 range:range];
    return matches.count > 0;
}

- (BOOL)isAddressString:(NSString *)text {
    // Simple check for address-like strings
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+.*\\b(street|st|avenue|ave|road|rd|boulevard|blvd)\\b" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRange range = NSMakeRange(0, text.length);
    NSArray *matches = [regex matchesInString:text options:0 range:range];
    return matches.count > 0;
}

- (void)saveReceiptData:(NSDictionary *)receiptData withImage:(UIImage *)image {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *receiptFolder = [documentDirectory URLByAppendingPathComponent:@"Receipts" isDirectory:YES];
    
    NSError *error;
    [fileManager createDirectoryAtURL:receiptFolder withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (error) {
        NSLog(@"Error creating receipt folder: %@", error);
        return;
    }
    
    NSString *fileName = [NSString stringWithFormat:@"receipt_%@.jpg", [[NSUUID UUID] UUIDString]];
    NSURL *fileURL = [receiptFolder URLByAppendingPathComponent:fileName];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    [imageData writeToURL:fileURL atomically:YES];
    
    NSMutableDictionary *fullReceiptData = [receiptData mutableCopy];
    fullReceiptData[@"imagePath"] = fileURL.path;
    
    [self.scannedReceipts addObject:fullReceiptData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        self.ocrPreviewLabel.text = [NSString stringWithFormat:@"Vendor: %@\nDate: %@\nTax: %@",
                                     receiptData[@"vendor"] ?: @"N/A",
                                     receiptData[@"date"] ?: @"N/A",
                                     receiptData[@"tax"] ?: @"N/A"];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.scannedReceipts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiptCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ReceiptCell"];
    }
    
    NSDictionary *receipt = self.scannedReceipts[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"File %03ld", (long)indexPath.row + 1];
    cell.detailTextLabel.text = receipt[@"vendor"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *receiptData = self.scannedReceipts[indexPath.row];
    QSDetailViewController *detailVC = [[QSDetailViewController alloc] initWithReceiptData:receiptData];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - VNDocumentCameraViewControllerDelegate

- (void)documentCameraViewController:(VNDocumentCameraViewController *)controller didFailWithError:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Document scanner failed with error: %@", error.localizedDescription);
    // You might want to show an alert to the user here
}

- (void)documentCameraViewControllerDidCancel:(VNDocumentCameraViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end

