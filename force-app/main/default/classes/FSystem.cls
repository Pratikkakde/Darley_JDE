public without sharing class FSystem {
//TODO RENAME CLASS NAME
    public static List<Object> logs = new List<Object>();

    public static void debug(LoggingLevel logLevel, Object o) {
        addLog(o);
        System.debug(logLevel, o);
    }

    public static void debug(Object o) {
        addLog(o);
        System.debug(o);
    }

    private static void addLog(Object o) {
        if (o instanceof Exception) {
            Exception e = (Exception) o;
            logs.add(e.getMessage());
            logs.add(e.getStackTraceString());
        } else {
            logs.add(o);
        }
    }
}