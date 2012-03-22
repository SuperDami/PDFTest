//
//  PDFContentView.m
//  PDFtest
//
//  Created by czj on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PDFContentView.h"
#import <QuartzCore/QuartzCore.h>
#import "PDFDocumentLink.h"

@interface PDFContentView(PrivateMethods)
- (void)buildAnnotationLinksList; 
@end

@implementation PDFContentView
+ (Class)layerClass
{
    return [CATiledLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CATiledLayer* layer = (CATiledLayer *)[self layer];
        
        layer.delegate = self;
        layer.levelsOfDetail = 2;
        layer.levelsOfDetailBias = 4;
        CGFloat tileSize = 512.0f * [[UIScreen mainScreen] scale];
        layer.tileSize = CGSizeMake(tileSize, tileSize);
        layer.contentsScale = 1.0f;
    }
    return self;
}

- (id)initWithURL:(NSURL *)fileURL page:(NSInteger)page 
{
    _pdfDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)fileURL);
    _pageRef= CGPDFDocumentGetPage(_pdfDocument, page);
    CGPDFPageRetain(_pageRef);
    
    CGRect cropBoxRect = CGPDFPageGetBoxRect(_pageRef, kCGPDFCropBox);
    CGRect mediaBoxRect = CGPDFPageGetBoxRect(_pageRef, kCGPDFMediaBox);
    CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
    
    CGRect viewRect = CGRectMake(0.0, 0.0, (NSInteger)effectiveRect.size.width, (NSInteger)effectiveRect.size.height);
    id view = [self initWithFrame:viewRect]; // UIView setup
        
    [self buildAnnotationLinksList];
	return view;
}

- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)context
{
	CGPDFPageRef drawPDFPageRef = NULL;
    
	CGPDFDocumentRef drawPDFDocRef = NULL;
    
	@synchronized(self) // Block any other threads
	{
		drawPDFDocRef = CGPDFDocumentRetain(_pdfDocument);
		drawPDFPageRef = CGPDFPageRetain(_pageRef);
	}
    
	CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // White
	CGContextFillRect(context, CGContextGetClipBoundingBox(context)); // Fill
    
	if (drawPDFPageRef != NULL) // Go ahead and render the PDF page into the context
	{
		CGContextTranslateCTM(context, 0.0f, self.bounds.size.height); CGContextScaleCTM(context, 1.0f, -1.0f);
		CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(drawPDFPageRef, kCGPDFCropBox, self.bounds, 0, true));
		CGContextSetRenderingIntent(context, kCGRenderingIntentDefault); CGContextSetInterpolationQuality(context, kCGInterpolationDefault);
		CGContextDrawPDFPage(context, drawPDFPageRef); // Render the PDF page into the context
	}
    
	CGPDFPageRelease(drawPDFPageRef); CGPDFDocumentRelease(drawPDFDocRef); // Cleanup
}

- (void)layoutSubviews {
    if ([self respondsToSelector:@selector(contentScaleFactor)]) {
        self.contentScaleFactor = 1.0f;
    }
}

- (void)dealloc
{
    CGPDFPageRelease(_pageRef);
    CGPDFDocumentRelease(_pdfDocument);
    [self layer].delegate = nil;
}

- (void)highlightPageLinks
{
	if (_links.count > 0) // Add highlight views over all links
	{
		UIColor *hilite = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.15f];
        
		for (PDFDocumentLink *link in _links) // Enumerate the links array
		{
			UIView *highlight = [[UIView alloc] initWithFrame:link.rect];
            
			highlight.autoresizesSubviews = NO;
			highlight.userInteractionEnabled = NO;
			highlight.clearsContextBeforeDrawing = NO;
			highlight.contentMode = UIViewContentModeRedraw;
			highlight.autoresizingMask = UIViewAutoresizingNone;
			highlight.backgroundColor = hilite; // Color
            
			[self addSubview:highlight];
		}
	}
}

- (void)addHighLightRect:(CGRect)highRect {

    if (!highLightView) {
        UIColor *hilite = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.15f];

        highLightView = [[UIView alloc] initWithFrame:CGRectInfinite];
        highLightView.autoresizesSubviews = NO;
        highLightView.userInteractionEnabled = NO;
        highLightView.clearsContextBeforeDrawing = NO;
        highLightView.contentMode = UIViewContentModeRedraw;
        highLightView.autoresizingMask = UIViewAutoresizingNone;
        highLightView.backgroundColor = hilite; // Color
        
        [self addSubview:highLightView];
    }
    
    [highLightView setFrame:highRect];
}

