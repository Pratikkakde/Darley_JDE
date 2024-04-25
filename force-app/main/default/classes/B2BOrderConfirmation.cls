/**
 * Created by IrinaSakovich on 4.08.22.
 */

public without sharing class B2BOrderConfirmation {

    @AuraEnabled
    public static B2BResponse getOrderData(String recordId) {
        try {
            if (String.isBlank(recordId)) {
                return new B2BResponse(false, 'No recordId');
            }

            OrderSummary orderSummary = [
                SELECT
                    OrderNumber
                FROM OrderSummary
                WHERE Id = :recordId
                LIMIT 1
            ];

            return new B2BResponse(true, orderSummary.OrderNumber, '');
        } catch (Exception ex) {
            String errorMessage = ex.getMessage() + ' On:' + ex.getStackTraceString();
            System.debug(errorMessage);
            return new B2BResponse(false, errorMessage);
        }
    }
}