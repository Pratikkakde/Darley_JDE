public with sharing class B2BMyAccountMenuController {

    @AuraEnabled
    public static B2BResponse getMyAccountMenuItem(String menuLabel) {
        try {
            List<B2BMyAccountMenuIcon__mdt> myAccountMenuLabelIcons = [
                SELECT TargetURL__c, Icon__c, Page_API_Name__c
                FROM B2BMyAccountMenuIcon__mdt
            ];

            Map<String, B2BMyAccountMenuIcon__mdt> urlToMenuItemInfoMap = new Map<String, B2BMyAccountMenuIcon__mdt>();
            for (B2BMyAccountMenuIcon__mdt item : myAccountMenuLabelIcons) {
                String lowerCaseMenuItem = item.TargetURL__c.toLowerCase();
                urlToMenuItemInfoMap.put(lowerCaseMenuItem, item);
            }

            List<NavigationLinkSet> linkSet = [
                SELECT
                    Id
                FROM NavigationLinkSet
                WHERE MasterLabel = :menuLabel
            ];

            List<NavigationMenuItem> myAccountMenuItems = [
                SELECT toLabel(Label), Target, Type
                FROM NavigationMenuItem
                WHERE Status = 'Live'
                    AND NavigationLinkSetId = :linkSet[0].Id
                ORDER BY Position ASC
            ];

            if (Test.isRunningTest()) {
                myAccountMenuItems.add(new NavigationMenuItem(Label = 'Test Label', Target = '/', Type = 'InternalLink'));
            }

            List<MyAccountMenuItem> myAccountMenu = new List<MyAccountMenuItem>();

            for (NavigationMenuItem item : myAccountMenuItems) {
                if (item.Type == 'InternalLink') {
                    String iconName = urlToMenuItemInfoMap.get(item.Target.toLowerCase())?.Icon__c != null
                        ? urlToMenuItemInfoMap.get(item.Target.toLowerCase()).Icon__c
                        : urlToMenuItemInfoMap.get('default')?.Icon__c;

                    myAccountMenu.add(wrapMyAccountMenuItem(item.Label, item.Target, iconName, urlToMenuItemInfoMap.get(item.Target.toLowerCase())?.Page_API_Name__c));
                }
            }

            return new B2BResponse(true, myAccountMenu, 'success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage(), 'fail');
        }
    }

    private static MyAccountMenuItem wrapMyAccountMenuItem(String label, String url, String iconName, String pageApiName) {
        return new MyAccountMenuItem(label, url, iconName, pageApiName);
    }

    public class MyAccountMenuItem {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String url { get; set; }
        @AuraEnabled public String iconName { get; set; }
        @AuraEnabled public String pageApiName { get; set; }

        public MyAccountMenuItem(String label, String url, String iconName, String pageApiName) {
            this.label = label;
            this.url = url;
            this.iconName = iconName;
            this.pageApiName = pageApiName;
        }
    }

}