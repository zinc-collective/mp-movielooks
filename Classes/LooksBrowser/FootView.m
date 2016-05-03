//
//  FootView.m
//  MobileLooks
//
//  Created by George on 10/18/10.
//  Copyright 2010 RED/SAFI. All rights reserved.
//

#import "FootView.h"


@implementation FootView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		self.backgroundColor = [UIColor clearColor];
		
		groupNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 250, 18)];
		groupNameLabel.font = [UIFont boldSystemFontOfSize:20];
		groupNameLabel.textAlignment = NSTextAlignmentRight;
		groupNameLabel.backgroundColor = [UIColor clearColor];
		groupNameLabel.textColor = [UIColor whiteColor];
		groupNameLabel.text = @" - ";
		groupNameLabel.shadowColor = [UIColor blackColor];
		[self addSubview:groupNameLabel];
		
		lookNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 4, 230, 18)];
		lookNameLabel.font = [UIFont systemFontOfSize:20];
		lookNameLabel.backgroundColor = [UIColor clearColor];
		lookNameLabel.textColor = [UIColor whiteColor];
		lookNameLabel.shadowColor = [UIColor blackColor];
		[self addSubview:lookNameLabel];
    }
    return self;
}

-(void)setGroupName:(NSString*)groupName andLookName:(NSString*)lookName
{
	NSString *groupName_ = [NSString stringWithFormat:@"%@ - ", groupName];
    CGSize groupNameSize = [groupName_ sizeWithAttributes:@{NSFontAttributeName: groupNameLabel.font}];
    CGSize lookNameSize = [lookName sizeWithAttributes:@{NSFontAttributeName: lookNameLabel.font}];
	
	float offset = (480 - groupNameSize.width - lookNameSize.width) / 2.0;
	groupNameLabel.frame = CGRectMake(offset, 3, groupNameSize.width, 24);
	groupNameLabel.text = groupName_;
	
	lookNameLabel.frame = CGRectMake(offset + groupNameSize.width, 4, lookNameSize.width, 24);
	lookNameLabel.text = lookName;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
