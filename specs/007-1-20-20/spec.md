# Feature Specification: Command Library Multi-Column Layout

**Feature Branch**: `007-1-20-20`
**Created**: 2025-10-17
**Status**: Draft
**Input**: User description: "命令库部分增加列数选项,包括1-20列自由选择,这样一行最多可以显示20列,但这个要确保整体显示尺寸不出错,字体可以跟着变小,但要可读"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Column Count Selection (Priority: P1)

As a user managing a large command library, I want to adjust the number of columns displayed (1-20 columns) so that I can view more commands at once on wide screens or focus on fewer commands on narrow screens.

**Why this priority**: This is the core functionality that enables users to optimize their screen real estate based on their display size and command quantity. Without column selection, users cannot take advantage of the multi-column layout feature.

**Independent Test**: Can be fully tested by adding a column selector control, selecting different column counts (1, 5, 10, 20), and verifying that commands reflow into the selected number of columns. Delivers immediate value by allowing users to customize their view.

**Acceptance Scenarios**:

1. **Given** I am viewing the command library, **When** I select "1 column" from the column selector, **Then** all commands display in a single vertical column
2. **Given** I am viewing the command library, **When** I select "10 columns" from the column selector, **Then** commands are distributed across 10 columns horizontally
3. **Given** I am viewing the command library, **When** I select "20 columns" from the column selector, **Then** commands are distributed across 20 columns with appropriately scaled font sizes
4. **Given** I have selected a column count, **When** I reload the page, **Then** my column count preference persists

---

### User Story 2 - Responsive Font Scaling (Priority: P2)

As a user who selects many columns, I want the font size to automatically adjust so that command text remains readable even when displaying 15-20 columns simultaneously.

**Why this priority**: Essential for usability when users select high column counts. Without font scaling, text would become illegibly small or cause horizontal overflow. This is secondary to P1 because column selection must exist first.

**Independent Test**: Can be tested by selecting progressively higher column counts (5, 10, 15, 20) and verifying that font sizes decrease proportionally while maintaining minimum readability thresholds. Delivers value by ensuring text remains legible at all column counts.

**Acceptance Scenarios**:

1. **Given** I select 1-5 columns, **When** commands are displayed, **Then** font size remains at the standard size
2. **Given** I select 6-10 columns, **When** commands are displayed, **Then** font size decreases moderately while maintaining readability
3. **Given** I select 11-20 columns, **When** commands are displayed, **Then** font size decreases further but never falls below the minimum readable size
4. **Given** any column count, **When** I view command text, **Then** all text remains readable without horizontal scrolling

---

### User Story 3 - Layout Integrity Across Column Counts (Priority: P3)

As a user switching between different column counts, I want the overall layout to remain stable and properly sized so that the interface never breaks or requires horizontal scrolling.

**Why this priority**: Ensures professional appearance and prevents layout bugs. This is tertiary because it's a quality/polish concern that builds on P1 and P2 - the feature can function without perfect layout management, but this makes it production-ready.

**Independent Test**: Can be tested by rapidly switching between all column counts (1-20) and verifying that the container always fits within the viewport, no elements overflow, and vertical scrolling still works smoothly. Delivers value by ensuring a polished, bug-free experience.

**Acceptance Scenarios**:

1. **Given** any column count from 1-20, **When** commands are displayed, **Then** the command library container fits within the viewport width without horizontal scrolling
2. **Given** I switch from 2 columns to 20 columns, **When** the layout reflows, **Then** all command items remain fully visible and properly aligned
3. **Given** I have 100+ commands displayed, **When** I change column count, **Then** vertical scrolling continues to work smoothly without layout shifts
4. **Given** I resize my browser window, **When** the window is narrower than the selected column count can accommodate, **Then** the layout gracefully reduces columns or adjusts sizing

---

### Edge Cases

