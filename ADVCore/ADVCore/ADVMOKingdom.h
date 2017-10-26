//
//  ADVMOKingdom.h
//  ADVCore
//
//  Created by Vladimir Ozerov on 12/10/2017.
//  Copyright © 2017 Crutches Bicycles. All rights reserved.
//

@import CoreData;
@import ModularCoreData;


@class ADVMOPrincess;


@interface ADVMOKingdom : NSManagedObject <MCDDatabaseEntityDataSource>

@property (nullable, nonatomic, strong) NSString *name;
@property (nullable, nonatomic, strong) NSNumber *population;

@property (nullable, nonatomic, strong) ADVMOPrincess *princess;

@end
