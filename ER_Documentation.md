# College Social Media Platform - ER Diagram Documentation
## CS 432 - Databases Assignment 1 (Module B)
## IIT Gandhinagar - February 4, 2026

---

## Entity-Relationship (ER) Diagram

### Overview
This document provides the ER diagram structure for the College Social Media Platform, derived from the UML class diagrams. The ER model represents entities, their attributes, relationships, and cardinalities according to standard ER notation.

---

## ER Notation Guide

### Entity Representation:
```
┌─────────────────┐
│     ENTITY      │  ← Rectangle
│                 │
│  Attributes...  │
└─────────────────┘
```

### Relationship Representation:
```
       ◇
      / \
     /   \
    /  REL \  ← Diamond
    \     /
     \   /
      \ /
       ◇
```

### Attribute Notation:
- **Underlined**: Primary Key
- **Dashed underline**: Foreign Key
- **Bold**: NOT NULL
- *(attribute)*: Optional/nullable

---

## Entity 1: MEMBER

```
┌───────────────────────────────────────┐
│             MEMBER                     │
├───────────────────────────────────────┤
│ MemberID (PK)                         │ ← Underlined = Primary Key
│ Name (NOT NULL)                       │
│ Email (UNIQUE, NOT NULL)              │
│ ContactNumber (NOT NULL)              │
│ Age (NOT NULL)                        │
│ Image                                 │
│ CollegeID (UNIQUE, NOT NULL)          │
│ Role (NOT NULL)                       │
│ Department (NOT NULL)                 │
│ IsVerified (NOT NULL)                 │
│ JoinDate (NOT NULL)                   │
│ LastLogin                             │
│ Bio                                   │
└───────────────────────────────────────┘
```

**Entity Type**: Strong entity
**Primary Key**: MemberID (surrogate key)
**Candidate Keys**: Email, CollegeID
**Domain Constraints**:
- Age: 16 ≤ Age ≤ 100
- Email: Must match pattern '%@%.%'
- Role: {Student, Faculty, Staff, Admin}

---

## Entity 2: POST

```
┌───────────────────────────────────────┐
│              POST                      │
├───────────────────────────────────────┤
│ PostID (PK)                           │
│ MemberID (FK) (NOT NULL)              │
│ Content (NOT NULL)                    │
│ MediaURL                              │
│ MediaType (NOT NULL)                  │
│ PostDate (NOT NULL)                   │
│ LastEditDate                          │
│ Visibility (NOT NULL)                 │
│ IsActive (NOT NULL)                   │
│ LikeCount (NOT NULL)                  │
│ CommentCount (NOT NULL)               │
└───────────────────────────────────────┘
```

**Entity Type**: Weak entity (depends on MEMBER)
**Primary Key**: PostID
**Foreign Key**: MemberID → MEMBER(MemberID)
**Domain Constraints**:
- MediaType: {Image, Video, Document, None}
- Visibility: {Public, Followers, Private}
- LikeCount, CommentCount: ≥ 0
- Content: Cannot be empty string

---

## Entity 3: COMMENT

```
┌───────────────────────────────────────┐
│            COMMENT                     │
├───────────────────────────────────────┤
│ CommentID (PK)                        │
│ PostID (FK) (NOT NULL)                │
│ MemberID (FK) (NOT NULL)              │
│ Content (NOT NULL)                    │
│ CommentDate (NOT NULL)                │
│ LastEditDate                          │
│ IsActive (NOT NULL)                   │
│ LikeCount (NOT NULL)                  │
└───────────────────────────────────────┘
```

**Entity Type**: Weak entity (depends on POST and MEMBER)
**Primary Key**: CommentID
**Foreign Keys**:
- PostID → POST(PostID)
- MemberID → MEMBER(MemberID)

---

## Entity 4: LIKE

```
┌───────────────────────────────────────┐
│              LIKE                      │
├───────────────────────────────────────┤
│ LikeID (PK)                           │
│ MemberID (FK) (NOT NULL)              │
│ TargetType (NOT NULL)                 │
│ TargetID (NOT NULL)                   │
│ LikeDate (NOT NULL)                   │
└───────────────────────────────────────┘
```

**Entity Type**: Associative entity (weak)
**Primary Key**: LikeID
**Composite Unique Key**: (MemberID, TargetType, TargetID)
**Foreign Key**: MemberID → MEMBER(MemberID)
**Special**: Polymorphic relationship
- TargetType: {Post, Comment}
- TargetID references PostID or CommentID based on TargetType

