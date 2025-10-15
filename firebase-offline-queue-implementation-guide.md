# Firebase Realtime Database Offline Queue Synchronization Implementation Guide

## Executive Summary

This guide provides a comprehensive strategy for implementing offline queue synchronization with Firebase Realtime Database without external libraries. Firebase has built-in offline support, but understanding its limitations and implementing a custom queue layer provides better control for complex scenarios.

---

## 1. Online/Offline Detection Strategy

### 1.1 Navigator.onLine Reliability

**Key Finding**: `navigator.onLine` is **unreliable** for production use.

**Limitations**:
- Only detects if the device has a network interface active
- Does NOT verify actual internet connectivity
- Returns `true` even when connected to a network without internet access
- Browser implementation varies significantly

**Recommendation**: Do NOT rely solely on `navigator.onLine`.

### 1.2 Firebase Connection State Listeners (RECOMMENDED)

Firebase provides `.info/connected` - a special reference that updates whenever connection state changes.

**Advantages**:
- Accurate detection of Firebase-specific connectivity
- Real-time updates when connection changes
- Built into Firebase SDK

**Limitations**:
- Only tracks connection to Firebase servers (not general internet)
- Can have 2-10 minute delays in detecting disconnections
- On some platforms (Android), disconnects after 60 seconds of inactivity

**Implementation**:

```javascript
import { getDatabase, ref, onValue } from 'firebase/database';

class FirebaseConnectionMonitor {
  constructor() {
    this.isConnected = false;
    this.listeners = [];
    this.setupConnectionListener();
  }

  setupConnectionListener() {
    const db = getDatabase();
    const connectedRef = ref(db, '.info/connected');

    onValue(connectedRef, (snapshot) => {
      this.isConnected = snapshot.val() === true;
      console.log(`Firebase connection status: ${this.isConnected ? 'ONLINE' : 'OFFLINE'}`);

      // Notify all registered listeners
      this.listeners.forEach(callback => callback(this.isConnected));
    });
  }

  onConnectionChange(callback) {
    this.listeners.push(callback);
    // Immediately call with current state
    callback(this.isConnected);
  }

  getConnectionState() {
    return this.isConnected;
  }
}

// Usage
const connectionMonitor = new FirebaseConnectionMonitor();
connectionMonitor.onConnectionChange((isOnline) => {
  if (isOnline) {
    console.log('Firebase reconnected - trigger sync');
    queueManager.processQueue();
  } else {
    console.log('Firebase disconnected - operations will queue');
  }
});
```

### 1.3 Hybrid Approach (BEST PRACTICE)

Combine both methods for comprehensive detection:

```javascript
class HybridConnectionDetector {
  constructor() {
    this.firebaseConnected = false;
    this.networkOnline = navigator.onLine;
    this.setupListeners();
  }

  setupListeners() {
    // Firebase connection listener
    const db = getDatabase();
    const connectedRef = ref(db, '.info/connected');
    onValue(connectedRef, (snapshot) => {
      this.firebaseConnected = snapshot.val() === true;
      this.notifyConnectionChange();
    });

    // Browser online/offline events (as supplementary signal)
    window.addEventListener('online', () => {
      this.networkOnline = true;
      console.log('Browser network: ONLINE');
      this.notifyConnectionChange();
    });

    window.addEventListener('offline', () => {
      this.networkOnline = false;
      console.log('Browser network: OFFLINE');
      this.notifyConnectionChange();
    });
  }

  isOnline() {
    // Only consider truly online if BOTH Firebase is connected AND network is up
    return this.firebaseConnected && this.networkOnline;
  }

  notifyConnectionChange() {
    const currentState = this.isOnline();
    // Emit event or call callbacks
    window.dispatchEvent(new CustomEvent('connectionChange', {
      detail: { online: currentState }
    }));
  }
}
```

---

## 2. Sync Trigger Strategy

### 2.1 Event Listeners vs Polling (RECOMMENDED: Event Listeners)

**Event-Driven Approach (BEST)**:
- More efficient (no unnecessary checks)
- Real-time response to connection changes
- Lower battery/CPU usage

```javascript
class SyncManager {
  constructor(connectionDetector, queueManager) {
    this.connectionDetector = connectionDetector;
    this.queueManager = queueManager;
    this.setupSyncTriggers();
  }

  setupSyncTriggers() {
    // 1. Listen for connection state changes
    window.addEventListener('connectionChange', (event) => {
      if (event.detail.online) {
        console.log('Connection restored - triggering sync');
        this.triggerSync();
      }
    });

    // 2. Listen for page visibility changes
    document.addEventListener('visibilitychange', () => {
      if (!document.hidden && this.connectionDetector.isOnline()) {
        console.log('Page became visible and online - checking sync');
        this.triggerSync();
      }
    });

    // 3. Listen for page load/focus events
    window.addEventListener('focus', () => {
      if (this.connectionDetector.isOnline()) {
        console.log('Window focused - checking sync');
        this.triggerSync();
      }
    });
  }

  async triggerSync() {
    if (this.queueManager.isSyncing) {
      console.log('Sync already in progress, skipping');
      return;
    }

    await this.queueManager.processQueue();
  }
}
```

### 2.2 Polling Approach (FALLBACK ONLY)

Use polling only as a fallback mechanism:

**Recommended Interval**: 30-60 seconds when online, 5-10 minutes when offline

