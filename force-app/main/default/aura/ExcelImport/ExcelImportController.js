({
    onTableImport: function (cmp, evt, helper) {
        helper.disableExcelInput(cmp);
        helper.importTableAndThrowEvent(cmp, evt, helper);
    }
})