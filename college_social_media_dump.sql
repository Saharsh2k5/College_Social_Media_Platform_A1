-- ============================================================================
-- College Social Media Platform - Complete SQL Dump
-- CS 432 - Databases Assignment 1 (Module A)
-- IIT Gandhinagar
-- 
-- Project: College Social Media Platform
-- Purpose: A private social network for colleges where students and faculty
--          can share updates, ideas, and announcements securely with proper        
--          verification of user identities
-- ============================================================================

-- Database Configuration
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- ============================================================================
-- Create Database
-- ============================================================================
DROP DATABASE IF EXISTS college_social_media;
CREATE DATABASE college_social_media;
USE college_social_media;

-- ============================================================================
-- SCHEMA DEFINITION
-- ============================================================================

-- Drop existing tables if they exist (in reverse order to respect foreign keys)
DROP TABLE IF EXISTS ActivityLog;
DROP TABLE IF EXISTS Notification;
DROP TABLE IF EXISTS Message;
DROP TABLE IF EXISTS GroupMember;
DROP TABLE IF EXISTS `Group`;
DROP TABLE IF EXISTS Report;
DROP TABLE IF EXISTS `Like`;
DROP TABLE IF EXISTS Comment;
DROP TABLE IF EXISTS Post;
DROP TABLE IF EXISTS Follow;
DROP TABLE IF EXISTS Member;

-- ============================================================================
-- Table 1: Member
-- Core user table with verification and profile information
-- ============================================================================
CREATE TABLE Member (
    MemberID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    ContactNumber VARCHAR(15) NOT NULL,
    Age INT NOT NULL CHECK (Age >= 16 AND Age <= 100),
    Image VARCHAR(255) DEFAULT 'default_avatar.jpg',
    CollegeID VARCHAR(20) NOT NULL UNIQUE,
    Role ENUM('Student', 'Faculty', 'Staff', 'Admin') NOT NULL DEFAULT 'Student',
    Department VARCHAR(50) NOT NULL,
    IsVerified BOOLEAN NOT NULL DEFAULT FALSE,
    JoinDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    LastLogin DATETIME,
    Bio TEXT,
    CONSTRAINT chk_email_format CHECK (Email LIKE '%@%.%')
);

-- ============================================================================
-- Table 2: Follow
-- Manages follower-following relationships between members
-- ============================================================================
CREATE TABLE Follow (
    FollowID INT PRIMARY KEY AUTO_INCREMENT,
    FollowerID INT NOT NULL,
    FollowingID INT NOT NULL,
    FollowDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (FollowerID) REFERENCES Member(MemberID) ON DELETE CASCADE,
    FOREIGN KEY (FollowingID) REFERENCES Member(MemberID) ON DELETE CASCADE,
    UNIQUE(FollowerID, FollowingID),
    CONSTRAINT chk_no_self_follow CHECK (FollowerID != FollowingID)
);

-- ============================================================================
-- Table 3: Post
-- Stores user posts and updates
-- ============================================================================
CREATE TABLE Post (
    PostID INT PRIMARY KEY AUTO_INCREMENT,
    MemberID INT NOT NULL,
    Content TEXT NOT NULL,
    MediaURL VARCHAR(255),
    MediaType ENUM('Image', 'Video', 'Document', 'None') NOT NULL DEFAULT 'None',
    PostDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    LastEditDate DATETIME,
    Visibility ENUM('Public', 'Followers', 'Private') NOT NULL DEFAULT 'Public',
    IsActive BOOLEAN NOT NULL DEFAULT TRUE,
    LikeCount INT NOT NULL DEFAULT 0 CHECK (LikeCount >= 0),
    CommentCount INT NOT NULL DEFAULT 0 CHECK (CommentCount >= 0),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID) ON DELETE CASCADE,
    CONSTRAINT chk_content_not_empty CHECK (CHAR_LENGTH(TRIM(Content)) > 0)
);

-- ============================================================================
-- Table 4: Comment
-- Stores comments on posts
-- ============================================================================
CREATE TABLE Comment (
    CommentID INT PRIMARY KEY AUTO_INCREMENT,
    PostID INT NOT NULL,
    MemberID INT NOT NULL,
    Content TEXT NOT NULL,
    CommentDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    LastEditDate DATETIME,
    IsActive BOOLEAN NOT NULL DEFAULT TRUE,
    LikeCount INT NOT NULL DEFAULT 0 CHECK (LikeCount >= 0),
    FOREIGN KEY (PostID) REFERENCES Post(PostID) ON DELETE CASCADE,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID) ON DELETE CASCADE,
    CONSTRAINT chk_comment_not_empty CHECK (CHAR_LENGTH(TRIM(Content)) > 0)
);