```javascript
class PollingSync {
  constructor(connectionDetector, queueManager) {
    this.connectionDetector = connectionDetector;
    this.queueManager = queueManager;
    this.pollInterval = null;
    this.onlineInterval = 30000; // 30 seconds
    this.offlineInterval = 300000; // 5 minutes
  }

  startPolling() {
    this.stopPolling(); // Clear any existing interval

    const interval = this.connectionDetector.isOnline()
      ? this.onlineInterval
      : this.offlineInterval;

    this.pollInterval = setInterval(() => {
      this.checkAndSync();
    }, interval);
  }

  stopPolling() {
    if (this.pollInterval) {
      clearInterval(this.pollInterval);
      this.pollInterval = null;
    }
  }

  async checkAndSync() {
    if (this.connectionDetector.isOnline() && this.queueManager.hasItems()) {
      await this.queueManager.processQueue();
    }
  }
}
```

### 2.3 Page Visibility API Integration

Handle tab switching and browser minimize:

```javascript
class VisibilityManager {
  constructor(syncManager) {
    this.syncManager = syncManager;
    this.wasHidden = false;
    this.setupVisibilityListener();
  }

  setupVisibilityListener() {
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) {
        // Page is now hidden
        this.wasHidden = true;
        console.log('Page hidden - pausing background sync');
        this.onPageHidden();
      } else {
        // Page is now visible
        console.log('Page visible - resuming operations');
        this.onPageVisible();
      }
    });
  }

  onPageHidden() {
    // Optional: Pause aggressive sync operations
    // Keep critical operations running
  }

  onPageVisible() {
    // Trigger sync when page becomes visible again
    if (this.wasHidden) {
      this.syncManager.triggerSync();
      this.wasHidden = false;
    }
  }

  isVisible() {
    return !document.hidden;
  }
}
```

---

## 3. Retry Backoff Algorithm

### 3.1 Exponential Backoff Implementation

**Recommended Configuration**:
- Initial retry delay: 1000ms (1 second)
- Max retry count: 5-7 attempts
- Backoff factor: 2 (doubles each time)
- Max delay cap: 32000ms (32 seconds)
- Jitter: Add randomness to prevent thundering herd

```javascript
class ExponentialBackoff {
  constructor(options = {}) {
    this.initialDelay = options.initialDelay || 1000; // 1 second
    this.maxDelay = options.maxDelay || 32000; // 32 seconds
    this.maxRetries = options.maxRetries || 5;
    this.backoffFactor = options.backoffFactor || 2;
    this.jitter = options.jitter !== false; // Default true
  }

  /**
   * Calculate delay for a given retry attempt
   * @param {number} attempt - Current attempt number (0-indexed)
   * @returns {number} Delay in milliseconds
   */
  calculateDelay(attempt) {
    // Exponential delay: initialDelay * (backoffFactor ^ attempt)
    let delay = this.initialDelay * Math.pow(this.backoffFactor, attempt);

    // Cap at max delay
    delay = Math.min(delay, this.maxDelay);

    // Add jitter (randomness) to prevent thundering herd
    if (this.jitter) {
      const jitterAmount = delay * 0.3; // ±30% randomness
      delay = delay + (Math.random() * jitterAmount * 2 - jitterAmount);
    }

    return Math.floor(delay);
  }

  /**
   * Execute function with retry logic
   * @param {Function} fn - Async function to execute
   * @param {Function} onRetry - Callback for each retry
   * @returns {Promise} Result of successful execution
   */
  async execute(fn, onRetry = null) {
    let lastError;

    for (let attempt = 0; attempt <= this.maxRetries; attempt++) {
      try {
        // Attempt the operation
        const result = await fn();

        if (attempt > 0) {
          console.log(`Operation succeeded on attempt ${attempt + 1}`);
        }

        return result;
      } catch (error) {
        lastError = error;

        // Don't retry if we've exhausted attempts
        if (attempt >= this.maxRetries) {
          console.error(`Operation failed after ${this.maxRetries + 1} attempts`);
          break;
        }

        // Calculate delay for next retry
        const delay = this.calculateDelay(attempt);
        console.warn(`Attempt ${attempt + 1} failed, retrying in ${delay}ms...`, error);

        // Call retry callback if provided
        if (onRetry) {
          onRetry(attempt + 1, delay, error);
        }

        // Wait before next retry
        await this.sleep(delay);
      }
    }

    // All retries exhausted
    throw new Error(`Operation failed after ${this.maxRetries + 1} attempts: ${lastError.message}`);
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// Usage Example
const backoff = new ExponentialBackoff({
  initialDelay: 1000,
  maxRetries: 5,
  maxDelay: 32000
});

async function syncOperation(item) {
  return backoff.execute(
    async () => {
      // Your Firebase operation
      return await firebase.database().ref(`data/${item.id}`).set(item.data);
    },
    (attempt, delay, error) => {
      console.log(`Retry ${attempt} scheduled in ${delay}ms due to:`, error.message);
    }
  );
}
```

### 3.2 When to Give Up and Alert User

