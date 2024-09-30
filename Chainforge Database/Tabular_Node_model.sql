USE Chain_forge_workflow;

-- Users table
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Permissions VARCHAR(255) NOT NULL
);

-- Workflows Table
CREATE TABLE Workflows (
    WorkflowID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    Description TEXT,
    CreationDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status VARCHAR(100),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Nodes Table, with focus on enabling different types of nodes including TabularNodes
CREATE TABLE Nodes (
    NodeID INT AUTO_INCREMENT PRIMARY KEY,
    WorkflowID INT NOT NULL,
    NodeType VARCHAR(100) NOT NULL,
    Settings JSON,  -- General settings for all nodes
    FOREIGN KEY (WorkflowID) REFERENCES Workflows(WorkflowID)
);

-- Specialized table for Tabular Nodes, extending the general Nodes table
CREATE TABLE TabularNodes (
    TabularNodeID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    TableSchema JSON,  -- JSON type to define columns and data types dynamically
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID)
);

-- Large Language Models (LLMs) Table
CREATE TABLE LLMs (
    ModelID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Version VARCHAR(100),
    ConfigurationOptions JSON
);

-- Data Stores Table
CREATE TABLE DataStores (
    StoreID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    DataFormat VARCHAR(50),
    Size BIGINT,
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID)
);

-- Node-LLM Join Table (for Many-to-Many Relationship)
CREATE TABLE NodeLLM (
    NodeID INT NOT NULL,
    ModelID INT NOT NULL,
    Configuration JSON,
    PRIMARY KEY (NodeID, ModelID),
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID),
    FOREIGN KEY (ModelID) REFERENCES LLMs(ModelID)
);

-- Node Connections Table (Adjacency List for Directed Graph)
CREATE TABLE NodeConnections (
    SourceNodeID INT NOT NULL,
    TargetNodeID INT NOT NULL,
    PRIMARY KEY (SourceNodeID, TargetNodeID),
    FOREIGN KEY (SourceNodeID) REFERENCES Nodes(NodeID),
    FOREIGN KEY (TargetNodeID) REFERENCES Nodes(NodeID)
);

-- Global Settings Table
CREATE TABLE GlobalSettings (
    SettingID INT AUTO_INCREMENT PRIMARY KEY,
    SettingKey VARCHAR(255) NOT NULL,
    SettingValue TEXT NOT NULL,
    Description TEXT
);


-- Adding indexes to improve query performance on frequently accessed columns
ALTER TABLE Workflows ADD INDEX idx_user (UserID);
ALTER TABLE Nodes ADD INDEX idx_workflow (WorkflowID);
ALTER TABLE DataStores ADD INDEX idx_node (NodeID);
ALTER TABLE NodeLLM ADD INDEX idx_node (NodeID);
ALTER TABLE NodeLLM ADD INDEX idx_llm (ModelID);

-- Table for storing LLM configurations with integration of Global Settings
ALTER TABLE NodeLLM DROP FOREIGN KEY nodellm_ibfk_2;
DROP TABLE LLMs;

CREATE TABLE LLMs (
    ModelID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Version VARCHAR(100),
    APIKey VARCHAR(255),  -- Storing API key for the LLM, potentially controlled by Global Settings
    ConfigurationOptions JSON,  -- Configuration options that can be influenced by global settings
    IsActive BOOLEAN DEFAULT TRUE
);

#users
INSERT INTO Users (Username, Email, Permissions) VALUES
('johndoe', 'john.doe@acmecorp.com', 'project_manager'),
('janesmith', 'jane.smith@acmecorp.com', 'developer'),
('bobjohnson', 'bob.johnson@acmecorp.com', 'developer'),
('alicebrown', 'alice.brown@acmecorp.com', 'developer'),
('davidlee', 'david.lee@acmecorp.com', 'qa_engineer');

DELETE from Users;


#workflows
INSERT INTO Workflows (UserID, Description, CreationDate, Status) VALUES
(1, 'New e-commerce website development', NOW(), 'In Progress'),
(1, 'Legacy system migration', NOW(), 'Planned'),
(1, 'Mobile app development', NOW(), 'Completed');

