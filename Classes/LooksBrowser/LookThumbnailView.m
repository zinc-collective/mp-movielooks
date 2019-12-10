//
//  LookThumnailView.m
//  MobileLooks
//
//  Created by George on 9/14/10.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
//

#import "LookThumbnailView.h"


#define PORTRAIT_LOCK_WIDTH		38
#define PORTRAIT_LOCK_HEIGHT	30

#define LANDSCAPE_LOCK_WIDTH	44
#define LANDSCAPE_LOCK_HEIGHT	35

//Joe, define or undefine this for the "inspired by" text
//#define BOTTOM_TEXT

@implementation LookThumbnailView

@synthesize groupIndex, lookIndex, pageIndex, delegate;
@synthesize frameView, borderView, titleBackgroundView, titleLabel, descBackgroundView, descLabel,lockView, activityIndicator;
@synthesize renderingState;
@synthesize actualRect;

- (id)initWithFrame:(CGRect)frame lookInfo:(NSDictionary*)lookDic;
{
    if ((self = [super initWithFrame:frame]))
	{
		//CGRect rect = CGRectMake(10, 10, self.bounds.size.width-20, self.bounds.size.height-20);
		//frameView = [[UIImageView alloc] initWithFrame:rect];
		//borderView = [[UIImageView alloc] initWithFrame:self.bounds];
		//bret
		borderView = [[UIImageView alloc] initWithFrame:self.bounds];
        CGRect rect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
		frameView = [[UIImageView alloc] initWithFrame:rect];

		NSString *title = [lookDic objectForKey:kLookName];
		UIFont *titleFont = [UIFont systemFontOfSize:16.0];
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
			titleFont = [UIFont boldSystemFontOfSize:22.0];
		}

        // http://stackoverflow.com/questions/18315441/with-what-should-i-replace-the-deprecated-sizewithfont-method
        CGSize maximumLabelSize = CGSizeMake(230, MAXFLOAT);
        NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
        NSDictionary * attributes = @{NSFontAttributeName: titleFont};
        CGRect titleRect = [title boundingRectWithSize:maximumLabelSize options:options attributes:attributes context:nil];

		titleBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 26)];
        //titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5+2, 6+3, titleSize.width + 10, 22)];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, titleRect.size.width + 10, 22)];
		titleLabel.font = titleFont;
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.text = title;

		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
			titleBackgroundView.frame = CGRectMake(0, 0, self.bounds.size.width, 58);
			titleLabel.frame = CGRectMake(5, 9, titleRect.size.width + 10, 30);
		}
		[titleBackgroundView setBackgroundColor:[UIColor blackColor]];
		titleBackgroundView.alpha = 0.5f;

        //bret new (wierd bug on ios 6, leaving out for now)
#ifdef BOTTOM_TEXT
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            NSString *desc;
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                desc = [lookDic objectForKey:kLookDesc];
            else
                desc = [lookDic objectForKey:kLookDesc1];

            UIFont *descFont = [UIFont systemFontOfSize:12.0];
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                descFont = [UIFont boldSystemFontOfSize:22.0];
            }
            CGSize descSize = [desc sizeWithFont:descFont
                                        forWidth:self.bounds.size.width-10
                                   lineBreakMode:NSLineBreakByTruncatingTail];

            descBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-26, self.bounds.size.width, 26)];
            descLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.bounds.size.width - descSize.width)/2, self.bounds.size.height-26+2, descSize.width + 10, 22)];
            descLabel.font = descFont;
            descLabel.textColor = [UIColor whiteColor];
            descLabel.text = desc;

            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                descBackgroundView.frame = CGRectMake(0, self.bounds.size.height-58, self.bounds.size.width, 58);
                descLabel.frame = CGRectMake((self.bounds.size.width - descSize.width)/2, self.bounds.size.height-58+13, descSize.width + 10, 30);
            }
            [descBackgroundView setBackgroundColor:[UIColor blackColor]];
            descBackgroundView.alpha = 0.5f;
        }