-- ============================================================================
-- Table 5: Like
-- Stores likes on posts and comments
-- ============================================================================
CREATE TABLE `Like` (
    LikeID INT PRIMARY KEY AUTO_INCREMENT,
    MemberID INT NOT NULL,
    TargetType ENUM('Post', 'Comment') NOT NULL,
    TargetID INT NOT NULL,
    LikeDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID) ON DELETE CASCADE,
    UNIQUE(MemberID, TargetType, TargetID)
);

-- ============================================================================
-- Table 6: Report
-- Manages content moderation and user reports
-- ============================================================================
CREATE TABLE Report (
    ReportID INT PRIMARY KEY AUTO_INCREMENT,
    ReporterID INT NOT NULL,
    ReportedItemType ENUM('Post', 'Comment', 'Member') NOT NULL,
    ReportedItemID INT NOT NULL,
    Reason TEXT NOT NULL,
    Status ENUM('Pending', 'Reviewed', 'Resolved', 'Dismissed') NOT NULL DEFAULT 'Pending',
    ReportDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ReviewedBy INT,
    ReviewDate DATETIME,
    Action VARCHAR(255),
    FOREIGN KEY (ReporterID) REFERENCES Member(MemberID) ON DELETE CASCADE,
    FOREIGN KEY (ReviewedBy) REFERENCES Member(MemberID) ON DELETE SET NULL,
    CONSTRAINT chk_reason_not_empty CHECK (CHAR_LENGTH(TRIM(Reason)) > 0),
    CONSTRAINT chk_review_logic CHECK (
        (Status = 'Pending' AND ReviewedBy IS NULL) OR
        (Status != 'Pending' AND ReviewedBy IS NOT NULL)
    )
);

-- ============================================================================
-- Table 7: Group
-- Campus groups and communities
-- ============================================================================
CREATE TABLE `Group` (
    GroupID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Description TEXT NOT NULL,
    CreatorID INT NOT NULL,
    CreateDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN NOT NULL DEFAULT TRUE,
    Category ENUM('Academic', 'Sports', 'Cultural', 'Tech', 'Other') NOT NULL DEFAULT 'Other',
    MemberCount INT NOT NULL DEFAULT 0 CHECK (MemberCount >= 0),
    FOREIGN KEY (CreatorID) REFERENCES Member(MemberID) ON DELETE CASCADE,
    CONSTRAINT chk_name_not_empty CHECK (CHAR_LENGTH(TRIM(Name)) > 0)
);

-- ============================================================================
-- Table 8: GroupMember
-- Manages group membership
-- ============================================================================
CREATE TABLE GroupMember (
    GroupMemberID INT PRIMARY KEY AUTO_INCREMENT,
    GroupID INT NOT NULL,
    MemberID INT NOT NULL,
    Role ENUM('Admin', 'Moderator', 'Member') NOT NULL DEFAULT 'Member',
    JoinDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (GroupID) REFERENCES `Group`(GroupID) ON DELETE CASCADE,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID) ON DELETE CASCADE,
    UNIQUE(GroupID, MemberID)
);

-- ============================================================================
-- Table 9: Message
-- Direct messages between users
-- ============================================================================
CREATE TABLE Message (
    MessageID INT PRIMARY KEY AUTO_INCREMENT,
    SenderID INT NOT NULL,
    ReceiverID INT NOT NULL,
    Content TEXT NOT NULL,
    SendDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IsRead BOOLEAN NOT NULL DEFAULT FALSE,
    ReadDate DATETIME,
    IsActive BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (SenderID) REFERENCES Member(MemberID) ON DELETE CASCADE,
    FOREIGN KEY (ReceiverID) REFERENCES Member(MemberID) ON DELETE CASCADE,
    CONSTRAINT chk_message_not_empty CHECK (CHAR_LENGTH(TRIM(Content)) > 0),
    CONSTRAINT chk_no_self_message CHECK (SenderID != ReceiverID),
    CONSTRAINT chk_read_date_logic CHECK (
        (IsRead = FALSE AND ReadDate IS NULL) OR
        (IsRead = TRUE AND ReadDate IS NOT NULL)
    )
);

