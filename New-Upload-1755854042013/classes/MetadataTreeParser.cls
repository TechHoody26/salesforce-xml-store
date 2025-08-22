public class MetadataTreeParser {
    
    // Inner class to represent a node in the tree structure
    public class TreeNode {
        @AuraEnabled public String name;
        @AuraEnabled public String type;
        @AuraEnabled public String value;
        @AuraEnabled public List<TreeNode> children;
        @AuraEnabled public Integer count;
        @AuraEnabled public Map<String, Object> properties;
        
        public TreeNode(String name, String type) {
            this.name = name;
            this.type = type;
            this.children = new List<TreeNode>();
            this.properties = new Map<String, Object>();
            this.count = 0;
        }
        
        public TreeNode(String name, String type, String value) {
            this(name, type);
            this.value = value;
        }
    }
    
    // Inner class to hold the complete metadata structure
    public class MetadataStructure {
        @AuraEnabled public Map<String, Object> meta;
        @AuraEnabled public TreeNode rootNode;
        @AuraEnabled public String metadataType;
        @AuraEnabled public String metadataName;
        
        public MetadataStructure(String metadataType, String metadataName) {
            this.metadataType = metadataType;
            this.metadataName = metadataName;
            this.meta = new Map<String, Object>();
            this.rootNode = new TreeNode(metadataName, metadataType);
        }
    }
    
    /**
     * Main method to parse XML data into a hierarchical tree structure
     * @param xmlData The XML string to parse
     * @param metadataType The type of metadata (Profile, PermissionSet, etc.)
     * @param metadataName The name of the metadata
     * @return MetadataStructure containing the parsed tree
     */
    @AuraEnabled
    public static MetadataStructure parseXMLToTree(String xmlData, String metadataType, String metadataName) {
        try {
            MetadataStructure structure = new MetadataStructure(metadataType, metadataName);
            
            // Parse XML to Map
            Map<String, Object> parsedData = parseXMLToMap(xmlData);
            
            // Build tree from parsed data
            buildTreeFromMap(parsedData, structure.rootNode);
            
            // Build meta structure
            buildMetaStructure(parsedData, structure);
            
            return structure;
        } catch (Exception e) {
            throw new AuraHandledException('Error parsing XML: ' + e.getMessage());
        }
    }
    
    /**
     * Parse XML string into a Map<String, Object>
     */
    private static Map<String, Object> parseXMLToMap(String xmlData) {
        try {
            // Try using Dom.Document first
            Dom.Document doc = new Dom.Document();
            doc.load(xmlData);
            Dom.XmlNode root = doc.getRootElement();
            
            Map<String, Object> result = new Map<String, Object>();
            parseNodeToMap(root, result);
            return result;
        } catch (Exception e) {
            // Fallback to regex parsing
            return parseXMLWithRegex(xmlData);
        }
    }
    
    /**
     * Parse XML node to Map using Dom.Document
     */
    private static void parseNodeToMap(Dom.XmlNode node, Map<String, Object> result) {
        String nodeName = node.getName();
        String nodeText = node.getText().trim();
        
        if (node.getChildElements().isEmpty()) {
            // Leaf node
            if (String.isNotBlank(nodeText)) {
                result.put(nodeName, nodeText);
            } else {
                result.put(nodeName, '');
            }
        } else {
            // Node with children
            Map<String, Object> childMap = new Map<String, Object>();
            parseNodeChildren(node, childMap);
            result.put(nodeName, childMap);
        }
    }
    
    /**
     * Parse children of an XML node
     */
    private static void parseNodeChildren(Dom.XmlNode node, Map<String, Object> result) {
        for (Dom.XmlNode child : node.getChildElements()) {
            parseNodeToMap(child, result);
        }
    }
    
    /**
     * Fallback XML parsing using regex
     */
    private static Map<String, Object> parseXMLWithRegex(String xmlData) {
        Map<String, Object> result = new Map<String, Object>();
        
        // Remove XML declaration and comments
        xmlData = xmlData.replaceAll('<!--.*?-->', '');
        xmlData = xmlData.replaceAll('<\\?xml.*?\\?>', '');
        
        // Parse the content
        result = parseTagContent(xmlData);
        
        return result;
    }
    
    /**
     * Parse XML tag content recursively
     */
    private static Map<String, Object> parseTagContent(String content) {
        Map<String, Object> result = new Map<String, Object>();
        
        // Pattern to match XML tags
        Pattern tagPattern = Pattern.compile('<([^>]+)>([^<]*)</\\1>');
        Matcher tagMatcher = tagPattern.matcher(content);
        
        while (tagMatcher.find()) {
            String tagName = tagMatcher.group(1);
            String tagValue = tagMatcher.group(2).trim();
            
            if (String.isNotBlank(tagValue)) {
                result.put(tagName, tagValue);
            } else {
                result.put(tagName, '');
            }
        }
        
        return result;
    }
    
    /**
     * Build tree structure from parsed Map
     */
    private static void buildTreeFromMap(Map<String, Object> data, TreeNode parentNode) {
        for (String key : data.keySet()) {
            Object value = data.get(key);
            
            if (value instanceof Map<String, Object>) {
                // This is a complex object with children
                TreeNode childNode = new TreeNode(key, 'object');
                childNode.count = ((Map<String, Object>) value).size();
                buildTreeFromMap((Map<String, Object>) value, childNode);
                parentNode.children.add(childNode);
            } else if (value instanceof List<Object>) {
                // This is a list of objects
                TreeNode childNode = new TreeNode(key, 'list');
                childNode.count = ((List<Object>) value).size();
                parentNode.children.add(childNode);
            } else {
                // This is a simple value
                TreeNode childNode = new TreeNode(key, 'value', String.valueOf(value));
                parentNode.children.add(childNode);
            }
        }
        
        parentNode.count = parentNode.children.size();
    }
    
    /**
     * Build meta structure for quick access
     */
    private static void buildMetaStructure(Map<String, Object> data, MetadataStructure structure) {
        structure.meta.putAll(data);
    }
    
    /**
     * Get inner objects from a specific path
     */
    @AuraEnabled
    public static List<Object> getInnerObjects(MetadataStructure structure, String path) {
        List<Object> result = new List<Object>();
        
        if (structure.meta.containsKey(path)) {
            Object pathData = structure.meta.get(path);
            if (pathData instanceof Map<String, Object>) {
                Map<String, Object> pathMap = (Map<String, Object>) pathData;
                result.addAll(pathMap.values());
            } else if (pathData instanceof List<Object>) {
                result.addAll((List<Object>) pathData);
            } else {
                result.add(pathData);
            }
        }
        
        return result;
    }
    
    /**
     * Get a specific node by path
     */
    @AuraEnabled
    public static TreeNode getNodeByPath(TreeNode rootNode, String path) {
        if (String.isBlank(path)) {
            return rootNode;
        }
        
        List<String> pathParts = path.split('/');
        TreeNode currentNode = rootNode;
        
        for (String part : pathParts) {
            if (String.isNotBlank(part)) {
                TreeNode foundNode = null;
                for (TreeNode child : currentNode.children) {
                    if (child.name == part) {
                        foundNode = child;
                        break;
                    }
                }
                if (foundNode != null) {
                    currentNode = foundNode;
                } else {
                    return null; // Path not found
                }
            }
        }
        
        return currentNode;
    }
    
    /**
     * Get all nodes of a specific type
     */
    @AuraEnabled
    public static List<TreeNode> getNodesByType(TreeNode rootNode, String nodeType) {
        List<TreeNode> result = new List<TreeNode>();
        findNodesByType(rootNode, nodeType, result);
        return result;
    }
    
    /**
     * Recursive helper to find nodes by type
     */
    private static void findNodesByType(TreeNode node, String nodeType, List<TreeNode> result) {
        if (node.type == nodeType) {
            result.add(node);
        }
        
        for (TreeNode child : node.children) {
            findNodesByType(child, nodeType, result);
        }
    }
    
    /**
     * Convert MetadataStructure to display format
     */
    @AuraEnabled
    public static Map<String, Object> getDisplayStructure(MetadataStructure structure) {
        Map<String, Object> displayMap = new Map<String, Object>();
        displayMap.put('metadataType', structure.metadataType);
        displayMap.put('metadataName', structure.metadataName);
        displayMap.put('rootNode', convertTreeNodeToMap(structure.rootNode));
        displayMap.put('meta', structure.meta);
        
        return displayMap;
    }
    
    /**
     * Convert TreeNode to Map for JSON serialization
     */
    private static Map<String, Object> convertTreeNodeToMap(TreeNode node) {
        Map<String, Object> nodeMap = new Map<String, Object>();
        nodeMap.put('name', node.name);
        nodeMap.put('type', node.type);
        nodeMap.put('value', node.value);
        nodeMap.put('count', node.count);
        nodeMap.put('properties', node.properties);
        
        List<Map<String, Object>> childrenList = new List<Map<String, Object>>();
        for (TreeNode child : node.children) {
            childrenList.add(convertTreeNodeToMap(child));
        }
        nodeMap.put('children', childrenList);
        
        return nodeMap;
    }
}