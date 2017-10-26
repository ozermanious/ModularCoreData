//
//  ADVMODwelling.h
//  ADVCore
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 Crutches Bicycles. All rights reserved.
//

@import CoreData;
@import ModularCoreData;


@class ADVMOHero;
@class ADVMOVillain;


@interface ADVMODwelling : NSManagedObject <MCDDatabaseEntityDataSource>

@property (nullable, nonatomic, strong) NSString *name;
@property (nullable, nonatomic, strong) NSString *location;

@property (nullable, nonatomic, strong) NSSet<ADVMOHero *> *heroSet;
@property (nullable, nonatomic, strong) ADVMOVillain *villain;

@end


@interface ADVMODwelling (CoreDataGeneratedAccessors)

- (void)addHeroSetObject:(nullable ADVMOHero *)value;
- (void)removeHeroSetObject:(nullable ADVMOHero *)value;
- (void)addHeroSet:(nullable NSSet<ADVMOHero *> *)values;
- (void)removeHeroSet:(nullable NSSet<ADVMOHero *> *)values;

@end