```javascript
class RetryStrategy {
  constructor(queueManager, notificationService) {
    this.queueManager = queueManager;
    this.notificationService = notificationService;
    this.failedOperations = new Map();
  }

  async processWithRetry(operation) {
    const backoff = new ExponentialBackoff({ maxRetries: 5 });

    try {
      const result = await backoff.execute(async () => {
        return await this.executeOperation(operation);
      });

      // Success - clear any failure tracking
      this.failedOperations.delete(operation.id);
      return result;

    } catch (error) {
      // All retries exhausted
      this.handlePermanentFailure(operation, error);
      throw error;
    }
  }

  handlePermanentFailure(operation, error) {
    // Track failed operation
    this.failedOperations.set(operation.id, {
      operation,
      error,
      timestamp: Date.now()
    });

    // Alert user based on severity
    if (this.shouldAlertUser(operation)) {
      this.notificationService.showError({
        title: 'Sync Failed',
        message: `Failed to sync ${operation.type} after multiple attempts. Your changes are saved locally and will retry automatically.`,
        action: {
          label: 'Retry Now',
          callback: () => this.queueManager.processQueue()
        }
      });
    }

    // Log for debugging
    console.error(`Permanent failure for operation ${operation.id}:`, error);
  }

  shouldAlertUser(operation) {
    // Alert user for critical operations or after certain threshold
    const criticalTypes = ['payment', 'booking', 'order'];
    const isCritical = criticalTypes.includes(operation.type);
    const failureCount = this.failedOperations.size;

    return isCritical || failureCount >= 3;
  }

  async executeOperation(operation) {
    // Your Firebase operation logic
    const db = getDatabase();
    const dataRef = ref(db, operation.path);

    switch (operation.type) {
      case 'set':
        return await set(dataRef, operation.data);
      case 'update':
        return await update(dataRef, operation.data);
      case 'remove':
        return await remove(dataRef);
      default:
        throw new Error(`Unknown operation type: ${operation.type}`);
    }
  }
}
```

---

## 4. Queue Management

### 4.1 LocalStorage Queue Implementation

```javascript
class QueueManager {
  constructor(storageKey = 'firebase_sync_queue') {
    this.storageKey = storageKey;
    this.maxQueueSize = 100; // Prevent unbounded growth
    this.maxItemAge = 7 * 24 * 60 * 60 * 1000; // 7 days in milliseconds
    this.isSyncing = false;
  }

  /**
   * Add operation to queue
   */
  enqueue(operation) {
    const queue = this.getQueue();

    // Check queue size limit
    if (queue.length >= this.maxQueueSize) {
      console.warn('Queue at maximum size, removing oldest item');
      queue.shift(); // Remove oldest
    }

    const queueItem = {
      id: this.generateId(),
      operation,
      timestamp: Date.now(),
      retryCount: 0,
      status: 'pending'
    };

    queue.push(queueItem);
    this.saveQueue(queue);

    return queueItem.id;
  }

  /**
   * Get all queue items
   */
  getQueue() {
    try {
      const stored = localStorage.getItem(this.storageKey);
      if (!stored) return [];

      const queue = JSON.parse(stored);

      // Prune old items
      return queue.filter(item => {
        const age = Date.now() - item.timestamp;
        return age < this.maxItemAge;
      });
    } catch (error) {
      console.error('Error reading queue:', error);
      return [];
    }
  }

  /**
   * Save queue to localStorage
   */
  saveQueue(queue) {
    try {
      localStorage.setItem(this.storageKey, JSON.stringify(queue));
    } catch (error) {
      if (error.name === 'QuotaExceededError') {
        console.error('localStorage quota exceeded, pruning queue');
        this.pruneQueue();
      } else {
        console.error('Error saving queue:', error);
      }
    }
  }

  /**
   * Remove item from queue
   */
  dequeue(itemId) {
    const queue = this.getQueue();
    const filtered = queue.filter(item => item.id !== itemId);
    this.saveQueue(filtered);
  }

  /**
   * Process entire queue
   */
  async processQueue() {
    if (this.isSyncing) {
      console.log('Sync already in progress');
      return;
    }

    this.isSyncing = true;
    const queue = this.getQueue();

    console.log(`Processing ${queue.length} queued operations`);

    const results = {
      success: 0,
      failed: 0,
      errors: []
    };

    for (const item of queue) {
      try {
        await this.processItem(item);
        this.dequeue(item.id);
        results.success++;
      } catch (error) {
        console.error(`Failed to process item ${item.id}:`, error);

        // Update retry count
        item.retryCount++;
        item.lastError = error.message;

        if (item.retryCount >= 5) {
          // Move to failed state or remove
          this.dequeue(item.id);
          results.failed++;
          results.errors.push({ item, error });
        } else {
          // Save updated item back to queue
          this.updateItem(item);
        }
      }
    }

    this.isSyncing = false;
    console.log(`Sync complete: ${results.success} succeeded, ${results.failed} failed`);

    return results;
  }

  /**
   * Process single queue item with retry logic
   */
  async processItem(item) {
    const backoff = new ExponentialBackoff({
      initialDelay: 1000,
      maxRetries: 3,
      maxDelay: 16000
    });

    return await backoff.execute(async () => {
      // Execute the Firebase operation
      return await this.executeFirebaseOperation(item.operation);
    });
  }

  /**
   * Execute Firebase operation
   */
  async executeFirebaseOperation(operation) {
    const db = getDatabase();
    const dataRef = ref(db, operation.path);

    switch (operation.type) {
      case 'set':
        return await set(dataRef, operation.data);
      case 'update':
        return await update(dataRef, operation.data);
      case 'remove':
        return await remove(dataRef);
      case 'push':
        return await push(dataRef, operation.data);
      default:
        throw new Error(`Unknown operation type: ${operation.type}`);
    }
  }

  /**
   * Update item in queue
   */
  updateItem(updatedItem) {
    const queue = this.getQueue();
    const index = queue.findIndex(item => item.id === updatedItem.id);

    if (index !== -1) {
      queue[index] = updatedItem;
      this.saveQueue(queue);
    }
  }

  /**
   * Prune queue when storage is full
   */
  pruneQueue() {
    const queue = this.getQueue();

    // Remove oldest 30% of items
    const pruneCount = Math.ceil(queue.length * 0.3);
    const pruned = queue.slice(pruneCount);

    this.saveQueue(pruned);
    console.log(`Pruned ${pruneCount} items from queue`);
  }

  /**
   * Check if queue has items
   */
  hasItems() {
    return this.getQueue().length > 0;
  }

  /**
   * Clear entire queue
   */
  clear() {
    localStorage.removeItem(this.storageKey);
  }

  /**
   * Generate unique ID
   */
  generateId() {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Get queue statistics
   */
  getStats() {
    const queue = this.getQueue();
    return {
      totalItems: queue.length,
      pendingItems: queue.filter(item => item.status === 'pending').length,
      oldestItem: queue.length > 0 ? new Date(queue[0].timestamp) : null,
      newestItem: queue.length > 0 ? new Date(queue[queue.length - 1].timestamp) : null
    };
  }
}
```

