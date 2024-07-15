/******************************************************************************************************************************************************
Name                    : SupplierXlatTrigger_handler
Author                  : Melonleaf
Description             :This class is written to give error if we find duplicate record
Version                 : 1.0
Change Log              : 
Test Class              : SupplierXlatTrigger_handlerTest
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/

public class SupplierXlatTrigger_handler {
    
/******************************************************************************************************************************************************
   Checking the duplicate record and giving error
/******************************************************************************************************************************************************/
 
    public static void duplicateChildName(list<Supplier_XLAT__c>supplierXlatList,map<id,Supplier_XLAT__c>oldXlatMap){
        system.debug('supplierXlatList'+supplierXlatList.size());
        
        map<string,Supplier_XLAT__c>xlatmap=new map <string,Supplier_XLAT__c>();
        set<string>childnameset=new set<string>();
         
        for(Supplier_XLAT__c x:supplierXlatList){
            if(oldXlatMap!=null){
            if(x.child__c !=oldXlatMap.get(x.id).child__C){
            childnameset.add(x.child__c); 
        }
        }
            else{
                           childnameset.add(x.child__c); 
 
            }
        }
        list<Supplier_XLAT__c>xlatlist=[select id, Child__c from Supplier_XLAT__c where child__C =: childnameset ]; 
        //system.debug('xlatlist'+xlatlist[0].child__c);
        for(Supplier_XLAT__c x:xlatlist){
            xlatmap.put(x.child__c,x);
        }
       
        for(Supplier_XLAT__c x:supplierXlatList){
            if(xlatmap.containskey(x.Child__c)){
                x.addError('Record with this child name already exist');
            }
            
        }
        }
      
}