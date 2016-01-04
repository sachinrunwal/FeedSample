//
//  JsonInfo.h
//  JSONtoCoreData
//
//  Created by Parag Dulam on 30/12/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface JsonInfo : NSManagedObject

@property (nonatomic, retain) NSString * country_name;
@property (nonatomic, retain) NSString * state_name;

@end
