@RestResource(urlMapping = '/subtodoapi/*')
global with sharing class SubToDoHandler_Rest {
    
    public static Map<Id, Id> getMapOfSubtodosTodos(List<SubToDo__c> subtodos){
        List<Id> todoIds = new List<Id>();
        for(SubToDo__C sub : subtodos){
            todoIds.add(sub.ToDo__c);
        }
        //select todos which have subtodos from request
        List<ToDo__c> todosOfSubtodos = 
            new List<ToDo__c>([select Id, Connected_Org_Record_Id__c from ToDo__c where Connected_Org_Record_Id__c in: todoIds]);
        
        Map<Id, Id> mapTodos = new Map<Id, Id>();
       	for(ToDo__c tod : todosOfSubtodos){
               mapTodos.put(tod.Connected_Org_Record_Id__c, tod.id);
        }
        return mapTodos;
    }
    	
    @HttpPost
    global static List<SubToDo__c> createSubToDos(){
        
        RestRequest req = RestContext.request;
        List<SubToDo__c> subtodos = 
        (List<SubToDo__c>)JSON.deserialize(req.requestBody.toString(), List<SubToDo__c>.class);
        Map<Id, Id> idmap = getMapOfSubtodosTodos(subtodos);
        for(SubToDo__c subtodo : subtodos){
            subtodo.Connected_Org_Record_Id__c = subtodo.Id;
            subtodo.Id = null;
            subtodo.ToDo__c = idmap.get(subtodo.ToDo__c);
        }
        insert subtodos;
        return subtodos;
    }
    
    @HttpPatch
    global static List<SubToDo__c> updateSubToDos(){ //данные получает, но не апдейтит?...
        RestRequest req = RestContext.request;
        List<SubToDo__c> subtodos = 
        (List<SubToDo__c>)JSON.deserialize(req.requestBody.toString(), List<SubToDo__c>.class);
        List<SubToDo__c> subsList = new List<SubToDo__c>();
        Map<Id, Id> mapTodos = getMapOfSubtodosTodos(subtodos);
        String tempSubtodoId, tempTodoId;
        for(SubToDo__c subtodo : subtodos){
            SubToDo__c subFor = new SubToDo__c(Name = subtodo.Name,
                                               Description__c = subtodo.Description__c,
                                               id = subtodo.Connected_Org_Record_Id__c,
                                               Connected_Org_Record_Id__c = subtodo.Id,
                                               Image_URL__c = subtodo.Image_URL__c,
                                               Is_Done__c = subtodo.Is_Done__c,
                                               Priority__c = subtodo.Priority__c,
                                               ToDo__c = mapTodos.get(subtodo.ToDo__c));
            subsList.add(subFor) ;
        }
        update subsList;
        return subsList;
    }
    
    @HttpDelete
    global static List<SubToDo__c> deleteSubToDos(){
        RestRequest req = RestContext.request;
        List<Id> ids = 
        (List<Id>)JSON.deserialize(req.requestBody.toString(), List<Id>.class);
        List<SubToDo__c> subtodos = 
        [SELECT Id FROM SubToDo__c WHERE Connected_Org_Record_Id__c IN : ids];
        delete subtodos;
        return subtodos;
    }
   
}