-- ============================================================================
-- Table 10: Notification
-- User notifications for various activities
-- ============================================================================
CREATE TABLE Notification (
    NotificationID INT PRIMARY KEY AUTO_INCREMENT,
    MemberID INT NOT NULL,
    Type ENUM('Like', 'Comment', 'Follow', 'Mention', 'GroupInvite', 'Report') NOT NULL,
    Content TEXT NOT NULL,
    ReferenceID INT,
    IsRead BOOLEAN NOT NULL DEFAULT FALSE,
    CreateDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ReadDate DATETIME,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID) ON DELETE CASCADE,
    CONSTRAINT chk_notification_not_empty CHECK (CHAR_LENGTH(TRIM(Content)) > 0)
);

-- ============================================================================
-- Table 11: ActivityLog
-- Tracks user activities for security and analytics
-- ============================================================================
CREATE TABLE ActivityLog (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    MemberID INT NOT NULL,
    ActivityType ENUM('Login', 'Logout', 'Post', 'Comment', 'Like', 'Report', 'ProfileUpdate') NOT NULL,
    Details TEXT NOT NULL,
    IPAddress VARCHAR(45),
    Timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID) ON DELETE CASCADE
);

-- ============================================================================
-- Indexes for Performance Optimization
-- ============================================================================
CREATE INDEX idx_member_email ON Member(Email);
CREATE INDEX idx_member_collegeid ON Member(CollegeID);
CREATE INDEX idx_member_role ON Member(Role);
CREATE INDEX idx_post_member ON Post(MemberID);
CREATE INDEX idx_post_date ON Post(PostDate DESC);
CREATE INDEX idx_comment_post ON Comment(PostID);
CREATE INDEX idx_comment_member ON Comment(MemberID);
CREATE INDEX idx_like_target ON `Like`(TargetType, TargetID);
CREATE INDEX idx_follow_follower ON Follow(FollowerID);
CREATE INDEX idx_follow_following ON Follow(FollowingID);
CREATE INDEX idx_report_status ON Report(Status);
CREATE INDEX idx_message_receiver ON Message(ReceiverID);
CREATE INDEX idx_notification_member ON Notification(MemberID);
CREATE INDEX idx_activitylog_member ON ActivityLog(MemberID);
CREATE INDEX idx_activitylog_timestamp ON ActivityLog(Timestamp DESC);

-- ============================================================================
-- SAMPLE DATA INSERTION
-- ============================================================================

