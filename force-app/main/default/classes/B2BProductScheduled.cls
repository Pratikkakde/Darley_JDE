public with sharing class B2BProductScheduled implements Schedulable {

    public void execute(SchedulableContext sc) {
        executeBatch();
    }

    private void executeBatch() {
        Database.executeBatch(new B2BProductBatch(), 50);
    }

}