public with sharing class B2BCsvParser {
    public Blob csvFileBody;
    public String csvFileBodyString;

    private final static String COMMA = ',';
    private final static String CR = '\r';
    private final static String LF = '\n';
    private final static String CRLF = '\r\n';

    public B2BCsvParser(Blob csvFileBody) {
        this.csvFileBody = csvFileBody;
        this.csvFileBodyString = convertLineEndings(csvFileBody.toString().toLowerCase());
    }

    public List<List<String>> getCSVData() {
        List<List<String>> result = new List<List<String>>();
        List<String> lines = this.csvFileBodyString.split(LF);

        List<String> handleLineResultFirstLine = handleCSVLine(lines[0]);
        result.add(handleLineResultFirstLine);
        Integer firstLineSize = handleLineResultFirstLine.size();

        for (Integer i = 1; i < lines.size(); i++) {
            String lineValue = '';
            List<String> handleLineResult;
            do {
                lineValue += LF + lines[i];
                handleLineResult = handleCSVLine(lineValue);

                if (handleLineResult.size() != firstLineSize) {
                    i++;
                    if (i >= lines.size()) {
                        throw new DmlException('Please, check the CSV file');
                    }
                }
            } while (handleLineResult.size() != firstLineSize);

            result.add(handleLineResult);
        }

        return result;
    }

    private static String convertLineEndings(String csvString) {
        return csvString.replace(CRLF, LF).replace(CR, LF);
    }

    private static List<String> handleCSVLine(String line) {
        if (line.endsWith(COMMA)) {
            line += ' ';
        }

        List<String> splitLine = line.split(COMMA);
        List<String> result = new List<String>();
        Integer splitLineSize = splitLine.size();
        for (Integer i = 0; i < splitLineSize; i++) {
            String item = splitLine[i];

            if (String.isBlank(item)) {
                result.add('');
                continue;
            } else {
                item = item.trim();
            }

            result.add(item);
        }

        return result;
    }
}