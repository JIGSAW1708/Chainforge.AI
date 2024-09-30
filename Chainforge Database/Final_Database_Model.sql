-- Drop existing database if exists and create new one
DROP DATABASE IF EXISTS New_Workflow_Db;
CREATE DATABASE New_Workflow_Db;
USE New_Workflow_Db;

-- Users Table
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Permissions VARCHAR(255) NOT NULL
);

-- Node Types Table
CREATE TABLE NodeTypes (
    TypeID INT AUTO_INCREMENT PRIMARY KEY,
    TypeName VARCHAR(255) NOT NULL
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

-- Nodes Table
CREATE TABLE Nodes (
    NodeID INT AUTO_INCREMENT PRIMARY KEY,
    WorkflowID INT NOT NULL,
    NodeTypeID INT NOT NULL,
    FOREIGN KEY (WorkflowID) REFERENCES Workflows(WorkflowID),
    FOREIGN KEY (NodeTypeID) REFERENCES NodeTypes(TypeID)
);

-- Text Field Nodes Table
CREATE TABLE TextFieldNodes (
    TextFieldID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT UNIQUE NOT NULL,
    Content TEXT,
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID)
);

-- Prompt Nodes Table
CREATE TABLE PromptNodes (
    PromptNodeID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    PromptText TEXT NOT NULL,
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID)
);
-- Inspect Node Table
CREATE TABLE InspectNode (
    InspectNodeID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    CorrectAnswer TEXT,
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID)
);

-- Evaluator Node Table
CREATE TABLE EvaluatorNode (
    EvaluatorNodeID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    IsCorrect BOOLEAN,
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID)
);

-- Node Connections Table
CREATE TABLE NodeConnections (
    ConnectionID INT AUTO_INCREMENT PRIMARY KEY,
    SourceNodeID INT NOT NULL,
    TargetNodeID INT NOT NULL,
    FOREIGN KEY (SourceNodeID) REFERENCES Nodes(NodeID),
    FOREIGN KEY (TargetNodeID) REFERENCES Nodes(NodeID)
);

-- LLM Table
CREATE TABLE LLMs (
    ModelID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Version VARCHAR(100),
    APIKey VARCHAR(255),
    ConfigurationOptions JSON
);

-- Global Settings Table
CREATE TABLE GlobalSettings (
    SettingID INT AUTO_INCREMENT PRIMARY KEY,
    SettingKey VARCHAR(255) NOT NULL,
    SettingValue TEXT NOT NULL,
    Description TEXT
);

-- LLM Score Table
CREATE TABLE LLMScore (
    ScoreID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    ModelID INT NOT NULL,
    Score DECIMAL(5,2),
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID),
    FOREIGN KEY (ModelID) REFERENCES LLMs(ModelID)
);

INSERT INTO Users (Username, Email, Permissions) VALUES
('alicegreen', 'alice.green@example.com', 'admin'),
('bobgray', 'bob.gray@example.com', 'editor'),
('carolwhite', 'carol.white@example.com', 'viewer'),
('daviddoe', 'david.doe@example.com', 'admin'),
('ellenblack', 'ellen.black@example.com', 'editor'),
('frankbrown', 'frank.brown@example.com', 'viewer'),
('gracelee', 'grace.lee@example.com', 'admin');

INSERT INTO NodeTypes (TypeName) VALUES
('Review'), ('Update'), ('Delete'), ('Inspect'), ('Evaluate');

INSERT INTO Workflows (UserID, Description, Status) VALUES
(1, 'Machine Learning Model Development', 'Active'),
(2, 'Cloud Computing Resources', 'Review'),
(3, 'Data Mining Techniques', 'Active'),
(4, 'Cybersecurity Measures', 'Pending'),
(5, 'IoT Deployment Strategies', 'Active'),
(6, 'Big Data Analytics', 'Active'),
(7, 'Virtual Reality Applications', 'Review');