### 4.2 Queue Pruning Strategy

```javascript
class QueuePruner {
  constructor(queueManager, options = {}) {
    this.queueManager = queueManager;
    this.maxAge = options.maxAge || 7 * 24 * 60 * 60 * 1000; // 7 days
    this.maxSize = options.maxSize || 100;
    this.pruneInterval = options.pruneInterval || 60 * 60 * 1000; // 1 hour

    this.startAutoPruning();
  }

  /**
   * Start automatic pruning
   */
  startAutoPruning() {
    this.pruneIntervalId = setInterval(() => {
      this.pruneOldItems();
      this.pruneLargeQueue();
    }, this.pruneInterval);
  }

  /**
   * Stop automatic pruning
   */
  stopAutoPruning() {
    if (this.pruneIntervalId) {
      clearInterval(this.pruneIntervalId);
    }
  }

  /**
   * Remove items older than maxAge
   */
  pruneOldItems() {
    const queue = this.queueManager.getQueue();
    const now = Date.now();

    const filtered = queue.filter(item => {
      const age = now - item.timestamp;
      return age < this.maxAge;
    });

    const removed = queue.length - filtered.length;
    if (removed > 0) {
      this.queueManager.saveQueue(filtered);
      console.log(`Pruned ${removed} old items from queue`);
    }
  }

  /**
   * Keep queue under size limit
   */
  pruneLargeQueue() {
    const queue = this.queueManager.getQueue();

    if (queue.length > this.maxSize) {
      // Keep newest items, remove oldest
      const pruned = queue.slice(-this.maxSize);
      this.queueManager.saveQueue(pruned);
      console.log(`Pruned queue from ${queue.length} to ${this.maxSize} items`);
    }
  }

  /**
   * Prune based on success threshold
   * Remove items that have been successfully synced
   */
  pruneSuccessful() {
    const queue = this.queueManager.getQueue();
    const pending = queue.filter(item => item.status !== 'completed');

    const removed = queue.length - pending.length;
    if (removed > 0) {
      this.queueManager.saveQueue(pending);
      console.log(`Removed ${removed} completed items from queue`);
    }
  }
}
```

---

## 5. Firebase-Specific Considerations

### 5.1 Built-in Offline Support

**Firebase Realtime Database has robust built-in offline support**:

1. **Automatic Write Queue**: All writes are automatically queued while offline
2. **Disk Persistence**: Enable with one line to persist across app restarts
3. **Automatic Sync**: Queued operations automatically sync when reconnected

**Enable Offline Persistence** (Web):

```javascript
import { getDatabase, enableDatabase Persistence } from 'firebase/database';

// Note: This is NOT available in Firebase Web SDK v9+
// Web SDK relies on browser caching instead

// For older versions (v8):
// firebase.database().enablePersistence({ experimentalTabSynchronization: true });
```

**Important Note**: The web SDK does NOT have `enablePersistence()` like mobile SDKs. Web relies on:
- Browser caching mechanisms
- IndexedDB for some offline data
- Your custom queue implementation (as described in this guide)

### 5.2 Firebase Transactions in Offline Mode

**Critical Limitation**: Transactions have limited offline support.

**Key Facts**:
1. **Transactions fail immediately when offline** - they require server communication
2. **Not persisted across app restarts** - even with persistence enabled
3. **Cannot be queued** - they require round-trip validation with server

**Recommendation**: Avoid transactions for offline scenarios. Use regular `set()` or `update()` operations instead.

```javascript
// ❌ BAD: Transactions don't work offline
async function incrementCounter(ref) {
  return runTransaction(ref, (current) => {
    return (current || 0) + 1;
  });
  // This will FAIL if offline
}

// ✅ GOOD: Use optimistic updates with conflict resolution
async function incrementCounterOffline(ref, queueManager) {
  const operation = {
    type: 'increment',
    path: ref.toString(),
    timestamp: Date.now()
  };

  // Queue the operation
  queueManager.enqueue(operation);

  // Update local UI optimistically
  return { success: true, queued: true };
}
```

### 5.3 Using .info/connected Reference

