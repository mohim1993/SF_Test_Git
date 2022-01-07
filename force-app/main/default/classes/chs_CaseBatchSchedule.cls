/*
* @Purpose: Scheduling chs_CaseBatch
* @Author: Cloud Haven Solutions - OV
* @CreatedDate: 09-02-2021 
* @Related Code: chs_CaseBatchHandler,chs_CaseBatch
* @Test Class: chs_caseBatchTest
* @LastModifiedDate: 09-02-2021
* @LastModifiedBy: 
*/
global class chs_CaseBatchSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        chs_CaseBatch b = new chs_CaseBatch(); 
        database.executebatch(b);
    }
}