INSERT INTO Nodes (WorkflowID, NodeTypeID) VALUES
(1, 1), (1, 2), (2, 2), (2, 3), (3, 1),
(3, 4), (4, 1), (4, 5), (5, 3), (5, 4),
(6, 1), (6, 5), (7, 2), (7, 3);


INSERT INTO TextFieldNodes (NodeID, Content) VALUES
(1, 'Introduction to ML models and their applications.'),
(3, 'Overview of cloud service models and their benefits.'),
(5, 'Techniques and tools in data mining for large datasets.'),
(7, 'Current cybersecurity threats and prevention strategies.'),
(10, 'Strategies for deploying IoT in smart cities.'),
(12, 'Use of big data tools for market analysis.'),
(14, 'Exploring potential of VR in education and training.');

INSERT INTO PromptNodes (NodeID, PromptText) VALUES
(2, 'How can machine learning transform industries?'),
(4, 'What are the main advantages of using public clouds?'),
(6, 'Identify the primary methods in data mining.'),
(8, 'Discuss the effectiveness of antivirus software in 2024.'),
(9, 'Describe IoT security challenges.'),
(11, 'How can data analytics improve business decisions?'),
(13, 'What are immersive technologies in VR?');
INSERT INTO PromptNodes (NodeID, PromptText) VALUES
(6, 'Explain how deep learning differs from traditional machine learning in visual tasks.'),
(8, 'What are the key benefits of blockchain technology in securing data?');

-- Populate Evaluator and Inspect Nodes
INSERT INTO EvaluatorNode (NodeID, IsCorrect) VALUES
(4, TRUE);  -- Assuming any response is initially marked true for simplicity.
INSERT INTO EvaluatorNode (NodeID, IsCorrect) VALUES
(8, FALSE);  -- Initially marked false for complexity.


INSERT INTO InspectNode (NodeID, CorrectAnswer) VALUES
(4, 'True');  -- Correct answer for the evaluator node.
INSERT INTO InspectNode (NodeID, CorrectAnswer) VALUES
(8, 'Decentralization, transparency, immutability');

-- Populate Node Connections
INSERT INTO NodeConnections (SourceNodeID, TargetNodeID) VALUES
(1, 2),  -- From TextField to Prompt in Workflow 1
(3, 4);  -- From TextField to Evaluator in Workflow 2
-- Additional Node Connections to represent complex workflows
INSERT INTO NodeConnections (SourceNodeID, TargetNodeID) VALUES
(5, 6),  -- From TextField to Prompt in Workflow 3
(7, 8),  -- From TextField to Evaluator in Workflow 4
(9, 10); -- From TextField to Prompt in Workflow 5

-- Populate LLMs and Scores
INSERT INTO LLMs (Name, Version, APIKey, ConfigurationOptions) VALUES
('GPT-4', '4.0', 'api_key_gpt4', '{"temperature": 0.7, "max_tokens": 100}'),
('BERT', 'latest', 'api_key_bert', '{"tokens": 512}');

-- Additional LLM Configurations
INSERT INTO LLMs (Name, Version, APIKey, ConfigurationOptions) VALUES
('Transformer', '3.1', 'api_key_transformer', '{"attention": "multi-head", "layers": 16}');

-- Additional LLM Scores for the nodes
INSERT INTO LLMScore (NodeID, ModelID, Score) VALUES
(6, 2, 91.20),  -- High performance in NLP tasks
(10, 3, 88.75); -- Good score for blockchain node evaluation


INSERT INTO LLMScore (NodeID, ModelID, Score) VALUES
(4, 1, 85.50);  -- Assuming an 85.5% score for a node evaluated using GPT-4.
-- Additional LLM Scores for the nodes
INSERT INTO LLMScore (NodeID, ModelID, Score) VALUES
(6, 2, 91.20),  -- High performance in NLP tasks
(10, 3, 88.75); -- Good score for blockchain node evaluation

-- Audit Log Table
CREATE TABLE AuditLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT,
    Action VARCHAR(255) NOT NULL,
    Description TEXT,
    LogDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- View for summarizing workflow details
