@isTest
public class Test_contactController {
    @isTest

    public static void testmethod2(){
        
        Account acc=new account();
        acc.name='test';
        insert acc;  
        
        opportunity opp=new opportunity();
        opp.name='test';
        opp.accountid=acc.id;
        opp.StageName='Customer Contact';
        opp.CloseDate=system.today();
        
        insert opp;
        
        List<RecordType> C_rtypes = [Select RecordType.Name From RecordType 
 where sObjectType='Contact' and isActive=true ORDER BY RecordType.Name ASC];
       
        List<contact> conlist=new  List<contact>();
        contact con=new contact();
        con.Lastname='Test';
        con.accountid=opp.accountid;
        conlist.add(con);
        insert conlist;
        
        Test.startTest();
        contactController.searchContact1(opp.id,'test');
        contactController.searchContact('test');
        contactController.getContactRTs();
        contactController.Recordtypemethod(opp.id);
        Test.stopTest();
    }
}