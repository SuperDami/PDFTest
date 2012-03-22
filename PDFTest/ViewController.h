//
//  ViewController.h
//  PDFtest
//
//  Created by czj on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFScrollView;
@interface ViewController : UIViewController <UIScrollViewDelegate>
{
    PDFScrollView *pdfScrollView;
}
@end
