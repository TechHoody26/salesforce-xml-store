public class ProfileXMLDemo {
    
    /**
     * Demo method to process the provided Profile XML
     * This method demonstrates how to use the ProfileXMLProcessor
     */
    public static void processStandardUserProfile() {
        // The XML content provided by the user
        String profileXML = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<Profile xmlns="http://soap.sforce.com/2006/04/metadata">' +
                '<custom>false</custom>' +
                '<description>Standard User Profile</description>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.AccountNumber</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.AccountSource</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.Active__c</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.AnnualRevenue</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.BillingAddress</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.CustomerPriority__c</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>false</editable>' +
                    '<field>Account.DandbCompanyId</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.Description</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>false</editable>' +
                    '<field>Account.DunsNumber</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.Fax</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.Industry</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.Jigsaw</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>false</editable>' +
                    '<field>Account.NaicsCode</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>false</editable>' +
                    '<field>Account.NaicsDesc</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.NumberOfEmployees</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.NumberofLocations__c</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.Ownership</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.ParentId</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.Phone</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.Rating</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.SLAExpirationDate__c</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.SLASerialNumber__c</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.SLA__c</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.ShippingAddress</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.Sic</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.SicDesc</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.Site</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.TickerSymbol</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>false</editable>' +
                    '<field>Account.Tradestyle</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.Type</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.UpsellOpportunity__c</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.Website</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>false</editable>' +
                    '<field>Account.YearStarted</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<objectPermissions>' +
                    '<allowCreate>true</allowCreate>' +
                    '<allowDelete>true</allowDelete>' +
                    '<allowEdit>true</allowEdit>' +
                    '<allowRead>true</allowRead>' +
                    '<modifyAllRecords>false</modifyAllRecords>' +
                    '<object>Account</object>' +
                    '<viewAllFields>false</viewAllFields>' +
                    '<viewAllRecords>false</viewAllRecords>' +
                '</objectPermissions>' +
                '<tabVisibilities>' +
                    '<tab>standard-Account</tab>' +
                    '<visibility>DefaultOn</visibility>' +
                '</tabVisibilities>' +
                '<userLicense>Salesforce</userLicense>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ActivitiesAccess</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>AllowUniversalSearch</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>AllowViewKnowledge</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ApexRestServices</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ApiEnabled</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>AssignTopics</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>CanAccessCE</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ChatterFileLink</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ContentWorkspaces</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ConvertLeads</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>CreateCustomizeFilters</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>CreateCustomizeReports</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>CreateTopics</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>DistributeFromPersWksp</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>EditEvent</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>EditOppLineItemUnitPrice</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>EditTask</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>EditTopics</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>EmailMass</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>EmailSingle</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>EnableCommunityAppLauncher</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>EnableNotifications</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ExportReport</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ImportPersonal</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>LightningConsoleAllowedForUser</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>LightningExperienceUser</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ListEmailSend</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>MassInlineEdit</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>RunReports</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>SelectFilesFromSalesforce</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>SendSitRequests</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ShowCompanyNameAsUserBadge</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>SubmitMacrosAllowed</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>SubscribeToLightningReports</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>TransactionalEmailSend</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>UseWebLink</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ViewDeveloperName</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ViewHelpLink</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ViewRoles</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ViewSetup</name>' +
                '</userPermissions>' +
            '</Profile>';
        
        try {
            // Process the Profile XML
            ProfileXMLProcessor.processProfileXML(profileXML);
            
            System.debug('Profile XML processed successfully!');
            
            // Query and display the created record
            List<Profiles__c> profiles = [SELECT Id, Name, Description__c, User_License__c, Custom__c, 
                                        Tag_Types__c, User_Permission_Enabled__c, User_Permission_Name__c,
                                        Field_Permission_Editable__c, Field_Permission_Readable__c, Field_Permission_Field__c,
                                        Object_Permission_AllowCreate__c, Object_Permission_Object__c,
                                        Tab_Visibility_Tab__c, Tab_Visibility_Visibility__c
                                        FROM Profiles__c 
                                        ORDER BY CreatedDate DESC 
                                        LIMIT 1];
            
            if (!profiles.isEmpty()) {
                Profiles__c profile = profiles[0];
                System.debug('Created Profile Record:');
                System.debug('ID: ' + profile.Id);
                System.debug('Name: ' + profile.Name);
                System.debug('Description: ' + profile.Description__c);
                System.debug('User License: ' + profile.User_License__c);
                System.debug('Custom: ' + profile.Custom__c);
                System.debug('Tag Types: ' + profile.Tag_Types__c);
                System.debug('User Permission Enabled: ' + profile.User_Permission_Enabled__c);
                System.debug('User Permission Name: ' + profile.User_Permission_Name__c);
                System.debug('Field Permission Editable: ' + profile.Field_Permission_Editable__c);
                System.debug('Field Permission Readable: ' + profile.Field_Permission_Readable__c);
                System.debug('Field Permission Field: ' + profile.Field_Permission_Field__c);
                System.debug('Object Permission Allow Create: ' + profile.Object_Permission_AllowCreate__c);
                System.debug('Object Permission Object: ' + profile.Object_Permission_Object__c);
                System.debug('Tab Visibility Tab: ' + profile.Tab_Visibility_Tab__c);
                System.debug('Tab Visibility Visibility: ' + profile.Tab_Visibility_Visibility__c);
            }
            
        } catch (Exception e) {
            System.debug('Error processing Profile XML: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
    }
    
    /**
     * Method to demonstrate processing multiple profiles
     */
    public static void processMultipleProfiles(List<String> profileXMLs) {
        for (Integer i = 0; i < profileXMLs.size(); i++) {
            try {
                System.debug('Processing profile ' + (i + 1) + ' of ' + profileXMLs.size());
                ProfileXMLProcessor.processProfileXML(profileXMLs[i]);
            } catch (Exception e) {
                System.debug('Error processing profile ' + (i + 1) + ': ' + e.getMessage());
            }
        }
    }
}