- What happens when the user selects 20 columns on a narrow mobile screen (320px-640px)?
- How does the system handle very long command labels or text that exceed column width?
- What happens when there are fewer commands than the selected column count (e.g., 5 commands but 10 columns selected)?
- How does the column layout interact with the existing category grouping and color-coding features?
- What happens when a user's saved preference is an invalid column count (e.g., corrupted data or future version mismatch)?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a column count selector with options from 1 to 20 columns
- **FR-002**: System MUST display commands in the selected number of columns, distributing them evenly across columns
- **FR-003**: System MUST persist the user's column count preference so it remains active across page reloads
- **FR-004**: System MUST automatically scale font sizes based on column count to maintain readability
- **FR-005**: System MUST ensure the command library container never exceeds viewport width, regardless of column count
- **FR-006**: System MUST maintain a minimum font size threshold (e.g., equivalent to 12px) even at 20 columns to ensure readability
- **FR-007**: System MUST preserve existing category grouping when displaying in multi-column layout
- **FR-008**: System MUST handle command text overflow within columns (truncate or wrap without breaking layout)
- **FR-009**: System MUST provide visual feedback when column count is changed (smooth transition or immediate reflow)
- **FR-010**: System MUST default to a reasonable column count (e.g., 3-4 columns) when no preference is saved

### Modularity Requirements *(新增 / NEW - Constitution Principle VI)*

- **MR-001**: Feature MUST be implemented as 3 function groups (pseudo-modules): layout*, column*, render*
- **MR-002**: Function naming MUST follow conventions: layout* for column calculations, column* for preference management, render* for UI updates
- **MR-003**: Function dependencies: render* functions can call layout* and column* functions; layout* functions are pure calculations; column* functions handle data persistence only
- **MR-004**: Each function group will have dedicated test section in manual tests

### Separation of Concerns Requirements *(新增 / NEW - Constitution Principle VII)*

- **SC-001**: Feature touches all three layers: Data (column preference persistence), Business (column layout calculations), Presentation (command grid rendering)
- **SC-002**: Layers communicate via function calls: Presentation → Business → Data (one-way flow)
- **SC-003**: Prohibited patterns: render* functions MUST NOT directly call localStorage; layout* functions MUST NOT manipulate DOM; column* functions MUST NOT contain layout logic

### Key Entities *(include if feature involves data)*

- **ColumnPreference**: Represents the user's saved column count setting (integer 1-20), stored persistently so the preference is retained across sessions
- **ColumnLayout**: Represents the calculated layout parameters for a given column count, including column width percentages, font scaling factors, and responsive breakpoints

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can select any column count from 1 to 20 and see commands immediately reflow into the selected layout
- **SC-002**: Font sizes scale appropriately so that text remains readable at all column counts, with no text smaller than 12px equivalent
- **SC-003**: Command library layout never causes horizontal scrolling on any column count from 1-20
- **SC-004**: Column count preference persists across page reloads with 100% reliability
- **SC-005**: Users can switch between any two column counts in under 1 second with smooth visual transition
- **SC-006**: At 20 columns on a 1920px display, individual command items are at least 80px wide and text remains legible
- **SC-007**: Existing features (category colors, search, drag-and-drop) continue to work correctly in all column layouts

## Assumptions *(optional)*

- Users primarily use desktop displays (1280px-2560px) when selecting high column counts (10-20 columns)
- Most users will prefer 3-6 columns for typical workflows, with 10-20 columns being "power user" options
- The existing command item structure (label + text + actions) can be scaled down to fit narrower columns
- Minimum readable font size is 12px (0.75rem) for labels and 11px (0.6875rem) for command text
- Column preference is device-specific (not synced across devices) - users may prefer different column counts on desktop vs laptop
- The feature will use CSS Grid or Flexbox for column layout (flexible enough to adapt to any column count)
- Command categories should stay together within columns when possible, but can span multiple columns if needed

## Dependencies *(optional)*

- Depends on existing command library rendering functionality (Feature 006: color-coded categories and density optimization)
- Requires existing localStorage infrastructure for preference persistence
- Must integrate with existing category grouping logic (commands grouped by category)
- Must preserve drag-and-drop functionality within multi-column layout

## Out of Scope *(optional)*

- Automatic column count selection based on screen size (user must manually select column count)
- Per-category column count settings (all categories use the same column count)
- Column width customization (columns are always equal width)
- Horizontal scrolling mode (layout must always fit within viewport)
- Column count synchronization across devices
- Custom column layouts (e.g., pinning certain commands to specific columns)
- Responsive column count that automatically adjusts on window resize (static once selected)
