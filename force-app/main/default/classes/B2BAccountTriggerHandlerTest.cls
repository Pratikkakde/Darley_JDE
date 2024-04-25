@isTest
public with sharing class B2BAccountTriggerHandlerTest {
    @isTest static void deleteRelatedDarleyDollarsTest() {
        Integer accToCreate = 50;
        Integer ordersToCreate = 2;
        List<Account> accounts = B2BTestDataFactory.createAccounts(accToCreate, true);
        Map<Id, Contact> accContactsMap = B2BTestDataFactory.createContacts(accounts, true);
        Map<Id, Contract> AccContractsMap = B2BTestDataFactory.createContracts(accounts, true);
        Map<Id, List<Order>> accOrdersMap = B2BTestDataFactory.createOrders(AccContractsMap, ordersToCreate, true);
        Map<Id, List<DarleyDollar__c>> AccDarleyDollarMap = B2BTestDataFactory.createDarleyDollars(accOrdersMap, accContactsMap, true);
        List<Account> updatedAccounts = B2BTestDataFactory.updateOptoutFromDarleyDollarsAccount(accounts, true, false);
        Integer createdDarleyDollars = [SELECT count() FROM DarleyDollar__c WHERE Contact__r.AccountId IN :accOrdersMap.keySet()];
        
        Test.startTest();
        update updatedAccounts;
        Test.stopTest();
        
        System.assertEquals(accToCreate*ordersToCreate, createdDarleyDollars);
        System.assertEquals(0, [SELECT count() FROM DarleyDollar__c WHERE Contact__r.AccountId IN :accOrdersMap.keySet()]);
    
    }

    @IsTest
    static void assignContactPointAddressesAfterMerge() {
        Account masterAccount = B2BTestDataFactory.createAccount(false, 'Account1');
        insert masterAccount;

        List<Account> accountDuplicates = new List<Account> {
            new Account(Name='Account2'),
            new Account(Name='Account3')
        };
        insert accountDuplicates;

        List<ContactPointAddress> addresses = new List<ContactPointAddress> {
            new ContactPointAddress(
                AddressType = 'Billing',
                Name = 'Address1',
                ParentId = masterAccount.Id,
                IsDefault = false,
                Country = 'United States',
                State = 'Texas',
                City = 'Austin1',
                Street = 'Test Address',
                PostalCode = '73301'
            ),
            new ContactPointAddress(
                AddressType = 'Billing',
                Name = 'Address2',
                ParentId = accountDuplicates[0].Id,
                IsDefault = false,
                Country = 'United States',
                State = 'Texas',
                City = 'Austin2',
                Street = 'Test Address',
                PostalCode = '73302'
            ),
            new ContactPointAddress(
                AddressType = 'Billing',
                Name = 'Address3',
                ParentId = accountDuplicates[0].Id,
                IsDefault = false,
                Country = 'United States',
                State = 'Texas',
                City = 'Austin3',
                Street = 'Test Address',
                PostalCode = '73303'
            ),
            new ContactPointAddress(
                AddressType = 'Billing',
                Name = 'Address4',
                ParentId = accountDuplicates[1].Id,
                IsDefault = false,
                Country = 'United States',
                State = 'Texas',
                City = 'Austin4',
                Street = 'Test Address',
                PostalCode = '73304'
            ),
            new ContactPointAddress(
                AddressType = 'Billing',
                Name = 'Address5',
                ParentId = accountDuplicates[1].Id,
                IsDefault = false,
                Country = 'United States',
                State = 'Texas',
                City = 'Austin5',
                Street = 'Test Address',
                PostalCode = '73305'
            )
        };
        insert addresses;

        Test.startTest();
        Database.MergeResult[] results = Database.merge(masterAccount, accountDuplicates, false);
        Test.stopTest();

        System.assertEquals([SELECT Id FROM ContactPointAddress WHERE ParentId = :masterAccount.Id].size(), 5, 'Contact Point Address records were not merged.');
    }

}