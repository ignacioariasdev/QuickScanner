//
//  QSViewController.h
//  QuickScanner
//
//  Created by Ignacio Arias on 2024-08-08.
//

#import <UIKit/UIKit.h>
#import <VisionKit/VisionKit.h>
#import <Vision/Vision.h>

@interface QSViewController : UIViewController <VNDocumentCameraViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *scannedReceipts;

- (void)scanButtonTapped;

@end
