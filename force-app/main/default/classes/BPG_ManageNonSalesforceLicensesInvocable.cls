/************************************************************************************************************
* Date:        	01Mar19
* Author:      	Richa Pal
* Comments:    	This class is to run the BPG_ManageNonSalesforceLicences class from a process builder. Since 
				BPG_ManageNonSalesforceLicences is made batchable and we cannot call an invocable method written 
				in a Batch, a separate class is created to call doAssignment method
*************************************** Change History ************************************************/
public class BPG_ManageNonSalesforceLicensesInvocable {

    @InvocableMethod(label='Insert PackageLicenses' description='Inserts the PackageLicense to the User based upon the Permission Set Assignment.')
    public static void doassingment()
    {        
        List<id> userIdLst = new List<id> ();
        string query = 'Select id from User';
        if (test.isRunningTest()){
            query += ' where firstname = \'Test\'';
        }
        for (user u : Database.query(query)) {
            userIdLst.add(u.id);
        }
        if (!userIdLst.isEmpty())	
        	BPG_ManageNonSalesforceLicences.doAssignment(userIdLst);
    }
}