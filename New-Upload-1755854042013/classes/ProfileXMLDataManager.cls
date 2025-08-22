public class ProfileXMLDataManager {
    
    // Inner class to represent profile data structure
    public class ProfileData {
        public String name;
        public String description;
        public String userLicense;
        public Boolean custom;
        public List<ApplicationVisibility> applicationVisibilities;
        public List<UserPermission> userPermissions;
        public List<ObjectPermission> objectPermissions;
        public List<FieldPermission> fieldPermissions;
        public List<PageAccess> pageAccesses;
        public List<ClassAccess> classAccesses;
        public List<TabVisibility> tabVisibilities;
        public List<RecordTypeVisibility> recordTypeVisibilities;
        public List<LayoutAssignment> layoutAssignments;
        public List<LoginHours> loginHours;
        public List<LoginIpRanges> loginIpRanges;
        
        public ProfileData() {
            applicationVisibilities = new List<ApplicationVisibility>();
            userPermissions = new List<UserPermission>();
            objectPermissions = new List<ObjectPermission>();
            fieldPermissions = new List<FieldPermission>();
            pageAccesses = new List<PageAccess>();
            classAccesses = new List<ClassAccess>();
            tabVisibilities = new List<TabVisibility>();
            recordTypeVisibilities = new List<RecordTypeVisibility>();
            layoutAssignments = new List<LayoutAssignment>();
            loginHours = new List<LoginHours>();
            loginIpRanges = new List<LoginIpRanges>();
        }
    }
    
    // Supporting classes for different permission types
    public class ApplicationVisibility {
        public String application;
        public Boolean visible;
    }
    
    public class UserPermission {
        public String name;
        public Boolean enabled;
    }
    
    public class ObjectPermission {
        public String objectName;
        public Boolean allowCreate;
        public Boolean allowDelete;
        public Boolean allowEdit;
        public Boolean allowRead;
        public Boolean viewAllRecords;
        public Boolean modifyAllRecords;
        public Boolean viewAllFields;
    }
    
    public class FieldPermission {
        public String field;
        public Boolean editable;
        public Boolean readable;
    }
    
    public class PageAccess {
        public String apexPage;
        public Boolean enabled;
    }
    
    public class ClassAccess {
        public String apexClass;
        public Boolean enabled;
    }
    
    public class TabVisibility {
        public String tab;
        public String visibility;
    }
    
    public class RecordTypeVisibility {
        public String recordType;
        public Boolean visible;
    }
    
    public class LayoutAssignment {
        public String layout;
        public Boolean recordType;
    }
    
    public class LoginHours {
        public String weekdayStart;
        public String weekdayEnd;
        public String weekendStart;
        public String weekendEnd;
    }
    
    public class LoginIpRanges {
        public String startAddress;
        public String endAddress;
        public String description;
    }
    
    /**
     * Parse profile XML and return ProfileData object
     * @param profileXml The XML string of the profile
     * @param profileName The name of the profile
     * @return ProfileData object containing parsed data
     */
    public static ProfileData parseAndStoreProfile(String profileXml, String profileName) {
        try {
            // Parse the XML
            ProfileData profileData = parseProfileXml(profileXml);
            profileData.name = profileName;
            
            System.debug('Successfully parsed profile: ' + profileName);
            System.debug('Profile Data: ' + profileData);
            
            return profileData;
            
        } catch (Exception e) {
            System.debug('Error parsing profile: ' + e.getMessage());
            throw new ProfileXMLDataManagerException('Failed to parse profile: ' + e.getMessage());
        }
    }
    
    /**
     * Parse the profile XML string
     */
    private static ProfileData parseProfileXml(String xmlString) {
        ProfileData profileData = new ProfileData();
        
        // Use DOM parsing for XML
        Dom.Document doc = new Dom.Document();
        doc.load(xmlString);
        Dom.XmlNode root = doc.getRootElement();
        
        // Parse basic information
        profileData.description = getNodeText(root, 'description');
        profileData.userLicense = getNodeText(root, 'userLicense');
        profileData.custom = Boolean.valueOf(getNodeText(root, 'custom'));
        
        // Parse application visibilities
        Dom.XmlNode appVisNode = root.getChildElement('applicationVisibilities', null);
        if (appVisNode != null) {
            for (Dom.XmlNode child : appVisNode.getChildElements()) {
                if (child.getName() == 'applicationVisibilities') {
                    ApplicationVisibility av = new ApplicationVisibility();
                    av.application = getNodeText(child, 'application');
                    av.visible = Boolean.valueOf(getNodeText(child, 'visible'));
                    profileData.applicationVisibilities.add(av);
                }
            }
        }
        
        // Parse user permissions
        Dom.XmlNode userPermNode = root.getChildElement('userPermissions', null);
        if (userPermNode != null) {
            for (Dom.XmlNode child : userPermNode.getChildElements()) {
                if (child.getName() == 'userPermissions') {
                    UserPermission up = new UserPermission();
                    up.name = getNodeText(child, 'name');
                    up.enabled = Boolean.valueOf(getNodeText(child, 'enabled'));
                    profileData.userPermissions.add(up);
                }
            }
        }
        
        // Parse object permissions
        Dom.XmlNode objPermNode = root.getChildElement('objectPermissions', null);
        if (objPermNode != null) {
            for (Dom.XmlNode child : objPermNode.getChildElements()) {
                if (child.getName() == 'objectPermissions') {
                    ObjectPermission op = new ObjectPermission();
                    op.objectName = getNodeText(child, 'object');
                    op.allowCreate = Boolean.valueOf(getNodeText(child, 'allowCreate'));
                    op.allowDelete = Boolean.valueOf(getNodeText(child, 'allowDelete'));
                    op.allowEdit = Boolean.valueOf(getNodeText(child, 'allowEdit'));
                    op.allowRead = Boolean.valueOf(getNodeText(child, 'allowRead'));
                    op.viewAllRecords = Boolean.valueOf(getNodeText(child, 'viewAllRecords'));
                    op.modifyAllRecords = Boolean.valueOf(getNodeText(child, 'modifyAllRecords'));
                    op.viewAllFields = Boolean.valueOf(getNodeText(child, 'viewAllFields'));
                    profileData.objectPermissions.add(op);
                }
            }
        }
        
        // Parse field permissions
        Dom.XmlNode fieldPermNode = root.getChildElement('fieldPermissions', null);
        if (fieldPermNode != null) {
            for (Dom.XmlNode child : fieldPermNode.getChildElements()) {
                if (child.getName() == 'fieldPermissions') {
                    FieldPermission fp = new FieldPermission();
                    fp.field = getNodeText(child, 'field');
                    fp.editable = Boolean.valueOf(getNodeText(child, 'editable'));
                    fp.readable = Boolean.valueOf(getNodeText(child, 'readable'));
                    profileData.fieldPermissions.add(fp);
                }
            }
        }
        
        // Parse page accesses
        Dom.XmlNode pageAccessNode = root.getChildElement('pageAccesses', null);
        if (pageAccessNode != null) {
            for (Dom.XmlNode child : pageAccessNode.getChildElements()) {
                if (child.getName() == 'pageAccesses') {
                    PageAccess pa = new PageAccess();
                    pa.apexPage = getNodeText(child, 'apexPage');
                    pa.enabled = Boolean.valueOf(getNodeText(child, 'enabled'));
                    profileData.pageAccesses.add(pa);
                }
            }
        }
        
        // Parse class accesses
        Dom.XmlNode classAccessNode = root.getChildElement('classAccesses', null);
        if (classAccessNode != null) {
            for (Dom.XmlNode child : classAccessNode.getChildElements()) {
                if (child.getName() == 'classAccesses') {
                    ClassAccess ca = new ClassAccess();
                    ca.apexClass = getNodeText(child, 'apexClass');
                    ca.enabled = Boolean.valueOf(getNodeText(child, 'enabled'));
                    profileData.classAccesses.add(ca);
                }
            }
        }
        
        // Parse tab visibilities
        Dom.XmlNode tabVisibilityNode = root.getChildElement('tabVisibilities', null);
        if (tabVisibilityNode != null) {
            for (Dom.XmlNode child : tabVisibilityNode.getChildElements()) {
                if (child.getName() == 'tabVisibilities') {
                    TabVisibility tv = new TabVisibility();
                    tv.tab = getNodeText(child, 'tab');
                    tv.visibility = getNodeText(child, 'visibility');
                    profileData.tabVisibilities.add(tv);
                }
            }
        }
        
        // Parse record type visibilities
        Dom.XmlNode recordTypeNode = root.getChildElement('recordTypeVisibilities', null);
        if (recordTypeNode != null) {
            for (Dom.XmlNode child : recordTypeNode.getChildElements()) {
                if (child.getName() == 'recordTypeVisibilities') {
                    RecordTypeVisibility rtv = new RecordTypeVisibility();
                    rtv.recordType = getNodeText(child, 'recordType');
                    rtv.visible = Boolean.valueOf(getNodeText(child, 'visible'));
                    profileData.recordTypeVisibilities.add(rtv);
                }
            }
        }
        
        // Parse layout assignments
        Dom.XmlNode layoutAssignmentNode = root.getChildElement('layoutAssignments', null);
        if (layoutAssignmentNode != null) {
            for (Dom.XmlNode child : layoutAssignmentNode.getChildElements()) {
                if (child.getName() == 'layoutAssignments') {
                    LayoutAssignment la = new LayoutAssignment();
                    la.layout = getNodeText(child, 'layout');
                    la.recordType = Boolean.valueOf(getNodeText(child, 'recordType'));
                    profileData.layoutAssignments.add(la);
                }
            }
        }
        
        // Parse login hours
        Dom.XmlNode loginHoursNode = root.getChildElement('loginHours', null);
        if (loginHoursNode != null) {
            LoginHours lh = new LoginHours();
            lh.weekdayStart = getNodeText(loginHoursNode, 'weekdayStart');
            lh.weekdayEnd = getNodeText(loginHoursNode, 'weekdayEnd');
            lh.weekendStart = getNodeText(loginHoursNode, 'weekendStart');
            lh.weekendEnd = getNodeText(loginHoursNode, 'weekendEnd');
            profileData.loginHours.add(lh);
        }
        
        // Parse login IP ranges
        Dom.XmlNode loginIpRangesNode = root.getChildElement('loginIpRanges', null);
        if (loginIpRangesNode != null) {
            for (Dom.XmlNode child : loginIpRangesNode.getChildElements()) {
                if (child.getName() == 'loginIpRanges') {
                    LoginIpRanges lir = new LoginIpRanges();
                    lir.startAddress = getNodeText(child, 'startAddress');
                    lir.endAddress = getNodeText(child, 'endAddress');
                    lir.description = getNodeText(child, 'description');
                    profileData.loginIpRanges.add(lir);
                }
            }
        }
        
        return profileData;
    }
    
    /**
     * Helper method to get text from XML node
     */
    private static String getNodeText(Dom.XmlNode parent, String childName) {
        Dom.XmlNode child = parent.getChildElement(childName, null);
        return child != null ? child.getText() : '';
    }
    
    /**
     * Custom exception class
     */
    public class ProfileXMLDataManagerException extends Exception {}
}