#nodes
INSERT INTO Nodes (WorkflowID, NodeType, Settings) VALUES
(1, 'Task', '{"name": "Requirements gathering", "description": "Collect and document requirements for the new e-commerce website"}'),
(1, 'TabularNode', '{"name": "Database design", "description": "Design the database schema for the e-commerce platform"}'),
(1, 'Task', '{"name": "Front-end development", "description": "Develop the user interface and front-end components"}'),
(1, 'Task', '{"name": "Back-end development", "description": "Develop the server-side logic and APIs"}'),
(1, 'Task', '{"name": "Testing", "description": "Perform integration testing and user acceptance testing"}'),
(2, 'Task', '{"name": "Legacy system analysis", "description": "Analyze the existing legacy system and document its functionality"}'),
(2, 'Task', '{"name": "Data migration strategy", "description": "Develop a strategy for migrating data from the legacy system"}'),
(3, 'Task', '{"name": "Mobile app design", "description": "Design wireframes and prototypes for the mobile app"}'),
(3, 'Task', '{"name": "App development", "description": "Develop the mobile app for iOS and Android platforms"}'),
(3, 'Task', '{"name": "App testing", "description": "Perform functional testing and usability testing for the mobile app"}');

#LLMs
INSERT INTO LLMs (Name, Version, APIKey, ConfigurationOptions) VALUES
('GPT-3', '3.5', 'your_api_key_here', '{"model": "text-davinci-003", "temperature": 0.7}'),
('GPT-4', '4.0', 'your_api_key_here', '{"model": "text-davinci-004", "temperature": 0.6}'),
('Turing', '1.2', 'your_api_key_here', '{"model": "turing-125", "temperature": 0.8}'),
('BERT', '2.0', 'your_api_key_here', '{"model": "bert-base-uncased", "temperature": 0.5}');

INSERT INTO DataStores (NodeID, DataFormat, Size) VALUES
(2, 'JSON', 1024),
(3, 'HTML', 512),
(4, 'JSON', 2048);

#NodeLLm
INSERT INTO NodeLLM (NodeID, ModelID, Configuration) VALUES
(1, 1, '{"prompt": "Generate a detailed requirements document for an e-commerce website"}'),
(2, 2, '{"prompt": "Design a database schema for an e-commerce platform with products, orders, and customers"}'),
(3, 1, '{"prompt": "Create a modern and responsive user interface for an e-commerce website"}'),
(4, 1, '{"prompt": "Develop a RESTful API for an e-commerce platform with authentication and CRUD operations"}');

 
INSERT INTO TabularNodes (NodeID, TableSchema) 
VALUES 
    (2, 
    '{"columns": ["table_name", "column_name", "data_type", "constraints"], 
      "data": [
        ["products", "product_id", "int", "primary key"], 
        ["products", "product_name", "varchar(255)", "not null"], 
        ["products", "price", "decimal(10,2)", "not null"], 
        ["orders", "order_id", "int", "primary key"], 
        ["orders", "customer_id", "int", "not null"], 
        ["orders", "order_date", "datetime", "not null"]
      ]}'
    );
    
DELETE FROM TabularNodes;


-- Now, we insert data into the TabularNodes table for this NodeID
INSERT INTO TabularNodes (NodeID, TableSchema) 
VALUES 
(2, 
'{
    "columns": ["product_id", "product_name", "price", "quantity", "description"],
    "data": [
        [1, "Laptop", 999.99, 50, "High-performance laptop with SSD storage"],
        [2, "Smartphone", 599.99, 100, "Latest model with OLED display"],
        [3, "Tablet", 399.99, 75, "Lightweight and portable tablet for on-the-go use"],
        [4, "Headphones", 149.99, 200, "Noise-canceling headphones with Bluetooth connectivity"],
        [5, "Monitor", 299.99, 30, "27-inch LED monitor with HDMI and VGA inputs"]
    ]
}');

CREATE TABLE PromptNodes (
    PromptNodeID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    PromptText TEXT NOT NULL,
    ResponseType VARCHAR(100) DEFAULT 'text',  -- Expected response type like text, json, etc.
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID)
);