#endif
        //
		//295,325,192-139
		lockView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-30, frame.size.height-53, PORTRAIT_LOCK_WIDTH, PORTRAIT_LOCK_HEIGHT)];
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activityIndicator.center = CGPointMake(165, 90);
		activityIndicator.hidesWhenStopped = YES;

        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			lockView.frame = CGRectMake(frame.size.width-80, frame.size.height-120, 96, 80);
		}

		UIColor *clearColor = [UIColor clearColor];
		borderView.backgroundColor = clearColor;
		//titleBackgroundView.backgroundColor = clearColor;
		titleLabel.backgroundColor = clearColor;
		lockView.backgroundColor = clearColor;

		[self addSubview:frameView];
		//[self addSubview:borderView];
		[self addSubview:titleBackgroundView];
		[self addSubview:titleLabel];
#ifdef BOTTOM_TEXT
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            [self addSubview:descBackgroundView];
            [self addSubview:descLabel];
        }
#endif
		[self addSubview:lockView];
		[self addSubview:activityIndicator];


		activityIndicator.center = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
	}
    return self;
}

- (void)setThumbnailImage:(UIImage*)image
{
#if 0
    CGRect thumbnailRect = CGRectMake(10, 10, self.bounds.size.width-20, self.bounds.size.height-20);
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		thumbnailRect = CGRectMake(10+7, 10+9, self.bounds.size.width-32, self.bounds.size.height-39);
	}
	CGSize thumbnailImageSize = CGSizeMake(image.size.width*thumbnailRect.size.height/image.size.height,thumbnailRect.size.height);
	frameView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2+10, 10, thumbnailImageSize.width, thumbnailImageSize.height);
    frameView.image = image;
#endif
    CGRect thumbnailRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
	CGSize thumbnailImageSize = CGSizeMake(image.size.width*thumbnailRect.size.height/image.size.height,thumbnailRect.size.height);
	frameView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
    frameView.image = image;
}

//bret
- (void)resizeThumbnailImage
{
#if 0
    CGRect thumbnailRect = CGRectMake(10, 10, self.bounds.size.width-20, self.bounds.size.height-20);
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		thumbnailRect = CGRectMake(10+7, 10+9, self.bounds.size.width-32, self.bounds.size.height-39);
	}
	CGSize thumbnailImageSize = CGSizeMake(frameView.image.size.width*thumbnailRect.size.height/frameView.image.size.height,thumbnailRect.size.height);
	frameView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2+10, 10, thumbnailImageSize.width, thumbnailImageSize.height);
#endif
    CGRect thumbnailRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
	CGSize thumbnailImageSize = CGSizeMake(frameView.image.size.width*thumbnailRect.size.height/frameView.image.size.height,thumbnailRect.size.height);
	frameView.frame = CGRectMake((thumbnailRect.size.width-thumbnailImageSize.width)/2, 0, thumbnailImageSize.width, thumbnailImageSize.height);
}

//- (void)portraitWithFrame:(CGRect)frame
//{
//	self.frame = frame;
//	borderView.frame = self.bounds;
//	frameView.frame = CGRectMake(self.bounds.origin.x + 9, self.bounds.origin.y + 9, self.bounds.size.width - 18, self.bounds.size.height - 18);
//	activityIndicator.center = CGPointMake(135, 80);
//
//	titleBackgroundView.frame = CGRectMake(8, 8, titleBackgroundView.frame.size.width, 26);
//	titleLabel.frame = CGRectMake(13, 9, titleLabel.frame.size.width, 20);
//
//	if (lockView.hidden == NO)
//	{
//		lockView.frame = CGRectMake(300, 130, 38, 30);
//	}
//}
//
//- (void)landscapeWithFrame:(CGRect)frame
//{
//	self.frame = frame;
//	borderView.frame = CGRectMake(7, 0, 325, 192);
//	frameView.frame = CGRectMake(16, 9, 307, 174);
//	activityIndicator.center = CGPointMake(165, 90);
//
//	titleBackgroundView.frame = CGRectMake(17, 11, titleBackgroundView.frame.size.width, 26);
//	titleLabel.frame = CGRectMake(22, 12, titleLabel.frame.size.width, 20);
//
//	if (lockView.hidden == NO)
//	{
//		lockView.frame = CGRectMake(295, 139, LANDSCAPE_LOCK_WIDTH, LANDSCAPE_LOCK_HEIGHT);
//	}
//}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];

	if ([touch view] == self)
	{
		CGPoint touchPoint = [touch locationInView:self];

		if ( CGRectContainsPoint(self.bounds, touchPoint) )
		{
			[delegate tapLook:lookIndex inGroup:groupIndex];
			NSLog(@"touch");
		}

		return;
	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end