---

## Entity 5: FOLLOW

```
┌───────────────────────────────────────┐
│             FOLLOW                     │
├───────────────────────────────────────┤
│ FollowID (PK)                         │
│ FollowerID (FK) (NOT NULL)            │
│ FollowingID (FK) (NOT NULL)           │
│ FollowDate (NOT NULL)                 │
└───────────────────────────────────────┘
```

**Entity Type**: Associative entity for M:M relationship
**Primary Key**: FollowID
**Composite Unique Key**: (FollowerID, FollowingID)
**Foreign Keys**:
- FollowerID → MEMBER(MemberID)
- FollowingID → MEMBER(MemberID)
**Constraint**: FollowerID ≠ FollowingID (no self-following)

---

## Entity 6: REPORT

```
┌───────────────────────────────────────┐
│             REPORT                     │
├───────────────────────────────────────┤
│ ReportID (PK)                         │
│ ReporterID (FK) (NOT NULL)            │
│ ReportedItemType (NOT NULL)           │
│ ReportedItemID (NOT NULL)             │
│ Reason (NOT NULL)                     │
│ Status (NOT NULL)                     │
│ ReportDate (NOT NULL)                 │
│ ReviewedBy (FK)                       │
│ ReviewDate                            │
│ Action                                │
└───────────────────────────────────────┘
```

**Entity Type**: Strong entity
**Primary Key**: ReportID
**Foreign Keys**:
- ReporterID → MEMBER(MemberID)
- ReviewedBy → MEMBER(MemberID)
**Domain Constraints**:
- ReportedItemType: {Post, Comment, Member}
- Status: {Pending, Reviewed, Resolved, Dismissed}
- If Status = 'Pending', then ReviewedBy IS NULL

---

## Entity 7: GROUP

```
┌───────────────────────────────────────┐
│             GROUP                      │
├───────────────────────────────────────┤
│ GroupID (PK)                          │
│ Name (NOT NULL)                       │
│ Description (NOT NULL)                │
│ CreatorID (FK) (NOT NULL)             │
│ CreateDate (NOT NULL)                 │
│ IsActive (NOT NULL)                   │
│ Category (NOT NULL)                   │
│ MemberCount (NOT NULL)                │
└───────────────────────────────────────┘
```

**Entity Type**: Strong entity
**Primary Key**: GroupID
**Foreign Key**: CreatorID → MEMBER(MemberID)
**Domain Constraints**:
- Category: {Academic, Sports, Cultural, Tech, Other}
- MemberCount: ≥ 0

---

## Entity 8: GROUP_MEMBER

```
┌───────────────────────────────────────┐
│          GROUP_MEMBER                  │
├───────────────────────────────────────┤
│ GroupMemberID (PK)                    │
│ GroupID (FK) (NOT NULL)               │
│ MemberID (FK) (NOT NULL)              │
│ Role (NOT NULL)                       │
│ JoinDate (NOT NULL)                   │
│ IsActive (NOT NULL)                   │
└───────────────────────────────────────┘
```

**Entity Type**: Associative entity for M:M relationship
**Primary Key**: GroupMemberID
**Composite Unique Key**: (GroupID, MemberID)
**Foreign Keys**:
- GroupID → GROUP(GroupID)
- MemberID → MEMBER(MemberID)
**Domain Constraints**:
- Role: {Admin, Moderator, Member}

---

## Entity 9: MESSAGE

```
┌───────────────────────────────────────┐
│            MESSAGE                     │
├───────────────────────────────────────┤
│ MessageID (PK)                        │
│ SenderID (FK) (NOT NULL)              │
│ ReceiverID (FK) (NOT NULL)            │
│ Content (NOT NULL)                    │
│ SendDate (NOT NULL)                   │
│ IsRead (NOT NULL)                     │
│ ReadDate                              │
│ IsActive (NOT NULL)                   │
└───────────────────────────────────────┘
```

**Entity Type**: Strong entity
**Primary Key**: MessageID
**Foreign Keys**:
- SenderID → MEMBER(MemberID)
- ReceiverID → MEMBER(MemberID)
**Constraints**:
- SenderID ≠ ReceiverID (cannot message yourself)
- If IsRead = TRUE, then ReadDate IS NOT NULL

---

