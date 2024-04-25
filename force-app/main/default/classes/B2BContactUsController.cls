/**
 * description: Controller Class for Contact Us component.
 */
public without sharing class B2BContactUsController {

    @AuraEnabled
    public static B2BResponse createCase(Map<String,Object> request) {
        try {
            //Create the case using basic info
            Database.DMLOptions dmo = new Database.DMLOptions();
            Case contactUsCase = new Case();
            
            AssignmentRule assignmentRule = [
                SELECT Id
                FROM AssignmentRule
                WHERE Name = 'Edarley Contact Us' AND SobjectType = 'Case'
                LIMIT 1
            ];

            List<RecordType> recordType = [
                SELECT Id
                FROM RecordType
                WHERE DeveloperName = 'EDarley_Contact_Us' AND SobjectType = 'Case'
                LIMIT 1
            ];

            dmo.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id; 
            dmo.EmailHeader.triggerUserEmail = true;
            contactUsCase.setOptions(dmo);

            contactUsCase.Subject = (String)request.get('subject');
            contactUsCase.Description = (String)request.get('description');
            contactUsCase.Origin = 'Web';
            contactUsCase.MethodOfContact__c = (String)request.get('contactMethod');
            contactUsCase.TimeOfContact__c = (String)request.get('contactTime');
            contactUsCase.Address__CountryCode__s = (String)request.get('country');
            contactUsCase.Address__StateCode__s = (String)request.get('state');
            contactUsCase.Reason_For_Contact__c = (String)request.get('contactReason');
            contactUsCase.RecordTypeId = recordType[0].Id;
            contactUsCase.SuppliedPhone = (String)request.get('phoneNumber');

            String orderInfo = (String)request.get('existingOrder');
            if (orderInfo != 'other') {
                contactUsCase.OrderId__c = orderInfo;
            }

            if ((Boolean)request.get('isGuestUser')) {
                String firstName=(String)request.get('firstName');
                String lastName=(String)request.get('lastName');
                contactUsCase.SuppliedName = firstName + ' ' + lastName;
                contactUsCase.SuppliedEmail = (String)request.get('email');
                contactUsCase.SuppliedCompany = (String)request.get('companyName');
            } else {
                List<User> users = [
                    SELECT
                        Id,
                        ContactId,
                        AccountId,
                        Account.OwnerId
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
                ];

                contactUsCase.AccountId = users[0].AccountId;
                contactUsCase.ContactId = users[0].ContactId;
            }

            insert contactUsCase;

            return new B2BResponse(true);

        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage());
        }
    }

    /**
    * Get options for Case fields.
    * @return List of Picklist Entry records.
    */
    private static List<B2BUtils.PicklistEntry> getPicklistOptions(string fieldName) { 
        List<B2BUtils.PicklistEntry> entries = new List<B2BUtils.PicklistEntry>();
        entries.addAll(B2BUtils.getPicklistValues('Case', fieldName)); 

        return entries;
    }

    @AuraEnabled
    public static Map<String, Object> getCaseFieldsPicklistOptions() {
        return new Map<String, Object> {
            'storeContactMethodOptions' => getPicklistOptions('MethodOfContact__c'),
            'storeContactTimeOptions' => getPicklistOptions('TimeOfContact__c'),
            'countriesAndStates' => B2BCountryStatePicklists.getCountryStatePicklists(),
            'countriesCode' => B2BCountryStatePicklists.getCountryByCode(),
            'countriesStatesCode' => B2BCountryStatePicklists.getStatesByCountryCode(B2BCountryStatePicklists.getCountryByCode()),
            'storeContactReasonOptions' => getPicklistOptions('Reason_For_Contact__c'),
            'storeLastFiveOrders' =>  getLastFiveOrders()
        };
    }

    private static List<B2BUtils.PicklistEntry> getLastFiveOrders() {
        List<B2BUtils.PicklistEntry> entries = new List<B2BUtils.PicklistEntry>();

        for (Order currentOrder : [
            SELECT 
                Id,
                OrderNumber,
                CreatedDate
            FROM Order
            WHERE OwnerId = :UserInfo.getUserId()
            ORDER BY CreatedDate DESC
            LIMIT 5
        ]) {
            String label = 'ORDER ' + currentOrder.OrderNumber + ', ' + currentOrder.CreatedDate.format('dd/MM/yyyy');
            entries.add(new B2BUtils.PicklistEntry(label, currentOrder.Id.to15()));
        }
        entries.add(new B2BUtils.PicklistEntry('Other', 'Other'));

        return entries;
    }
}