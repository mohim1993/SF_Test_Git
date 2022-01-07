global class chs_AggregateResultIterator implements Iterator<AggregateResult>{
    AggregateResult [] results {get;set;}

    // tracks which result item is returned
    Integer index {get; set;} 
         
    global chs_AggregateResultIterator(String query) {
      index = 0;
      results = Database.query(query);            
    } 
  
    global boolean hasNext(){ 
      return results != null && !results.isEmpty() && index < results.size(); 
    }    
  
    global AggregateResult next(){        
      return results[index++];            
    }   
}