- (PDFDocumentLink *)linkFromAnnotation:(CGPDFDictionaryRef)annotationDictionary
{    
	PDFDocumentLink *documentLink = nil; // Document link object
    
	CGPDFArrayRef annotationRectArray = NULL; // Annotation co-ordinates array
    
	if (CGPDFDictionaryGetArray(annotationDictionary, "Rect", &annotationRectArray))
	{
		CGPDFReal ll_x = 0.0f; CGPDFReal ll_y = 0.0f; // PDFRect lower-left X and Y
		CGPDFReal ur_x = 0.0f; CGPDFReal ur_y = 0.0f; // PDFRect upper-right X and Y
        
		CGPDFArrayGetNumber(annotationRectArray, 0, &ll_x); // Lower-left X co-ordinate
		CGPDFArrayGetNumber(annotationRectArray, 1, &ll_y); // Lower-left Y co-ordinate
        
		CGPDFArrayGetNumber(annotationRectArray, 2, &ur_x); // Upper-right X co-ordinate
		CGPDFArrayGetNumber(annotationRectArray, 3, &ur_y); // Upper-right Y co-ordinate
        ll_y = ((0.0f - ll_y) + self.frame.size.height);
        ur_y = ((0.0f - ur_y) + self.frame.size.height);
        
		NSInteger x = ll_x; NSInteger w = (ur_x - ll_x); // Integer X and width
		NSInteger y = ll_y; NSInteger h = (ur_y - ll_y); // Integer Y and height
		CGRect viewRect = CGRectMake(x, y, w, h); // View CGRect from PDFRect
        
		documentLink = [[PDFDocumentLink alloc] initWithRect:viewRect dictionary:annotationDictionary];
	}
    
	return documentLink;
}

- (void)buildAnnotationLinksList {
    _links = [NSMutableArray array];
    
	CGPDFArrayRef pageAnnotations = NULL; // Page annotations array
    
	CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(_pageRef);
    
	if (CGPDFDictionaryGetArray(pageDictionary, "Annots", &pageAnnotations) == true)
	{
		NSInteger count = CGPDFArrayGetCount(pageAnnotations); // Number of annotations
        
		for (NSInteger index = 0; index < count; index++) // Iterate through all annotations
		{
			CGPDFDictionaryRef annotationDictionary = NULL; // PDF annotation dictionary
            
			if (CGPDFArrayGetDictionary(pageAnnotations, index, &annotationDictionary) == true)
			{
				const char *annotationSubtype = NULL; // PDF annotation subtype string
                
				if (CGPDFDictionaryGetName(annotationDictionary, "Subtype", &annotationSubtype) == true)
				{
					if (strcmp(annotationSubtype, "Link") == 0) // Found annotation subtype of 'Link'
					{
						PDFDocumentLink *documentLink = [self linkFromAnnotation:annotationDictionary];
                        
						if (documentLink != nil) [_links insertObject:documentLink atIndex:0]; // Add link
					}
				}
			}
		}
	}
}

- (NSURL *)getLinkTarget:(CGPDFDictionaryRef)dictionary {
    
    NSURL *linkTarget = nil;
    CGPDFDictionaryRef actDic = nil;
    if(CGPDFDictionaryGetDictionary(dictionary, "A", &actDic)) {
        const char *actionType = NULL;
        if (CGPDFDictionaryGetName(actDic, "S", &actionType)) {
            if (strcmp(actionType, "URI") == 0) {
                CGPDFStringRef uriString = NULL; // Action's URI string
                
                if (CGPDFDictionaryGetString(actDic, "URI", &uriString))
                {
                    const char *uri = (const char *)CGPDFStringGetBytePtr(uriString);
                    
                    linkTarget = [NSURL URLWithString:[NSString stringWithCString:uri encoding:NSASCIIStringEncoding]];
                } 
            }
        }
    }
    
    return linkTarget;
}

- (void)tap:(UITapGestureRecognizer *)gesture {
    if ([gesture state] == UIGestureRecognizerStateRecognized) {
        CGPoint tapPoint = [gesture locationInView:self];
        for (PDFDocumentLink *link in _links) {
            if (CGRectContainsPoint(link.rect, tapPoint)) {
                
                [self addHighLightRect:link.rect];
                NSURL *targetUrl = [self getLinkTarget:link.dictionary];                
                [[UIApplication sharedApplication] openURL:targetUrl];
            }
        }
    }
}
@end