## Entity 10: NOTIFICATION

```
┌───────────────────────────────────────┐
│          NOTIFICATION                  │
├───────────────────────────────────────┤
│ NotificationID (PK)                   │
│ MemberID (FK) (NOT NULL)              │
│ Type (NOT NULL)                       │
│ Content (NOT NULL)                    │
│ ReferenceID                           │
│ IsRead (NOT NULL)                     │
│ CreateDate (NOT NULL)                 │
│ ReadDate                              │
└───────────────────────────────────────┘
```

**Entity Type**: Weak entity (depends on MEMBER)
**Primary Key**: NotificationID
**Foreign Key**: MemberID → MEMBER(MemberID)
**Domain Constraints**:
- Type: {Like, Comment, Follow, Mention, GroupInvite, Report}

---

## Entity 11: ACTIVITY_LOG

```
┌───────────────────────────────────────┐
│          ACTIVITY_LOG                  │
├───────────────────────────────────────┤
│ LogID (PK)                            │
│ MemberID (FK) (NOT NULL)              │
│ ActivityType (NOT NULL)               │
│ Details (NOT NULL)                    │
│ IPAddress                             │
│ Timestamp (NOT NULL)                  │
└───────────────────────────────────────┘
```

**Entity Type**: Weak entity (depends on MEMBER)
**Primary Key**: LogID
**Foreign Key**: MemberID → MEMBER(MemberID)
**Domain Constraints**:
- ActivityType: {Login, Logout, Post, Comment, Like, Report, ProfileUpdate}

---

## ER Relationships

### Relationship 1: CREATES (Member → Post)

```
MEMBER ──────────< CREATES >──────────── POST
  1                                      M

Cardinality: 1:M (One-to-Many)
```

**Relationship Details:**
- **Name**: CREATES
- **Participating Entities**: MEMBER (1), POST (M)
- **Cardinality**: 1:M
- **Participation**: Total participation from POST (every post must have a creator)
- **Attributes**: None (creation date stored in POST entity)
- **Mapping**: Foreign key MemberID in POST table

**Description**: One member creates many posts. Each post is created by exactly one member.

---

### Relationship 2: WRITES (Member → Comment)

```
MEMBER ──────────< WRITES >──────────── COMMENT
  1                                       M

Cardinality: 1:M
```

**Relationship Details:**
- **Name**: WRITES
- **Participating Entities**: MEMBER (1), COMMENT (M)
- **Cardinality**: 1:M
- **Participation**: Total from COMMENT
- **Mapping**: Foreign key MemberID in COMMENT table

**Description**: One member writes many comments. Each comment is written by exactly one member.

---

### Relationship 3: HAS_COMMENT (Post → Comment)

```
POST ──────────< HAS_COMMENT >──────────── COMMENT
  1                                           M

Cardinality: 1:M
```

**Relationship Details:**
- **Name**: HAS_COMMENT
- **Participating Entities**: POST (1), COMMENT (M)
- **Cardinality**: 1:M
- **Participation**: Total from COMMENT (every comment belongs to a post)
- **Deletion**: Cascade (if post deleted, comments deleted)
- **Mapping**: Foreign key PostID in COMMENT table

**Description**: One post has many comments. Each comment belongs to exactly one post.

---

### Relationship 4: GIVES_LIKE (Member → Like)

```
MEMBER ──────────< GIVES_LIKE >──────────── LIKE
  1                                           M

Cardinality: 1:M
```

**Relationship Details:**
- **Name**: GIVES_LIKE
- **Participating Entities**: MEMBER (1), LIKE (M)
- **Cardinality**: 1:M
- **Participation**: Total from LIKE
- **Mapping**: Foreign key MemberID in LIKE table

**Description**: One member gives many likes. Each like is given by exactly one member.

---

### Relationship 5: FOLLOWS (Member → Member)

```
        ┌─────────────────┐
        │     MEMBER      │
        └────────┬────────┘
                 │
          ┌──────┴──────┐
          │   FOLLOWS   │ ← Recursive M:M relationship
          │   (M:M)     │
          └──────┬──────┘
                 │
        ┌────────┴────────┐
        │     MEMBER      │
        └─────────────────┘

MEMBER (Follower) ──< FOLLOWS >── MEMBER (Following)
       M                                M

Cardinality: M:M (Many-to-Many)
```

