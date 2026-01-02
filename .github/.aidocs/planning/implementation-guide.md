# The Library App - Implementation Guide

**Date:** 2025-11-22
**App:** The Library
**Project Plan:** [the-library-app-plan.md](./the-library-app-plan.md)
**Repository:** TheLibrary

## Overview

This guide provides instructions for implementing The Library Business Central AL app following the AL Vibe Coding Rules framework.

## Prerequisites

### 1. Workspace Setup

Set bc-code-intel workspace context:

```
Workspace root: [path to repo]\TheLibrary
App source: [path to repo]\TheLibrary\App
```

### 2. Read Project Context

- [Project Plan](./the-library-app-plan.md) - Complete domain model and objectives
- [AL Vibe Coding Rules](https://alguidelines.dev/docs/agentic-coding/vibe-coding-rules/) - AL best practices
- `.github/instructions/generic.instructions.md` - Generic workflow guidelines
- `.github/instructions/mcp-servers.instructions.md` - MCP server usage

## Implementation Phases

Based on the project plan, implementation is divided into 4 phases:

### Phase 1: Setup & Master Data Foundation

**Scope:** Library Setup, Author, Genre, Book

**Objects to Create:**

- Table 70300: LIB Library Setup
- Table 70301: LIB Author
- Table 70302: LIB Genre
- Table 70303: LIB Book
- Page 70320: LIB Library Setup
- Page 70321: LIB Author Card
- Page 70322: LIB Author List
- Page 70323: LIB Genre List
- Page 70324: LIB Book Card
- Page 70325: LIB Book List

**Key Features:**

- No. Series configuration for all entities
- Author with optional identifiers (ISNI, ORCID, VIAF ID)
- Genre as master data table
- Book with FlowField placeholder for Available Quantity
- ISBN, ISNI, ORCID format validations
- All fields have Caption and ToolTip properties

### Phase 2: Member Management

**Scope:** Library Member

**Objects to Create:**

- Table 70304: LIB Library Member
- Page 70326: LIB Library Member Card
- Page 70327: LIB Library Member List

**Key Features:**

- No. Series integration
- Membership Type enum
- Email validation
- Active status tracking

### Phase 3: Document Structure

**Scope:** Book Loan Header/Lines

**Objects to Create:**

- Table 70305: LIB Book Loan Header
- Table 70306: LIB Book Loan Line
- Page 70328: LIB Book Loan
- Page 70329: LIB Book Loan List
- Page 70330: LIB Book Loan Subpage

**Key Features:**

- Document header/line pattern
- FlowFields for Member Name, Book Title
- Quantity restricted to 1 per line
- Basic document logic (add/delete lines)

### Phase 4: Posting & Return Processing

**Scope:** Posting, Returns, Ledger Entries

**Objects to Create:**

- Table 70307: Posted LIB Book Loan Header
- Table 70308: Posted LIB Book Loan Line
- Table 70309: LIB Book Loan Ledger Entry
- Page 70331: Posted LIB Book Loan Card
- Page 70332: Posted LIB Book Loan List
- Page 70333: LIB Book Loan Ledger Entries
- Codeunit 70350: LIB Book Loan-Post
- Codeunit 70351: LIB Book Loan-Post (Yes/No)
- Codeunit 70352: LIB Book Return-Post
- Codeunit 70353: LIB Book Return-Post (Yes/No)
- Enum 70370: LIB Membership Type
- Enum 70371: LIB Book Loan Status
- Enum 70372: LIB Book Loan Entry Type

**Key Features:**

- Full posting mechanism (loans)
- Return processing
- Book Available Quantity FlowField calculation
- Rich validation messages
- Ledger entry creation

## AL Coding Standards

### Naming Conventions

- **Prefix:** "LIB" for all custom objects (e.g., "LIB Book", "LIB Member")

### Mandatory Properties

- **Every field:** Caption and ToolTip properties
- **Every object:** Caption property
- **Translatable content:** Use label variables with appropriate suffixes

### AL Vibe Coding Rules

Follow the [AL Vibe Coding Rules](https://alguidelines.dev/docs/agentic-coding/vibe-coding-rules/) for:

- Code structure and organization
- Naming conventions
- Performance optimization patterns
- Error handling approaches
- Testing strategies

### bc-code-intel Consultation

**CRITICAL:** Before using bc-code-intel, set workspace context:

```
mcp_bc-code-intel_set_workspace_info
workspace_root: "[path to repository]\\TheLibrary"
available_mcps: []
```

**Consult bc-code-intel for:**

- No. Series implementation patterns
- Setup table best practices
- TableRelation and lookup patterns
- FlowField CalcFormula syntax
- Document posting patterns
- AL validation approaches
- Format validation (ISBN, ISNI, ORCID)
- Performance optimization

## Agent Workflow

1. **Review Project Plan**
   - Read [the-library-app-plan.md](./the-library-app-plan.md)
   - Understand domain model and phase objectives
   - Consult bc-code-intel for AL capabilities

2. **Create Implementation Plan**
   - Design table structures, page layouts
   - Plan No. Series integration
   - Define field validations
   - Document in `.aidocs/implementation-plans/[phase-name].md`

3. **Create Task Breakdown** (optional)
   - Read implementation plan
   - Break into implementable units if needed
   - Can create task files in `tasks/[phase-name]/task-N.md` for tracking

4. **Implement AL Code**
   - Consult bc-code-intel as needed
   - Implement AL code following AL Vibe rules
   - Create unit tests (80%+ coverage)
   - Verify code analysis clean
   - Create PR when phase is complete

5. **Testing & Validation**
   - Run all tests in PR pipeline
   - Verify code analysis clean
   - Manual testing of functionality
   - Present for code review

## Key Implementation Details

### Library Setup Table (70300)

- Singleton table (single record with fixed primary key)
- No. Series fields for: Authors, Books, Members, Book Loans, Posted Book Loans
- AssistEdit on page for No. Series selection

### Author Table (70301)

- Primary Key: No. (Code20, auto-assigned via No. Series)
- Required: Name
- Optional identifiers: ISNI (Code16), ORCID (Code19), VIAF ID (Code20)
- Validations:
  - ISNI: 16-digit format
  - ORCID: 19-character format with hyphens (0000-0000-0000-0000)

### Genre Table (70302)

- Primary Key: Code (Code20)
- Description field for genre name
- Simple master data, no auto-numbering

### Book Table (70303)

- Primary Key: No. (Code20, auto-assigned via No. Series)
- TableRelations:
  - Author No. → LIB Author
  - Genre Code → LIB Genre
- Quantity: Total copies owned (Integer)
- Available Quantity: FlowField (Integer)
  - Phase 1: Implement as placeholder field
  - Phase 4: Add CalcFormula from ledger entries
- Validation: ISBN format (basic check for numbers and hyphens)

### Book Loan Document Pattern

- Header/Line structure like Sales Orders
- Line Quantity fixed at 1.0 (validation required)
- FlowFields for related data (Member Name, Book Title)
- Status enum: Open, Posted
- Posted documents use separate No. Series

### Posting Logic

- Creates Posted Book Loan Header/Lines
- Creates Book Loan Ledger Entries
  - Entry Type: Loan (positive quantity), Return (negative quantity)
- Available Quantity FlowField recalculates automatically
- Rich validation messages for translation demo

## Common Pitfalls to Avoid

1. **Missing bc-code-intel workspace setup** - Always call `set_workspace_info` first
2. **No No. Series integration** - Use standard BC No. Series, not custom logic
3. **Missing Caption/ToolTip** - Every field must have both properties
4. **Wrong identifier casing** - Always use PascalCase, never camelCase
5. **Missing "LIB" prefix** - All custom objects must have the prefix
6. **FlowField in Phase 1** - Implement Available Quantity as placeholder, CalcFormula in Phase 4
7. **Skipping validations** - Implement format checks for ISBN, ISNI, ORCID
8. **Assuming without asking** - Follow generic.instructions.md: ask clarifying questions

## Validation Checklist

Before marking any phase complete:

- [ ] All objects compile without errors
- [ ] Code analysis shows zero warnings
- [ ] All fields have Caption property
- [ ] All user-facing fields have ToolTip property
- [ ] All objects have "LIB" prefix
- [ ] All identifiers use PascalCase
- [ ] No. Series integration working correctly
- [ ] TableRelations configured and working
- [ ] Field validations implemented and tested
- [ ] Format validations working (ISBN, ISNI, ORCID)
- [ ] Unit tests created (80%+ coverage for new code)
- [ ] All tests passing
- [ ] bc-code-intel consulted for AL-specific questions
- [ ] AL Vibe Coding Rules followed

## Translation Demo Preparation

The app is designed for translation workflow demonstrations:

### Translation-Rich Content

- All field captions and tooltips
- Validation error messages
- Confirmation dialogs
- Page instructions and action labels
- Enum value captions

## Getting Help

### Consult bc-code-intel First

For AL-specific questions:

- Implementation patterns
- Naming conventions
- Best practices
- Performance optimization
- Validation approaches

### Review Documentation

- [AL Vibe Coding Rules](https://alguidelines.dev/docs/agentic-coding/vibe-coding-rules/)
- [Project Plan](./the-library-app-plan.md)
- Generic instructions in `.github/instructions/`

### Ask Human

For clarifications on:

- Business requirements
- Domain logic
- Scope questions