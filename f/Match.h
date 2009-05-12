#import <Cocoa/Cocoa.h>

@interface Match : NSObject {
  NSNumber *_score;
}

-(NSNumber*)score;
-(void)setScore:(NSNumber*)score;

@end