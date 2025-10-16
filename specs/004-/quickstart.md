# Quick Start: Cycle Management for Project Iterations

**Feature**: 004-cycle-management
**Date**: 2025-10-16
**Prerequisites**: Existing Spec Kit project with at least one iteration

## Overview

Cycle management enables you to track multiple review/revision rounds within a single iteration. Each cycle maintains independent data (inputs, notes, completion status), allowing you to iterate on your specification without losing historical versions.

## Key Concepts

### What is a Cycle?

A **cycle** represents a single review/revision round within an iteration. For example:
- **Cycle 1**: Initial specification draft
- **Cycle 2**: After client review and feedback
- **Cycle 3**: Final revision after security audit

### Why Use Cycles?

✅ **Track iteration history**: See how your spec evolved across review rounds
✅ **Preserve old versions**: Each cycle keeps its own inputs and notes
✅ **Flexible workflow**: Add cycles as needed, no upfront planning required
✅ **Data isolation**: Changes in one cycle don't affect others

---

## Getting Started

### 1. Automatic Migration (First Time)

When you first load the updated Spec Kit, **existing iterations will be automatically migrated**:

**Before Migration**:
```
Iteration: "Feature Implementation"
  ├─ Input (specify): "Initial spec text"
  ├─ Note (specify): "Client feedback needed"
  └─ Status: Completed
```

**After Migration**:
```
Iteration: "Feature Implementation"
  └─ Cycle 1: "Initial Cycle - Migrated 2025-10-16"
      ├─ Input (specify): "Initial spec text"
      ├─ Note (specify): "Client feedback needed"
      └─ Status: Completed
```

**No action required** - migration happens automatically and preserves all your data.

---

### 2. Viewing Cycles

When viewing an iteration, you'll see a **Cycle Selector** at the top:

```
┌──────────────────────────────────────────────────┐
│ [Initial Cycle - Migrated 2025-10-16 ▼] ➕ ✏️ 🗑️  │
└──────────────────────────────────────────────────┘
```

- **Dropdown**: Select which cycle to view/edit
- **➕ Button**: Add a new cycle
- **✏️ Button**: Rename current cycle
- **🗑️ Button**: Delete current cycle

---

### 3. Adding Your First New Cycle

**Scenario**: After client review, you need to create a second revision round.

**Steps**:
1. Click the **➕ (Add Cycle)** button
2. Enter cycle name: `"Client Review Round"` (or leave empty for default "Cycle 2")
3. Press **Enter** or click **OK**

**Result**:
- New cycle created and automatically selected
- All workflow steps reset to empty (clean slate for new round)
- Previous cycle preserved with all its data

**UI Changes**:
```
Before:                                    After:
┌─────────────────────────────────┐      ┌─────────────────────────────────┐
│ [Initial Cycle ▼] ➕ ✏️ 🗑️        │      │ [Client Review Round ▼] ➕ ✏️ 🗑️  │
└─────────────────────────────────┘      └─────────────────────────────────┘
                                         │ ├─ Initial Cycle                │
                                         │ └─ Client Review Round (current)│
```

---

### 4. Switching Between Cycles

**Scenario**: You want to reference your original specification while working on the new cycle.

**Steps**:
1. Click the **cycle dropdown**
2. Select **"Initial Cycle"**

**Result**:
- Workflow instantly updates to show Initial Cycle's data
- All inputs, notes, and completion status reflect that cycle
- "Client Review Round" cycle data is preserved but not displayed

**Visual Indicator**:
- Selected cycle shows **(current)** in dropdown
- Cycle selector displays the active cycle name

---

### 5. Renaming a Cycle

**Scenario**: Default name "Cycle 2" isn't descriptive enough.

**Steps**:
1. Select the cycle you want to rename (or keep current if already selected)
2. Click the **✏️ (Rename)** button
3. Enter new name: `"Security Audit Revision"`
4. Press **Enter** or click **OK**

**Result**:
- Cycle name updated immediately in dropdown
- Name persists across all views and page refreshes

---

### 6. Deleting a Cycle

**Scenario**: You created a cycle by mistake or it's no longer relevant.

**Steps**:
1. Select the cycle you want to delete
2. Click the **🗑️ (Delete)** button
3. Read confirmation dialog carefully
4. Click **OK** to confirm (or **Cancel** to abort)

**Result**:
- Cycle removed from dropdown
- All cycle-specific data permanently deleted (inputs, notes, completion status)
- System auto-switches to previous or next cycle

**Safety Features**:
- ❌ Cannot delete if it's the only cycle (minimum 1 cycle required)
- ⚠️ Confirmation dialog warns about permanent data loss
- 🔄 Auto-switch to adjacent cycle if deleting current cycle

---

## Common Workflows

