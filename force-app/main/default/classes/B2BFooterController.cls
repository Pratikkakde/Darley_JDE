public with sharing class B2BFooterController {

    @AuraEnabled
    public static B2BResponse getNavigationMenuItems(String menuLabel1, String menuLabel2 , String menuLabel4) {
        try {
            List<Object> navigationMenuLinks = new List<Object>();

            Map<String, Object> menuNameToMenuItems1 = new Map<String, Object>{
                'label' => System.Label.B2B_Footer_Menu_Column1_Name,
                'options' => getNavigationMenuLinks(menuLabel1)
            };

            Map<String, Object> menuNameToMenuItems2 = new Map<String, Object>{
                'label' => System.Label.B2B_Footer_Menu_Column2_Name,
                'options' => getNavigationMenuLinks(menuLabel2)
            };

            Map<String, Object> menuNameToMenuItems4 = new Map<String, Object>{
                'label' => System.Label.B2B_Footer_Menu_Column4_Name,
                'options' => getNavigationMenuLinks(menuLabel4)
            };

            navigationMenuLinks.add(menuNameToMenuItems1);
            navigationMenuLinks.add(menuNameToMenuItems2);
            navigationMenuLinks.add(menuNameToMenuItems4);

            return new B2BResponse(true, navigationMenuLinks, 'success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage(), Label.Something_Went_Wrong_Please_contact_your_System_Administrator);
        }
    }

    private static List<Map<String, String>> getNavigationMenuLinks(String menuLabel) {
        List<Map<String, String>> navigationMenuLinks = new List<Map<String, String>>();
        String networkId = Network.getNetworkId();

        List<NavigationLinkSet> linkSet = [
            SELECT
                Id
            FROM NavigationLinkSet
            WHERE MasterLabel = :menuLabel
                AND NetworkId = :networkId
        ];

        Id linkSetId = linkSet.isEmpty() ? null : linkSet[0].Id;
        List<NavigationMenuItem> navigationMenuItems = [
            SELECT
                toLabel(Label),
                Type,
                Target,
                TargetPrefs,
                DefaultListViewId,
                AccessRestriction
            FROM NavigationMenuItem
            WHERE NavigationLinkSetId = :linkSetId
                AND Status = 'Live'
            ORDER BY Position ASC
        ];

        if (Test.isRunningTest()) {
            navigationMenuItems.add(new NavigationMenuItem(Label = 'Test Label1', Target = '/', Type = 'InternalLink'));
            navigationMenuItems.add(new NavigationMenuItem(Label = 'Test Label2', Target = 'https://github.com/', Type = 'ExternalLink'));
        }

        for (NavigationMenuItem item : navigationMenuItems) {
            Map<String, String> menuLabelURLMap = new Map<String, String>();
            if (item.Type == 'InternalLink') {
                menuLabelURLMap.put('label', item.Label);
                menuLabelURLMap.put('value', '/s' + item.Target);
                menuLabelURLMap.put('target','_self');
            }

            if (item.Type == 'ExternalLink') {
                menuLabelURLMap.put('label', item.Label);
                menuLabelURLMap.put('value', item.Target);
                menuLabelURLMap.put('target','_blank');
            }
            navigationMenuLinks.add(menuLabelURLMap);
        }

        return navigationMenuLinks;
    }
}