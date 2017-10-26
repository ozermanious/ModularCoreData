//
//  ADVMOPrincess.h
//  ADVCore
//
//  Created by Vladimir Ozerov on 12/10/2017.
//  Copyright © 2017 Crutches Bicycles. All rights reserved.
//

#import <ADVCore/ADVMOCharacter.h>

@import CoreData;
@import ModularCoreData;


@class ADVMOKingdom;


@interface ADVMOPrincess : ADVMOCharacter <MCDDatabaseEntityDataSource>

@property (nullable, nonatomic, strong) NSString *consistsOf;

@property (nullable, nonatomic, strong) ADVMOKingdom *kingdom;

@end