### Workflow A: Specification Iteration

**Use Case**: Refining a specification through multiple review rounds

1. **Initial Draft** (Cycle 1: "Initial Cycle")
   - Write first draft of spec
   - Complete all workflow steps
   - Mark as completed

2. **Client Review** (Cycle 2: "Client Feedback Round")
   - Add new cycle: "Client Feedback Round"
   - Revise spec based on feedback
   - Add notes documenting client requests
   - Complete revised workflow

3. **Security Audit** (Cycle 3: "Security Review")
   - Add new cycle: "Security Review"
   - Incorporate security team feedback
   - Update plan with security requirements
   - Mark final version as completed

**Result**: Full audit trail of specification evolution

---

### Workflow B: Parallel Alternatives

**Use Case**: Exploring multiple design approaches before committing

1. **Baseline** (Cycle 1: "Initial Approach")
   - Document first approach (e.g., REST API)
   - Complete initial plan

2. **Alternative A** (Cycle 2: "GraphQL Approach")
   - Add new cycle: "GraphQL Approach"
   - Document alternative design
   - Compare pros/cons in notes

3. **Alternative B** (Cycle 3: "gRPC Approach")
   - Add new cycle: "gRPC Approach"
   - Document third option
   - Evaluate tradeoffs

4. **Final Decision**
   - Review all three cycles
   - Delete unchosen alternatives (or keep for reference)
   - Rename chosen cycle to "Final Design"

---

### Workflow C: Incremental Refinement

**Use Case**: Continuous improvement over time

1. **MVP** (Cycle 1: "V1.0 - MVP")
   - Minimal viable specification
   - Focus on core requirements

2. **Enhancement** (Cycle 2: "V1.1 - UX Improvements")
   - Add UX feedback
   - Expand on user scenarios

3. **Performance** (Cycle 3: "V1.2 - Performance Tuning")
   - Add performance requirements
   - Document optimization strategies

**Result**: Versioned specification with clear progression

---

## Best Practices

### Naming Conventions

✅ **Good cycle names**:
- Descriptive: "Client Review Round", "Security Audit", "Final Revision"
- Versioned: "V1.0 - Initial", "V2.0 - After Feedback"
- Dated: "2025-10-16 Draft", "November Review"

❌ **Avoid**:
- Generic: "Cycle 2", "Cycle 3" (default names, not meaningful)
- Ambiguous: "Changes", "Updates" (what kind of changes?)
- Too long: Names exceeding 50 characters are truncated

### When to Add a Cycle

✅ **Good reasons to add a cycle**:
- After a major review (client, security, legal)
- When pivoting approach (architectural change)
- When requirements change significantly
- To preserve a milestone version

❌ **Don't add a cycle for**:
- Minor typo fixes (just edit current cycle)
- Work in progress (continue in current cycle)
- Daily updates (cycles are for major revisions)

### Managing Many Cycles

**Recommended**: 3-5 cycles per iteration

**If you have >5 cycles**:
- Consider whether some cycles can be deleted (obsolete drafts)
- Use descriptive names to quickly identify relevant cycles
- Delete early exploratory cycles once direction is decided

**If you have >10 cycles**:
- Pagination activates automatically
- Search/filter helps find cycles quickly
- Consider splitting into separate iterations if representing different features

---

## Data Management

### What Data is Cycle-Specific?

Each cycle maintains **independent copies** of:
- ✅ **Inputs**: Text entered in each workflow step
- ✅ **Notes**: Notes attached to each step
- ✅ **Completion Status**: Which steps are marked complete
- ✅ **Completion Timestamps**: When steps were completed

### What Data is Iteration-Level?

These fields are **shared across all cycles**:
- Iteration name
- Iteration description
- Iteration creation date

### Data Persistence

- **LocalStorage**: Primary storage, works offline
- **Firebase**: Optional sync if authenticated
- **Backup**: Automatic backup before destructive operations (delete)

### Backup and Recovery

**Before deletion**: System creates backup in `localStorage` under key `spec_kit_backup`

**Retention**: Backup retained for 24 hours

**Manual backup**: Export projects via existing export functionality

---

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Add Cycle | *(Click ➕ button)* |
| Rename Cycle | *(Click ✏️ button)* |
| Delete Cycle | *(Click 🗑️ button)* |
| Switch Cycle | *(Use dropdown or arrow keys when focused)* |
| Confirm Inline Edit | **Enter** |
| Cancel Inline Edit | **Escape** |

---

## Troubleshooting

### "Cannot delete the last cycle"

**Problem**: You're trying to delete the only remaining cycle

**Solution**: Each iteration must have at least one cycle. Add a new cycle before deleting the current one, or keep the existing cycle.

---

### Cycle name appears truncated

**Problem**: Long cycle names show "..." in dropdown

