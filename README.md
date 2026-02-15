# College Social Media Platform

---

## Project Overview

**Objective**: Design and implement a relational database for a private social network enabling secure, verified communication and content sharing among college students and faculty.

**Functional Scope**:

- User verification through College ID
- Content sharing (posts, comments, likes)
- Social connections (follow/unfollow)
- Content moderation and reporting
- Group/community management
- Direct messaging
- Activity tracking and analytics

---

## Project Structure

```
College_Social_Media_Platform_A1/
│
├── college_social_media_dump.sql    # Complete SQL dump (Module A)
├── schema.sql                        # Database schema only
├── sample_data.sql                   # Sample data only
├── README.md                         # This file
│
├── ER_Diagrams/                      # Entity-Relationship Diagrams
│   └── ER.png                        # Complete ER diagram
│
└── UML_Diagrams/                     # UML Design Diagrams
    ├── like_and_comment.png          # Like and Comment system design
    ├── login.png                     # Login flow diagram
    ├── post.png                      # Post system design
    ├── UML for maaps.png             # MAAPS UML diagram
    └── use_case.png                  # Use case diagram
```

---

## Database Schema

The database consists of **12 tables** supporting a comprehensive college social media platform:

1. **Member** - Core user table with verification
2. **AuthCredential** - Authentication credentials (password hashes)
3. **Post** - User posts and updates
4. **Comment** - Comments on posts
5. **Like** - Likes on posts and comments
6. **Follow** - Follower-following relationships
7. **Report** - Content moderation reports
8. **Group** - Campus groups and communities
9. **GroupMember** - Group membership (bridge table)
10. **Message** - Direct messages between users
11. **Notification** - User notifications
12. **ActivityLog** - Activity tracking for analytics

For detailed schema definitions, see [schema.sql](schema.sql).

---

## Core Functionalities

### 1. User Registration & Verification

- Member registration with unique college ID
- Profile verification system
- Role-based access control (Student, Faculty, Staff, Admin)
- Complete profile management

**SQL Examples**:

```sql
-- Register new member
INSERT INTO Member (Name, Email, ContactNumber, CollegeID, Department)
VALUES ('John Doe', 'john.doe@iitgn.ac.in', '9876543210', 'IITGN2023001', 'Computer Science');

-- Verify member
UPDATE Member SET IsVerified = TRUE WHERE CollegeID = 'IITGN2023001';

-- Get all verified members
SELECT * FROM Member WHERE IsVerified = TRUE;
```

### 2. Content Sharing & Engagement

- Full CRUD operations on posts
- Hierarchical commenting system
- Like functionality for posts and comments
- Media attachment support (images, videos, documents)

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

### 3. Social Connections

- Bidirectional follow relationships
- Follower and following lists
- Connection analytics

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

### 4. Content Moderation & Reporting

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

### 5. Group Management

- Campus group creation and management
- Dynamic group membership
- Hierarchical role system (Admin, Moderator, Member)
- Categorical organization (Academic, Sports, Cultural, Tech, Other)

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

### 6. Direct Messaging

- Private message exchange between users
- Read/unread status tracking
- Message history management

### 7. Notification System

- Event-based notifications (likes, comments, follows, mentions)
- Read status management
- Activity logging for security and analytics

---

## Installation & Usage

### Prerequisites

- MySQL 5.7+ or MariaDB 10.3+
- MySQL Workbench (optional)

### Setup Instructions

1. **Database Import**:

```bash
mysql -u root -p < college_social_media_dump.sql
```

2. **Verification**:

```sql
USE college_social_media;
SHOW TABLES;

-- Verify data population
SELECT 'Member' as TableName, COUNT(*) as RowCount FROM Member
UNION ALL
SELECT 'Post', COUNT(*) FROM Post;
```

---

## Sample Queries

### Query 1: Most Active Users

