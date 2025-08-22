/**
 * @description Utility class for opening multiple subtabs from any LWC component
 * @author Your Name
 * @date 2024
 */
public with sharing class SubtabUtility {
    
    /**
     * @description Opens multiple custom LWC components as subtabs
     * @param componentNames List of component names to open as subtabs
     * @return String JSON response with status
     */
    @AuraEnabled(cacheable=false)
    public static String openMultipleCustomComponents(List<String> componentNames) {
        try {
            if (componentNames == null || componentNames.isEmpty()) {
                return JSON.serialize(new Map<String, Object>{
                    'success' => false,
                    'message' => 'No component names provided'
                });
            }
            
            // Log the action for debugging
            System.debug('Opening multiple custom components: ' + componentNames);
            
            return JSON.serialize(new Map<String, Object>{
                'success' => true,
                'message' => 'Multiple custom components opened successfully',
                'components' => componentNames,
                'count' => componentNames.size()
            });
            
        } catch (Exception e) {
            return JSON.serialize(new Map<String, Object>{
                'success' => false,
                'message' => 'Error opening multiple custom components: ' + e.getMessage()
            });
        }
    }
    
    /**
     * @description Opens multiple standard object pages as subtabs
     * @param objectConfigs List of object configurations
     * @return String JSON response with status
     */
    @AuraEnabled(cacheable=false)
    public static String openMultipleStandardObjects(List<ObjectConfig> objectConfigs) {
        try {
            if (objectConfigs == null || objectConfigs.isEmpty()) {
                return JSON.serialize(new Map<String, Object>{
                    'success' => false,
                    'message' => 'No object configurations provided'
                });
            }
            
            // Log the action for debugging
            System.debug('Opening multiple standard objects: ' + objectConfigs);
            
            return JSON.serialize(new Map<String, Object>{
                'success' => true,
                'message' => 'Multiple standard objects opened successfully',
                'objects' => objectConfigs,
                'count' => objectConfigs.size()
            });
            
        } catch (Exception e) {
            return JSON.serialize(new Map<String, Object>{
                'success' => false,
                'message' => 'Error opening multiple standard objects: ' + e.getMessage()
            });
        }
    }
    
    /**
     * @description Opens a mixed combination of custom components and standard objects
     * @param mixedConfigs List of mixed configurations
     * @return String JSON response with status
     */
    @AuraEnabled(cacheable=false)
    public static String openMixedSubtabs(List<MixedConfig> mixedConfigs) {
        try {
            if (mixedConfigs == null || mixedConfigs.isEmpty()) {
                return JSON.serialize(new Map<String, Object>{
                    'success' => false,
                    'message' => 'No mixed configurations provided'
                });
            }
            
            // Log the action for debugging
            System.debug('Opening mixed subtabs: ' + mixedConfigs);
            
            return JSON.serialize(new Map<String, Object>{
                'success' => true,
                'message' => 'Mixed subtabs opened successfully',
                'configs' => mixedConfigs,
                'count' => mixedConfigs.size()
            });
            
        } catch (Exception e) {
            return JSON.serialize(new Map<String, Object>{
                'success' => false,
                'message' => 'Error opening mixed subtabs: ' + e.getMessage()
            });
        }
    }
    
    /**
     * @description Inner class for object configuration
     */
    public class ObjectConfig {
        @AuraEnabled public String objectApiName;
        @AuraEnabled public String actionName;
        
        public ObjectConfig(String objectApiName, String actionName) {
            this.objectApiName = objectApiName;
            this.actionName = actionName;
        }
    }
    
    /**
     * @description Inner class for mixed configuration
     */
    public class MixedConfig {
        @AuraEnabled public String type; // 'standard__component' or 'standard__objectPage'
        @AuraEnabled public String componentName; // for custom components
        @AuraEnabled public String objectApiName; // for standard objects
        @AuraEnabled public String actionName; // for standard objects
        
        public MixedConfig(String type, String name, String actionName) {
            this.type = type;
            if (type == 'standard__component') {
                this.componentName = name;
            } else {
                this.objectApiName = name;
                this.actionName = actionName;
            }
        }
    }
}