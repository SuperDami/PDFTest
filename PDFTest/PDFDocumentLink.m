//
//  PDFDocumentLink.m
//  PDFtest
//
//  Created by czj on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PDFDocumentLink.h"

@implementation PDFDocumentLink
@synthesize rect = _rect;
@synthesize dictionary = _dictionary;

- (id)initWithRect:(CGRect)rect dictionary:(CGPDFDictionaryRef)dictionary {
    if ((self = [super init]))
	{
		_dictionary = dictionary;        
		_rect = rect;
	}
	return self;
}

@end
