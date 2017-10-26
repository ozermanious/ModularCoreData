//
//  ADVCharacterListViewController.h
//  ADVCore
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 Crutches Bicycles. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MCDDatabase;


/**
 Контроллер со списком докладов
 */
@interface ADVCharacterListViewController : UIViewController

- (nonnull instancetype)initWithDatabase:(nonnull MCDDatabase *)database;

- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(nullable NSCoder *)aDecoder NS_UNAVAILABLE;
- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end
