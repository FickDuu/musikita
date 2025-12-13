# Phase 3: Remaining Compilation Errors

## Summary
We've successfully completed the major refactoring:
✅ Consolidated duplicate screens into shared folder
✅ Modified screens to load their own data
✅ Updated router configuration
✅ Removed redundant files

**Remaining**: 21 compilation errors (down from 43)

---

## Errors to Fix

### 1. **route_guards.dart** (3 errors)
**Issue**: Trying to get `role` from Firebase `User` instead of `AppUser`

**Lines**: 23, 66, 102
```dart
// WRONG:
final userRole = authService.currentUser?.role;

// FIX: Get AppUser from AuthProvider instead
```

**Solution**: Route guards should use AuthProvider to get user role, not AuthService directly.

---

### 2. **auth_gate.dart** (2 errors)
**Issue**: References deleted `main_navigation.dart` file

**Fix**: Update to use go_router navigation or redirect logic

---

### 3. **create_event_screen.dart** (5 errors)
**Issue**: References `widget.event` which was changed to `_event`

**Lines**: 246, 263, 267, 326, 585

**Fix**: Replace all `widget.event` with `_event`

---

### 4. **events_tab.dart** (1 error)
**Issue**: Passes `event:` parameter to CreateEventScreen

**Line**: 151

**Fix**: Pass `eventId: event.id` instead of `event: event`

---

### 5. **discover_music_screen.dart** (3 errors)
**Issue**: LoggerService calls using positional arguments

**Lines**: 34, 78, 91

**Fix**: Change to named parameter `tag:`
```dart
// WRONG:
LoggerService.debug(_tag, 'message');

// CORRECT:
LoggerService.debug('message', tag: _tag);
```

---

### 6. **chat_screen.dart** (5 errors)
**Issue**: References `widget.otherUser` which no longer exists

**Lines**: 272, 274, 280, 285, 287

**Fix**: Replace with `_otherUser!` (we load it in initState)

---

### 7. **messages_screen.dart** (2 errors)
**Issue**: Passes `otherUser` and `otherUserId` to ChatScreen

**Line**: 116-117

**Fix**: Remove these parameters, ChatScreen loads them internally now

---

## Quick Fix Commands

I can fix all these issues for you right now. The changes are straightforward:

1. Update route_guards to use AuthProvider
2. Fix auth_gate to use proper navigation
3. Replace widget.event → _event
4. Fix LoggerService calls
5. Replace widget.otherUser → _otherUser
6. Update ChatScreen navigation calls

**Would you like me to proceed with these fixes?**

---

## Status After Fixes

Once these 21 errors are fixed:
- ✅ Phase 3 Complete
- ✅ Ready for Phase 4: Messaging Service Refactor
- ✅ Clean codebase for Phases 5-7 (Notifications, Analytics, Testing)

**Estimated time to fix**: 10-15 minutes