-- Insert Sample Data into Member Table (20 rows)
INSERT INTO Member (Name, Email, ContactNumber, Age, Image, CollegeID, Role, Department, IsVerified, Bio) VALUES
('Rahul Sharma', 'rahul.sharma@iitgn.ac.in', '9876543210', 20, 'rahul.jpg', 'IITGN2023001', 'Student', 'Computer Science', TRUE, 'CS undergrad | AI enthusiast | Love coding'),
('Priya Patel', 'priya.patel@iitgn.ac.in', '9876543211', 19, 'priya.jpg', 'IITGN2024002', 'Student', 'Electrical Engineering', TRUE, 'EE sophomore | Robotics club member'),
('Dr. Amit Kumar', 'amit.kumar@iitgn.ac.in', '9876543212', 45, 'amit.jpg', 'IITGN2010FAC01', 'Faculty', 'Computer Science', TRUE, 'Associate Professor | Database Systems'),
('Sneha Gupta', 'sneha.gupta@iitgn.ac.in', '9876543213', 21, 'sneha.jpg', 'IITGN2022003', 'Student', 'Mechanical Engineering', TRUE, 'Mech senior | Formula student team captain'),
('Arjun Reddy', 'arjun.reddy@iitgn.ac.in', '9876543214', 22, 'arjun.jpg', 'IITGN2021004', 'Student', 'Chemical Engineering', TRUE, 'ChemE | Research enthusiast | Photography'),
('Ananya Singh', 'ananya.singh@iitgn.ac.in', '9876543215', 20, 'ananya.jpg', 'IITGN2023005', 'Student', 'Computer Science', TRUE, 'CS junior | Web dev | Open source contributor'),
('Vikram Joshi', 'vikram.joshi@iitgn.ac.in', '9876543216', 19, 'vikram.jpg', 'IITGN2024006', 'Student', 'Civil Engineering', TRUE, 'Civil sophomore | Debate club | Music'),
('Dr. Meera Shah', 'meera.shah@iitgn.ac.in', '9876543217', 38, 'meera.jpg', 'IITGN2015FAC02', 'Faculty', 'Mathematics', TRUE, 'Assistant Professor | Applied Mathematics'),
('Karan Malhotra', 'karan.malhotra@iitgn.ac.in', '9876543218', 21, 'karan.jpg', 'IITGN2022007', 'Student', 'Electrical Engineering', TRUE, 'EE | Embedded systems | IoT projects'),
('Neha Desai', 'neha.desai@iitgn.ac.in', '9876543219', 20, 'neha.jpg', 'IITGN2023008', 'Student', 'Computer Science', TRUE, 'CS | ML researcher | Hackathon winner'),
('Rohan Kapoor', 'rohan.kapoor@iitgn.ac.in', '9876543220', 22, 'rohan.jpg', 'IITGN2021009', 'Student', 'Mechanical Engineering', TRUE, 'Mech | CAD design | 3D printing'),
('Ishita Agarwal', 'ishita.agarwal@iitgn.ac.in', '9876543221', 19, 'ishita.jpg', 'IITGN2024010', 'Student', 'Chemical Engineering', TRUE, 'ChemE freshman | Coding club'),
('Aditya Verma', 'aditya.verma@iitgn.ac.in', '9876543222', 21, 'aditya.jpg', 'IITGN2022011', 'Student', 'Computer Science', TRUE, 'CS | Cybersecurity | CTF player'),
('Pooja Rao', 'pooja.rao@iitgn.ac.in', '9876543223', 20, 'pooja.jpg', 'IITGN2023012', 'Student', 'Civil Engineering', TRUE, 'Civil | Architecture | Sustainability'),
('Siddharth Mishra', 'siddharth.mishra@iitgn.ac.in', '9876543224', 19, 'siddharth.jpg', 'IITGN2024013', 'Student', 'Electrical Engineering', TRUE, 'EE | Electronics | Circuit design'),
('Divya Nair', 'divya.nair@iitgn.ac.in', '9876543225', 22, 'divya.jpg', 'IITGN2021014', 'Student', 'Computer Science', TRUE, 'CS senior | Full stack dev | Placement coordinator'),
('Abhishek Pandey', 'abhishek.pandey@iitgn.ac.in', '9876543226', 21, 'abhishek.jpg', 'IITGN2022015', 'Student', 'Mechanical Engineering', TRUE, 'Mech | Thermodynamics | Sports enthusiast'),
('Sakshi Jain', 'sakshi.jain@iitgn.ac.in', '9876543227', 20, 'sakshi.jpg', 'IITGN2023016', 'Student', 'Chemical Engineering', TRUE, 'ChemE | Process design | Dance team'),
('Varun Saxena', 'varun.saxena@iitgn.ac.in', '9876543228', 35, 'varun.jpg', 'IITGN2018STAFF01', 'Staff', 'Administration', TRUE, 'Network Administrator | IT Support'),
('Kavya Krishnan', 'kavya.krishnan@iitgn.ac.in', '9876543229', 19, 'kavya.jpg', 'IITGN2024017', 'Student', 'Computer Science', TRUE, 'CS freshman | AI/ML | Competitive programmer');

-- Insert Sample Data into Follow Table (15 rows)
INSERT INTO Follow (FollowerID, FollowingID) VALUES
(1, 2), (1, 3), (1, 6), (1, 10),
(2, 1), (2, 6), (2, 9),
(4, 1), (4, 5), (4, 11),
(6, 1), (6, 10), (6, 13),
(10, 1), (10, 6);

