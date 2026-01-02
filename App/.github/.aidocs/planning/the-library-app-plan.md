# The Library App - Project Plan

**Created:** 2025-11-22
**Status:** Planning Phase
**App Name:** The Library
**Publisher:** Johannes Wikman
**App ID:** 741887eb-f67b-45e4-9920-c296b52179ce

## Executive Summary

A Business Central AL app designed to demonstrate translation workflows and AL development best practices. The app models a simple library management system with books, members, authors, genres, and book loan transactions.

## Primary Objectives

### 1. Translation Demo Focus

- **Main Goal:** Showcase AL translation workflows (XLIFF Tools)
- **Languages:** English (base code) + Swedish
- **Translation Coverage:** Comprehensive across all object types
  - Field captions on every field
  - ToolTips on every field (following AppSource best practices)
  - Error messages and confirmations
  - UI elements (actions, groups, page instructions)
  - All translatable elements across tables, pages, codeunits

### 2. Development Standards

- **Complexity Level:** Intermediate
- **Target Platform:** Business Central v27.0
- **Runtime:** 16.0
- **ID Range:** 70300-70449 (150 IDs available)
- **Pattern:** Professional BC document pattern (Header/Lines with posting)
- **Compliance:** Follow AL best practices and AppSource guidelines

## Domain Model

### Core Entities

#### 0. **Library Setup** (Setup)

- Singleton setup table
- Fields:
  - Primary Key (Code10, fixed value)
  - Author Nos. (Code20, TableRelation to "No. Series")
  - Book Nos. (Code20, TableRelation to "No. Series")
  - Member Nos. (Code20, TableRelation to "No. Series")
  - Book Loan Nos. (Code20, TableRelation to "No. Series")
  - Posted Book Loan Nos. (Code20, TableRelation to "No. Series")
- Card page for configuration

#### 1. **Author** (Master Data)

- Simple master data table
- Fields:
  - No. (Code20, auto-assigned from No. Series) - primary key
  - Name (Text100)
  - Country (Text50)
  - Biography (Text250)
  - ISNI (Code16) - International Standard Name Identifier (optional)
  - ORCID (Code19) - Open Researcher and Contributor ID (optional, format: 0000-0000-0000-0000)
  - VIAF ID (Code20) - Virtual International Authority File identifier (optional)
- Single card page
- List page
- Validation: ISNI format (16 digits), ORCID format (19 chars with hyphens)

#### 2. **Genre** (Master Data)

- Master data table (not enum)
- Fields: Code, Description
- List page (for selection)

#### 3. **Book** (Master Data)

- Primary inventory-like entity
- Fields:
  - No. (Code20, auto-assigned from No. Series)
  - Title (Text100)
  - Author No. (Code20, TableRelation to Author)
  - ISBN (Code20)
  - Genre Code (Code20, TableRelation to Genre)
  - Publication Year (Integer)
  - Quantity (Integer) - total copies owned
  - Available Quantity (Integer, FlowField) - calculated from ledger entries
  - Description (Text250) - rich translation content
- Card page with FastTabs
- List page
- Validation: ISBN format, prevent negative quantities

#### 4. **Library Member** (Master Data)

- Customer-like entity
- Fields:
  - No. (Code20, auto-assigned from No. Series)
  - Name (Text100)
  - Email (Text80)
  - Phone No. (Text30)
  - Address (Text100)
  - City (Text30)
  - Post Code (Code20)
  - Membership Type (Enum: Regular, Student, Senior)
  - Member Since (Date)
  - Active (Boolean)
- Card page
- List page
- Validation: Email format

#### 5. **Book Loan** (Document - Header/Lines)

**Book Loan Header:**

- Document header table
- Fields:
  - No. (Code20, auto-assigned from No. Series)
  - Member No. (Code20, TableRelation to "LIB Member")
  - Member Name (Text100, FlowField)
  - Loan Date (Date)
  - Expected Return Date (Date)
  - Status (Enum: Open, Posted)
  - No. of Lines (Integer, FlowField)
- Document page
- List page

**Book Loan Line:**

