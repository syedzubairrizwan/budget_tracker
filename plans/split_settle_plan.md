# Expense Split & Settle-Up Plan

A Splitwise-inspired feature allowing users to split expenses with **registered app users**, initiate settlements via notifications, and view settled/pending splits on a dedicated screen.

> **Status**: Planning Phase — Awaiting backend decision (Firebase vs. Local-only)

---

## Overview

The existing "Split Bill" stores participant names as free-text strings with no connection to real users. This plan upgrades the system to:

1. **User-linked splits**: Split partners must be registered app users (searchable by name/email)
2. **Dual-book recording**: Each split expense is written to both users' transaction books
3. **Settlement notifications**: The non-creator initiates a settle-up → creator gets an approval notification
4. **Settle Up screen**: A new tab showing active splits and settled history with avatar + arrow UI

---

## Architecture Decision

### Option A — Firebase (Recommended for Production)

| Component | Package |
|-----------|---------|
| Auth & user registry | `firebase_auth` + `cloud_firestore` |
| Shared transaction sync | `cloud_firestore` |
| Push notifications | `firebase_messaging` (FCM) |

**Firestore Collections:**
```
users/{userId}         → name, email, avatarUrl, fcmToken
split_transactions/{groupId} → creatorId, partnerId, amount, splitAmount, title, date, status
settle_requests/{requestId}  → groupId, requestedBy, targetUser, status, createdAt
```

### Option B — Local-only / Demo Mode

Use SQLite + `flutter_local_notifications` only. Two local user accounts share the same device database. No real push to another device.

---

## File Change Map

### New Files

| File | Purpose |
|------|---------|
| `lib/models/app_user.dart` | AppUser data model (id, name, email, avatarUrl) |
| `lib/models/settle_request.dart` | SettleRequest model (id, groupId, status, createdAt) |
| `lib/services/user_search_service.dart` | Search registered users by email/name |
| `lib/services/split_service.dart` | Core split/settle business logic |
| `lib/features/split_settle/settle_up_screen.dart` | New "Settle Up" tab screen |
| `lib/features/split_settle/user_search_bottom_sheet.dart` | User picker modal for AddTransactionScreen |
| `lib/features/split_settle/settle_request_notification_handler.dart` | Handles notification tap → Approve/Deny dialog |

### Modified Files

| File | What Changes |
|------|-------------|
| `lib/models/transaction.dart` | Add: `splitWithUserId`, `splitWithName`, `splitWithAvatar`, `splitGroupId`, `splitStatus`, `isCreator` |
| `lib/services/database_service.dart` | Bump to v9; migrate transactions table; add `settle_requests` table; new CRUD methods |
| `lib/services/notification_service.dart` | New `split_alerts` channel; `showSettlementRequestNotification()`; `showSettlementDeniedNotification()` |
| `lib/features/add_transaction/add_transaction_screen.dart` | Replace free-text participant names with `UserSearchBottomSheet` picker for registered users |
| `lib/homepage.dart` | Add 5th bottom nav tab → SettleUpScreen |
| `pubspec.yaml` | (Option A only) Add firebase_auth, cloud_firestore, firebase_messaging |

---

## Transaction Model Extension

```dart
enum SplitStatus { none, pending, settled, denied }

class Transaction {
  // ... existing fields ...

  // NEW fields:
  final String? splitWithUserId;   // Partner's user ID in the registry
  final String? splitWithName;     // Cached display name
  final String? splitWithAvatar;   // Cached avatar URL
  final String? splitGroupId;      // Shared UUID linking both copies
  final SplitStatus splitStatus;   // Current settlement status
  final bool isCreator;            // Did this user create the expense?
}
```

**DB Migration (version 9):**
```sql
ALTER TABLE transactions ADD COLUMN splitWithUserId TEXT;
ALTER TABLE transactions ADD COLUMN splitWithName TEXT;
ALTER TABLE transactions ADD COLUMN splitWithAvatar TEXT;
ALTER TABLE transactions ADD COLUMN splitGroupId TEXT;
ALTER TABLE transactions ADD COLUMN splitStatus TEXT DEFAULT 'none';
ALTER TABLE transactions ADD COLUMN isCreator INTEGER DEFAULT 1;
```

