public with sharing class ProfileXMLController {
    
    // Static variable to store parsed profiles (for demonstration purposes)
    private static List<ProfileXMLDataManager.ProfileData> storedProfiles = new List<ProfileXMLDataManager.ProfileData>();
    
    @AuraEnabled(cacheable=true)
    public static List<ProfileXMLDataManager.ProfileData> getSampleProfiles() {
        try {
            // If we have stored profiles from XML parsing, return those
            if (!storedProfiles.isEmpty()) {
                return storedProfiles;
            }
            
            // Otherwise, return the default sample profiles
            return getDefaultSampleProfiles();
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving profiles: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static String parseAndStoreProfileXML(String profileXml, String profileName) {
        try {
            if (String.isBlank(profileXml) || String.isBlank(profileName)) {
                throw new AuraHandledException('Profile XML and name are required');
            }
            
            // Parse the XML using ProfileXMLDataManager
            ProfileXMLDataManager.ProfileData profileData = 
                ProfileXMLDataManager.parseAndStoreProfile(profileXml, profileName);
            
            // Store the parsed profile
            storedProfiles.add(profileData);
            
            return 'Profile "' + profileName + '" parsed and stored successfully. Total profiles: ' + storedProfiles.size();
            
        } catch (Exception e) {
            throw new AuraHandledException('Error parsing profile XML: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static String clearStoredProfiles() {
        try {
            Integer count = storedProfiles.size();
            storedProfiles.clear();
            return 'Cleared ' + count + ' stored profiles.';
        } catch (Exception e) {
            throw new AuraHandledException('Error clearing profiles: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ProfileXMLDataManager.ProfileData> getProfilesFromXML(List<String> profileXmls, List<String> profileNames) {
        try {
            List<ProfileXMLDataManager.ProfileData> profiles = new List<ProfileXMLDataManager.ProfileData>();
            
            if (profileXmls != null && profileNames != null && profileXmls.size() == profileNames.size()) {
                for (Integer i = 0; i < profileXmls.size(); i++) {
                    String profileXml = profileXmls[i];
                    String profileName = profileNames[i];
                    
                    if (String.isNotBlank(profileXml) && String.isNotBlank(profileName)) {
                        ProfileXMLDataManager.ProfileData profileData = 
                            ProfileXMLDataManager.parseAndStoreProfile(profileXml, profileName);
                        profiles.add(profileData);
                    }
                }
            }
            
            return profiles;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error parsing profile XMLs: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static ProfileXMLDataManager.ProfileData getProfileFromXML(String profileXml, String profileName) {
        try {
            if (String.isBlank(profileXml) || String.isBlank(profileName)) {
                throw new AuraHandledException('Profile XML and name are required');
            }
            
            ProfileXMLDataManager.ProfileData profileData = 
                ProfileXMLDataManager.parseAndStoreProfile(profileXml, profileName);
            
            return profileData;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error parsing profile XML: ' + e.getMessage());
        }
    }
    
    // Private method to get default sample profiles
    private static List<ProfileXMLDataManager.ProfileData> getDefaultSampleProfiles() {
        try {
            // This method provides sample profile data for demonstration
            // In a real scenario, you would fetch actual profile XMLs from your system
            List<ProfileXMLDataManager.ProfileData> sampleProfiles = new List<ProfileXMLDataManager.ProfileData>();
            
            // Create sample profile 1: Custom - Sales Profile
            ProfileXMLDataManager.ProfileData sampleProfile1 = new ProfileXMLDataManager.ProfileData();
            sampleProfile1.name = 'Custom - Sales Profile';
            sampleProfile1.description = 'Custom profile for sales users with enhanced permissions';
            sampleProfile1.userLicense = 'Salesforce';
            sampleProfile1.custom = true;
            
            // Add sample application visibilities
            ProfileXMLDataManager.ApplicationVisibility appVis1 = new ProfileXMLDataManager.ApplicationVisibility();
            appVis1.application = 'Sales';
            appVis1.visible = true;
            sampleProfile1.applicationVisibilities.add(appVis1);
            
            ProfileXMLDataManager.ApplicationVisibility appVis2 = new ProfileXMLDataManager.ApplicationVisibility();
            appVis2.application = 'Marketing';
            appVis2.visible = false;
            sampleProfile1.applicationVisibilities.add(appVis2);
            
            // Add sample user permissions
            ProfileXMLDataManager.UserPermission userPerm1 = new ProfileXMLDataManager.UserPermission();
            userPerm1.name = 'ViewSetup';
            userPerm1.enabled = true;
            sampleProfile1.userPermissions.add(userPerm1);
            
            ProfileXMLDataManager.UserPermission userPerm2 = new ProfileXMLDataManager.UserPermission();
            userPerm2.name = 'ModifyAllData';
            userPerm2.enabled = false;
            sampleProfile1.userPermissions.add(userPerm2);
            
            // Add sample object permissions
            ProfileXMLDataManager.ObjectPermission objPerm1 = new ProfileXMLDataManager.ObjectPermission();
            objPerm1.objectName = 'Account';
            objPerm1.allowCreate = true;
            objPerm1.allowDelete = false;
            objPerm1.allowEdit = true;
            objPerm1.allowRead = true;
            objPerm1.viewAllRecords = false;
            objPerm1.modifyAllRecords = false;
            objPerm1.viewAllFields = false;
            sampleProfile1.objectPermissions.add(objPerm1);
            
            ProfileXMLDataManager.ObjectPermission objPerm2 = new ProfileXMLDataManager.ObjectPermission();
            objPerm2.objectName = 'Contact';
            objPerm2.allowCreate = true;
            objPerm2.allowDelete = false;
            objPerm2.allowEdit = true;
            objPerm2.allowRead = true;
            objPerm2.viewAllRecords = false;
            objPerm2.modifyAllRecords = false;
            objPerm2.viewAllFields = false;
            sampleProfile1.objectPermissions.add(objPerm2);
            
            // Add sample field permissions
            ProfileXMLDataManager.FieldPermission fieldPerm1 = new ProfileXMLDataManager.FieldPermission();
            fieldPerm1.field = 'Account.Name';
            fieldPerm1.editable = true;
            fieldPerm1.readable = true;
            sampleProfile1.fieldPermissions.add(fieldPerm1);
            
            ProfileXMLDataManager.FieldPermission fieldPerm2 = new ProfileXMLDataManager.FieldPermission();
            fieldPerm2.field = 'Account.Industry';
            fieldPerm2.editable = false;
            fieldPerm2.readable = true;
            sampleProfile1.fieldPermissions.add(fieldPerm2);
            
            // Add sample page accesses
            ProfileXMLDataManager.PageAccess pageAccess1 = new ProfileXMLDataManager.PageAccess();
            pageAccess1.apexPage = 'AccountView';
            pageAccess1.enabled = true;
            sampleProfile1.pageAccesses.add(pageAccess1);
            
            // Add sample class accesses
            ProfileXMLDataManager.ClassAccess classAccess1 = new ProfileXMLDataManager.ClassAccess();
            classAccess1.apexClass = 'AccountController';
            classAccess1.enabled = true;
            sampleProfile1.classAccesses.add(classAccess1);
            
            // Add sample tab visibilities
            ProfileXMLDataManager.TabVisibility tabVis1 = new ProfileXMLDataManager.TabVisibility();
            tabVis1.tab = 'Account';
            tabVis1.visibility = 'Visible';
            sampleProfile1.tabVisibilities.add(tabVis1);
            
            ProfileXMLDataManager.TabVisibility tabVis2 = new ProfileXMLDataManager.TabVisibility();
            tabVis2.tab = 'Contact';
            tabVis2.visibility = 'Visible';
            sampleProfile1.tabVisibilities.add(tabVis2);
            
            // Add sample record type visibilities
            ProfileXMLDataManager.RecordTypeVisibility recordTypeVis1 = new ProfileXMLDataManager.RecordTypeVisibility();
            recordTypeVis1.recordType = 'Account.Customer';
            recordTypeVis1.visible = true;
            sampleProfile1.recordTypeVisibilities.add(recordTypeVis1);
            
            // Add sample layout assignments
            ProfileXMLDataManager.LayoutAssignment layoutAssign1 = new ProfileXMLDataManager.LayoutAssignment();
            layoutAssign1.layout = 'Account-Sales Layout';
            layoutAssign1.recordType = false;
            sampleProfile1.layoutAssignments.add(layoutAssign1);
            
            // Add sample login hours
            ProfileXMLDataManager.LoginHours loginHours1 = new ProfileXMLDataManager.LoginHours();
            loginHours1.weekdayStart = '06:00';
            loginHours1.weekdayEnd = '22:00';
            loginHours1.weekendStart = '08:00';
            loginHours1.weekendEnd = '18:00';
            sampleProfile1.loginHours.add(loginHours1);
            
            // Add sample login IP ranges
            ProfileXMLDataManager.LoginIpRanges loginIpRange1 = new ProfileXMLDataManager.LoginIpRanges();
            loginIpRange1.startAddress = '192.168.1.1';
            loginIpRange1.endAddress = '192.168.1.255';
            loginIpRange1.description = 'Office Network';
            sampleProfile1.loginIpRanges.add(loginIpRange1);
            
            sampleProfiles.add(sampleProfile1);
            
            // Create sample profile 2: Standard User Profile
            ProfileXMLDataManager.ProfileData sampleProfile2 = new ProfileXMLDataManager.ProfileData();
            sampleProfile2.name = 'Standard User';
            sampleProfile2.description = 'Standard profile for regular users';
            sampleProfile2.userLicense = 'Salesforce';
            sampleProfile2.custom = false;
            
            // Add sample application visibilities
            ProfileXMLDataManager.ApplicationVisibility appVis3 = new ProfileXMLDataManager.ApplicationVisibility();
            appVis3.application = 'Sales';
            appVis3.visible = true;
            sampleProfile2.applicationVisibilities.add(appVis3);
            
            // Add sample user permissions
            ProfileXMLDataManager.UserPermission userPerm3 = new ProfileXMLDataManager.UserPermission();
            userPerm3.name = 'ViewSetup';
            userPerm3.enabled = false;
            sampleProfile2.userPermissions.add(userPerm3);
            
            // Add sample object permissions
            ProfileXMLDataManager.ObjectPermission objPerm3 = new ProfileXMLDataManager.ObjectPermission();
            objPerm3.objectName = 'Account';
            objPerm3.allowCreate = false;
            objPerm3.allowDelete = false;
            objPerm3.allowEdit = false;
            objPerm3.allowRead = true;
            objPerm3.viewAllRecords = false;
            objPerm3.modifyAllRecords = false;
            objPerm3.viewAllFields = false;
            sampleProfile2.objectPermissions.add(objPerm3);
            
            // Add sample field permissions
            ProfileXMLDataManager.FieldPermission fieldPerm3 = new ProfileXMLDataManager.FieldPermission();
            fieldPerm3.field = 'Account.Name';
            fieldPerm3.editable = false;
            fieldPerm3.readable = true;
            sampleProfile2.fieldPermissions.add(fieldPerm3);
            
            // Add sample tab visibilities
            ProfileXMLDataManager.TabVisibility tabVis3 = new ProfileXMLDataManager.TabVisibility();
            tabVis3.tab = 'Account';
            tabVis3.visibility = 'Visible';
            sampleProfile2.tabVisibilities.add(tabVis3);
            
            sampleProfiles.add(sampleProfile2);
            
            // Create sample profile 3: System Administrator Profile
            ProfileXMLDataManager.ProfileData sampleProfile3 = new ProfileXMLDataManager.ProfileData();
            sampleProfile3.name = 'System Administrator';
            sampleProfile3.description = 'Full system access profile for administrators';
            sampleProfile3.userLicense = 'Salesforce';
            sampleProfile3.custom = false;
            
            // Add sample application visibilities
            ProfileXMLDataManager.ApplicationVisibility appVis4 = new ProfileXMLDataManager.ApplicationVisibility();
            appVis4.application = 'Sales';
            appVis4.visible = true;
            sampleProfile3.applicationVisibilities.add(appVis4);
            
            ProfileXMLDataManager.ApplicationVisibility appVis5 = new ProfileXMLDataManager.ApplicationVisibility();
            appVis5.application = 'Marketing';
            appVis5.visible = true;
            sampleProfile3.applicationVisibilities.add(appVis5);
            
            // Add sample user permissions
            ProfileXMLDataManager.UserPermission userPerm4 = new ProfileXMLDataManager.UserPermission();
            userPerm4.name = 'ViewSetup';
            userPerm4.enabled = true;
            sampleProfile3.userPermissions.add(userPerm4);
            
            ProfileXMLDataManager.UserPermission userPerm5 = new ProfileXMLDataManager.UserPermission();
            userPerm5.name = 'ModifyAllData';
            userPerm5.enabled = true;
            sampleProfile3.userPermissions.add(userPerm5);
            
            // Add sample object permissions
            ProfileXMLDataManager.ObjectPermission objPerm4 = new ProfileXMLDataManager.ObjectPermission();
            objPerm4.objectName = 'Account';
            objPerm4.allowCreate = true;
            objPerm4.allowDelete = true;
            objPerm4.allowEdit = true;
            objPerm4.allowRead = true;
            objPerm4.viewAllRecords = true;
            objPerm4.modifyAllRecords = true;
            objPerm4.viewAllFields = true;
            sampleProfile3.objectPermissions.add(objPerm4);
            
            // Add sample field permissions
            ProfileXMLDataManager.FieldPermission fieldPerm4 = new ProfileXMLDataManager.FieldPermission();
            fieldPerm4.field = 'Account.Name';
            fieldPerm4.editable = true;
            fieldPerm4.readable = true;
            sampleProfile3.fieldPermissions.add(fieldPerm4);
            
            // Add sample page accesses
            ProfileXMLDataManager.PageAccess pageAccess2 = new ProfileXMLDataManager.PageAccess();
            pageAccess2.apexPage = 'AccountView';
            pageAccess2.enabled = true;
            sampleProfile3.pageAccesses.add(pageAccess2);
            
            // Add sample class accesses
            ProfileXMLDataManager.ClassAccess classAccess2 = new ProfileXMLDataManager.ClassAccess();
            classAccess2.apexClass = 'AccountController';
            classAccess2.enabled = true;
            sampleProfile3.classAccesses.add(classAccess2);
            
            // Add sample tab visibilities
            ProfileXMLDataManager.TabVisibility tabVis4 = new ProfileXMLDataManager.TabVisibility();
            tabVis4.tab = 'Account';
            tabVis4.visibility = 'Visible';
            sampleProfile3.tabVisibilities.add(tabVis4);
            
            // Add sample record type visibilities
            ProfileXMLDataManager.RecordTypeVisibility recordTypeVis2 = new ProfileXMLDataManager.RecordTypeVisibility();
            recordTypeVis2.recordType = 'Account.Customer';
            recordTypeVis2.visible = true;
            sampleProfile3.recordTypeVisibilities.add(recordTypeVis2);
            
            // Add sample layout assignments
            ProfileXMLDataManager.LayoutAssignment layoutAssign2 = new ProfileXMLDataManager.LayoutAssignment();
            layoutAssign2.layout = 'Account-Admin Layout';
            layoutAssign2.recordType = false;
            sampleProfile3.layoutAssignments.add(layoutAssign2);
            
            // Add sample login hours
            ProfileXMLDataManager.LoginHours loginHours2 = new ProfileXMLDataManager.LoginHours();
            loginHours2.weekdayStart = '00:00';
            loginHours2.weekdayEnd = '23:59';
            loginHours2.weekendStart = '00:00';
            loginHours2.weekendEnd = '23:59';
            sampleProfile3.loginHours.add(loginHours2);
            
            // Add sample login IP ranges
            ProfileXMLDataManager.LoginIpRanges loginIpRange2 = new ProfileXMLDataManager.LoginIpRanges();
            loginIpRange2.startAddress = '0.0.0.0';
            loginIpRange2.endAddress = '255.255.255.255';
            loginIpRange2.description = 'All IPs Allowed';
            sampleProfile3.loginIpRanges.add(loginIpRange2);
            
            sampleProfiles.add(sampleProfile3);
            
            return sampleProfiles;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error creating sample profiles: ' + e.getMessage());
        }
    }
}