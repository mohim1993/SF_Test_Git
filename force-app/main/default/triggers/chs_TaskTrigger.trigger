trigger chs_TaskTrigger on Task (before insert) {
    if(Trigger.isbefore && Trigger.isInsert)
    {
        List<Task> lstTask = new list<Task>();
        set<String> setCarePlan = new  set<String>();
        
        String carePlanRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByName().get('Care Plan Task').getRecordTypeId();    
       
        for(Task objtask : Trigger.new)
        {
            if(objtask.WhatId != Null){
                if(String.valueof(objtask.WhatId).Startswith('500')  && objtask.RecordTypeId == carePlanRecordTypeId)
                {
                    setCarePlan.add(objtask.WhatId);
                    lstTask.add(objtask);
                }
            }
        }
        if(!setCarePlan.isEmpty()){
            chs_TaskTriggerHandler.TaskPatientUpdate(setCarePlan,lstTask);
        }
    }
}