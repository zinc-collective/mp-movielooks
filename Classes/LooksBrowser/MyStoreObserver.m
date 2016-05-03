//
//  MyStoreObserver.h
//  
//
//  Created by George on 10-9-1.
//  Copyright RED/SAFI 2010. All rights reserved.
//

#import "MyStoreObserver.h"


@implementation MyStoreObserver

#pragma mark -
#pragma mark Business

- (void) recordTransaction: (SKPaymentTransaction *)transaction
{
	NSLog(@"recordTransaction:");
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	NSArray *looks = [prefs arrayForKey:kUserLooks];
	
	if (looks != nil)
	{
		NSMutableArray *mutableLooks = [NSMutableArray arrayWithCapacity:[looks count]];
		
		for (NSDictionary *groupsDic in looks)
		{
			NSString *identifier = [groupsDic objectForKey:kProductIdentifier];
			
			if ([identifier compare:transaction.payment.productIdentifier] == NSOrderedSame)
			{
				NSMutableDictionary *mutableGroupsDic = [groupsDic mutableCopy];
				[mutableGroupsDic setObject:[NSNumber numberWithBool:NO] forKey:kProductLocked];
				[mutableLooks addObject:mutableGroupsDic];
			}
			else
			{
				[mutableLooks addObject:groupsDic];
			}
		}
		
		[prefs setObject:mutableLooks forKey:kUserLooks];
		[prefs synchronize];
	}
}

- (void) provideContent: (NSString *)identifier
{
	NSLog(@"provideContent:");
	//NSDictionary *dic = [NSDictionary dictionaryWithObject:identifier forKey:kProductIdentifier];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"purchaseSuccess" object:identifier];// userInfo:dic];
}


#pragma mark -
#pragma mark Transaction Event

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
	// Your application should implement these two methods.
	[self recordTransaction: transaction];
	[self provideContent: transaction.payment.productIdentifier];
	
	// Remove the transaction from the payment queue.
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	if (transaction.error.code != SKErrorPaymentCancelled)		// Optionally, display an error here.
		[[NSNotificationCenter defaultCenter] postNotificationName:@"faliedTransaction" object:nil];
    else
		[[NSNotificationCenter defaultCenter] postNotificationName:@"cancelTransaction" object:nil];
	
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
	[self recordTransaction: transaction];
//	[self provideContent: transaction.originalTransaction.payment.productIdentifier];
//	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


#pragma mark -
#pragma mark Observer Methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	NSLog(@"paymentQueue: updatedTransactions:");
	for (SKPaymentTransaction* transaction in transactions)
	{
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchased:
				[self completeTransaction:transaction];
				break;
			case SKPaymentTransactionStateFailed:
				[self failedTransaction:transaction];
				break;
			case SKPaymentTransactionStateRestored:
				[self restoreTransaction:transaction];
				break;
			default:
				break;
		}
	}
}

@end