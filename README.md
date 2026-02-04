# College Social Media Platform - Database Assignment
## CS 432 - Databases (Course Project/Assignment 1)
## IIT Gandhinagar - February 4, 2026

---

## 📋 Project Overview

**Domain**: College Social Media Platform  
**Problem Statement**: A private social network for colleges where students and faculty can share updates, ideas, and announcements in a secure, verified environment.

**Key Features**:
- User verification through College ID
- Content sharing (posts, comments, likes)
- Social connections (follow/unfollow)
- Content moderation and reporting
- Group/community management
- Direct messaging
- Activity tracking and analytics

---

## 📁 Project Structure

```
Assignment1/
│
├── college_social_media_dump.sql    # Complete SQL dump (Module A)
├── schema.sql                        # Database schema only
├── sample_data.sql                   # Sample data only
├── UML_Documentation.md              # UML diagrams documentation (Module B)
├── ER_Documentation.md               # ER diagrams documentation (Module B)
├── README.md                         # This file
└── REQUIREMENTS_CHECKLIST.md         # Assignment requirements verification
```

---

## 🗄️ Database Schema

### Tables (11 total):
1. **Member** - Core user table with verification
2. **Post** - User posts and updates
3. **Comment** - Comments on posts
4. **Like** - Likes on posts and comments
5. **Follow** - Follower-following relationships
6. **Report** - Content moderation reports
7. **Group** - Campus groups and communities
8. **GroupMember** - Group membership (bridge table)
9. **Message** - Direct messages between users
10. **Notification** - User notifications
11. **ActivityLog** - Activity tracking for analytics

---

## ⚙️ Core Functionalities (5+ required)

### ✅ 1. User Registration & Verification
- Member registration with college ID
- Profile verification system
- Role-based access (Student, Faculty, Staff, Admin)
- Profile management

**SQL Examples**:
```sql
-- Register new member
INSERT INTO Member (Name, Email, ContactNumber, Age, CollegeID, Department)
VALUES ('John Doe', 'john.doe@iitgn.ac.in', '9876543210', 20, 'IITGN2023001', 'Computer Science');

-- Verify member
UPDATE Member SET IsVerified = TRUE WHERE CollegeID = 'IITGN2023001';

-- Get all verified members
SELECT * FROM Member WHERE IsVerified = TRUE;
```

### ✅ 2. Content Sharing & Engagement
- Create, edit, delete posts
- Add comments on posts
- Like posts and comments
- Media attachments support

**SQL Examples**:
```sql
-- Create post
INSERT INTO Post (MemberID, Content, MediaType, Visibility)
VALUES (1, 'Hello IITGN! Excited to join this platform!', 'None', 'Public');

-- Add comment
INSERT INTO Comment (PostID, MemberID, Content)
VALUES (1, 2, 'Welcome to the platform!');

-- Like a post
INSERT INTO `Like` (MemberID, TargetType, TargetID)
VALUES (3, 'Post', 1);

-- Get post with engagement stats
SELECT p.*, m.Name AS AuthorName, p.LikeCount, p.CommentCount
FROM Post p
JOIN Member m ON p.MemberID = m.MemberID
WHERE p.PostID = 1;
```

### ✅ 3. Social Connections
- Follow/unfollow users
- View followers and following
- Track connection growth

**SQL Examples**:
```sql
-- Follow a user
INSERT INTO Follow (FollowerID, FollowingID)
VALUES (1, 2);

-- Get follower count
SELECT COUNT(*) AS FollowerCount
FROM Follow
WHERE FollowingID = 2;

-- Get following count
SELECT COUNT(*) AS FollowingCount
FROM Follow
WHERE FollowerID = 1;

-- Get user's followers
SELECT m.*
FROM Member m
JOIN Follow f ON m.MemberID = f.FollowerID
WHERE f.FollowingID = 2;
```

### ✅ 4. Content Moderation & Reporting
- Report inappropriate content
- Review and resolve reports
- Track moderation actions
- Admin review workflow

