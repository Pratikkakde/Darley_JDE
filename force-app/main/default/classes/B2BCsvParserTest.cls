@IsTest
private class B2BCsvParserTest {
    public static final String TEST_CSV_DATA =
        'SKU' + ',' + 'Quantity' + '\n' +
            '10000-min' + ',' + '10' + '\n' +
            '10000-max' + ',' + '4' + '\n' +
            '10000-px' + ',' + '10' + '\n' +
            '10000-ss' + ',' + '3' + '\n' +
            '10001' + ',' + '15' + '\n';

    @IsTest
    private static void testParseCSV() {
        B2BCsvParser aB2BCsvParser = new B2BCsvParser(Blob.valueOf(TEST_CSV_DATA));
        List<List<String>> fields = aB2BCsvParser.getCSVData();

        System.assertEquals(false, fields.isEmpty());
    }
}