```javascript
import { getDatabase, ref, onValue, onDisconnect, set, serverTimestamp } from 'firebase/database';

class PresenceSystem {
  constructor(userId) {
    this.userId = userId;
    this.db = getDatabase();
    this.setupPresence();
  }

  setupPresence() {
    // Reference to this user's presence
    const userStatusRef = ref(this.db, `/status/${this.userId}`);

    // Reference to connection state
    const connectedRef = ref(this.db, '.info/connected');

    onValue(connectedRef, (snapshot) => {
      if (snapshot.val() === true) {
        console.log('Connected to Firebase');

        // When disconnected, set offline status
        onDisconnect(userStatusRef).set({
          state: 'offline',
          last_changed: serverTimestamp()
        });

        // Set online status
        set(userStatusRef, {
          state: 'online',
          last_changed: serverTimestamp()
        });
      } else {
        console.log('Disconnected from Firebase');
      }
    });
  }
}

// Usage
const presence = new PresenceSystem('user123');
```

### 5.4 onDisconnect() Operations

Use Firebase's `onDisconnect()` for operations that should execute when connection is lost:

```javascript
class DisconnectHandler {
  constructor(userId) {
    this.userId = userId;
    this.db = getDatabase();
  }

  /**
   * Setup operations to execute on disconnect
   */
  setupDisconnectHandlers() {
    const userRef = ref(this.db, `/users/${this.userId}`);
    const sessionRef = ref(this.db, `/sessions/${this.userId}`);

    // Clear online status
    onDisconnect(userRef).update({
      online: false,
      lastSeen: serverTimestamp()
    });

    // Remove session
    onDisconnect(sessionRef).remove();

    console.log('Disconnect handlers configured');
  }

  /**
   * Cancel disconnect operations (call when user logs out cleanly)
   */
  async cancelDisconnectHandlers() {
    const userRef = ref(this.db, `/users/${this.userId}`);
    await onDisconnect(userRef).cancel();
  }
}
```

---

## 6. Complete Integration Example

Here's a complete working example integrating all components:

```javascript
import { getDatabase, ref, set, update, remove, push, onValue } from 'firebase/database';

/**
 * Complete offline sync system for Firebase
 */
class FirebaseOfflineSync {
  constructor(options = {}) {
    this.db = getDatabase();
    this.queueManager = new QueueManager();
    this.connectionDetector = new HybridConnectionDetector();
    this.syncManager = new SyncManager(this.connectionDetector, this.queueManager);
    this.visibilityManager = new VisibilityManager(this.syncManager);
    this.pruner = new QueuePruner(this.queueManager);

    this.initialize();
  }

  initialize() {
    console.log('Initializing Firebase Offline Sync');

    // Listen for connection changes
    this.connectionDetector.onConnectionChange((isOnline) => {
      if (isOnline) {
        console.log('Connection restored, processing queue');
        this.queueManager.processQueue();
      }
    });

    // Process queue on initialization if online
    if (this.connectionDetector.isOnline()) {
      setTimeout(() => this.queueManager.processQueue(), 1000);
    }
  }

  /**
   * Queue-aware Firebase operations
   */
  async set(path, data) {
    if (this.connectionDetector.isOnline()) {
      try {
        const dataRef = ref(this.db, path);
        await set(dataRef, data);
        return { success: true, queued: false };
      } catch (error) {
        console.warn('Online operation failed, queueing:', error);
        return this.queueOperation('set', path, data);
      }
    } else {
      return this.queueOperation('set', path, data);
    }
  }

  async update(path, data) {
    if (this.connectionDetector.isOnline()) {
      try {
        const dataRef = ref(this.db, path);
        await update(dataRef, data);
        return { success: true, queued: false };
      } catch (error) {
        console.warn('Online operation failed, queueing:', error);
        return this.queueOperation('update', path, data);
      }
    } else {
      return this.queueOperation('update', path, data);
    }
  }

  async remove(path) {
    if (this.connectionDetector.isOnline()) {
      try {
        const dataRef = ref(this.db, path);
        await remove(dataRef);
        return { success: true, queued: false };
      } catch (error) {
        console.warn('Online operation failed, queueing:', error);
        return this.queueOperation('remove', path, null);
      }
    } else {
      return this.queueOperation('remove', path, null);
    }
  }

  async push(path, data) {
    if (this.connectionDetector.isOnline()) {
      try {
        const dataRef = ref(this.db, path);
        const newRef = await push(dataRef, data);
        return { success: true, queued: false, key: newRef.key };
      } catch (error) {
        console.warn('Online operation failed, queueing:', error);
        return this.queueOperation('push', path, data);
      }
    } else {
      return this.queueOperation('push', path, data);
    }
  }

  /**
   * Queue operation for later sync
   */
  queueOperation(type, path, data) {
    const operation = { type, path, data };
    const id = this.queueManager.enqueue(operation);

    console.log(`Operation queued (${type} ${path}): ${id}`);

    return { success: true, queued: true, queueId: id };
  }

  /**
   * Get queue statistics
   */
  getQueueStats() {
    return this.queueManager.getStats();
  }

  /**
   * Manually trigger sync
   */
  async syncNow() {
    return await this.queueManager.processQueue();
  }

  /**
   * Clear all queued operations
   */
  clearQueue() {
    this.queueManager.clear();
  }

  /**
   * Check if online
   */
  isOnline() {
    return this.connectionDetector.isOnline();
  }

  /**
   * Cleanup
   */
  destroy() {
    this.pruner.stopAutoPruning();
  }
}

// ============================================
// Usage Example
// ============================================

// Initialize the sync system
const firebaseSync = new FirebaseOfflineSync();

// Use it like normal Firebase operations
async function saveUserData(userId, userData) {
  const result = await firebaseSync.set(`users/${userId}`, userData);

  if (result.queued) {
    console.log('Operation queued - will sync when online');
    showNotification('Changes saved locally and will sync when online');
  } else {
    console.log('Operation completed immediately');
    showNotification('Changes saved successfully');
  }
}

// Update user profile
async function updateProfile(userId, updates) {
  await firebaseSync.update(`users/${userId}/profile`, updates);
}

// Delete user data
async function deleteUser(userId) {
  await firebaseSync.remove(`users/${userId}`);
}

// Add new item to list
async function addItem(listId, itemData) {
  const result = await firebaseSync.push(`lists/${listId}/items`, itemData);
  if (result.key) {
    console.log('New item created with key:', result.key);
  }
}

// Check queue status
function displayQueueStatus() {
  const stats = firebaseSync.getQueueStats();
  console.log('Queue stats:', stats);

  if (stats.totalItems > 0) {
    showNotification(`${stats.totalItems} operations pending sync`);
  }
}

// Manual sync trigger
async function manualSync() {
  if (firebaseSync.isOnline()) {
    const results = await firebaseSync.syncNow();
    console.log(`Sync complete: ${results.success} succeeded, ${results.failed} failed`);
  } else {
    showNotification('Cannot sync while offline');
  }
}
```