**SQL Examples**:
```sql
-- Report a post
INSERT INTO Report (ReporterID, ReportedItemType, ReportedItemID, Reason)
VALUES (5, 'Post', 10, 'Spam content with irrelevant links');

-- Admin reviews report
UPDATE Report
SET Status = 'Reviewed', ReviewedBy = 3, ReviewDate = NOW(),
    Action = 'Post removed'
WHERE ReportID = 1;

-- Get pending reports
SELECT r.*, m1.Name AS ReporterName
FROM Report r
JOIN Member m1 ON r.ReporterID = m1.MemberID
WHERE r.Status = 'Pending';
```

### ✅ 5. Group Management
- Create campus groups
- Join/leave groups
- Role-based group management (Admin, Moderator, Member)
- Category-based organization

**SQL Examples**:
```sql
-- Create group
INSERT INTO `Group` (Name, Description, CreatorID, Category)
VALUES ('Coding Club IITGN', 'Programming enthusiasts community', 1, 'Tech');

-- Add member to group
INSERT INTO GroupMember (GroupID, MemberID, Role)
VALUES (1, 2, 'Member');

-- Get all groups a member belongs to
SELECT g.*
FROM `Group` g
JOIN GroupMember gm ON g.GroupID = gm.GroupID
WHERE gm.MemberID = 1 AND gm.IsActive = TRUE;
```

### ✅ Bonus: Direct Messaging & Notifications
- Send direct messages
- Real-time notifications
- Activity logging

---

## 📊 Assignment Requirements Compliance

### ✅ Module A Requirements:

| Requirement | Status | Details |
|-------------|--------|---------|
| Member Table | ✅ | Complete with all required attributes |
| 5+ Functionalities | ✅ | 5 core + 2 bonus functionalities |
| 5+ Entities | ✅ | 11 entities implemented |
| 10+ Tables | ✅ | 11 tables implemented |
| Primary Keys | ✅ | All tables have PKs |
| Foreign Keys | ✅ | Proper FK relationships with CASCADE/SET NULL |
| Functional Coverage | ✅ | All functionalities supported |
| Real-life Data | ✅ | 15-20 rows per table with realistic data |
| Referential Integrity | ✅ | CASCADE and SET NULL constraints |
| 3+ NOT NULL per table | ✅ | All tables have 3+ NOT NULL columns |
| Unique Row ID | ✅ | All tables have unique identifiers |
| Logical Constraints | ✅ | Age range, no self-follow, read date logic, etc. |

### ✅ Module B Requirements:

| Requirement | Status | File |
|-------------|--------|------|
| UML Diagrams | ✅ | UML_Documentation.md |
| ER Diagram | ✅ | ER_Documentation.md |
| UML-to-ER Explanation | ✅ | Included in ER_Documentation.md |
| Relationship Justifications | ✅ | Detailed in both documents |
| Constraints Documentation | ✅ | Comprehensive constraint lists |

---

## 🚀 Installation & Usage

### Prerequisites:
- MySQL 5.7+ or MariaDB 10.3+
- MySQL Workbench (optional, for visualization)

### Setup Instructions:

1. **Create Database**:
```bash
mysql -u root -p
```

2. **Import SQL Dump**:
```sql
source college_social_media_dump.sql
```

Or via command line:
```bash
mysql -u root -p < college_social_media_dump.sql
```

3. **Verify Installation**:
```sql
USE college_social_media;
SHOW TABLES;

-- Check row counts
SELECT 'Member' as TableName, COUNT(*) as RowCount FROM Member
UNION ALL
SELECT 'Post', COUNT(*) FROM Post;
```

---

## 🔍 Sample Queries

### Query 1: Get Most Active Users
```sql
SELECT m.Name, m.Email,
       COUNT(DISTINCT p.PostID) AS PostCount,
       COUNT(DISTINCT c.CommentID) AS CommentCount,
       COUNT(DISTINCT l.LikeID) AS LikeCount
FROM Member m
LEFT JOIN Post p ON m.MemberID = p.MemberID
LEFT JOIN Comment c ON m.MemberID = c.MemberID
LEFT JOIN `Like` l ON m.MemberID = l.MemberID
GROUP BY m.MemberID
ORDER BY (PostCount + CommentCount + LikeCount) DESC
LIMIT 10;
```

