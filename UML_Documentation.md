# College Social Media Platform - UML Diagram Documentation
## CS 432 - Databases Assignment 1 (Module B)
## IIT Gandhinagar - February 4, 2026

---

## UML Class Diagrams

### Overview
This document provides the structure for UML class diagrams for the College Social Media Platform. The system consists of 11 main classes corresponding to the database tables, with their relationships, attributes, and multiplicities.

---

## UML Diagram 1: Core User Management System

### Class: Member
```
+------------------------------------------+
|               Member                     |
+------------------------------------------+
| - MemberID: int {PK}                    |
| - Name: string                           |
| - Email: string {unique}                 |
| - ContactNumber: string                  |
| - Age: int                               |
| - Image: string                          |
| - CollegeID: string {unique}             |
| - Role: enum                             |
| - Department: string                     |
| - IsVerified: boolean                    |
| - JoinDate: datetime                     |
| - LastLogin: datetime                    |
| - Bio: text                              |
+------------------------------------------+
| + register()                             |
| + login()                                |
| + updateProfile()                        |
| + verifyAccount()                        |
| + getFollowers()                         |
| + getFollowing()                         |
+------------------------------------------+
```

**Attributes Explanation:**
- **MemberID** (PK): Unique identifier for each member
- **Email & CollegeID**: Unique constraints ensure no duplicates
- **Role**: ENUM('Student', 'Faculty', 'Staff', 'Admin')
- **IsVerified**: Boolean flag for account verification status

**Methods:**
- register(): Creates a new member account
- login(): Authenticates and tracks login activity
- updateProfile(): Modifies member information
- verifyAccount(): Verifies college ID for authentication

---

### Class: Follow
```
+------------------------------------------+
|               Follow                     |
+------------------------------------------+
| - FollowID: int {PK}                    |
| - FollowerID: int {FK -> Member}        |
| - FollowingID: int {FK -> Member}       |
| - FollowDate: datetime                   |
+------------------------------------------+
| + followUser()                           |
| + unfollowUser()                         |
| + getFollowerCount()                     |
| + getFollowingCount()                    |
+------------------------------------------+
```

**Relationships:**
- Self-referential many-to-many relationship on Member
- A member can follow many other members
- A member can be followed by many other members

**Constraints:**
- Cannot follow yourself (FollowerID != FollowingID)
- Unique combination of (FollowerID, FollowingID)

---

## UML Diagram 2: Content Management System

### Class: Post
```
+------------------------------------------+
|                Post                      |
+------------------------------------------+
| - PostID: int {PK}                      |
| - MemberID: int {FK -> Member}          |
| - Content: text                          |
| - MediaURL: string                       |
| - MediaType: enum                        |
| - PostDate: datetime                     |
| - LastEditDate: datetime                 |
| - Visibility: enum                       |
| - IsActive: boolean                      |
| - LikeCount: int                         |
| - CommentCount: int                      |
+------------------------------------------+
| + createPost()                           |
| + editPost()                             |
| + deletePost()                           |
| + getLikes()                             |
| + getComments()                          |
+------------------------------------------+
```

**Attributes Explanation:**
- **MediaType**: ENUM('Image', 'Video', 'Document', 'None')
- **Visibility**: ENUM('Public', 'Followers', 'Private')
- **LikeCount, CommentCount**: Denormalized for performance

---

### Class: Comment
```
+------------------------------------------+
|              Comment                     |
+------------------------------------------+
| - CommentID: int {PK}                   |
| - PostID: int {FK -> Post}              |
| - MemberID: int {FK -> Member}          |
| - Content: text                          |
| - CommentDate: datetime                  |
| - LastEditDate: datetime                 |
| - IsActive: boolean                      |
| - LikeCount: int                         |
+------------------------------------------+
| + addComment()                           |
| + editComment()                          |
| + deleteComment()                        |
| + getLikes()                             |
+------------------------------------------+
```

**Relationships:**
- Many-to-one with Post (one post has many comments)
- Many-to-one with Member (one member creates many comments)

---

### Class: Like
```
+------------------------------------------+
|                Like                      |
+------------------------------------------+
| - LikeID: int {PK}                      |
| - MemberID: int {FK -> Member}          |
| - TargetType: enum                       |
| - TargetID: int                          |
| - LikeDate: datetime                     |
+------------------------------------------+
| + addLike()                              |
| + removeLike()                           |
| + checkIfLiked()                         |
+------------------------------------------+
```

**Special Design:**
- **Polymorphic relationship**: Can like both Posts and Comments
- **TargetType**: ENUM('Post', 'Comment')
- **TargetID**: References PostID or CommentID based on TargetType
- Unique constraint on (MemberID, TargetType, TargetID)

