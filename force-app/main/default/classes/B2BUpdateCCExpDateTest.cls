@IsTest
public class B2BUpdateCCExpDateTest {
    
    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();
        createTestOrder();
    }
    
    @IsTest
    private static void testUpdateCCInfo() {
            
        List<Order> mockTrigger = [SELECT Id, B2BCreditCardId__c, B2B_CreditCard_AuthCode__c, B2B_CreditCard_ExpDate__c FROM Order LIMIT 1];
        
        if(!mockTrigger.isEmpty()) {
            Test.startTest();
            B2BUpdateCCExpDate.updateCCInfo(mockTrigger); 
            Test.stopTest();
            
            //fetch updated orders
            List<Order> afterUpdate = [SELECT B2B_CreditCard_ExpDate__c From Order WHERE B2B_CreditCard_ExpDate__c != null];
            Assert.areEqual(1, afterUpdate.size(), 'Order was not successfully updated');
        }else {
            Assert.fail();
        }
                                                                        
    }
    
    private static void createTestOrder() {
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        if(!accList.isEmpty()) {
            Contact con = new Contact(FirstName = 'Aleysian', LastName = 'Consultant', AccountId = accList[0].Id);
            insert con;
            
            CustomerCardPayment__c payment = new CustomerCardPayment__c(
                        Name = 'Test User',
                        Card_Type__c = 'Visa',
                        Is_Default__c = true,
                        Card_Last_Four__c = '4444',
                        Contact__c =  con.Id,
                        Expiration_Month__c = '06',
                        Expiration_Year__c = '2030',
                        Token__c = 'AAAAAAAAAAAA'
            );
            
            insert payment;
        
            Order order = new Order(
                AccountId = accList[0].Id,
                StoreStatus__c = 'Activated',
                Payment_Type__c = 'Credit Card',
                PaymentIntentId__c = '1234567890',
                BillingPhoneNumber = '1234567890',
                ShippingCity = 'Chicago',
                ShippingStreet = '500 W Madison Street Ste 1450',
                ShippingState = 'Illinois',
                ShippingPostalCode = '60661',
                ShippingCountry = 'United States',
                B2B_CreditCard_AuthCode__c = '200000',
                EffectiveDate = Date.newInstance(2024, 01, 01),
                Status = 'Draft',
                B2BCreditCardId__c = payment.Id
            ); 
            
            try {
                insert order;
            }catch(DmlException e) {
                System.debug(e.getMessage());
            }            
        }        
                    
    }    

}