- Document line table
- Fields:
  - Document No. (Code20)
  - Line No. (Integer)
  - Book No. (Code20, TableRelation to "LIB Book")
  - Book Title (Text100, FlowField)
  - Quantity (Decimal, fixed at 1.0) - one book per line
  - Due Date (Date)
- Subpage on Book Loan document
- Validation: Quantity must be 1

**Posted Book Loan Header:**

- Posted document header
- Same structure as Book Loan Header (with auto-assigned Posted No. from No. Series)
- Card page (for viewing posted document)
- List page (archive/history)

**Posted Book Loan Line:**

- Posted document line
- Same structure as Book Loan Line
- Subpage on Posted Book Loan

#### 6. **Book Loan Ledger Entry**

- Transactional log (like Item Ledger Entry)
- Fields:
  - Entry No. (Integer, auto-increment)
  - Book No. (Code20)
  - Member No. (Code20)
  - Posting Date (Date)
  - Document No. (Code20)
  - Entry Type (Enum: Loan, Return)
  - Quantity (Decimal) - positive for loan, negative for return
  - Loan Date (Date) - when book was loaned
  - Due Date (Date) - when book should be returned
  - Return Date (Date) - actual return date (for Return entries)
- List page (read-only)
- Used as CalcFormula source for Book Available Quantity FlowField

### Business Logic

#### Posting Mechanism

- **Book Loan-Post codeunit**
  - Validates header and lines
  - Creates Posted Book Loan Header/Lines (with new Posted No. from No. Series)
  - Creates Book Loan Ledger Entries (Loan type, positive quantity)
  - Book Available Quantity automatically recalculates via FlowField
  - Rich validation messages (for translation demo):
    - "Member %1 is not active"
    - "Book %1 is not available. Available quantity: %2"
    - "Expected return date must be after loan date"
    - "Cannot post empty document"
    - Confirmation: "Do you want to post Book Loan %1?"

#### Return Processing

- **Book Return-Post codeunit**
  - Select posted book loan to return
  - Validate all books being returned
  - Create Book Loan Ledger Entries (Return type, negative quantity)
  - Record actual return date
  - Book Available Quantity automatically recalculates via FlowField
  - Validation messages:
    - "Book %1 has already been returned"
    - "Cannot return book that was not loaned"
    - Confirmation: "Do you want to register return for Posted Book Loan %1?"

#### Validations

- **ISBN Format:** Basic format check (numbers and hyphens)
- **Availability Check:** Cannot loan more books than available (via FlowField)
- **Member Status:** Only active members can loan books
- **Date Logic:** Expected return date must be after loan date
- **Quantity Restriction:** Book Loan Line quantity must be exactly 1
- **Duplicate Prevention:** Cannot add same book twice to one loan document

## Object Structure

### Tables (10 objects)

1. Library Setup (Setup)
2. Author (Master)
3. Genre (Master)
4. Book (Master)
5. Library Member (Master)
6. Book Loan Header (Document)
7. Book Loan Line (Document)
8. Posted Book Loan Header (Posted Document)
9. Posted Book Loan Line (Posted Document)
10. Book Loan Ledger Entry (Ledger)

### Pages (14 objects)

1. Library Setup Card
2. Author Card
3. Author List
4. Genre List
5. Book Card
6. Book List
7. Library Member Card
8. Library Member List
9. Book Loan (Document with subpage)
10. Book Loan List
11. Book Loan Subpage (Lines)
12. Posted Book Loan Card (view posted document with lines subpage)
13. Posted Book Loan List
14. Book Loan Ledger Entries

### Codeunits (4 objects)

1. Book Loan-Post (Posting logic)
2. Book Loan-Post (Yes/No) (Posting with confirmation)
3. Book Return-Post (Return processing logic)
4. Book Return-Post (Yes/No) (Return with confirmation)

### Enums (3 objects)

1. Membership Type (Regular, Student, Senior)
2. Book Loan Status (Open, Posted)
3. Book Loan Entry Type (Loan, Return)

### Total Object Count: ~31 objects (10 tables, 14 pages, 4 codeunits, 3 enums)