**Relationship Details:**
- **Name**: FOLLOWS
- **Participating Entities**: MEMBER (as Follower), MEMBER (as Following)
- **Cardinality**: M:M
- **Type**: Recursive/Self-referential
- **Participation**: Partial from both sides
- **Associative Entity**: FOLLOW table
- **Attributes**: FollowDate
- **Constraint**: A member cannot follow themselves

**Description**: Members can follow other members and be followed by other members, creating a many-to-many recursive relationship.

---

### Relationship 6: REPORTS (Member → Report)

```
MEMBER ──────────< REPORTS >──────────── REPORT
  1                                        M

Cardinality: 1:M
```

**Relationship Details:**
- **Name**: REPORTS (as Reporter)
- **Participating Entities**: MEMBER (1), REPORT (M)
- **Cardinality**: 1:M
- **Mapping**: Foreign key ReporterID in REPORT table

**Additional Relationship**: REVIEWS
```
MEMBER ──────────< REVIEWS >──────────── REPORT
  1                                        M
```
- **Name**: REVIEWS (as Reviewer)
- **Foreign Key**: ReviewedBy in REPORT table
- **Participation**: Partial (only admins/faculty review)

**Description**: One member can create many reports. One member (admin) can review many reports.

---

### Relationship 7: CREATES_GROUP (Member → Group)

```
MEMBER ──────────< CREATES_GROUP >──────────── GROUP
  1                                              M

Cardinality: 1:M
```

**Relationship Details:**
- **Name**: CREATES_GROUP
- **Participating Entities**: MEMBER (1), GROUP (M)
- **Cardinality**: 1:M
- **Participation**: Total from GROUP
- **Mapping**: Foreign key CreatorID in GROUP table

**Description**: One member creates many groups. Each group has exactly one creator.

---

### Relationship 8: BELONGS_TO (Member ↔ Group)

```
MEMBER ──────< BELONGS_TO >────── GROUP
  M                                  M

Cardinality: M:M (Many-to-Many)
```

**Relationship Details:**
- **Name**: BELONGS_TO / MEMBERSHIP
- **Participating Entities**: MEMBER (M), GROUP (M)
- **Cardinality**: M:M
- **Participation**: Partial from both sides
- **Associative Entity**: GROUP_MEMBER table
- **Attributes**: Role (Admin/Moderator/Member), JoinDate, IsActive

**Description**: A member can belong to many groups. A group can have many members. The relationship has attributes (role, join date).

---

### Relationship 9: SENDS (Member → Message)

```
MEMBER ──────────< SENDS >──────────── MESSAGE
  1                                      M

Cardinality: 1:M
```

**Relationship Details:**
- **Name**: SENDS
- **Participating Entities**: MEMBER (as Sender) (1), MESSAGE (M)
- **Cardinality**: 1:M
- **Mapping**: Foreign key SenderID in MESSAGE table

**Additional Relationship**: RECEIVES
```
MEMBER ──────────< RECEIVES >──────────── MESSAGE
  1                                         M
```
- **Name**: RECEIVES
- **Foreign Key**: ReceiverID in MESSAGE table

**Description**: One member sends many messages. One member receives many messages. Each message has exactly one sender and one receiver.

---

### Relationship 10: RECEIVES_NOTIFICATION (Member → Notification)

```
MEMBER ──────────< RECEIVES_NOTIFICATION >──────────── NOTIFICATION
  1                                                       M

Cardinality: 1:M
```

**Relationship Details:**
- **Name**: RECEIVES_NOTIFICATION
- **Participating Entities**: MEMBER (1), NOTIFICATION (M)
- **Cardinality**: 1:M
- **Participation**: Total from NOTIFICATION
- **Mapping**: Foreign key MemberID in NOTIFICATION table

**Description**: One member receives many notifications. Each notification belongs to exactly one member.

---

### Relationship 11: HAS_ACTIVITY (Member → ActivityLog)

```
MEMBER ──────────< HAS_ACTIVITY >──────────── ACTIVITY_LOG
  1                                              M

Cardinality: 1:M
```

**Relationship Details:**
- **Name**: HAS_ACTIVITY / PERFORMS
- **Participating Entities**: MEMBER (1), ACTIVITY_LOG (M)
- **Cardinality**: 1:M
- **Participation**: Total from ACTIVITY_LOG
- **Mapping**: Foreign key MemberID in ACTIVITY_LOG table