CREATE VIEW WorkflowSummary AS
SELECT w.WorkflowID, w.Description, w.Status, u.Username, COUNT(n.NodeID) AS NumberOfNodes
FROM Workflows w
JOIN Users u ON w.UserID = u.UserID
LEFT JOIN Nodes n ON w.WorkflowID = n.WorkflowID
GROUP BY w.WorkflowID;

-- View for detailed node interactions
CREATE VIEW NodeDetails AS
SELECT n.NodeID, nt.TypeName, n.WorkflowID, w.Description AS WorkflowDescription, t.Content AS TextFieldContent, p.PromptText
FROM Nodes n
JOIN NodeTypes nt ON n.NodeTypeID = nt.TypeID
LEFT JOIN TextFieldNodes t ON n.NodeID = t.NodeID
LEFT JOIN PromptNodes p ON n.NodeID = p.NodeID
JOIN Workflows w ON n.WorkflowID = w.WorkflowID;

-- Procedure to add a new node
DELIMITER $$
CREATE PROCEDURE AddNode(IN p_WorkflowID INT, IN p_NodeTypeID INT, IN p_Content TEXT)
BEGIN
    INSERT INTO Nodes (WorkflowID, NodeTypeID) VALUES (p_WorkflowID, p_NodeTypeID);
    SET @last_id = LAST_INSERT_ID();
    IF p_NodeTypeID = 1 THEN -- Assuming 1 is TextField
        INSERT INTO TextFieldNodes (NodeID, Content) VALUES (@last_id, p_Content);
    END IF;
END$$
DELIMITER ;

-- Trigger to log when a new node is added
DELIMITER $$
CREATE TRIGGER AfterNodeAdded
AFTER INSERT ON Nodes FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (UserID, Action, Description)
    VALUES (NEW.UserID, 'Add Node', CONCAT('Node added to Workflow ID: ', NEW.WorkflowID));
END$$
DELIMITER ;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS PromptResponses;
DROP TABLE IF EXISTS OriginalResponses;
DROP TABLE IF EXISTS EvaluatedScores;

-- Create necessary tables
CREATE TABLE PromptResponses (
    ResponseID INT AUTO_INCREMENT PRIMARY KEY,
    PromptID INT,
    ResponseText TEXT,
    FOREIGN KEY (PromptID) REFERENCES Prompts(PromptID)
);

CREATE TABLE OriginalResponses (
    ResponseID INT AUTO_INCREMENT PRIMARY KEY,
    PromptID INT,
    OriginalResponse TEXT,
    DateRecorded DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PromptID) REFERENCES Prompts(PromptID)
);

CREATE TABLE EvaluatedScores (
    ScoreID INT AUTO_INCREMENT PRIMARY KEY,
    PromptID INT,
    LLM_Score INT,
    Simple_Evaluation BOOLEAN,
    LLM_Model VARCHAR(100),
    FOREIGN KEY (PromptID) REFERENCES Prompts(PromptID)
);

-- Populate PromptResponses Table with responses related to big database organization
INSERT INTO PromptResponses (PromptID, ResponseText) VALUES
(1, 'Best Practices for Oracle Database Administration include optimizing SQL queries and tuning performance parameters.'),
(2, 'In a large Oracle database, managing tablespaces and datafiles efficiently is crucial for performance and scalability.'),
(3, 'Sophie is an experienced Oracle DBA who specializes in designing high availability architectures.'),
(4, 'Introduction to Oracle Relational Databases covers topics such as schema design, indexing strategies, and data partitioning.'),
(5, 'Data Governance Strategies in Oracle environments involve establishing data quality standards, access controls, and compliance measures.'),
(6, 'In a well-organized Oracle database, it is common to have zero downtime during scheduled maintenance.'),
(7, 'Data Visualization Techniques for Oracle databases often involve using tools like Oracle Analytics Cloud and Oracle Data Visualization Desktop.'),
(8, 'Oracle databases with 10 comments may indicate active community engagement and support.');

