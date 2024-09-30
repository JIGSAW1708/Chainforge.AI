CREATE DATABASE Replica_Chainforge;

USE Replica_Chainforge;

#users
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Permissions VARCHAR(255) NOT NULL
);

#Workflows
CREATE TABLE Workflows (
    WorkflowID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    Description TEXT,
    CreationDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status VARCHAR(100),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

#nodes
CREATE TABLE Nodes (
    NodeID INT AUTO_INCREMENT PRIMARY KEY,
    WorkflowID INT NOT NULL,
    NodeType VARCHAR(100) NOT NULL,
    FOREIGN KEY (WorkflowID) REFERENCES Workflows(WorkflowID)
);

#nodetype
CREATE TABLE NodeTypes (
    TypeID INT AUTO_INCREMENT PRIMARY KEY,
    TypeName VARCHAR(255) NOT NULL
);

#textfieldnodes
CREATE TABLE TextFieldNodes (
    TextFieldID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT UNIQUE NOT NULL,
    Content TEXT,
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID)
);

#promptnodes
CREATE TABLE PromptNodes (
    PromptNodeID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    PromptText TEXT NOT NULL,
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID)
);

#evaluatornode
CREATE TABLE EvaluatorNode (
    EvaluatorNodeID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    IsCorrect BOOLEAN,
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID)
);

#inspectnode
CREATE TABLE InspectNode (
    InspectNodeID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    CorrectAnswer TEXT,
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID)
);

#nodeconnection
CREATE TABLE NodeConnections (
    ConnectionID INT AUTO_INCREMENT PRIMARY KEY,
    SourceNodeID INT NOT NULL,
    TargetNodeID INT NOT NULL,
    FOREIGN KEY (SourceNodeID) REFERENCES Nodes(NodeID),
    FOREIGN KEY (TargetNodeID) REFERENCES Nodes(NodeID)
);

#llm table
CREATE TABLE LLMs (
    ModelID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Version VARCHAR(100),
    APIKey VARCHAR(255),
    ConfigurationOptions JSON
);

#globalsetttings
CREATE TABLE GlobalSettings (
    SettingID INT AUTO_INCREMENT PRIMARY KEY,
    SettingKey VARCHAR(255) NOT NULL,
    SettingValue TEXT NOT NULL,
    Description TEXT
);

#llmscore
CREATE TABLE LLMScore (
    ScoreID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    ModelID INT NOT NULL,
    Score DECIMAL(5,2),
    FOREIGN KEY (NodeID) REFERENCES Nodes(NodeID),
    FOREIGN KEY (ModelID) REFERENCES LLMs(ModelID)
);


#insertion of user
INSERT INTO Users (Username, Email, Permissions) VALUES
('johndoe', 'john.doe@example.com', 'admin'),
('janedoe', 'jane.doe@example.com', 'editor'),
('bobsmith', 'bob.smith@example.com', 'viewer');

#insertion of workflows
INSERT INTO Workflows (UserID, Description, CreationDate, Status) VALUES
(1, 'Exploration of Quantum Computing Advances', NOW(), 'Active'),
(2, 'Review of Latest AI Developments', NOW(), 'Active'),
(3, 'Discussion on Renewable Energy Sources', NOW(), 'Pending');

#insertionofnodes
INSERT INTO Nodes (WorkflowID, NodeType) VALUES
(1, 'TextField'),
(1, 'Prompt'),
(2, 'TextField'),
(2, 'Evaluator'),
(3, 'TextField');

#textfieldnodes
INSERT INTO TextFieldNodes (NodeID, Content) VALUES
(1, 'Quantum computing uses principles of quantum mechanics to process information exponentially faster than classical computers.'),
(3, 'Artificial Intelligence has progressed with new models that can generate human-like text.'),
(5, 'Renewable energy sources like solar and wind are crucial to reducing carbon emissions.');

#promptnodes
INSERT INTO PromptNodes (NodeID, PromptText) VALUES
(2, 'What is the principle quantum computing exploits to achieve faster processing speeds?'),
(4, 'Evaluate the impact of AI on job markets. Provide a true or false statement.');

#evaluatornodes
INSERT INTO EvaluatorNode (NodeID, IsCorrect) VALUES
(4, TRUE);  -- Assume any response to this will initially be marked true for simplicity.

#inspectnodes
INSERT INTO InspectNode (NodeID, CorrectAnswer) VALUES
(4, 'True');  -- Simplistic correct answer setup.

#nodeconnections
INSERT INTO NodeConnections (SourceNodeID, TargetNodeID) VALUES
(1, 2),  -- From TextField to Prompt in Quantum Computing.
(2, 4),  -- From Prompt to Evaluator in AI Developments.
(3, 4);  -- Another connection to the evaluator from a different node.

#llms
INSERT INTO LLMs (Name, Version, APIKey, ConfigurationOptions) VALUES
('GPT-4', '4.0', 'api_key_gpt4', '{"temperature": 0.7, "max_tokens": 100}'),
('BERT', 'latest', 'api_key_bert', '{"tokens": 512}');

#globalsettings
INSERT INTO GlobalSettings (SettingKey, SettingValue, Description) VALUES
('theme', 'dark', 'The theme of the UI'),
('defaultLLM', 'GPT-4', 'Default language model used for processing');

##llmscorre
INSERT INTO LLMScore (NodeID, ModelID, Score) VALUES
(4, 1, 85.50);  -- Assuming an 85.5% score for a node using GPT-4.
    
DELIMITER //

CREATE PROCEDURE AddWorkflow(
    IN p_UserID INT,
    IN p_Description TEXT,
    IN p_Status VARCHAR(100)
)
BEGIN
    INSERT INTO Workflows (UserID, Description, CreationDate, Status) 
    VALUES (p_UserID, p_Description, NOW(), p_Status);
END//

DELIMITER ;


CREATE VIEW WorkflowData AS
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
    insp.CorrectAnswer AS InspectCorrectAnswer,
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
    InspectNode insp ON n.NodeID = insp.NodeID
LEFT JOIN 
    LLMs llm ON ls.ModelID = llm.ModelID;

SELECT 
    UserID,
    Username,
    Email,
    Description,
    TextfieldContent,
    PromptText,
    EvaluatorIsCorrect,
    Score,
    ModelID,
    InspectCorrectAnswer,
    LLMName,
    LLMVersion
FROM 
    WorkflowData;


    

    