---

## Split Service API

```dart
class SplitService {
  // Creates two Transaction records with the same splitGroupId
  Future<void> recordSplitExpense({
    required Transaction creatorTransaction,
    required AppUser partner,
  });

  // Initiates settle-up. Sets status = pending. Notifies expense creator.
  Future<void> initiateSettlement({
    required String groupId,
    required String requestedByUserId,
    required String targetUserId,
  });

  // Approves: both transactions → status = settled
  Future<void> approveSettlement(String settleRequestId);

  // Denies: status = denied. Sends denial notification to initiator.
  Future<void> denySettlement(String settleRequestId);

  // All active (pending) splits for current user
  Future<List<Transaction>> getActiveSplits(String currentUserId);

  // All settled transactions for current user
  Future<List<Transaction>> getSettledTransactions(String currentUserId);
}
```

---

## Full User Flow

```
User A → Add Expense → Toggle Split Bill ON
       → Tap participant slot → UserSearchBottomSheet opens
       → Search "Ali" → Select Ali (registered user)
       → Save transaction

       ┌── Transaction A saved (isCreator: true, status: pending)
       └── Transaction B saved to Ali's book (isCreator: false, status: pending)

Ali opens app:
  → Sees "Dinner at Pizza Hut" in Active Splits tab
  → Taps "Settle Up"
  → SettleRequest created, status: pending
  → PUSH NOTIFICATION → User A:
    "Ali wants to settle 'Dinner at Pizza Hut' — Approve or Deny?"

User A receives notification:
  ┌── Taps APPROVE:
  │     Both transactions → status: settled
  │     Cards move to "Settled" tab
  │     Arrow UI: [User A avatar] ──→ [Ali avatar]  ✓ Settled
  │
  └── Taps DENY:
        PUSH NOTIFICATION → Ali:
        "User A denied the settlement for 'Dinner at Pizza Hut'"
        Ali's card shows "✗ Denied" with a "Re-request" option
```

---

## Settle Up Screen UI Spec

### Active Splits Tab

```
┌─────────────────────────────────────────────┐
│  [🧑 You]  ─────────────────→  [👤 Ali]    │
│  Dinner at Pizza Hut                        │
│  Rs. 600 (your share: Rs. 300)              │
│  May 24, 2026                    [Settle Up]│
└─────────────────────────────────────────────┘
```

- Arrow direction: **Payer → Receiver** (whoever owes points to whoever is owed)
- Profile pictures from `avatarUrl` or initials fallback
- Color: gradient accent (blue → purple)

### Settled Tab

```
┌─────────────────────────────────────────────┐
│  [🧑 You]  ─────────────────→  [👤 Ali]    │
│  Dinner at Pizza Hut                ✓ Settled│
│  Rs. 600 • May 24, 2026                     │
└─────────────────────────────────────────────┘
```

- Green checkmark badge
- Greyed out card with reduced opacity

---

## Notification Channels

| Channel ID | Channel Name | Triggered By |
|-----------|-------------|-------------|
| `budget_alerts` | Budget Alerts | Existing budget limit alerts |
| `split_alerts` | Split & Settle Alerts | Settlement requests & denials |

---

## Verification Checklist

- [ ] Two transaction records created with same `splitGroupId` when saving a split
- [ ] Partner's transaction appears in their "Active Splits" tab
- [ ] "Settle Up" button triggers notification to expense creator
- [ ] Approving settlement moves both cards to "Settled" tab
- [ ] Denying settlement sends denial notification to initiator
- [ ] Arrow UI displays correct direction (payer → receiver)
- [ ] Avatars load correctly (fallback to initials if no URL)
- [ ] Dark mode / light mode renders correctly on Settle Up screen
- [ ] Notification tap opens Approve/Deny dialog correctly

---

## Dependencies to Add (pubspec.yaml)

```yaml
# Option A (Firebase) additions:
firebase_core: ^3.0.0
firebase_auth: ^5.0.0
cloud_firestore: ^5.0.0
firebase_messaging: ^15.0.0

# Already present (verify versions):
flutter_local_notifications: ^18.0.0
uuid: ^4.0.0
```

---

*Created: 2026-05-25 | Status: Awaiting approval to implement*
