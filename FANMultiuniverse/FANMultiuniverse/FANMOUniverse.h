//
//  FANMOUniverse.h
//  FANMultiuniverse
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 FANs. All rights reserved.
//

#import <Foundation/Foundation.h>


@import CoreData;
@import ModularCoreData;
@import ADVCore;


@interface FANMOUniverse : NSManagedObject

@property (nullable, nonatomic, strong) NSString *name;
@property (nullable, nonatomic, strong) NSNumber *isOriginal;

@property (nullable, nonatomic, strong) NSSet<ADVMOCharacter *> *characterSet;
@property (nullable, nonatomic, strong) NSSet<ADVMOKingdom *> *kingdomSet;
@property (nullable, nonatomic, strong) NSSet<ADVMODwelling *> *dwellingSet;

@end


@interface FANMOUniverse (CoreDataGeneratedAccessors)

- (void)addCharacterSetObject:(nullable ADVMOCharacter *)value;
- (void)removeCharacterSetObject:(nullable ADVMOCharacter *)value;
- (void)addCharacterSet:(nullable NSSet<ADVMOCharacter *> *)values;
- (void)removeCharacterSet:(nullable NSSet<ADVMOCharacter *> *)values;

- (void)addKingdomSetObject:(nullable ADVMOKingdom *)value;
- (void)removeKingdomSetObject:(nullable ADVMOKingdom *)value;
- (void)addKingdomSet:(nullable NSSet<ADVMOKingdom *> *)values;
- (void)removeKingdomSet:(nullable NSSet<ADVMOKingdom *> *)values;

- (void)addDwellingSetObject:(nullable ADVMODwelling *)value;
- (void)removeDwellingSetObject:(nullable ADVMODwelling *)value;
- (void)addDwellingSet:(nullable NSSet<ADVMODwelling *> *)values;
- (void)removeDwellingSet:(nullable NSSet<ADVMODwelling *> *)values;

@end