**Solution**: Hover over the cycle name to see the full name in a tooltip. Consider shortening the name using the rename function.

---

### Changes not saving

**Problem**: Cycle operations (add/rename/delete) don't persist

**Possible Causes**:
1. **LocalStorage Full**: Browser storage quota exceeded (5-10 MB limit)
   - Solution: Delete old projects or cycles
   - Check browser console for quota errors

2. **Browser Restrictions**: Private/Incognito mode may limit storage
   - Solution: Use normal browsing mode

3. **JavaScript Error**: Check browser console for errors
   - Solution: Refresh page, report bug if persistent

---

### Lost cycle after refresh

**Problem**: Created cycle disappeared after page reload

**Cause**: Save operation failed silently

**Solution**:
1. Check browser console for errors
2. Ensure LocalStorage is enabled
3. Try creating cycle again
4. Contact support if issue persists

---

### Cycles appear out of order

**Problem**: Cycles not sorted chronologically

**Expected Behavior**: Cycles should display in creation order (oldest to newest)

**Solution**:
- This is a bug - cycles should auto-sort by `order` field
- Workaround: Rename cycles with numeric prefixes (1-, 2-, 3-)
- Report issue with screenshot

---

## Performance Expectations

| Operation | Expected Time |
|-----------|---------------|
| Add Cycle | < 5 seconds (3 clicks) |
| Rename Cycle | < 10 seconds (2 clicks + typing) |
| Delete Cycle | < 5 seconds (2 clicks) |
| Switch Cycle | < 100ms (UI update) |
| Load Iteration | < 500ms (up to 20 cycles) |

**If operations are slower**: Check number of cycles (>20 may impact performance)

---

## Next Steps

### After Adding Your First Cycle

1. ✅ Complete the workflow in the new cycle
2. ✅ Switch back to review previous cycle's data
3. ✅ Rename cycles with meaningful names
4. ✅ Delete obsolete or exploratory cycles

### Advanced Usage

1. **Export Cycle Data**: Use existing project export (includes all cycles)
2. **Share Iterations**: Firebase sync includes all cycle data
3. **Track Cycle Metrics**: View completion timestamps in cycleHistory

### Related Documentation

- [Feature Specification](./spec.md) - Complete requirements
- [Implementation Plan](./plan.md) - Technical design
- [Data Model](./data-model.md) - Data structure details
- [API Contracts](./contracts/README.md) - Function interfaces

---

## FAQ

### Q: Can I copy data from one cycle to another?

**A**: Not in the initial release. Each cycle starts with a clean slate. Copy-paste manually if needed.

**Future**: Cycle duplication feature may be added in future iteration.

---

### Q: Can I reorder cycles?

**A**: No. Cycles are always displayed in chronological order (creation date). Rename cycles to add context (e.g., "1 - Initial", "2 - Review").

---

### Q: What happens to cycle data when I delete an iteration?

**A**: All cycles and their data are permanently deleted along with the iteration. This matches existing behavior - no change.

---

### Q: Can I have different cycle names in different iterations?

**A**: Yes. Cycle names are scoped to their iteration. Two iterations can both have a cycle named "Initial Draft" without conflict.

---

### Q: Is there a limit to the number of cycles?

**A**: No hard limit, but performance is optimized for 3-5 cycles (tested up to 20 cycles). Beyond 20 cycles, consider splitting into separate iterations.

---

### Q: Can I export cycle data separately?

**A**: Not directly. Use the existing project export function, which includes all cycles. Filter cycles manually after export if needed.

---

### Q: Does cycle management work offline?

**A**: Yes. All cycle operations use LocalStorage as primary storage. Firebase sync is optional and only runs when authenticated and online.

---

### Q: Can I undo cycle deletion?

**A**: No undo functionality in initial release. A backup is created before deletion, but manual recovery requires technical knowledge. **Be cautious when deleting cycles.**

---

## Support

### Reporting Issues

If you encounter problems:
1. Check browser console for errors (F12 → Console)
2. Note the steps to reproduce
3. Include browser version and OS
4. Report via project issue tracker

### Feature Requests

Suggest improvements:
- Cycle duplication
- Cycle search/filter
- Cycle reordering
- Bulk cycle operations
- Cycle comparison view

---

## Summary

🎉 **You're ready to use cycle management!**

**Key Takeaways**:
- ✅ Existing data automatically migrated to first cycle
- ✅ Add cycles via ➕ button
- ✅ Rename cycles via ✏️ button
- ✅ Delete cycles via 🗑️ button (with confirmation)
- ✅ Switch cycles via dropdown
- ✅ Each cycle has independent data
- ✅ Minimum 1 cycle per iteration enforced

**Get Started**: Open an iteration and click ➕ to add your first cycle!
