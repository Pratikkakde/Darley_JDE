public class batch_toadd_blank implements Database.Batchable<sObject>{
public Database.QueryLocator start(Database.BatchableContext bc){
return Database.getQueryLocator('SELECT Id, Is_Blank__c, JDE_Component__c, Logic_Releationship__c FROM Product_Bundle_Rule_Engine__c WHERE JDE_Component__c = null AND Logic_Releationship__c = \'EQ\' AND Is_Blank__c = true');
}
public void execute(Database.BatchableContext bc, List<Product_Bundle_Rule_Engine__c> records){
List<Product_Bundle_Rule_Engine__c> pbList = new List<Product_Bundle_Rule_Engine__c>();
for(Product_Bundle_Rule_Engine__c pb:records){
pb.JDE_Component__c = '*BLANK';
pbList.add(pb);
}
    update pbList;
}
    public void finish(Database.BatchableContext bc){
}
}