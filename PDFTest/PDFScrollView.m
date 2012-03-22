//
//  PDFScrollView.m
//  PDFtest
//
//  Created by czj on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PDFScrollView.h"
#import "PDFContentView.h"

@implementation PDFScrollView
@synthesize pdfContentView = _pdfContentView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setDecelerationRate:UIScrollViewDecelerationRateFast];
        [self setBounces:NO];
        [self setBouncesZoom:NO];
        [self setMultipleTouchEnabled:YES];
        [self setScrollEnabled:YES];
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
        [self setMinimumZoomScale:1.0];
        [self setMaximumZoomScale:4.0];
        [self setDirectionalLockEnabled:YES];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self setBackgroundColor:[UIColor grayColor]];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Reader" ofType:@"pdf"];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:path isDirectory:NO];
        
        _pdfContentView = [[PDFContentView alloc] initWithURL:url page:1];
        [self addSubview:_pdfContentView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:_pdfContentView action:@selector(tap:)];
        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _pdfContentView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2.0;
    else
        frameToCenter.origin.x = 0.0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2.0;
    else
        frameToCenter.origin.y = 0.0;
    
    _pdfContentView.frame = frameToCenter;
}
@end