## Translation Content Strategy

### Comprehensive Coverage

Every AL object will include extensive translatable content:

1. **Field Captions:** Every field has a caption property
2. **ToolTips:** Every user-facing field has a descriptive ToolTip
3. **Object Captions:** Tables, Pages, Reports
4. **UI Labels:** Actions, Groups, Parts
5. **Messages:** Errors, Warnings, Confirmations, Information
6. **Instructions:** Page instructions and promoted action areas

### Example Translation Scope

- ~50-70 field captions across all tables
- ~50-70 tooltips
- ~10-15 page/table object captions
- ~15-20 action captions
- ~10-15 validation messages
- ~5-10 confirmation/information messages

Total translatable strings: ~150-200 texts

## Development Phases

### Phase 1: Setup & Master Data Foundation

**Scope:** Library Setup, Author, Genre, Book

- Create Library Setup table and page
- Configure No. Series for all entities
- Create Author, Genre, Book tables with all fields, captions, tooltips
- Create pages (cards and lists)
- Implement No. Series integration
- Implement basic validation
- **Outcome:** Configure setup, browse books, authors, genres with auto-numbering

### Phase 2: Member Management

**Scope:** Library Member

- Create member table
- Create member pages
- Implement member validation
- **Outcome:** Manage library members

### Phase 3: Document Structure

**Scope:** Book Loan Header/Lines

- Create document tables
- Create document pages
- Implement basic document logic (add/delete lines)
- **Outcome:** Create book loan documents (not posted yet)

### Phase 4: Posting & Return Processing

**Scope:** Posting, Returns, Ledger Entries

- Create posted document tables
- Create ledger entry table
- Implement posting codeunits (loan and return)
- Configure Book Available Quantity FlowField (CalcFormula from ledger)
- Implement all validation and messaging
- Create Posted Book Loan card page
- **Outcome:** Complete loan and return cycle with posting

## Technical Specifications

### Object ID Allocation (70300-70449)

**Tables (70300-70319):**

- 70300: Library Setup
- 70301: Author
- 70302: Genre
- 70303: Book
- 70304: Library Member
- 70305: Book Loan Header
- 70306: Book Loan Line
- 70307: Posted Book Loan Header
- 70308: Posted Book Loan Line
- 70309: Book Loan Ledger Entry

**Pages (70320-70349):**

- 70320: Library Setup
- 70321: Author Card
- 70322: Author List
- 70323: Genre List
- 70324: Book Card
- 70325: Book List
- 70326: Library Member Card
- 70327: Library Member List
- 70328: Book Loan
- 70329: Book Loan List
- 70330: Book Loan Subpage
- 70331: Posted Book Loan Card
- 70332: Posted Book Loan List
- 70333: Book Loan Ledger Entries

**Codeunits (70350-70369):**

- 70350: Book Loan-Post
- 70351: Book Loan-Post (Yes/No)
- 70352: Book Return-Post
- 70353: Book Return-Post (Yes/No)

**Enums (70370-70379):**

- 70370: Membership Type (Regular, Student, Senior)
- 70371: Book Loan Status (Open, Posted)
- 70372: Book Loan Entry Type (Loan, Return)

### Naming Conventions

- **Prefix:** "LIB" for library objects (e.g., "LIB Book", "LIB Member")
- **Follow AL naming standards:** PascalCase for all identifiers (objects, variables, fields, procedures)
- **Readable names:** Prioritize clarity over brevity

## Success Criteria

- [ ] All objects follow AL best practices
- [ ] Every field has Caption and ToolTip
- [ ] Rich validation messaging for translation demo
- [ ] Full document posting cycle implemented
- [ ] Code is clean, well-structured, and documented
- [ ] Ready for demo presentations

## Future Enhancements (Out of Scope for Initial Version)

- Late fees calculation
- Book reservations/waitlist
- Overdue tracking and notifications
- Reporting (Books on Loan, Overdue Reports, Member Statistics)
- Partial returns (return some books from a loan)
- Email notifications
- API endpoints
- Power Platform integration
