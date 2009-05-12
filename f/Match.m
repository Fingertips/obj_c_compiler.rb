#import "Match.h"

@implementation Match

-(NSNumber*)score { return _score; }
-(void)setScore:(NSNumber*)score { _score = [score copy]; }

@end

void Init_Match() {}