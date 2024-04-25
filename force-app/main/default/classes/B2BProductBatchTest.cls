@IsTest
private class B2BProductBatchTest {

    @IsTest
    static void checkApprovalProcessWithFakeData() {
        
        Test.startTest();

        List<Product2> products = new List<Product2>();
        for (Decimal i = 1; i <= 10; i++) {
            products.add(new Product2(
                Name = 'BatchProductTest' + i
            ));
        }
        insert products;
        
        Test.stopTest();

        Map<Id, Product2> productById = new Map<Id, Product2>(products);
        List<ProcessInstance> processes = [
            SELECT Id, TargetObjectId
            FROM ProcessInstance
            WHERE TargetObjectId IN :productById.keySet()
        ];
        System.assertEquals(processes.size(), products.size(), 'Approval processes were not executed.');

        List<Product2> updatedProducts = [SELECT Id FROM Product2 WHERE Id IN :productById.keySet()];
        System.assertEquals(updatedProducts.size(), products.size(), 'Product fields Is Approval Process were not updated.');
    }

    @IsTest
    static void checkApprovalProcess() {

        Test.startTest();

        List<Product2> products = new List<Product2>();
        for (Decimal i = 1; i <= 50; i++) {
            products.add(new Product2(
                Name = 'BatchProductTest' + i
            ));
        }
        insert products;

        Test.stopTest();

        Map<Id, Product2> productById = new Map<Id, Product2>(products);
        List<ProcessInstance> processes = [
            SELECT Id, TargetObjectId
            FROM ProcessInstance
            WHERE TargetObjectId IN :productById.keySet()
        ];
        System.assertEquals(processes.size(), products.size(), 'Approval processes were not executed.');

        List<Product2> updatedProducts = [SELECT Id FROM Product2 WHERE Id IN :productById.keySet()];
        System.assertEquals(updatedProducts.size(), products.size(), 'Product fields Is Approval Process were not updated.');

    }

    @IsTest
    static void createAsanaTaskFails() {
        Product2 prod = new Product2(Name = 'BatchProductTest');
        insert prod;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BCalloutAsanaTaskCreationTest.B2BAsanaTaskMock(true));
            B2BProductBatch.asanaTaskIntegration(new List<Product2>{prod});
        Test.stopTest();
        Integer taskRelationsCount = [SELECT COUNT() FROM AsanaPublic__AsanaTasksRelation__c WHERE AsanaPublic__ObjectId__c = :prod.Id];
        System.assertEquals(taskRelationsCount, 0);
    }

    @IsTest
    static void createAsanaTaskSuccess() {
        Product2 prod = new Product2(Name = 'BatchProductTest');
        insert prod;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BCalloutAsanaTaskCreationTest.B2BAsanaTaskMock(false));
            B2BProductBatch.asanaTaskIntegration(new List<Product2>{prod});
        Test.stopTest();
        Integer taskRelationsCount = [SELECT COUNT() FROM AsanaPublic__AsanaTasksRelation__c WHERE AsanaPublic__ObjectId__c = :prod.Id];
        System.assertEquals(taskRelationsCount, 1, 'No product task relationship was created');
    }

    @IsTest
    static void productTriggerCoverage() {
        Product2 prod = new Product2(Name = 'BatchProductTest');
        insert prod;
        prod.Name = 'Update name';
        update prod;
        delete prod;
    }

}