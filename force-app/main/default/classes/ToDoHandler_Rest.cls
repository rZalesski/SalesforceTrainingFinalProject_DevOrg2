@RestResource(urlMapping = '/todoapi/*')
global with sharing class ToDoHandler_Rest {
    @HttpPost
    global static List<ToDo__c> createToDos(){
        RestRequest req = RestContext.request;
        List<ToDo__c> todos = 
        (List<ToDo__c>)JSON.deserialize(req.requestBody.toString(), List<ToDo__c>.class);
        
        Map<String, Id> recTypeIds = new Map<String, Id>();
        recTypeIds.put('Management', Schema.SObjectType.ToDo__c.getRecordTypeInfosByName().get('Management').getRecordTypeId());
        recTypeIds.put('Administration', Schema.SObjectType.ToDo__c.getRecordTypeInfosByName().get('Administration').getRecordTypeId());
        recTypeIds.put('Development', Schema.SObjectType.ToDo__c.getRecordTypeInfosByName().get('Development').getRecordTypeId());

        for(ToDo__c todo : todos){
            todo.Connected_Org_Record_Id__c = todo.Id;
            todo.RecordTypeId = recTypeIds.get(todo.RecordType.Name);
            todo.RecordType = null;
            todo.Id = null;
        }
        insert todos;
        return todos;
    }
    @HttpPatch
    global static List<ToDo__c> updateToDos(){
        RestRequest req = RestContext.request;
        List<ToDo__c> todos = 
        (List<ToDo__c>)JSON.deserialize(req.requestBody.toString(), List<ToDo__c>.class);
        String temp;
        for(ToDo__c todo : todos){
            temp = todo.Id;
            todo.Id = todo.Connected_Org_Record_Id__c;
            todo.Connected_Org_Record_Id__c = temp;
        }
        update todos;
        return todos;
    }
    @HttpDelete
    global static List<ToDo__c> deleteToDos(){
        RestRequest req = RestContext.request;
        List<Id> ids = 
        (List<Id>)JSON.deserialize(req.requestBody.toString(), List<Id>.class);
        List<ToDo__c> todos = 
        [SELECT Id FROM ToDo__c WHERE Connected_Org_Record_Id__c IN : ids];
        delete todos;
        return todos;
    }
}