-- Insert Sample Data into Post Table (20 rows)
INSERT INTO Post (MemberID, Content, MediaURL, MediaType, Visibility, LikeCount, CommentCount) VALUES
(1, 'Just finished my database assignment! Really enjoyed designing the schema for our college social media platform. 🎓', 'post1.jpg', 'Image', 'Public', 15, 3),
(2, 'Excited to share that our robotics team qualified for the national competition! Hard work pays off! 🤖', 'robot.jpg', 'Image', 'Public', 28, 5),
(3, 'Reminder: Database Systems midterm exam on February 15th. Office hours this Friday 2-4 PM.', NULL, 'None', 'Public', 45, 8),
(4, 'Our Formula Student car testing went amazingly well today! Can''t wait for the competition season.', 'car_test.mp4', 'Video', 'Public', 32, 7),
(5, 'Published my research paper on catalytic reactions! Link in bio. Thank you to all my lab mates! 📚', 'paper.pdf', 'Document', 'Public', 21, 4),
(6, 'Working on a new web application using React and Node.js. Open source project coming soon! 💻', 'webapp.jpg', 'Image', 'Public', 19, 6),
(7, 'Won the inter-college debate competition! Topic: AI Ethics and Regulation. Great experience!', 'debate.jpg', 'Image', 'Public', 26, 4),
(8, 'New course announcement: Advanced Topics in Applied Mathematics - Spring 2026. Registration open!', NULL, 'None', 'Public', 38, 12),
(9, 'Built an IoT-based smart irrigation system for our campus garden. Sustainability matters! 🌱', 'iot.jpg', 'Image', 'Public', 24, 5),
(10, 'Won first place at the National Hackathon with my ML-based healthcare prediction model! 🏆', 'hackathon.jpg', 'Image', 'Public', 42, 9),
(11, 'CAD model of our new mechanical project. 3D printing starts tomorrow!', 'cad.jpg', 'Image', 'Followers', 17, 3),
(1, 'Anyone interested in forming a study group for algorithms? DM me!', NULL, 'None', 'Public', 12, 8),
(13, 'Participated in my first CTF competition. Cybersecurity is fascinating!', NULL, 'None', 'Public', 18, 2),
(14, 'Campus sustainability initiative: Join us for tree plantation this Sunday!', 'trees.jpg', 'Image', 'Public', 31, 11),
(6, 'Just deployed my portfolio website. Check it out and give feedback! Link in bio.', NULL, 'None', 'Public', 22, 6),
(16, 'Placement season tips: Start preparing early, practice DSA daily, and network effectively!', NULL, 'None', 'Public', 36, 14),
(4, 'Engineering is not just about calculations, it''s about creativity and problem solving! 💡', NULL, 'None', 'Public', 29, 5),
(10, 'Research paper accepted at ICML 2026! Dreams do come true with hard work! 🎉', 'acceptance.jpg', 'Image', 'Public', 51, 15),
(20, 'Learning Python for data science. Any good resource recommendations?', NULL, 'None', 'Public', 14, 9),
(2, 'Circuit design workshop this Saturday in EE lab. All departments welcome!', 'circuit.jpg', 'Image', 'Public', 20, 4);

-- Insert Sample Data into Comment Table (20 rows)
INSERT INTO Comment (PostID, MemberID, Content, LikeCount) VALUES
(1, 2, 'Great work Rahul! Your schema design looks solid!', 3),
(1, 6, 'Can you share your ER diagram? Would love to see it!', 2),
(1, 10, 'Database design is so interesting! Good job!', 1),
(2, 1, 'Congratulations Priya! Your team deserves it!', 5),
(2, 9, 'Amazing achievement! Best of luck for nationals!', 4),
(3, 1, 'Thank you sir! Will attend office hours.', 2),
(3, 6, 'What topics should we focus on for the exam?', 8),
(3, 13, 'Is the exam open book or closed book?', 3),
(4, 1, 'That''s awesome! Formula Student is so cool!', 4),
(4, 11, 'Great job team! The car looks fantastic!', 3),
(5, 3, 'Excellent research Arjun! Congratulations!', 6),
(6, 1, 'Looking forward to the open source project!', 2),
(6, 10, 'Which tech stack are you using?', 4),
(7, 2, 'Well done Vikram! You spoke brilliantly!', 3),
(8, 1, 'Will definitely register for this course!', 5),
(8, 6, 'What are the prerequisites for this course?', 4),
(10, 1, 'Incredible Neha! You''re an inspiration!', 7),
(10, 6, 'Wow! Can you share details about your model?', 5),
(10, 13, 'Congratulations! Healthcare + ML is the future!', 6),
(18, 1, 'Congratulations Neha! ICML is prestigious!', 9);