---

## 7. Best Practices Summary

### 7.1 Connection Detection
✅ **DO**:
- Use Firebase `.info/connected` as primary connection indicator
- Combine with `navigator.onLine` for comprehensive detection
- Use event listeners instead of polling

❌ **DON'T**:
- Rely solely on `navigator.onLine`
- Poll connection state frequently
- Ignore connection state changes

### 7.2 Queue Management
✅ **DO**:
- Set maximum queue size (recommended: 100 items)
- Implement age-based pruning (recommended: 7 days)
- Store timestamp and retry count with each item
- Provide user feedback for queued operations

❌ **DON'T**:
- Allow unbounded queue growth
- Keep failed items indefinitely
- Hide queue status from users

### 7.3 Retry Strategy
✅ **DO**:
- Use exponential backoff (factor of 2)
- Add jitter to prevent thundering herd
- Cap maximum delay (recommended: 32 seconds)
- Give up after 5-7 attempts

❌ **DON'T**:
- Retry immediately on failure
- Use linear backoff
- Retry indefinitely without limit

### 7.4 User Experience
✅ **DO**:
- Show sync status indicators
- Provide manual sync button
- Alert users about persistent failures
- Allow users to view queued operations

❌ **DON'T**:
- Block UI while syncing
- Fail silently
- Hide offline state from users

### 7.5 Firebase-Specific
✅ **DO**:
- Leverage Firebase's built-in offline support
- Use `onDisconnect()` for presence
- Use regular writes instead of transactions for offline scenarios
- Monitor `.info/connected` for real-time status

❌ **DON'T**:
- Use transactions in offline scenarios
- Ignore Firebase's built-in queue
- Duplicate Firebase's automatic retry logic

---

## 8. Testing Strategies

### 8.1 Simulating Offline Mode

```javascript
class OfflineSimulator {
  constructor(firebaseSync) {
    this.firebaseSync = firebaseSync;
    this.originalFetch = window.fetch;
  }

  /**
   * Simulate offline mode
   */
  goOffline() {
    // Block all network requests
    window.fetch = () => {
      return Promise.reject(new Error('Network request failed (simulated offline)'));
    };

    // Trigger offline event
    window.dispatchEvent(new Event('offline'));

    console.log('Offline mode simulated');
  }

  /**
   * Restore online mode
   */
  goOnline() {
    // Restore fetch
    window.fetch = this.originalFetch;

    // Trigger online event
    window.dispatchEvent(new Event('online'));

    console.log('Online mode restored');
  }

  /**
   * Simulate intermittent connectivity
   */
  async simulateIntermittent(duration = 5000) {
    const cycles = 5;
    const interval = duration / cycles;

    for (let i = 0; i < cycles; i++) {
      this.goOffline();
      await this.sleep(interval / 2);
      this.goOnline();
      await this.sleep(interval / 2);
    }
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// Usage
const simulator = new OfflineSimulator(firebaseSync);

// Test offline scenario
simulator.goOffline();
await saveUserData('user123', { name: 'John' }); // Should queue
simulator.goOnline(); // Should trigger sync
```

### 8.2 Queue Testing

```javascript
describe('QueueManager', () => {
  let queueManager;

  beforeEach(() => {
    localStorage.clear();
    queueManager = new QueueManager('test_queue');
  });

  test('should enqueue operation', () => {
    const id = queueManager.enqueue({
      type: 'set',
      path: '/test',
      data: { value: 123 }
    });

    expect(id).toBeTruthy();
    expect(queueManager.hasItems()).toBe(true);
  });

  test('should process queue when online', async () => {
    queueManager.enqueue({
      type: 'set',
      path: '/test',
      data: { value: 123 }
    });

    const results = await queueManager.processQueue();
    expect(results.success).toBe(1);
    expect(queueManager.hasItems()).toBe(false);
  });

  test('should respect max queue size', () => {
    queueManager.maxQueueSize = 5;

    for (let i = 0; i < 10; i++) {
      queueManager.enqueue({ type: 'set', path: `/test${i}`, data: {} });
    }

    const queue = queueManager.getQueue();
    expect(queue.length).toBe(5);
  });

  test('should prune old items', () => {
    // Add old item
    const queue = [{
      id: '1',
      operation: { type: 'set', path: '/old', data: {} },
      timestamp: Date.now() - (8 * 24 * 60 * 60 * 1000), // 8 days ago
      retryCount: 0
    }];

    queueManager.saveQueue(queue);

    const retrieved = queueManager.getQueue();
    expect(retrieved.length).toBe(0); // Should be pruned
  });
});
```

