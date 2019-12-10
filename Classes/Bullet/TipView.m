//
//  TipView.m
//  MobileLooks
//
//  Created by George on 11/15/10.
//  Copyright 2019 Zinc Collective, LLC. All rights reserved.
//

#import "TipView.h"
#import "DeviceDetect.h"

@implementation TipView

- (id)initWithFrame:(CGRect)frame title:(NSString*)title content:(NSString*)text
{
    if ((self = [super initWithFrame:frame]))
	{
		background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tips_background.png"]];
		background.frame = CGRectMake(5, 8, self.bounds.size.width-10, self.bounds.size.height-17) ;
		[self addSubview:background];


		float font = 16.0;
		CGRect titleRect = CGRectMake(20, 15, 285, 20);

		float width = 285;
		float height = 140.0;

		float contentFontSize = 14.0;

		float fLeft = 20;
		float fTop = 35;

		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {

			font = 30.0;
			titleRect = CGRectMake(40, 55, 530, 35);
			width  = 470;
			height = 394.0;

			contentFontSize = 24.0;

			fLeft = 80;
			fTop = 105;
		}

		UIFont *titleFont = [UIFont boldSystemFontOfSize:font];
		titleLabel = [[UILabel alloc] initWithFrame:titleRect];
		titleLabel.font = titleFont;
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.text = title;
		[self addSubview:titleLabel];

		UIFont *contentFont = [UIFont systemFontOfSize:contentFontSize];
		CGSize constrainedSize = CGSizeMake(width, INT_MAX);
        NSStringDrawingOptions drawingOptions = NSStringDrawingTruncatesLastVisibleLine;
        CGRect contentRect = [text boundingRectWithSize:constrainedSize options:drawingOptions attributes:@{NSFontAttributeName: contentFont} context:nil];

		if (contentRect.size.height > height)
		{
			for (int offset = 1; contentRect.size.height > height && offset < 4; offset++)
			{
				contentFontSize -= offset;
				contentFont = [UIFont systemFontOfSize:contentFontSize];
                contentRect = [text boundingRectWithSize:constrainedSize options:drawingOptions attributes:@{NSFontAttributeName: contentFont} context:nil];
				// NSLog(@"offset=%i, contentFontSize=%.1f", offset, contentFontSize);
			}
		}

		contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(fLeft, fTop, contentRect.size.width, contentRect.size.height)];
		contentLabel.font = contentFont;
		contentLabel.backgroundColor = [UIColor clearColor];
		contentLabel.textColor = [UIColor whiteColor];
		contentLabel.text = text;
		contentLabel.numberOfLines = 0;
		[self addSubview:contentLabel];


		UIImage *img = [UIImage imageNamed:@"lb_thumbnail_border.png"];
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			img = [UIImage imageNamed:@"Processing_text_xiangkuang_heng.png"];
		}
		borderView = [[UIImageView alloc] initWithImage:img];
//		borderView.backgroundColor = [UIColor clearColor];
		borderView.frame = self.bounds;
		[self addSubview:borderView];

    }
    return self;
}

