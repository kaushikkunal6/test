@isTest

public class AITM_MassEditRL_LookupFieldCtrlTest {
    
    static testMethod void myTestMethod() {
        Contact c = new contact(Lastname='john');
        insert c;
        String[] objects = new list<String>{'Contact','Lead'};
        AITM_MassEditRL_LookupFieldCtrl.lookup('john',objects);
        AITM_MassEditRL_LookupFieldCtrl.getRecordName(c.id,objects);
        
    }

}