-- Insert Sample Data into Like Table (20 rows)
INSERT INTO `Like` (MemberID, TargetType, TargetID) VALUES
(1, 'Post', 2), (1, 'Post', 3), (1, 'Post', 10),
(2, 'Post', 1), (2, 'Post', 4), (2, 'Post', 6),
(3, 'Post', 5), (3, 'Post', 8), (3, 'Post', 10),
(6, 'Post', 1), (6, 'Post', 2), (6, 'Post', 10),
(10, 'Post', 1), (10, 'Post', 6), (10, 'Post', 16),
(1, 'Comment', 1), (2, 'Comment', 4), (6, 'Comment', 7),
(10, 'Comment', 17), (13, 'Comment', 19);

-- Insert Sample Data into Report Table (12 rows)
INSERT INTO Report (ReporterID, ReportedItemType, ReportedItemID, Reason, Status, ReviewedBy, ReviewDate, Action) VALUES
(2, 'Post', 13, 'Spam content with irrelevant links', 'Resolved', 3, '2026-02-01 10:30:00', 'Post removed'),
(6, 'Comment', 8, 'Inappropriate language used', 'Resolved', 3, '2026-02-01 14:20:00', 'Comment deleted'),
(10, 'Member', 15, 'Fake profile using someone else''s photo', 'Reviewed', 3, '2026-02-02 09:15:00', 'Under investigation'),
(1, 'Post', 7, 'Misleading information about exam dates', 'Dismissed', 3, '2026-02-02 16:45:00', 'Verified as accurate'),
(4, 'Comment', 12, 'Harassment and bullying', 'Resolved', 8, '2026-02-03 11:00:00', 'User warned'),
(9, 'Post', 15, 'Advertisement of external services', 'Pending', NULL, NULL, NULL),
(13, 'Member', 7, 'Creating multiple fake accounts', 'Pending', NULL, NULL, NULL),
(14, 'Post', 19, 'Copyright violation - using others'' work', 'Reviewed', 3, '2026-02-03 15:30:00', 'Asked for attribution'),
(6, 'Comment', 15, 'Off-topic spam comments', 'Resolved', 8, '2026-02-04 08:20:00', 'Comment removed'),
(1, 'Post', 11, 'Sensitive personal information shared', 'Resolved', 3, '2026-02-04 10:00:00', 'Post edited'),
(10, 'Comment', 19, 'Hate speech and discrimination', 'Pending', NULL, NULL, NULL),
(16, 'Member', 20, 'Impersonating faculty member', 'Reviewed', 3, '2026-02-04 12:15:00', 'Profile verification required');

-- Insert Sample Data into Group Table (15 rows)
INSERT INTO `Group` (Name, Description, CreatorID, Category, MemberCount) VALUES
('Coding Club IITGN', 'A community for programming enthusiasts. Weekly coding sessions and hackathons.', 1, 'Tech', 45),
('Robotics Club', 'Building robots, competing in national events, and learning automation.', 2, 'Tech', 32),
('Formula Student Team', 'Designing and building formula-style race cars for international competitions.', 4, 'Tech', 28),
('Machine Learning Study Group', 'Discussing ML algorithms, research papers, and working on AI projects.', 10, 'Academic', 38),
('Debate Society', 'Enhancing public speaking and critical thinking through debates and MUNs.', 7, 'Cultural', 41),
('Photography Club', 'Campus photography, workshops, and exhibitions.', 5, 'Cultural', 35),
('CS Department Forum', 'Academic discussions, doubt clearing, and resource sharing for CS students.', 6, 'Academic', 67),
('Sustainability Initiative', 'Environmental awareness, tree plantation, and green campus initiatives.', 14, 'Other', 52),
('Math Circle', 'Problem solving sessions, math competitions, and research discussions.', 8, 'Academic', 29),
('Dance Team', 'Cultural performances, choreography, and dance competitions.', 18, 'Cultural', 44),
('Placement Preparation', 'Interview preparation, mock tests, and placement strategies.', 16, 'Academic', 89),
('Sports Enthusiasts', 'Organizing sports events, tournaments, and fitness activities.', 17, 'Sports', 56),
('IoT Makers', 'Building IoT projects, smart devices, and embedded systems.', 9, 'Tech', 24),
('Open Source Contributors', 'Contributing to open source projects and learning collaborative development.', 6, 'Tech', 31),
('Research Scholars', 'Research paper discussions, collaboration opportunities, and academic writing.', 5, 'Academic', 22);

