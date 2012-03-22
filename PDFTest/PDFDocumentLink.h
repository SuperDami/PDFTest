//
//  PDFDocumentLink.h
//  PDFtest
//
//  Created by czj on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFDocumentLink : NSObject

@property (nonatomic, assign, readonly) CGRect rect;
@property (nonatomic, assign, readonly) CGPDFDictionaryRef dictionary;

- (id)initWithRect:(CGRect)rect dictionary:(CGPDFDictionaryRef)dictionary;
@end
