//
//  ADVMOHero.h
//  ADVCore
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 Crutches Bicycles. All rights reserved.
//

#import <ADVCore/ADVMOCharacter.h>

@import CoreData;
@import ModularCoreData;


@class ADVMODwelling;


@interface ADVMOHero : ADVMOCharacter <MCDDatabaseEntityDataSource>

@property (nullable, nonatomic, strong) NSString *feature;

@property (nullable, nonatomic, strong) ADVMODwelling *home;

@end
