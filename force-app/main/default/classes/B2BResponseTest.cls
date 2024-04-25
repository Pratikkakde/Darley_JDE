@IsTest
public with sharing class B2BResponseTest {
    @IsTest
    private static void testBehavior() {
        B2BResponse response = new B2BResponse();
        response = new B2BResponse(true);
        response = new B2BResponse(true, 'Test');
        response = new B2BResponse(true, 'Test');
        response = new B2BResponse(true, 'Test','Test');
    }
}