### Query 2: Get Popular Posts
```sql
SELECT p.PostID, m.Name AS Author, p.Content,
       p.LikeCount, p.CommentCount,
       (p.LikeCount * 2 + p.CommentCount) AS PopularityScore
FROM Post p
JOIN Member m ON p.MemberID = m.MemberID
WHERE p.IsActive = TRUE
ORDER BY PopularityScore DESC
LIMIT 10;
```

### Query 3: Get Group Statistics
```sql
SELECT g.Name, g.Category, g.MemberCount,
       COUNT(DISTINCT gm.MemberID) AS ActualMemberCount,
       m.Name AS Creator
FROM `Group` g
JOIN Member m ON g.CreatorID = m.MemberID
LEFT JOIN GroupMember gm ON g.GroupID = gm.GroupID AND gm.IsActive = TRUE
GROUP BY g.GroupID
ORDER BY g.MemberCount DESC;
```

### Query 4: Get User's Social Network
```sql
-- Get followers and following for a specific user
SELECT
    (SELECT COUNT(*) FROM Follow WHERE FollowingID = 1) AS Followers,
    (SELECT COUNT(*) FROM Follow WHERE FollowerID = 1) AS Following,
    (SELECT COUNT(*) FROM Post WHERE MemberID = 1) AS Posts,
    (SELECT COUNT(*) FROM Comment WHERE MemberID = 1) AS Comments;
```

### Query 5: Get Pending Moderation Reports
```sql
SELECT r.ReportID, r.ReportedItemType, r.ReportedItemID,
       m1.Name AS Reporter, r.Reason, r.ReportDate
FROM Report r
JOIN Member m1 ON r.ReporterID = m1.MemberID
WHERE r.Status = 'Pending'
ORDER BY r.ReportDate ASC;
```

---

## 🔐 Security & Constraints

### CHECK Constraints:
- Age: 16 ≤ Age ≤ 100
- Email format: Must contain '@' and '.'
- No self-following: FollowerID ≠ FollowingID
- No self-messaging: SenderID ≠ ReceiverID
- Positive counts: LikeCount, CommentCount ≥ 0
- Content validation: Non-empty strings

### UNIQUE Constraints:
- Member: Email, CollegeID
- Follow: (FollowerID, FollowingID)
- Like: (MemberID, TargetType, TargetID)
- GroupMember: (GroupID, MemberID)

### Referential Integrity:
- CASCADE DELETE: When member deleted, their content is removed
- SET NULL: When reviewer deleted, reports remain but reviewer is cleared

---

## 📈 Performance Optimization

### Indexes Created:
- Email and CollegeID lookup (Member)
- Post date sorting (Post)
- Comment lookups by post and member
- Follow relationship queries
- Report status filtering
- Message receiver inbox queries
- Activity log timestamp ordering

---

## 👥 Team Contributions

This section should be filled by your team:

| Name | Roll Number | Contribution |
|------|-------------|--------------|
| [Your Name] | [Roll No] | Schema design, SQL implementation |
| [Team Member 2] | [Roll No] | Data generation, testing |
| [Team Member 3] | [Roll No] | UML/ER diagrams, documentation |

---

## 📝 Notes for Submission

### Module A Submission:
- File: `college_social_media_dump.sql`
- Contains: Complete database with schema and sample data
- Verified: All constraints and requirements met

### Module B Submission:
- Prepare a PDF report combining:
  - UML diagrams (create visual diagrams from UML_Documentation.md)
  - ER diagram (create visual diagram from ER_Documentation.md)
  - UML-to-ER transition explanation
  - Relationship justifications
  - Team member contributions

### Recommended Tools for Diagrams:
- draw.io (free, online)
- Lucidchart (free tier available)
- Microsoft Visio
- MySQL Workbench (for ER diagrams)

---

## 📞 Contact Information

For queries about this implementation:
- Instructor: Dr. Yogesh K. Meena
- Course: CS 432 - Databases
- Institution: IIT Gandhinagar
- Semester: II (2025-2026)

---

## 📜 License

This project is created for academic purposes as part of CS 432 course assignment at IIT Gandhinagar.

---