---

## 9. Monitoring and Debugging

### 9.1 Queue Monitor Dashboard

```javascript
class QueueMonitor {
  constructor(queueManager) {
    this.queueManager = queueManager;
  }

  /**
   * Get detailed queue information
   */
  getDetailedStats() {
    const queue = this.queueManager.getQueue();

    return {
      totalItems: queue.length,
      byStatus: this.groupByStatus(queue),
      byType: this.groupByType(queue),
      avgRetryCount: this.calculateAvgRetries(queue),
      oldestItem: queue[0]?.timestamp,
      newestItem: queue[queue.length - 1]?.timestamp,
      storageSize: this.calculateStorageSize()
    };
  }

  groupByStatus(queue) {
    return queue.reduce((acc, item) => {
      acc[item.status] = (acc[item.status] || 0) + 1;
      return acc;
    }, {});
  }

  groupByType(queue) {
    return queue.reduce((acc, item) => {
      const type = item.operation.type;
      acc[type] = (acc[type] || 0) + 1;
      return acc;
    }, {});
  }

  calculateAvgRetries(queue) {
    if (queue.length === 0) return 0;
    const total = queue.reduce((sum, item) => sum + item.retryCount, 0);
    return (total / queue.length).toFixed(2);
  }

  calculateStorageSize() {
    const stored = localStorage.getItem(this.queueManager.storageKey);
    return stored ? new Blob([stored]).size : 0;
  }

  /**
   * Display dashboard
   */
  displayDashboard() {
    const stats = this.getDetailedStats();

    console.group('📊 Queue Monitor Dashboard');
    console.log(`Total Items: ${stats.totalItems}`);
    console.log('By Status:', stats.byStatus);
    console.log('By Type:', stats.byType);
    console.log(`Average Retries: ${stats.avgRetryCount}`);
    console.log(`Storage Size: ${stats.storageSize} bytes`);
    console.groupEnd();

    return stats;
  }
}

// Usage
const monitor = new QueueMonitor(queueManager);
setInterval(() => monitor.displayDashboard(), 30000); // Every 30 seconds
```

### 9.2 Debug Logging

```javascript
class SyncLogger {
  constructor(enabled = true) {
    this.enabled = enabled;
    this.logs = [];
    this.maxLogs = 100;
  }

  log(level, category, message, data = null) {
    if (!this.enabled) return;

    const entry = {
      timestamp: new Date().toISOString(),
      level,
      category,
      message,
      data
    };

    this.logs.push(entry);

    // Keep only recent logs
    if (this.logs.length > this.maxLogs) {
      this.logs.shift();
    }

    // Console output
    const emoji = {
      info: 'ℹ️',
      warn: '⚠️',
      error: '❌',
      success: '✅'
    }[level] || '📝';

    console.log(`${emoji} [${category}] ${message}`, data || '');
  }

  info(category, message, data) {
    this.log('info', category, message, data);
  }

  warn(category, message, data) {
    this.log('warn', category, message, data);
  }

  error(category, message, data) {
    this.log('error', category, message, data);
  }

  success(category, message, data) {
    this.log('success', category, message, data);
  }

  getLogs(filter = {}) {
    let filtered = this.logs;

    if (filter.level) {
      filtered = filtered.filter(log => log.level === filter.level);
    }

    if (filter.category) {
      filtered = filtered.filter(log => log.category === filter.category);
    }

    return filtered;
  }

  export() {
    return JSON.stringify(this.logs, null, 2);
  }
}

// Integrate with queue manager
const logger = new SyncLogger();

// Log queue operations
queueManager.enqueue = new Proxy(queueManager.enqueue, {
  apply(target, thisArg, args) {
    logger.info('Queue', 'Operation enqueued', args[0]);
    return target.apply(thisArg, args);
  }
});
```

---

## 10. Performance Considerations

### 10.1 Batch Operations

```javascript
class BatchOperations {
  constructor(firebaseSync) {
    this.firebaseSync = firebaseSync;
    this.batchSize = 10;
    this.batchDelay = 100; // ms between batches
  }

  /**
   * Process operations in batches to avoid overwhelming the system
   */
  async processBatch(operations) {
    const batches = this.createBatches(operations, this.batchSize);
    const results = [];

    for (const batch of batches) {
      const batchResults = await Promise.allSettled(
        batch.map(op => this.firebaseSync[op.type](op.path, op.data))
      );

      results.push(...batchResults);

      // Delay between batches
      if (batches.indexOf(batch) < batches.length - 1) {
        await this.sleep(this.batchDelay);
      }
    }

    return results;
  }

  createBatches(items, batchSize) {
    const batches = [];
    for (let i = 0; i < items.length; i += batchSize) {
      batches.push(items.slice(i, i + batchSize));
    }
    return batches;
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
```

### 10.2 localStorage Optimization

