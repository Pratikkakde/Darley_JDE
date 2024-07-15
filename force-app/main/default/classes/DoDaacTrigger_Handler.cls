/******************************************************************************************************************************************************
Name                    : DoDaacTrigger_Handler
Author                  : Melonleaf
Purpose                 : This Trigger Handler class is designed to update the Bid Line Items  on insert and update of DoDaac.
Description             : This is the Trigger Handler of DoDaac . updating related Bid Line Item records with specific address and state information whenever 
                          DoDAAC records are inserted or updated on the bases of the Due Date .
Version                 : 1.0
Change Log              : 
Test Class              : DoDaacTrigger_Test
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/


/******************************************************************************************************************************************************
The method updates Bid Line Item records to associate them with the correct DoDAAC and populate address fields based on the DoDAAC information,
ensuring data consistency whenever DoDAAC records are inserted
******************************************************************************************************************************************************/
public class DoDaacTrigger_Handler {
    // when user enters the Dodaac through Email then also we have to insert some Fields in the Bid line item....
    public static void DodaacUpdate_Method(List<DoDAAC__c> dodaacList) {
        Map<String, DoDAAC__c> dodaacMap = new Map<String, DoDAAC__c>();
        Set<String> dodaacNames = new Set<String>();

        // Populate the dodaacMap and dodaacNames
        for (DoDAAC__c dodaacRecord : dodaacList) {
            dodaacMap.put(dodaacRecord.Name, dodaacRecord);
            dodaacNames.add(dodaacRecord.Name);
            System.debug('Dodaac Name --> ' + dodaacRecord.Name);
        }

        List<Bid_Line_Item__c> bidLineUpdateList = new List<Bid_Line_Item__c>();
       Id recordTypeId = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        // Query only the relevant Bid_Line_Item__c records
        List<Bid_Line_Item__c> bidLineItemList = [SELECT Id, Name, Ship_To_DoDAAC__c, DoDAAC_Number_Text__c ,Bid_Supplier__r.Email_Address__c, Status__c,ServiceNow_State__c,Country__c,City__c,ZIP_Postal_Code__c,Due_Date__c
                                                  FROM Bid_Line_Item__c
                                                  WHERE DoDAAC_Number_Text__c IN :dodaacNames AND RecordTypeId =: recordTypeId];

        for (Bid_Line_Item__c bidRecord : bidLineItemList) {
            if (dodaacMap.containsKey(bidRecord.DoDAAC_Number_Text__c) && bidRecord.Ship_To_DoDAAC__c == Null && bidRecord.Bid_Supplier__r.Email_Address__c != NULL &&  bidRecord.Due_Date__c >= Date.Today()) {
                bidRecord.Ship_To_DoDAAC__c = dodaacMap.get(bidRecord.DoDAAC_Number_Text__c).Id;
      
                if( bidRecord.ServiceNow_State__c == null && bidRecord.Country__c == null && bidRecord.City__c == null &&  bidRecord.ZIP_Postal_Code__c == null ){
                    // Tac2 State
                bidRecord.ServiceNow_State__c = dodaacMap.get(bidRecord.DoDAAC_Number_Text__c).TAC2_Ship_To_State_A_Province__c;
                    //Tac2 Country
                  bidRecord.Country__c = dodaacMap.get(bidRecord.DoDAAC_Number_Text__c).TAC2_Ship_To_Country_Name__c; 
                    //Tac2 City
                    bidRecord.City__c = dodaacMap.get(bidRecord.DoDAAC_Number_Text__c).TAC2_Ship_To_City__c;
                    //Tac2 Zip
                     bidRecord.ZIP_Postal_Code__c  = dodaacMap.get(bidRecord.DoDAAC_Number_Text__c).TAC2_Ship_To_Zip__c;
                }
               
                
                
            }
            // FOR NULL EMAIL ADDRESS 
                else if(dodaacMap.containsKey(bidRecord.DoDAAC_Number_Text__c) && bidRecord.Ship_To_DoDAAC__c == Null  && bidRecord.Bid_Supplier__r.Email_Address__c == NULL  && bidRecord.Due_Date__c >= Date.Today() ){
                     bidRecord.Ship_To_DoDAAC__c = dodaacMap.get(bidRecord.DoDAAC_Number_Text__c).id;
                // bidRecord.Status__c = 'New';  
        if( bidRecord.ServiceNow_State__c == null && bidRecord.Country__c == null && bidRecord.City__c == null &&  bidRecord.ZIP_Postal_Code__c == null ){// Tac2 State
                bidRecord.ServiceNow_State__c = dodaacMap.get(bidRecord.DoDAAC_Number_Text__c).TAC2_Ship_To_State_A_Province__c;
                    //Tac2 Country
                  bidRecord.Country__c = dodaacMap.get(bidRecord.DoDAAC_Number_Text__c).TAC2_Ship_To_Country_Name__c; 
                    //Tac2 City
                    bidRecord.City__c = dodaacMap.get(bidRecord.DoDAAC_Number_Text__c).TAC2_Ship_To_City__c;
                    //Tac2 Zip
                     bidRecord.ZIP_Postal_Code__c  = dodaacMap.get(bidRecord.DoDAAC_Number_Text__c).TAC2_Ship_To_Zip__c;
                }
               
                    SYSTEM.DEBUG('Status-->'+  bidRecord.Status__c);
                     SYSTEM.DEBUG('Email Address-->'+  bidRecord.Bid_Supplier__r.Email_Address__c);
                }
                bidLineUpdateList.add(bidRecord);
            }
        

       
        if (!bidLineUpdateList.isEmpty()) {
            update bidLineUpdateList;
        }
    }
    
    
    /******************************************************************************************************************************************************
    The method updates Bid Line Item records with address information from related DoDAAC records when certain conditions are met, 
    ensuring that the latest DoDAAC data is reflected in Bid Line Items.
    When user updates the Existing Record then we have to update the Updated value in the Bid line item ..................
   ******************************************************************************************************************************************************/
    public static void handleDoDaacUpdates(List<DoDAAC__c> dodaacList) {
        List<Bid_Line_Item__c> bidLineItemsToUpdate = [SELECT Id, ServiceNow_State__c, Ship_To_DoDAAC__c, DoDAAC_Number_Text__c, Ship_To_DoDAAC__r.Name,
                                                       Ship_To_DoDAAC__r.TAC2_Ship_To_State_A_Province__c, Ship_To_DoDAAC__r.TAC2_Ship_To_Country_Name__c,
                                                       Ship_To_DoDAAC__r.TAC2_Ship_To_Line_1__c, Ship_To_DoDAAC__r.TAC2_Ship_To_Zip__c,
                                                       Ship_To_DoDAAC__r.TAC2_Ship_To_City__c,ZIP_Postal_Code__c,Country__c,City__c,Due_Date__c
                                                       FROM Bid_Line_Item__c WHERE Ship_To_DoDAAC__c IN :dodaacList AND Due_Date__c >= Today ];
        System.debug('bidLineItemsToUpdate--->'+ bidLineItemsToUpdate);
        list<Bid_Line_Item__c>  bidlineUpdate = new list<Bid_Line_Item__c>(); 
        Map<String, DoDAAC__c> DodaacMapId = new Map<String, DoDAAC__c>();
        for (DoDAAC__c dodaacRecord : dodaacList) {
            DodaacMapId.put(dodaacRecord.Name, dodaacRecord);
        }
        for (Bid_Line_Item__c bidlinerecord : bidLineItemsToUpdate) {
            if (DodaacMapId.containsKey(bidlinerecord.Ship_To_DoDAAC__r.Name)  &&  bidlinerecord.Due_Date__c >= Date.Today()) {
                System.debug('IN If--------->');
                if(bidlinerecord.ServiceNow_State__c == null && bidlinerecord.Country__c == null && bidlinerecord.City__c == null &&  bidlinerecord.ZIP_Postal_Code__c == null ){                
                    // Tac2 State
                    bidlinerecord.ServiceNow_State__c = DodaacMapId.get(bidlinerecord.DoDAAC_Number_Text__c).TAC2_Ship_To_State_A_Province__c;
                    //Tac2 Country
                    bidlinerecord.Country__c = DodaacMapId.get(bidlinerecord.DoDAAC_Number_Text__c).TAC2_Ship_To_Country_Name__c; 
                    //Tac2 City
                    bidlinerecord.City__c = DodaacMapId.get(bidlinerecord.DoDAAC_Number_Text__c).TAC2_Ship_To_City__c;
                    //Tac2 Zip
                    bidlinerecord.ZIP_Postal_Code__c  = DodaacMapId.get(bidlinerecord.DoDAAC_Number_Text__c).TAC2_Ship_To_Zip__c;
                }
                
                
                System.debug('bidlinerecord.ServiceNow_State__c-->'+ bidlinerecord.ServiceNow_State__c);
            }
            bidlineUpdate.add(bidlinerecord);   
        }
        if(!bidlineUpdate.isEmpty()){
            Update bidlineUpdate;
        }
    }
}