- (void) setNewFrame:(CGRect)frame landscape:(BOOL)landscape{

	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, frame.size.height);
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine;

	UIImage* img;
	if (IS_IPAD)
    {
        if(landscape)
        {
            img = [UIImage imageNamed:@"Processing_text_xiangkuang_heng.png"];

            float font = 30.0;
            CGRect titleRect = CGRectMake(40, 55, 530, 35);
            float width  = 470;
            float height = 394.0;

            float contentFontSize = 24.0;

            float fLeft = 80;
            float fTop = 105;

            UIFont *titleFont = [UIFont boldSystemFontOfSize:font];
            titleLabel.frame = titleRect;
            titleLabel.font = titleFont;

            NSString* text = contentLabel.text;
            UIFont *contentFont = [UIFont systemFontOfSize:contentFontSize];
            CGSize constrainedSize = CGSizeMake(width, INT_MAX);
            CGSize contentSize = [text boundingRectWithSize:constrainedSize options:options attributes:@{NSFontAttributeName: contentFont} context:nil].size;

            if (contentSize.height > height)
            {
                for (int offset = 1; contentSize.height > height && offset < 4; offset++)
                {
                    contentFontSize -= offset;
                    contentFont = [UIFont systemFontOfSize:contentFontSize];
                    contentSize = [text boundingRectWithSize:constrainedSize options:options attributes:@{NSFontAttributeName: contentFont} context:nil].size;

                    // NSLog(@"offset=%i, contentFontSize=%.1f", offset, contentFontSize);
                }
            }

            contentLabel.font = contentFont;
            contentLabel.frame = CGRectMake(fLeft, fTop, contentSize.width, contentSize.height);
        }
        else
        {
            img = [UIImage imageNamed:@"Processing02_text_xiangkuang_shu.png"];

            float font = 30.0;
            CGRect titleRect = CGRectMake(40, 60, 530, 35);
            float width  = 430;
            float height = 394.0;

            float contentFontSize = 26.0;

            float fLeft = 100;
            float fTop = 110;

            UIFont *titleFont = [UIFont boldSystemFontOfSize:font];
            titleLabel.frame = titleRect;
            titleLabel.font = titleFont;

            NSString* text = contentLabel.text;
            UIFont *contentFont = [UIFont systemFontOfSize:contentFontSize];
            CGSize constrainedSize = CGSizeMake(width, INT_MAX);
            CGSize contentSize = [text boundingRectWithSize:constrainedSize options:options attributes:@{NSFontAttributeName: contentFont} context:nil].size;

            if (contentSize.height > height)
            {
                for (int offset = 1; contentSize.height > height && offset < 4; offset++)
                {
                    contentFontSize -= offset;
                    contentFont = [UIFont systemFontOfSize:contentFontSize];
                    contentSize = [text boundingRectWithSize:constrainedSize options:options attributes:@{NSFontAttributeName: contentFont} context:nil].size;

                    // NSLog(@"offset=%i, contentFontSize=%.1f", offset, contentFontSize);
                }
            }

            contentLabel.font = contentFont;
            contentLabel.frame = CGRectMake(fLeft, fTop, contentSize.width, contentSize.height);
        }
    }else //iphone
    {
        if(landscape)
        {
            img = [UIImage imageNamed:@"lb_thumbnail_border.png"];

            float font = 16.0;
            CGRect titleRect = CGRectMake(20, 15, 285, 20);

            float width = 285;
            float height = 140.0;

            float contentFontSize = 14.0;

            float fLeft = 20;
            float fTop = 35;

            UIFont *titleFont = [UIFont boldSystemFontOfSize:font];
            titleLabel.frame = titleRect;
            titleLabel.font = titleFont;

            NSString* text = contentLabel.text;
            UIFont *contentFont = [UIFont systemFontOfSize:contentFontSize];
            CGSize constrainedSize = CGSizeMake(width, INT_MAX);
            CGSize contentSize = [text boundingRectWithSize:constrainedSize options:options attributes:@{NSFontAttributeName: contentFont} context:nil].size;

            if (contentSize.height > height)
            {
                for (int offset = 1; contentSize.height > height && offset < 4; offset++)
                {
                    contentFontSize -= offset;
                    contentFont = [UIFont systemFontOfSize:contentFontSize];
                    contentSize = [text boundingRectWithSize:constrainedSize options:options attributes:@{NSFontAttributeName: contentFont} context:nil].size;

                    // NSLog(@"offset=%i, contentFontSize=%.1f", offset, contentFontSize);
                }
            }

            contentLabel.font = contentFont;
            contentLabel.frame = CGRectMake(fLeft, fTop, contentSize.width, contentSize.height);
        }else
        {
            img = [UIImage imageNamed:@"lb_thumbnail_border.png"];
            float font = 16.0;
            CGRect titleRect = CGRectMake(20, 15, 285-10, 20);

            float width = 285-10;
            float height = 140.0;

            float contentFontSize = 14.0;

            float fLeft = 20;
            float fTop = 35;

            UIFont *titleFont = [UIFont boldSystemFontOfSize:font];
            titleLabel.frame = titleRect;
            titleLabel.font = titleFont;

            NSString* text = contentLabel.text;
            UIFont *contentFont = [UIFont systemFontOfSize:contentFontSize];
            CGSize constrainedSize = CGSizeMake(width, INT_MAX);
            CGSize contentSize = [text boundingRectWithSize:constrainedSize options:options attributes:@{NSFontAttributeName: contentFont} context:nil].size;

            if (contentSize.height > height)
            {
                for (int offset = 1; contentSize.height > height && offset < 4; offset++)
                {
                    contentFontSize -= offset;
                    contentFont = [UIFont systemFontOfSize:contentFontSize];
                    contentSize = [text boundingRectWithSize:constrainedSize options:options attributes:@{NSFontAttributeName: contentFont} context:nil].size;

                    // NSLog(@"offset=%i, contentFontSize=%.1f", offset, contentFontSize);
                }
            }

            contentLabel.font = contentFont;
            contentLabel.frame = CGRectMake(fLeft, fTop, contentSize.width, contentSize.height);
        }
    }

    borderView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	borderView.image = img;

	background.frame = CGRectMake(5, 8, self.bounds.size.width-10, self.bounds.size.height-17);

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