---

## UML Diagram 3: Moderation & Reporting System

### Class: Report
```
+------------------------------------------+
|               Report                     |
+------------------------------------------+
| - ReportID: int {PK}                    |
| - ReporterID: int {FK -> Member}        |
| - ReportedItemType: enum                 |
| - ReportedItemID: int                    |
| - Reason: text                           |
| - Status: enum                           |
| - ReportDate: datetime                   |
| - ReviewedBy: int {FK -> Member}        |
| - ReviewDate: datetime                   |
| - Action: string                         |
+------------------------------------------+
| + createReport()                         |
| + reviewReport()                         |
| + resolveReport()                        |
| + dismissReport()                        |
+------------------------------------------+
```

**Attributes Explanation:**
- **ReportedItemType**: ENUM('Post', 'Comment', 'Member')
- **Status**: ENUM('Pending', 'Reviewed', 'Resolved', 'Dismissed')
- **ReviewedBy**: FK to Member (typically Admin/Faculty role)

**Constraints:**
- Pending reports must have NULL ReviewedBy
- Non-pending reports must have ReviewedBy set

---

## UML Diagram 4: Group Management System

### Class: Group
```
+------------------------------------------+
|               Group                      |
+------------------------------------------+
| - GroupID: int {PK}                     |
| - Name: string                           |
| - Description: text                      |
| - CreatorID: int {FK -> Member}         |
| - CreateDate: datetime                   |
| - IsActive: boolean                      |
| - Category: enum                         |
| - MemberCount: int                       |
+------------------------------------------+
| + createGroup()                          |
| + updateGroup()                          |
| + deleteGroup()                          |
| + addMember()                            |
| + removeMember()                         |
+------------------------------------------+
```

**Attributes Explanation:**
- **Category**: ENUM('Academic', 'Sports', 'Cultural', 'Tech', 'Other')
- **MemberCount**: Denormalized count of group members

---

### Class: GroupMember
```
+------------------------------------------+
|            GroupMember                   |
+------------------------------------------+
| - GroupMemberID: int {PK}               |
| - GroupID: int {FK -> Group}            |
| - MemberID: int {FK -> Member}          |
| - Role: enum                             |
| - JoinDate: datetime                     |
| - IsActive: boolean                      |
+------------------------------------------+
| + joinGroup()                            |
| + leaveGroup()                           |
| + promoteToModerator()                   |
| + promoteToAdmin()                       |
+------------------------------------------+
```

**Relationships:**
- **Bridge table** for many-to-many relationship between Group and Member
- **Role**: ENUM('Admin', 'Moderator', 'Member')
- Unique constraint on (GroupID, MemberID)

---

## UML Diagram 5: Messaging & Notification System

### Class: Message
```
+------------------------------------------+
|              Message                     |
+------------------------------------------+
| - MessageID: int {PK}                   |
| - SenderID: int {FK -> Member}          |
| - ReceiverID: int {FK -> Member}        |
| - Content: text                          |
| - SendDate: datetime                     |
| - IsRead: boolean                        |
| - ReadDate: datetime                     |
| - IsActive: boolean                      |
+------------------------------------------+
| + sendMessage()                          |
| + markAsRead()                           |
| + deleteMessage()                        |
| + getConversation()                      |
+------------------------------------------+
```

**Relationships:**
- Two foreign keys to Member (SenderID and ReceiverID)
- Self-referential but different roles

**Constraints:**
- Cannot message yourself (SenderID != ReceiverID)
- If IsRead is TRUE, ReadDate must be set

---

### Class: Notification
```
+------------------------------------------+
|           Notification                   |
+------------------------------------------+
| - NotificationID: int {PK}              |
| - MemberID: int {FK -> Member}          |
| - Type: enum                             |
| - Content: text                          |
| - ReferenceID: int                       |
| - IsRead: boolean                        |
| - CreateDate: datetime                   |
| - ReadDate: datetime                     |
+------------------------------------------+
| + createNotification()                   |
| + markAsRead()                           |
| + deleteNotification()                   |
| + getUnreadCount()                       |
+------------------------------------------+
```

**Attributes Explanation:**
- **Type**: ENUM('Like', 'Comment', 'Follow', 'Mention', 'GroupInvite', 'Report')
- **ReferenceID**: Points to the related entity (PostID, CommentID, etc.)

---

## UML Diagram 6: Activity Tracking System

