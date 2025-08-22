public class ProfileXMLExample {
    
    /**
     * Example method showing how to use Profile XML functionality
     * This demonstrates the complete workflow from XML parsing to data storage
     * Note: DML operations require custom objects to be created first
     */
    public static void demonstrateProfileXMLFunctionality() {
        try {
            System.debug('=== Profile XML Functionality Demonstration ===');
            
            // Step 1: Create the custom objects (metadata) - This is simulation only
            System.debug('Step 1: Creating custom objects (simulation)...');
            ProfileXMLMetadataManager.createProfileObjects();
            System.debug('Custom objects metadata created (simulation)');
            
            // Step 2: Sample Profile XML
            String profileXml = createSampleProfileXML();
            System.debug('Step 2: Sample Profile XML created');
            
            // Step 3: Parse using ProfileXMLDataManager (works now)
            System.debug('Step 3: Using ProfileXMLDataManager for parsing...');
            ProfileXMLDataManager.ProfileData profileData = ProfileXMLDataManager.parseAndStoreProfile(profileXml, 'StandardUser');
            System.debug('ProfileXMLDataManager parsing completed');
            System.debug('Parsed data contains:');
            System.debug('  - Application Visibilities: ' + profileData.applicationVisibilities.size());
            System.debug('  - User Permissions: ' + profileData.userPermissions.size());
            System.debug('  - Object Permissions: ' + profileData.objectPermissions.size());
            System.debug('  - Field Permissions: ' + profileData.fieldPermissions.size());
            System.debug('  - Tab Visibilities: ' + profileData.tabVisibilities.size());
            
            // Step 4: Demonstrate DML operations (would work once custom objects exist)
            System.debug('Step 4: DML operations demonstration (requires custom objects)...');
            demonstrateDMLOperations(profileXml);
            
            // Step 5: Demonstrate bulk processing
            System.debug('Step 5: Bulk processing demonstration...');
            processMultipleProfiles();
            
            System.debug('=== Profile XML Functionality Demonstration Completed ===');
            
        } catch (Exception e) {
            System.debug('Error in demonstration: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
    }
    
    /**
     * Demonstrate DML operations (commented out until custom objects exist)
     */
    private static void demonstrateDMLOperations(String profileXml) {
        System.debug('DML operations would include:');
        System.debug('  - Creating Profile_Admin__c records');
        System.debug('  - Creating child records (Tab_Visibility__c, User_Permission__c, etc.)');
        System.debug('  - Querying profiles with child relationships');
        System.debug('  - Updating profile data');
        System.debug('  - Deleting profiles and related records');
        
        // Example of what the DML operations would look like:
        /*
        try {
            // This would work once custom objects are created
            ProfileXMLMasterManager.parseAndStoreProfile(profileXml, 'SystemAdministrator');
            
            // Retrieve profiles
            List<Profile_Admin__c> profiles = ProfileXMLMasterManager.getAllProfiles();
            System.debug('Total profiles: ' + profiles.size());
            
            // Get specific profile
            Profile_Admin__c profile = ProfileXMLMasterManager.getProfileByName('SystemAdministrator');
            if (profile != null) {
                System.debug('Found profile: ' + profile.Name);
            }
            
        } catch (Exception e) {
            System.debug('DML operations failed (expected if custom objects not created): ' + e.getMessage());
        }
        */
    }
    
    /**
     * Create a sample Profile XML for demonstration
     */
    private static String createSampleProfileXML() {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
            '<Profile xmlns="http://soap.sforce.com/2006/04/metadata">' +
                '<description>Standard User Profile with Enhanced Permissions</description>' +
                '<userLicense>Salesforce</userLicense>' +
                '<custom>true</custom>' +
                
                // Tab Visibilities
                '<tabVisibilities>' +
                    '<tab>Account</tab>' +
                    '<visibility>Visible</visibility>' +
                '</tabVisibilities>' +
                '<tabVisibilities>' +
                    '<tab>Contact</tab>' +
                    '<visibility>Visible</visibility>' +
                '</tabVisibilities>' +
                '<tabVisibilities>' +
                    '<tab>Opportunity</tab>' +
                    '<visibility>Visible</visibility>' +
                '</tabVisibilities>' +
                '<tabVisibilities>' +
                    '<tab>Lead</tab>' +
                    '<visibility>Visible</visibility>' +
                '</tabVisibilities>' +
                
                // User Permissions
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ViewSetup</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>false</enabled>' +
                    '<name>ModifyAllData</name>' +
                '</userPermissions>' +
                '<userPermissions>' +
                    '<enabled>true</enabled>' +
                    '<name>ViewDataCategories</name>' +
                '</userPermissions>' +
                
                // Object Permissions
                '<objectPermissions>' +
                    '<allowCreate>true</allowCreate>' +
                    '<allowDelete>false</allowDelete>' +
                    '<allowEdit>true</allowEdit>' +
                    '<allowRead>true</allowRead>' +
                    '<modifyAllRecords>false</modifyAllRecords>' +
                    '<object>Account</object>' +
                    '<viewAllFields>true</viewAllFields>' +
                    '<viewAllRecords>false</viewAllRecords>' +
                '</objectPermissions>' +
                '<objectPermissions>' +
                    '<allowCreate>true</allowCreate>' +
                    '<allowDelete>false</allowDelete>' +
                    '<allowEdit>true</allowEdit>' +
                    '<allowRead>true</allowRead>' +
                    '<modifyAllRecords>false</modifyAllRecords>' +
                    '<object>Contact</object>' +
                    '<viewAllFields>true</viewAllFields>' +
                    '<viewAllRecords>false</viewAllRecords>' +
                '</objectPermissions>' +
                
                // Field Permissions
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.Name</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Account.Phone</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>false</editable>' +
                    '<field>Account.AnnualRevenue</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Contact.FirstName</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                '<fieldPermissions>' +
                    '<editable>true</editable>' +
                    '<field>Contact.LastName</field>' +
                    '<readable>true</readable>' +
                '</fieldPermissions>' +
                
                // Class Access
                '<classAccesses>' +
                    '<apexClass>AccountController</apexClass>' +
                    '<enabled>true</enabled>' +
                '</classAccesses>' +
                '<classAccesses>' +
                    '<apexClass>ContactHelper</apexClass>' +
                    '<enabled>true</enabled>' +
                '</classAccesses>' +
                
                // Page Access
                '<pageAccesses>' +
                    '<apexPage>AccountDetail</apexPage>' +
                    '<enabled>true</enabled>' +
                '</pageAccesses>' +
                '<pageAccesses>' +
                    '<apexPage>ContactList</apexPage>' +
                    '<enabled>true</enabled>' +
                '</pageAccesses>' +
                
                // Record Type Visibility
                '<recordTypeVisibilities>' +
                    '<recordType>Account.Customer</recordType>' +
                    '<visible>true</visible>' +
                '</recordTypeVisibilities>' +
                '<recordTypeVisibilities>' +
                    '<recordType>Account.Prospect</recordType>' +
                    '<visible>true</visible>' +
                '</recordTypeVisibilities>' +
                '<recordTypeVisibilities>' +
                    '<recordType>Contact.Customer</recordType>' +
                    '<visible>true</visible>' +
                '</recordTypeVisibilities>' +
                
                // Layout Assignments
                '<layoutAssignments>' +
                    '<layout>Account-Account Layout</layout>' +
                    '<recordType>false</recordType>' +
                '</layoutAssignments>' +
                '<layoutAssignments>' +
                    '<layout>Contact-Contact Layout</layout>' +
                    '<recordType>false</recordType>' +
                '</layoutAssignments>' +
                
                // Login Hours
                '<loginHours>' +
                    '<weekdayStart>08:00</weekdayStart>' +
                    '<weekdayEnd>18:00</weekdayEnd>' +
                    '<weekendStart>09:00</weekendStart>' +
                    '<weekendEnd>17:00</weekendEnd>' +
                '</loginHours>' +
                
                // Login IP Ranges
                '<loginIpRanges>' +
                    '<startAddress>192.168.1.1</startAddress>' +
                    '<endAddress>192.168.1.255</endAddress>' +
                    '<description>Office Network</description>' +
                '</loginIpRanges>' +
                '<loginIpRanges>' +
                    '<startAddress>10.0.0.1</startAddress>' +
                    '<endAddress>10.0.0.255</endAddress>' +
                    '<description>VPN Network</description>' +
                '</loginIpRanges>' +
                
            '</Profile>';
    }
    
    /**
     * Display parsed profile data (works now)
     */
    private static void displayParsedProfileData(ProfileXMLDataManager.ProfileData profileData) {
        System.debug('=== Parsed Profile Data ===');
        System.debug('Profile Name: ' + profileData.name);
        System.debug('Description: ' + profileData.description);
        System.debug('User License: ' + profileData.userLicense);
        System.debug('Custom: ' + profileData.custom);
        
        // Display tab visibilities
        System.debug('Tab Visibilities: ' + profileData.tabVisibilities.size());
        for (ProfileXMLDataManager.TabVisibility tv : profileData.tabVisibilities) {
            System.debug('  - ' + tv.tab + ': ' + tv.visibility);
        }
        
        // Display user permissions
        System.debug('User Permissions: ' + profileData.userPermissions.size());
        for (ProfileXMLDataManager.UserPermission up : profileData.userPermissions) {
            System.debug('  - ' + up.name + ': ' + up.enabled);
        }
        
        // Display object permissions
        System.debug('Object Permissions: ' + profileData.objectPermissions.size());
        for (ProfileXMLDataManager.ObjectPermission op : profileData.objectPermissions) {
            System.debug('  - ' + op.objectName + ': Create=' + op.allowCreate + 
                        ', Edit=' + op.allowEdit + ', Delete=' + op.allowDelete);
        }
        
        // Display field permissions
        System.debug('Field Permissions: ' + profileData.fieldPermissions.size());
        for (ProfileXMLDataManager.FieldPermission fp : profileData.fieldPermissions) {
            System.debug('  - ' + fp.field + ': Readable=' + fp.readable + 
                        ', Editable=' + fp.editable);
        }
        
        System.debug('=== End Parsed Profile Data ===');
    }
    
    /**
     * Example method for bulk profile processing (parsing only)
     */
    public static void processMultipleProfiles() {
        System.debug('=== Bulk Profile Processing Example (Parsing Only) ===');
        
        // Sample profile XMLs
        Map<String, String> profileXmls = new Map<String, String>{
            'SalesUser' => createSampleProfileXML().replace('Standard User Profile with Enhanced Permissions', 'Sales User Profile'),
            'MarketingUser' => createSampleProfileXML().replace('Standard User Profile with Enhanced Permissions', 'Marketing User Profile'),
            'SupportUser' => createSampleProfileXML().replace('Standard User Profile with Enhanced Permissions', 'Support User Profile')
        };
        
        try {
            List<ProfileXMLDataManager.ProfileData> parsedProfiles = new List<ProfileXMLDataManager.ProfileData>();
            
            for (String profileName : profileXmls.keySet()) {
                System.debug('Parsing profile: ' + profileName);
                ProfileXMLDataManager.ProfileData profileData = ProfileXMLDataManager.parseAndStoreProfile(profileXmls.get(profileName), profileName);
                parsedProfiles.add(profileData);
                
                // Display parsed data
                displayParsedProfileData(profileData);
            }
            
            System.debug('Bulk parsing completed. Total profiles parsed: ' + parsedProfiles.size());
            
            // Demonstrate data analysis
            analyzeParsedProfiles(parsedProfiles);
            
        } catch (Exception e) {
            System.debug('Error in bulk processing: ' + e.getMessage());
        }
    }
    
    /**
     * Analyze parsed profile data
     */
    private static void analyzeParsedProfiles(List<ProfileXMLDataManager.ProfileData> profiles) {
        System.debug('=== Profile Analysis ===');
        
        // Count total permissions across all profiles
        Integer totalUserPermissions = 0;
        Integer totalObjectPermissions = 0;
        Integer totalFieldPermissions = 0;
        
        for (ProfileXMLDataManager.ProfileData profile : profiles) {
            totalUserPermissions += profile.userPermissions.size();
            totalObjectPermissions += profile.objectPermissions.size();
            totalFieldPermissions += profile.fieldPermissions.size();
        }
        
        System.debug('Analysis Results:');
        System.debug('  - Total Profiles: ' + profiles.size());
        System.debug('  - Total User Permissions: ' + totalUserPermissions);
        System.debug('  - Total Object Permissions: ' + totalObjectPermissions);
        System.debug('  - Total Field Permissions: ' + totalFieldPermissions);
        System.debug('  - Average User Permissions per Profile: ' + (totalUserPermissions / profiles.size()));
        System.debug('  - Average Object Permissions per Profile: ' + (totalObjectPermissions / profiles.size()));
        System.debug('  - Average Field Permissions per Profile: ' + (totalFieldPermissions / profiles.size()));
    }
    
    /**
     * Example method for profile comparison (parsing only)
     */
    public static void compareParsedProfiles(String profile1Xml, String profile2Xml, String profile1Name, String profile2Name) {
        System.debug('=== Profile Comparison Example (Parsing Only) ===');
        
        try {
            ProfileXMLDataManager.ProfileData profile1 = ProfileXMLDataManager.parseAndStoreProfile(profile1Xml, profile1Name);
            ProfileXMLDataManager.ProfileData profile2 = ProfileXMLDataManager.parseAndStoreProfile(profile2Xml, profile2Name);
            
            System.debug('Comparing ' + profile1Name + ' vs ' + profile2Name);
            
            // Compare basic properties
            System.debug('Description comparison:');
            System.debug('  ' + profile1Name + ': ' + profile1.description);
            System.debug('  ' + profile2Name + ': ' + profile2.description);
            
            // Compare user permissions
            System.debug('User Permissions comparison:');
            Set<String> profile1Permissions = new Set<String>();
            Set<String> profile2Permissions = new Set<String>();
            
            for (ProfileXMLDataManager.UserPermission up : profile1.userPermissions) {
                if (up.enabled) {
                    profile1Permissions.add(up.name);
                }
            }
            
            for (ProfileXMLDataManager.UserPermission up : profile2.userPermissions) {
                if (up.enabled) {
                    profile2Permissions.add(up.name);
                }
            }
            
            System.debug('  ' + profile1Name + ' permissions: ' + profile1Permissions.size());
            System.debug('  ' + profile2Name + ' permissions: ' + profile2Permissions.size());
            
            // Find differences
            Set<String> onlyInProfile1 = new Set<String>(profile1Permissions);
            onlyInProfile1.removeAll(profile2Permissions);
            
            Set<String> onlyInProfile2 = new Set<String>(profile2Permissions);
            onlyInProfile2.removeAll(profile1Permissions);
            
            if (!onlyInProfile1.isEmpty()) {
                System.debug('  Permissions only in ' + profile1Name + ': ' + onlyInProfile1);
            }
            if (!onlyInProfile2.isEmpty()) {
                System.debug('  Permissions only in ' + profile2Name + ': ' + onlyInProfile2);
            }
            
        } catch (Exception e) {
            System.debug('Error in profile comparison: ' + e.getMessage());
        }
    }
}