-- Populate OriginalResponses Table
INSERT INTO OriginalResponses (PromptID, OriginalResponse) VALUES 
(1, 'Best Practices for Oracle Database Administration include optimizing SQL queries and tuning performance parameters.'),
(2, 'In a large Oracle database, managing tablespaces and datafiles efficiently is crucial for performance and scalability.'),
(3, 'Sophie is an experienced Oracle DBA who specializes in designing high availability architectures.'),
(4, 'Introduction to Oracle Relational Databases covers topics such as schema design, indexing strategies, and data partitioning.'),
(5, 'Data Governance Strategies in Oracle environments involve establishing data quality standards, access controls, and compliance measures.'),
(6, 'In a well-organized Oracle database, it is common to have zero downtime during scheduled maintenance.'),
(7, 'Data Visualization Techniques for Oracle databases often involve using tools like Oracle Analytics Cloud and Oracle Data Visualization Desktop.'),
(8, 'Oracle databases with 10 comments may indicate active community engagement and support.');

-- Populate EvaluatedScores Table
INSERT INTO EvaluatedScores (PromptID, LLM_Score, Simple_Evaluation, LLM_Model) VALUES
(1, 90, TRUE, 'GPT-4.0'),
(2, 80, TRUE, 'GPT-4.0'),
(3, 85, TRUE, 'GPT-4.0'),
(4, 95, TRUE, 'GPT-4.0'),
(5, 75, TRUE, 'GPT-4.0'),
(6, 70, TRUE, 'GPT-4.0'),
(7, 88, TRUE, 'GPT-4.0'),
(8, 92, TRUE, 'GPT-4.0');

-- Create Views for Workflow No. 1 and Workflow No. 2
CREATE VIEW Workflow_No_1 AS
SELECT 
    p.PromptID,
    p.PromptText AS PromptQuestion,
    pr.ResponseText AS PromptResponse,
    ors.OriginalResponse,
    es.LLM_Score,
    es.Simple_Evaluation,
    es.LLM_Model
FROM 
    Prompts p
LEFT JOIN 
    PromptResponses pr ON p.PromptID = pr.PromptID
LEFT JOIN 
    OriginalResponses ors ON p.PromptID = ors.PromptID
LEFT JOIN 
    EvaluatedScores es ON p.PromptID = es.PromptID
WHERE 
    p.PromptID BETWEEN 1 AND 4;

CREATE VIEW Workflow_No_2 AS
SELECT 
    p.PromptID,
    p.PromptText AS PromptQuestion,
    pr.ResponseText AS PromptResponse,
    ors.OriginalResponse,
    es.LLM_Score,
    es.Simple_Evaluation,
    es.LLM_Model
FROM 
    Prompts p
LEFT JOIN 
    PromptResponses pr ON p.PromptID = pr.PromptID
LEFT JOIN 
    OriginalResponses ors ON p.PromptID = ors.PromptID
LEFT JOIN 
    EvaluatedScores es ON p.PromptID = es.PromptID
WHERE 
    p.PromptID BETWEEN 5 AND 8;

SELECT 
    u.UserID,
    u.Username,
    u.Email,
    w.Description,
    tf.Content AS TextfieldContent,
    pn.PromptText,
    en.IsCorrect AS EvaluatorIsCorrect,
    ls.Score,
    ls.ModelID,
    ina.CorrectAnswer AS InspectCorrectAnswer,
    llm.Name AS LLMName,
    llm.Version AS LLMVersion
FROM 
    Users u
JOIN 
    Workflows w ON u.UserID = w.UserID
LEFT JOIN 
    Nodes n ON w.WorkflowID = n.WorkflowID
LEFT JOIN 
    TextFieldNodes tf ON n.NodeID = tf.NodeID
LEFT JOIN 
    PromptNodes pn ON n.NodeID = pn.NodeID
LEFT JOIN 
    EvaluatorNode en ON n.NodeID = en.NodeID
LEFT JOIN 
    LLMScore ls ON n.NodeID = ls.NodeID
LEFT JOIN 
    InspectNode ina ON n.NodeID = ina.NodeID
LEFT JOIN 
    LLMs llm ON ls.ModelID = llm.ModelID;

























