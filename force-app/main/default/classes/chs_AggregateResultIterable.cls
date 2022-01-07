global class chs_AggregateResultIterable implements Iterable<AggregateResult>{
    private String query;

    global chs_AggregateResultIterable(String soql){
      query = soql;
    }
  
    global Iterator<AggregateResult> Iterator(){
      return new chs_AggregateResultIterator(query);
    }
}