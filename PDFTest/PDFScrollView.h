//
//  PDFScrollView.h
//  PDFtest
//
//  Created by czj on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFContentView;

@interface PDFScrollView : UIScrollView <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
}

@property (nonatomic, strong) PDFContentView *pdfContentView;

@end