#LLm score node
CREATE TABLE LLMScoreNode (
    ScoreNodeID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    LLmscore INT,
    ModelID INT,  -- Optional, if scoring is model-specific
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID),
    FOREIGN KEY (ModelID) REFERENCES LLMs(ModelID)
);

CREATE TABLE SimpleEvaluatorNode (
    EvalNodeID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    Eval_score INT,
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID)
);

CREATE TABLE CodeEvaluatorNode (
    CodeNodeID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    CodeSnippet TEXT,  -- The code to execute
    Code_Eval_score INT,
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID)
);

CREATE TABLE VISNode (
VISNode_ID INT AUTO_INCREMENT PRIMARY KEY,
NodeID INT NOT NULL,
VisualisationType VARCHAR(255),
FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID)
);

CREATE TABLE Inspect_Node (
InspectNode_ID INT AUTO_INCREMENT PRIMARY KEY,
NodeID INT NOT NULL,
Response VARCHAR(255),
FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID)
);

#Insert Queries for PromptNodes
INSERT INTO PromptNodes (NodeID, PromptText, ResponseType) VALUES
(2, 'What is the price of the Smartphone?', 'text'),
(2, 'How many Laptops are in stock?', 'text'),
(2, 'List all products with more than 100 units in stock.', 'text'),
(2, 'Which product has the least quantity available?', 'text'),
(2, 'Provide the descriptions for all products priced over $400.', 'text');

#Insert Queries for SimpleEvaluatorNode
-- Let's assume NodeIDs for the evaluators are sequential starting from the last NodeID used
INSERT INTO SimpleEvaluatorNode (NodeID, Eval_score) VALUES
(3, ROUND(RAND() * 10)),  -- Random score between 0 and 10 for the first prompt
(4, ROUND(RAND() * 10)),  -- Random score for the second prompt
(5, ROUND(RAND() * 10)),  -- Random score for the third prompt
(6, ROUND(RAND() * 10)),  -- Random score for the fourth prompt
(7, ROUND(RAND() * 10));  -- Random score for the fifth prompt

#Insert Queries for Inspect_Node
INSERT INTO Inspect_Node (NodeID, Response) VALUES
(2, '$599.99'),  -- Response to 'What is the price of the Smartphone?'
(2, '50 units'),  -- Response to 'How many Laptops are in stock?'
(2, 'Smartphone, Headphones'),  -- Response to 'List all products with more than 100 units in stock.'
(2, 'Monitor'),  -- Response to 'Which product has the least quantity available?'
(2, 'Laptop, Smartphone, Tablet');  -- Response to 'Provide descriptions for all products priced over $400.'

SELECT
    u.Username,
    u.Email,
    w.Description AS WorkflowDescription,
    t.TableSchema AS TabularNodeSchema,
    p.PromptText,
    p.ResponseType,
    s.Eval_score,
    i.Response AS InspectNodeResponse,
    l.Name AS LLMName,
    l.Version AS LLMVersion
FROM
    Users u
    -- Join Workflows to Users
    JOIN Workflows w ON u.UserID = w.UserID
    -- Join Nodes to Workflows
    JOIN Nodes n ON w.WorkflowID = n.WorkflowID
    -- Join TabularNodes to Nodes
    LEFT JOIN TabularNodes t ON n.NodeID = t.NodeID
    -- Join PromptNodes to Nodes
    LEFT JOIN PromptNodes p ON n.NodeID = p.NodeID
    -- Join SimpleEvaluatorNode to PromptNodes (assuming linkage via NodeID)
    LEFT JOIN SimpleEvaluatorNode s ON p.NodeID = s.NodeID
    -- Join Inspect_Node to PromptNodes (assuming linkage via NodeID)
    LEFT JOIN Inspect_Node i ON p.NodeID = i.NodeID
    -- Join NodeLLM to Nodes for LLM details
    LEFT JOIN NodeLLM nl ON n.NodeID = nl.NodeID
    -- Join LLMs to NodeLLM
    LEFT JOIN LLMs l ON nl.ModelID = l.ModelID
WHERE
    u.UserID = 1;
    
SELECT * From SimpleEvaluatorNode ;