```sql
SELECT m.Name, m.Email,
       COUNT(DISTINCT p.PostID) AS PostCount,
       COUNT(DISTINCT c.CommentID) AS CommentCount,
       COUNT(DISTINCT l.LikeID) AS LikeGivenCount
FROM Member m
LEFT JOIN Post p ON m.MemberID = p.MemberID
LEFT JOIN Comment c ON m.MemberID = c.MemberID
LEFT JOIN `Like` l ON m.MemberID = l.MemberID
GROUP BY m.MemberID
ORDER BY (PostCount + CommentCount + LikeGivenCount) DESC
LIMIT 10;
```

### Query 2: Popular Posts by Engagement

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

### Query 3: Group Membership Statistics

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

### Query 4: User Social Network Metrics

```sql
-- Retrieve followers and following counts for a specific user
SELECT
    (SELECT COUNT(*) FROM Follow WHERE FollowingID = 1) AS Followers,
    (SELECT COUNT(*) FROM Follow WHERE FollowerID = 1) AS Following,
    (SELECT COUNT(*) FROM Post WHERE MemberID = 1) AS Posts,
    (SELECT COUNT(*) FROM Comment WHERE MemberID = 1) AS Comments;
```

### Query 5: Pending Moderation Reports

```sql
SELECT r.ReportID, r.ReportedItemType, r.ReportedItemID,
       m1.Name AS Reporter, r.Reason, r.ReportDate
FROM Report r
JOIN Member m1 ON r.ReporterID = m1.MemberID
WHERE r.Status = 'Pending'
ORDER BY r.ReportDate ASC;
```

---

## Database Constraints & Integrity

### CHECK Constraints

- Email format validation (`LIKE '%@%.%'`)
- Non-negative counters (LikeCount, CommentCount ≥ 0)
- Non-empty content validation
- Chronological consistency (ReadDate ≥ SendDate, ReviewDate ≥ ReportDate)

### TRIGGERS (Business Rules)

The following business rules are enforced using triggers instead of CHECK constraints due to MySQL foreign key constraint limitations:

- **Self-follow prevention**: Users cannot follow themselves
- **Self-message prevention**: Users cannot send messages to themselves
- **Report review logic**: Pending reports must not have a reviewer; non-pending reports must have a reviewer

### UNIQUE Constraints

- Member: Email, CollegeID
- Follow: (FollowerID, FollowingID)
- Like: (MemberID, TargetType, TargetID)
- GroupMember: (GroupID, MemberID)

### Referential Integrity

- ON DELETE CASCADE: Dependent records removed when parent is deleted
- ON DELETE SET NULL: Foreign key set to NULL when referenced record is deleted (e.g., ReviewedBy in Report)
- ON UPDATE CASCADE: Key changes propagate to dependent tables

---

## Performance Optimization

### Indexed Columns

- `Member(Role)` - Role-based filtering
- `Post(MemberID)` - User posts lookup
- `Post(PostDate)` - Chronological ordering
- `Comment(PostID)` - Post comments lookup
- `Comment(MemberID)` - User comment activity
- `Like(TargetType, TargetID)` - Target-based like retrieval
- `Follow(FollowerID)` - Follower queries
- `Follow(FollowingID)` - Following queries
- `Report(Status)` - Status-based filtering
- `Message(ReceiverID)` - Inbox queries
- `Notification(MemberID)` - User notification retrieval
- `ActivityLog(MemberID)` - User activity tracking
- `ActivityLog(Timestamp)` - Temporal queries

### Database Triggers

Six triggers are implemented to enforce business rules that cannot be implemented as CHECK constraints in MySQL (due to foreign key CASCADE conflict):

1. **trg_follow_no_self_follow_insert** - Prevents users from following themselves on INSERT
2. **trg_follow_no_self_follow_update** - Prevents users from following themselves on UPDATE
3. **trg_message_no_self_message_insert** - Prevents users from messaging themselves on INSERT
4. **trg_message_no_self_message_update** - Prevents users from messaging themselves on UPDATE
5. **trg_report_review_logic_insert** - Enforces report review logic on INSERT
6. **trg_report_review_logic_update** - Enforces report review logic on UPDATE

These triggers use `SIGNAL SQLSTATE '45000'` to raise custom errors when business rules are violated.
