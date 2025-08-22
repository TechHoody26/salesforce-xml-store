public with sharing class ProfileDataProcessor {
    
    /**
     * Process profile data received from LWC component
     * This method will be called to handle the profile data processing
     * 
     * @param profileData List of profile data with key-value pairs
     * @param contentVersionId The ContentVersion ID that contains the original files
     * @return ProcessingResult with status and message 
     */
    @AuraEnabled
    public static ProcessingResult processProfileData(List<ProfileDataWrapper> profileData, String contentVersionId) {
        try {
            System.debug('🚀 Starting profile data processing...');
            System.debug('📊 Total profiles to process: ' + profileData.size());
            System.debug('📁 ContentVersion ID: ' + contentVersionId);
            
            // Validate input
            if (profileData == null || profileData.isEmpty()) {
                return new ProcessingResult('error', 'No profile data provided');
            }
            
            // Process each profile
            List<String> processedProfiles = new List<String>();
            List<String> errors = new List<String>();
            
            for (ProfileDataWrapper profile : profileData) {
                try {
                    System.debug('🔍 Processing profile: ' + profile.profileKey);
                    
                    // Here you can add your specific profile processing logic
                    // For example:
                    // - Parse the XML content
                    // - Extract specific permissions
                    // - Create or update records
                    // - Validate data
                    
                    // For now, we'll just log the data
                    System.debug('📝 Profile Key: ' + profile.profileKey);
                    System.debug('📄 File Name: ' + profile.fileName);
                    System.debug('📋 Profile Value Length: ' + (profile.profileValue != null ? profile.profileValue.length() : 0));
                    
                    // Add to processed list
                    processedProfiles.add(profile.profileKey);
                    
                } catch (Exception e) {
                    System.debug('❌ Error processing profile ' + profile.profileKey + ': ' + e.getMessage());
                    errors.add('Profile ' + profile.profileKey + ': ' + e.getMessage());
                }
            }
            
            // Prepare result
            String message = 'Successfully processed ' + processedProfiles.size() + ' profiles';
            if (!errors.isEmpty()) {
                message += '. Errors: ' + errors.size();
            }
            
            System.debug('✅ Profile processing completed. Processed: ' + processedProfiles.size() + ', Errors: ' + errors.size());
            
            return new ProcessingResult('success', message, processedProfiles, errors);
            
        } catch (Exception e) {
            System.debug('❌ Fatal error in profile processing: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            
            return new ProcessingResult('error', 'Fatal error: ' + e.getMessage());
        }
    }
    
    /**
     * Wrapper class for profile data received from LWC
     */
    public class ProfileDataWrapper {
        @AuraEnabled public String profileKey { get; set; }
        @AuraEnabled public String profileValue { get; set; }
        @AuraEnabled public String fileName { get; set; }
        
        public ProfileDataWrapper() {}
        
        public ProfileDataWrapper(String profileKey, String profileValue, String fileName) {
            this.profileKey = profileKey;
            this.profileValue = profileValue;
            this.fileName = fileName;
        }
    }
    
    /**
     * Result class for profile processing
     */
    public class ProcessingResult {
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public List<String> processedProfiles { get; set; }
        @AuraEnabled public List<String> errors { get; set; }
        
        public ProcessingResult(String status, String message) {
            this.status = status;
            this.message = message;
            this.processedProfiles = new List<String>();
            this.errors = new List<String>();
        }
        
        public ProcessingResult(String status, String message, List<String> processedProfiles, List<String> errors) {
            this.status = status;
            this.message = message;
            this.processedProfiles = processedProfiles != null ? processedProfiles : new List<String>();
            this.errors = errors != null ? errors : new List<String>();
        }
    }
}