-- Insert Sample Data into GroupMember Table (20 rows)
INSERT INTO GroupMember (GroupID, MemberID, Role) VALUES
(1, 1, 'Admin'), (1, 6, 'Moderator'), (1, 10, 'Member'), (1, 13, 'Member'), (1, 20, 'Member'),
(2, 2, 'Admin'), (2, 9, 'Moderator'), (2, 15, 'Member'),
(3, 4, 'Admin'), (3, 11, 'Moderator'), (3, 17, 'Member'),
(4, 10, 'Admin'), (4, 1, 'Member'), (4, 6, 'Member'), (4, 20, 'Member'),
(5, 7, 'Admin'), (5, 2, 'Member'),
(7, 6, 'Admin'), (7, 1, 'Moderator'), (7, 10, 'Member');

-- Insert Sample Data into Message Table (15 rows)
INSERT INTO Message (SenderID, ReceiverID, Content, IsRead, ReadDate) VALUES
(1, 2, 'Hey Priya! Congratulations on the robotics competition qualification!', TRUE, '2026-02-01 10:15:00'),
(2, 1, 'Thanks Rahul! How is your database assignment going?', TRUE, '2026-02-01 10:30:00'),
(6, 1, 'Can you help me with the normalization concepts? I''m a bit confused.', TRUE, '2026-02-02 14:20:00'),
(1, 6, 'Sure! Let''s meet in the library at 4 PM today.', TRUE, '2026-02-02 14:35:00'),
(10, 1, 'Hey! Want to team up for the upcoming hackathon?', TRUE, '2026-02-02 18:45:00'),
(1, 10, 'Absolutely! Your ML skills + my backend development = winning combo!', TRUE, '2026-02-02 19:00:00'),
(4, 11, 'The CAD files for the new chassis are ready. Check your email.', TRUE, '2026-02-03 09:30:00'),
(13, 1, 'Any resources for learning penetration testing?', FALSE, NULL),
(14, 4, 'Are you joining the sustainability event this Sunday?', TRUE, '2026-02-03 16:20:00'),
(6, 10, 'I checked out your ML model. Impressive accuracy! Can we collaborate?', TRUE, '2026-02-04 08:40:00'),
(10, 6, 'Thanks! Yes, let''s work on a project together.', TRUE, '2026-02-04 09:10:00'),
(16, 1, 'Need any help with placement preparation? I can share some resources.', FALSE, NULL),
(7, 5, 'Great research paper! Can I cite it in my presentation?', TRUE, '2026-02-04 11:25:00'),
(9, 2, 'Want to collaborate on an IoT project for the smart campus?', FALSE, NULL),
(20, 10, 'I''m new to ML. Can you suggest some beginner-friendly projects?', FALSE, NULL);

-- Insert Sample Data into Notification Table (20 rows)
INSERT INTO Notification (MemberID, Type, Content, ReferenceID, IsRead, ReadDate) VALUES
(1, 'Like', 'Priya Patel liked your post about database assignment', 1, TRUE, '2026-02-01 09:15:00'),
(1, 'Comment', 'Ananya Singh commented on your post', 1, TRUE, '2026-02-01 09:30:00'),
(1, 'Follow', 'Neha Desai started following you', 10, TRUE, '2026-02-01 11:00:00'),
(2, 'Like', 'Rahul Sharma liked your post about robotics competition', 2, TRUE, '2026-02-01 12:20:00'),
(6, 'Comment', 'Rahul Sharma commented on your post', 6, TRUE, '2026-02-02 10:45:00'),
(10, 'Like', 'Multiple people liked your hackathon achievement post', 10, TRUE, '2026-02-02 15:30:00'),
(3, 'Comment', 'Students commented on your exam announcement', 3, TRUE, '2026-02-01 16:00:00'),
(4, 'Like', 'Rohan Kapoor liked your Formula Student post', 4, FALSE, NULL),
(5, 'Comment', 'Dr. Amit Kumar commented on your research paper', 5, TRUE, '2026-02-02 08:15:00'),
(6, 'Follow', 'Kavya Krishnan started following you', 20, FALSE, NULL),
(7, 'Like', 'Priya Patel liked your debate competition post', 7, TRUE, '2026-02-02 14:40:00'),
(1, 'GroupInvite', 'You have been invited to join Machine Learning Study Group', 4, FALSE, NULL),
(10, 'Mention', 'Rahul Sharma mentioned you in a comment', 12, TRUE, '2026-02-03 09:50:00'),
(16, 'Comment', 'Multiple students commented on your placement tips post', 16, TRUE, '2026-02-03 17:20:00'),
(1, 'Like', 'Neha Desai liked your comment', 16, FALSE, NULL),
(6, 'Comment', 'Neha Desai commented on your web application post', 6, TRUE, '2026-02-04 10:15:00'),
(14, 'Like', 'Multiple people liked your sustainability post', 14, FALSE, NULL),
(2, 'Comment', 'Vikram Saxena commented on your circuit workshop post', 20, FALSE, NULL),
(10, 'Like', 'Everyone is congratulating you on ICML acceptance!', 18, TRUE, '2026-02-04 11:45:00'),
(20, 'Comment', 'Students shared Python learning resources', 19, FALSE, NULL);

