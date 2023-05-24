/**
 * @description: Unique trigger for MuleEventQueue__c
 * @author: Henrique Bustillos - Everymind
 */
trigger MuleEventQueue on MuleEventQueue__c (
    before insert, before update
    , after insert, after update
) {
    new MuleEventQueueHandler().run();
}