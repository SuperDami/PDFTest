//
//  PDFContentView.h
//  PDFtest
//
//  Created by czj on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFContentView : UIView
{
    CGPDFDocumentRef _pdfDocument;
    CGPDFPageRef _pageRef;
    NSMutableArray *_links;
    UIView *highLightView;
}

- (id)initWithURL:(NSURL *)fileURL page:(NSInteger)page;
@end