-- Insert Sample Data into ActivityLog Table (20 rows)
INSERT INTO ActivityLog (MemberID, ActivityType, Details, IPAddress, Timestamp) VALUES
(1, 'Login', 'User logged in successfully', '192.168.1.101', '2026-02-01 08:00:00'),
(1, 'Post', 'Created new post about database assignment', '192.168.1.101', '2026-02-01 09:00:00'),
(2, 'Login', 'User logged in successfully', '192.168.1.102', '2026-02-01 08:30:00'),
(2, 'Post', 'Created post about robotics competition', '192.168.1.102', '2026-02-01 09:45:00'),
(3, 'Login', 'User logged in successfully', '192.168.1.103', '2026-02-01 10:00:00'),
(3, 'Post', 'Posted exam reminder announcement', '192.168.1.103', '2026-02-01 10:15:00'),
(6, 'Login', 'User logged in successfully', '192.168.1.106', '2026-02-01 14:00:00'),
(6, 'Comment', 'Commented on post ID 1', '192.168.1.106', '2026-02-01 14:10:00'),
(10, 'Login', 'User logged in successfully', '192.168.1.110', '2026-02-02 07:30:00'),
(10, 'Post', 'Shared hackathon achievement', '192.168.1.110', '2026-02-02 08:00:00'),
(1, 'Like', 'Liked multiple posts', '192.168.1.101', '2026-02-02 09:30:00'),
(6, 'ProfileUpdate', 'Updated bio and profile picture', '192.168.1.106', '2026-02-02 15:20:00'),
(13, 'Login', 'User logged in successfully', '192.168.1.113', '2026-02-03 08:45:00'),
(13, 'Post', 'Posted about CTF competition', '192.168.1.113', '2026-02-03 09:00:00'),
(14, 'Post', 'Created sustainability initiative post', '192.168.1.114', '2026-02-03 10:30:00'),
(2, 'Report', 'Reported spam content', '192.168.1.102', '2026-02-01 10:30:00'),
(16, 'Post', 'Shared placement preparation tips', '192.168.1.116', '2026-02-03 16:00:00'),
(10, 'Login', 'User logged in successfully', '192.168.1.110', '2026-02-04 07:15:00'),
(10, 'Post', 'Announced ICML paper acceptance', '192.168.1.110', '2026-02-04 08:00:00'),
(1, 'Logout', 'User logged out', '192.168.1.101', '2026-02-04 18:00:00');

-- ============================================================================
-- Verification Queries
-- ============================================================================

-- Verify all tables have data
SELECT 'Member' as TableName, COUNT(*) as RowCount FROM Member
UNION ALL
SELECT 'Follow', COUNT(*) FROM Follow
UNION ALL
SELECT 'Post', COUNT(*) FROM Post
UNION ALL
SELECT 'Comment', COUNT(*) FROM Comment
UNION ALL
SELECT 'Like', COUNT(*) FROM `Like`
UNION ALL
SELECT 'Report', COUNT(*) FROM Report
UNION ALL
SELECT 'Group', COUNT(*) FROM `Group`
UNION ALL
SELECT 'GroupMember', COUNT(*) FROM GroupMember
UNION ALL
SELECT 'Message', COUNT(*) FROM Message
UNION ALL
SELECT 'Notification', COUNT(*) FROM Notification
UNION ALL
SELECT 'ActivityLog', COUNT(*) FROM ActivityLog;

COMMIT;

-- ============================================================================
-- End of SQL Dump
-- ============================================================================