**Description**: One member has many activity log entries. Each log entry belongs to exactly one member.

---

## Complete ER Diagram Relationship Summary

| Relationship | Entity 1 | Cardinality | Entity 2 | Type | Associative Entity |
|--------------|----------|-------------|----------|------|-------------------|
| CREATES | MEMBER | 1:M | POST | Regular | No |
| WRITES | MEMBER | 1:M | COMMENT | Regular | No |
| HAS_COMMENT | POST | 1:M | COMMENT | Regular | No |
| GIVES_LIKE | MEMBER | 1:M | LIKE | Regular | No |
| FOLLOWS | MEMBER | M:M | MEMBER | Recursive | FOLLOW |
| REPORTS | MEMBER | 1:M | REPORT | Regular | No |
| REVIEWS | MEMBER | 1:M | REPORT | Regular | No |
| CREATES_GROUP | MEMBER | 1:M | GROUP | Regular | No |
| BELONGS_TO | MEMBER | M:M | GROUP | Regular | GROUP_MEMBER |
| SENDS | MEMBER | 1:M | MESSAGE | Regular | No |
| RECEIVES | MEMBER | 1:M | MESSAGE | Regular | No |
| RECEIVES_NOTIF | MEMBER | 1:M | NOTIFICATION | Regular | No |
| HAS_ACTIVITY | MEMBER | 1:M | ACTIVITY_LOG | Regular | No |

---

## UML to ER Transformation

### Transformation Rules Applied:

1. **UML Classes → ER Entities**
   - Each UML class becomes an ER entity
   - Class attributes → Entity attributes
   - Methods are not represented in ER (implementation details)

2. **UML Associations → ER Relationships**
   - 1:1 associations → 1:1 relationships
   - 1:M associations → 1:M relationships
   - M:M associations → M:M relationships with associative entities

3. **UML Multiplicity → ER Cardinality**
   - UML 1..* → ER 1:M
   - UML 0..* → ER M with partial participation
   - UML 1 → ER 1 with total participation

4. **UML Composition → ER with Cascade Delete**
   - Strong ownership in UML → ON DELETE CASCADE in database

5. **UML Primary Keys → ER Primary Keys**
   - Underlined in ER diagrams
   - Uniquely identifies each entity instance

6. **UML Foreign Keys → ER Foreign Keys**
   - Dashed underline in ER diagrams
   - Implements relationships between entities

---

## Constraints Summary

### Primary Key Constraints:
- Every entity has exactly one primary key
- All tables use surrogate integer keys (auto-increment)

### Foreign Key Constraints:
- **ON DELETE CASCADE**: POST, COMMENT, LIKE, FOLLOW, GROUP_MEMBER, MESSAGE, NOTIFICATION, ACTIVITY_LOG
- **ON DELETE SET NULL**: REPORT.ReviewedBy

### Referential Integrity:
- All foreign keys reference valid primary keys
- Deletion of referenced entity cascades or sets null as appropriate

### CHECK Constraints:
- Age: 16-100 range
- LikeCount, CommentCount, MemberCount: ≥ 0
- Content fields: Cannot be empty strings
- Self-referential constraints: No self-following, no self-messaging
- Logical constraints: ReadDate requires IsRead=TRUE

### UNIQUE Constraints:
- Member: Email, CollegeID
- Follow: (FollowerID, FollowingID)
- Like: (MemberID, TargetType, TargetID)
- GroupMember: (GroupID, MemberID)

### NOT NULL Constraints:
- Every table has at least 3 NOT NULL columns (requirement satisfied)
- Critical fields like IDs, names, dates are NOT NULL

---

## Key Insights for ER Diagram Drawing

When creating the visual ER diagram:

1. **Central Entity**: Place MEMBER at the center (most relationships)

2. **Grouping**:
   - Content group: POST, COMMENT, LIKE
   - Social group: FOLLOW, MESSAGE, NOTIFICATION
   - Moderation group: REPORT, ACTIVITY_LOG
   - Community group: GROUP, GROUP_MEMBER

3. **Relationship Diamonds**: Draw clearly between entities

4. **Cardinality Labels**: 
   - Place 1, M, or M:M near entity boxes
   - Add participation constraints (total = double line, partial = single line)

5. **Attributes**: List inside entity boxes with proper notation

6. **Legend**: Include key showing PK, FK, NOT NULL notation

---

## End of ER Documentation
