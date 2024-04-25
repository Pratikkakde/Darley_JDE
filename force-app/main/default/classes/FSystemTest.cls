@IsTest
public class FSystemTest {

    public class TestException extends Exception {}

    @IsTest
    public static void debugWithLogLevel() {
        FSystem.debug(System.LoggingLevel.ERROR, 'debugWithLogLevel');
        System.assertEquals(1, FSystem.logs.size());
        System.assertEquals('debugWithLogLevel', FSystem.logs.get(0));
    }

    @IsTest
    public static void debugException() {
        FSystem.debug(System.LoggingLevel.ERROR, new TestException('debugException'));
        System.assertEquals(2, FSystem.logs.size());
        System.assertEquals('debugException', FSystem.logs.get(0));
        System.assertEquals('Class.FSystemTest.debugException: line 15, column 1', FSystem.logs.get(1));
    }

    @IsTest
    public static void debugWithoutLogLevel() {
        FSystem.debug('debugWithoutLogLevel');
        System.assertEquals(1, FSystem.logs.size());
        System.assertEquals('debugWithoutLogLevel', FSystem.logs.get(0));
    }
}