### Class: ActivityLog
```
+------------------------------------------+
|           ActivityLog                    |
+------------------------------------------+
| - LogID: int {PK}                       |
| - MemberID: int {FK -> Member}          |
| - ActivityType: enum                     |
| - Details: text                          |
| - IPAddress: string                      |
| - Timestamp: datetime                    |
+------------------------------------------+
| + logActivity()                          |
| + getActivityHistory()                   |
| + analyzeUserBehavior()                  |
+------------------------------------------+
```

**Attributes Explanation:**
- **ActivityType**: ENUM('Login', 'Logout', 'Post', 'Comment', 'Like', 'Report', 'ProfileUpdate')
- **IPAddress**: IPv4 or IPv6 address (VARCHAR(45))
- Used for security auditing and analytics

---

## Relationship Summary

### 1. Member → Post (1:M)
- **Multiplicity**: One member creates many posts
- **Cardinality**: 1..* (Member) to 0..* (Post)
- **Description**: A member can create multiple posts; each post belongs to one member

### 2. Member → Comment (1:M)
- **Multiplicity**: One member creates many comments
- **Cardinality**: 1..* (Member) to 0..* (Comment)
- **Description**: A member can write multiple comments

### 3. Post → Comment (1:M)
- **Multiplicity**: One post has many comments
- **Cardinality**: 1..* (Post) to 0..* (Comment)
- **Description**: A post can have multiple comments; each comment belongs to one post

### 4. Member → Like (1:M)
- **Multiplicity**: One member creates many likes
- **Cardinality**: 1..* (Member) to 0..* (Like)
- **Description**: A member can like multiple posts/comments

### 5. Member → Follow (M:M)
- **Multiplicity**: Many-to-many self-referential
- **Cardinality**: 0..* to 0..*
- **Description**: Members can follow and be followed by other members

### 6. Member → Report (1:M)
- **Multiplicity**: One member creates many reports
- **Cardinality**: 1..* (Member as Reporter) to 0..* (Report)
- **Additional**: One member (admin) reviews many reports

### 7. Group ↔ Member (M:M through GroupMember)
- **Multiplicity**: Many-to-many
- **Bridge Entity**: GroupMember
- **Cardinality**: 0..* (Group) to 0..* (Member)
- **Description**: A group has many members; a member can join many groups

### 8. Member → Message (1:M)
- **Multiplicity**: One member sends/receives many messages
- **Cardinality**: 1..* (Member) to 0..* (Message)
- **Description**: Two relationships - as sender and as receiver

### 9. Member → Notification (1:M)
- **Multiplicity**: One member receives many notifications
- **Cardinality**: 1..* (Member) to 0..* (Notification)

### 10. Member → ActivityLog (1:M)
- **Multiplicity**: One member has many activity logs
- **Cardinality**: 1..* (Member) to 0..* (ActivityLog)

### 11. Group → GroupMember (1:M)
- **Multiplicity**: One group has many group members
- **Cardinality**: 1..* (Group) to 0..* (GroupMember)

---

## UML Design Patterns Used

### 1. **Association**
- Simple relationships between classes (e.g., Member → Post)

### 2. **Composition**
- Strong ownership relationship
- Example: Post → Comment (comments cannot exist without posts)

### 3. **Aggregation**
- Weak ownership relationship
- Example: Group → GroupMember (members can exist without groups)

### 4. **Self-Referential Association**
- Member → Follow (members follow other members)

### 5. **Polymorphic Association**
- Like can reference both Post and Comment using TargetType discriminator

---

## Key UML Notation

### Multiplicity Symbols:
- **1**: Exactly one
- **0..1**: Zero or one
- **0..***: Zero or many
- **1..***: One or many
- **M..N**: Between M and N

### Relationship Types:
- **→**: Association (one-way)
- **↔**: Association (bidirectional)
- **◆**: Composition (filled diamond)
- **◇**: Aggregation (hollow diamond)
- **△**: Inheritance/Generalization

---

## Diagram Drawing Instructions

When creating visual UML diagrams using tools like draw.io or Lucidchart:

1. **Classes**: Draw as rectangles with three compartments:
   - Top: Class name (bold)
   - Middle: Attributes with types and constraints
   - Bottom: Methods/operations

2. **Relationships**: Draw as lines connecting classes:
   - Add multiplicity labels at both ends
   - Use appropriate arrow heads for directionality
   - Label the relationship with a verb phrase

3. **Constraints**: Show in curly braces {PK}, {FK}, {unique}

4. **Layout**: Arrange classes logically:
   - Core entities (Member, Post) in the center
   - Related entities grouped nearby
   - Minimize line crossings

---

## End of UML Documentation
