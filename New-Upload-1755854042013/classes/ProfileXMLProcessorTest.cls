@isTest
public class ProfileXMLProcessorTest {
    
    @TestSetup
    static void setupTestData() {
        // This method will run before each test method
    }
    
    @isTest
    static void testProcessProfileXML() {
        // Test XML content based on the provided Profile XML
        String testXML = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<Profile xmlns="http://soap.sforce.com/2006/04/metadata">' +
                '<custom>false</custom>' +
                '<description>Standard User Profile</description>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.AccountNumber</field>' +
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
            '</Profile>';
        
        Test.startTest();
        
        // Call the main processing method
        ProfileXMLProcessor.processProfileXML(testXML);
        
        Test.stopTest();
        
        // Verify that a Profiles__c record was created
        List<Profiles__c> profiles = [SELECT Id, Name, Description__c, User_License__c, Custom__c, 
                                    Tag_Types__c, User_Permission_Enabled__c, User_Permission_Name__c,
                                    Field_Permission_Editable__c, Field_Permission_Readable__c, Field_Permission_Field__c,
                                    Object_Permission_AllowCreate__c, Object_Permission_Object__c,
                                    Tab_Visibility_Tab__c, Tab_Visibility_Visibility__c
                                    FROM Profiles__c];
        
        System.assertEquals(1, profiles.size(), 'Should have created one Profiles record');
        
        Profiles__c profile = profiles[0];
        System.assertEquals('Standard User Profile', profile.Description__c, 'Description should match');
        System.assertEquals('Salesforce', profile.User_License__c, 'User License should match');
        System.assertEquals(false, profile.Custom__c, 'Custom should be false');
        System.assert(profile.Tag_Types__c.contains('fieldPermissions'), 'Should contain fieldPermissions');
        System.assert(profile.Tag_Types__c.contains('objectPermissions'), 'Should contain objectPermissions');
        System.assert(profile.Tag_Types__c.contains('tabVisibilities'), 'Should contain tabVisibilities');
        System.assert(profile.Tag_Types__c.contains('userPermissions'), 'Should contain userPermissions');
        
        // Verify user permission values
        System.assertEquals(true, profile.User_Permission_Enabled__c, 'User permission enabled should be true');
        System.assertEquals('ActivitiesAccess', profile.User_Permission_Name__c, 'User permission name should match');
        
        // Verify field permission values
        System.assertEquals(true, profile.Field_Permission_Editable__c, 'Field permission editable should be true');
        System.assertEquals(true, profile.Field_Permission_Readable__c, 'Field permission readable should be true');
        System.assertEquals('Account.AccountNumber', profile.Field_Permission_Field__c, 'Field permission field should match');
        
        // Verify object permission values
        System.assertEquals(true, profile.Object_Permission_AllowCreate__c, 'Object permission allow create should be true');
        System.assertEquals('Account', profile.Object_Permission_Object__c, 'Object permission object should match');
        
        // Verify tab visibility values
        System.assertEquals('standard-Account', profile.Tab_Visibility_Tab__c, 'Tab visibility tab should match');
        System.assertEquals('DefaultOn', profile.Tab_Visibility_Visibility__c, 'Tab visibility visibility should match');
    }
    
    @isTest
    static void testParseProfileXML() {
        String testXML = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<Profile xmlns="http://soap.sforce.com/2006/04/metadata">' +
                '<custom>false</custom>' +
                '<description>Test Profile</description>' +
                '<userLicense>Salesforce</userLicense>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ViewSetup</name>' +
                '</userPermissions>' +
            '</Profile>';
        
        Test.startTest();
        
        // Test the public method instead of private method
        ProfileXMLProcessor.processProfileXML(testXML);
        
        Test.stopTest();
        
        // Verify the record was created
        List<Profiles__c> profiles = [SELECT Id, Description__c, User_License__c, Custom__c, 
                                      User_Permission_Enabled__c, User_Permission_Name__c
                                      FROM Profiles__c WHERE Description__c = 'Test Profile'];
        
        System.assertEquals(1, profiles.size(), 'Should have created one Profiles record');
        Profiles__c profile = profiles[0];
        System.assertEquals('Test Profile', profile.Description__c, 'Description should match');
        System.assertEquals('Salesforce', profile.User_License__c, 'User License should match');
        System.assertEquals(false, profile.Custom__c, 'Custom should be false');
        System.assertEquals(true, profile.User_Permission_Enabled__c, 'User permission enabled should be true');
        System.assertEquals('ViewSetup', profile.User_Permission_Name__c, 'User permission name should match');
    }
    
    @isTest
    static void testInvalidXML() {
        String invalidXML = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<InvalidTag>' +
                '<someContent>test</someContent>' +
            '</InvalidTag>';
        
        Test.startTest();
        
        try {
            ProfileXMLProcessor.processProfileXML(invalidXML);
            System.assert(false, 'Should have thrown an exception for invalid XML');
        } catch (ProfileXMLProcessor.ProfileXMLProcessorException e) {
            System.assert(true, 'Exception was thrown as expected');
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testEmptyXML() {
        String emptyXML = '';
        
        Test.startTest();
        
        try {
            ProfileXMLProcessor.processProfileXML(emptyXML);
            System.assert(false, 'Should have thrown an exception for empty XML');
        } catch (ProfileXMLProcessor.ProfileXMLProcessorException e) {
            System.assert(true, 'Exception was thrown as expected');
        }
        
        Test.stopTest();
    }
}