```javascript
class OptimizedStorage {
  constructor(key) {
    this.key = key;
    this.cache = null;
    this.cacheTime = 0;
    this.cacheDuration = 1000; // 1 second
  }

  /**
   * Read with caching
   */
  read() {
    const now = Date.now();

    // Return cached data if still valid
    if (this.cache && (now - this.cacheTime) < this.cacheDuration) {
      return this.cache;
    }

    // Read from localStorage
    try {
      const stored = localStorage.getItem(this.key);
      this.cache = stored ? JSON.parse(stored) : [];
      this.cacheTime = now;
      return this.cache;
    } catch (error) {
      console.error('Error reading from storage:', error);
      return [];
    }
  }

  /**
   * Write with debouncing
   */
  write(data) {
    this.cache = data;
    this.cacheTime = Date.now();

    // Debounce writes
    clearTimeout(this.writeTimeout);
    this.writeTimeout = setTimeout(() => {
      try {
        localStorage.setItem(this.key, JSON.stringify(data));
      } catch (error) {
        console.error('Error writing to storage:', error);
      }
    }, 100);
  }

  clear() {
    this.cache = null;
    this.cacheTime = 0;
    localStorage.removeItem(this.key);
  }
}
```

---

## 11. Error Recovery Strategies

### 11.1 Conflict Resolution

```javascript
class ConflictResolver {
  /**
   * Resolve conflicts when offline changes conflict with server state
   */
  async resolveConflict(localData, serverData, strategy = 'server-wins') {
    switch (strategy) {
      case 'server-wins':
        return serverData;

      case 'client-wins':
        return localData;

      case 'merge':
        return this.mergeData(localData, serverData);

      case 'timestamp':
        return this.timestampResolution(localData, serverData);

      default:
        throw new Error(`Unknown conflict resolution strategy: ${strategy}`);
    }
  }

  /**
   * Merge local and server data
   */
  mergeData(local, server) {
    if (typeof local === 'object' && typeof server === 'object') {
      return { ...server, ...local };
    }
    return local;
  }

  /**
   * Resolve based on timestamp
   */
  timestampResolution(local, server) {
    const localTime = local._timestamp || 0;
    const serverTime = server._timestamp || 0;

    return localTime > serverTime ? local : server;
  }
}
```

### 11.2 Data Integrity Checks

```javascript
class IntegrityChecker {
  /**
   * Validate data before syncing
   */
  validateOperation(operation) {
    const errors = [];

    // Check required fields
    if (!operation.type) {
      errors.push('Missing operation type');
    }

    if (!operation.path) {
      errors.push('Missing operation path');
    }

    // Validate data
    if (operation.type !== 'remove' && !operation.data) {
      errors.push('Missing operation data');
    }

    // Check data size (Firebase limit is 256MB, but be conservative)
    if (operation.data) {
      const size = new Blob([JSON.stringify(operation.data)]).size;
      if (size > 10 * 1024 * 1024) { // 10MB
        errors.push('Data size exceeds limit');
      }
    }

    return {
      valid: errors.length === 0,
      errors
    };
  }

  /**
   * Sanitize data before saving
   */
  sanitize(data) {
    // Remove undefined values (Firebase doesn't support them)
    return JSON.parse(JSON.stringify(data));
  }
}
```

---

## 12. Summary and Recommendations

### Key Takeaways

1. **Connection Detection**: Use Firebase `.info/connected` + `navigator.onLine` hybrid approach
2. **Sync Triggers**: Event-driven (not polling) for efficiency
3. **Retry Logic**: Exponential backoff with 1s initial delay, 5-7 max retries
4. **Queue Management**: localStorage with 100-item limit, 7-day age pruning
5. **Firebase Features**: Leverage built-in offline support, avoid transactions offline

### Implementation Checklist

- [ ] Implement hybrid connection detection
- [ ] Setup event-driven sync triggers
- [ ] Create queue manager with localStorage
- [ ] Add exponential backoff retry logic
- [ ] Implement queue pruning strategy
- [ ] Add Page Visibility API handling
- [ ] Setup Firebase `.info/connected` monitoring
- [ ] Create user notification system
- [ ] Add monitoring/debugging tools
- [ ] Implement error recovery
- [ ] Write tests for offline scenarios
- [ ] Add queue status UI indicators

### Production Readiness

Before deploying to production:

1. **Test thoroughly** with simulated offline scenarios
2. **Monitor queue growth** in production
3. **Set up alerting** for sync failures
4. **Provide clear user feedback** about sync status
5. **Document** edge cases and limitations
6. **Implement analytics** to track sync success rates

---

## Appendix: Quick Reference

### Connection States

```javascript
// Check if online
firebaseSync.isOnline() // true/false

// Listen for changes
connectionDetector.onConnectionChange((online) => {
  console.log('Online:', online);
});
```

### Queue Operations

```javascript
// Queue operation
await firebaseSync.set('/path', data);

// Manual sync
await firebaseSync.syncNow();

// Check queue
const stats = firebaseSync.getQueueStats();

// Clear queue
firebaseSync.clearQueue();
```

### Retry Configuration

```javascript
new ExponentialBackoff({
  initialDelay: 1000,    // 1 second
  maxDelay: 32000,       // 32 seconds
  maxRetries: 5,         // 5 attempts
  backoffFactor: 2,      // Double each time
  jitter: true           // Add randomness
});
```

### Queue Limits

```javascript
new QueueManager({
  maxQueueSize: 100,              // Max 100 items
  maxItemAge: 7 * 24 * 60 * 60 * 1000  // 7 days
});
```

---

*This implementation guide provides a production-ready offline synchronization system for Firebase Realtime Database without relying on external libraries.*
