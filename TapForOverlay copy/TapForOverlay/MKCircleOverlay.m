//
//  MKCircleOverlay.m
//  TapForOverlay
//
//  Created by Jaime Connor on 4/9/15.
//  Copyright (c) 2015 Jaime Connor. All rights reserved.
//

#import "MKCircleOverlay.h"

@implementation MKCircleOverlay
{
    CADisplayLink * displayLink;
    BOOL animationRunning;
    BOOL animationDone;
    NSTimeInterval drawDuration;
    CFTimeInterval lastDrawTime;
    CGFloat drawProgress;
    CGRect overlayRect;
    CGPoint overlayPoint;
    
    CGFloat innerCircleRadius;
    CGFloat outerCircleRadius;
}

-(id)initWithOverlay:(id<MKOverlay>)overlay {
    self  = [super initWithOverlay:overlay];
    if (self) {
        displayLink = [CADisplayLink displayLinkWithTarget:self
                                                  selector:@selector(setNeedsDisplay)];
        
        
        //These two methods don't seem to produce any results. I don't understand why. I thought they would be necessary in this situation since I'm drawing on a mapRect but calling them here doesn't draw a circle.
        /*
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplayInMapRect:)];
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplayInMapRect:zoomScale:)];
        
        */
        drawDuration = 1;
        
        
        overlayRect = [self rectForMapRect:[self.overlay boundingMapRect]];
        MKMapPoint overlayMapPoint = MKMapPointForCoordinate([self.overlay coordinate]);
        overlayPoint = [self pointForMapPoint:overlayMapPoint];
    }
    return self;
}

/*
 The overlay gets weird at the end of the animation. It disappears on some map tiles and tries to fill up the entire screen. The code as it is will show this.
 The disappearing tiles problem might have something to do with map tiles rendering on separate threads. When the displaylink gets invalidated and drawMapRect stops getting called, it might be that some of the threads didn't render some of the tiles in time. Something like that. Maybe.
 
 I got around it with the animationDone boolean that adds the whole overlay once and for all when the animation is done. That's done with the if-else-statement that's commented out at the top and bottom of the method. It sort of fixes it, but even then the animation itself isn't reliable. It's choppy and slow, and sometimes I see parts of it "growing faster" than other parts.
 
 An option+click of drawMapRect said this:
 "the map view may divide your overlay into multiple tiles and render each one on a separate thread. Your implementation of this method must therefore be capable of safely running from multiple threads simultaneously. In addition, you should avoid drawing the entire contents of the overlay each time this method is called."
 
 Well I don't know what it means to make the animation run safely on multiple threads, but I can try and keep from redrawing the whole overlay each time the method is called. I could try and add one segment at a time.
 In a regular drawRect I tried to make concentric rings "stack up," but all I achieved was one very thin expanding ring. I did not know how to keep the new rings from replacing the previous ones. I was dead set on trying to figure it out until I tried to make my expanding ring work here in a drawMapRect. It doesn't work at all. It's comically bad. The code for it is commented out below.
 
 I'm guessing that it's running into similar threading issues, and that if it's even possible to make a smoothly animated overlay, then the solution will have to accomodate for these multiple threads.
    I would be surprised if there's any way to have any control over map threads. That seems like something that would be completely under the hood. There's no mention of it in the documentation for MKMapView.
 
 I wonder if setNeedsDisplayInMapRect does this automatically. It might be that I'm not calling it correctly, and that a correct implementation of it would be a magic solution.
 
If that doesn't work, then all I need to know is if this is a nasty problem that I should be avoiding.

*/
- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
   
    
//    if (!animationDone) {
    
    //code for drawing a full circle
    ///////////////////////////////////////////////////////////////////////////////////////////////////
        if (!animationRunning && !animationDone)
        {
            [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            animationRunning = YES;
            return;
        }
        NSLog(@"lastDrawTime %f", lastDrawTime);
        if (lastDrawTime == 0 && !animationDone)
        {
            lastDrawTime = displayLink.timestamp;
            return;
        }

        CFTimeInterval elapsedTime = displayLink.timestamp - lastDrawTime;
       
        CGFloat frameSizeToDraw = drawProgress + (overlayRect.size.width/drawDuration) * elapsedTime;
        
        CGContextSetFillColorWithColor(context, [[UIColor redColor] colorWithAlphaComponent:0.4].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(overlayPoint.x - (frameSizeToDraw/2), overlayPoint.y - (frameSizeToDraw/2), frameSizeToDraw, frameSizeToDraw));

        lastDrawTime = displayLink.timestamp;
        drawProgress = frameSizeToDraw;
        
        if (frameSizeToDraw > overlayRect.size.width)
        {
            NSLog(@"Invalidate display link");
            [displayLink invalidate];
            animationRunning = NO;
            animationDone = YES;
            lastDrawTime = 0;
        }
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    //code for drawing an "expanding ring." Works fine in a regular drawRect.
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
//     if (!animationRunning && !animationDone)
//     {
//     
//     [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//     
//     animationRunning = YES;
//        
//     return;
//     }
//
//     if (lastDrawTime == 0 && !animationDone)
//     {
//     lastDrawTime = displayLink.timestamp;
//     return;
//     }
//    
//    
//     CFTimeInterval elapsedTime = displayLink.timestamp - lastDrawTime;
//     outerCircleRadius = innerCircleRadius +(overlayRect.size.width/drawDuration) * elapsedTime;
//     
//     
//     CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
//     CGContextAddArc(context, overlayPoint.x, overlayPoint.y, innerCircleRadius, 0, M_PI*2, 0);
//     CGContextAddArc(context, overlayPoint.x, overlayPoint.y, outerCircleRadius, 0, M_PI*2, 0);
//     CGContextEOFillPath(context);
//     
//     lastDrawTime = displayLink.timestamp;
//     innerCircleRadius = outerCircleRadius;
//     
//     if (outerCircleRadius > overlayRect.size.width)
//     {
//     NSLog(@"Invalidate display link");
//     [displayLink invalidate];
//     animationRunning = NO;
//     animationDone = YES;
//     lastDrawTime = 0;
//     }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    

//    }
//    else {
//        CGContextSetFillColorWithColor(context, [[UIColor redColor] colorWithAlphaComponent:0.4].CGColor);
//        CGContextFillEllipseInRect(context, CGRectMake(overlayPoint.x - (overlayRect.size.width/2), overlayPoint.y - (overlayRect.size.height/2), overlayRect.size.width, overlayRect.size.height));
//            }
    
}

- (void)setNeedsDisplayInMapRect:(MKMapRect)mapRect
{
    NSLog(@"This NSLog will work but the circle won't draw");

}

-(void)setNeedsDisplayInMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale {
    
}
@end
