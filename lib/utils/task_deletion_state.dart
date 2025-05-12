// A simple utility class to maintain deletion state across the app
// This helps prevent multiple messages appearing when deleting tasks
class TaskDeletionState {
  // This flag indicates whether a task is currently being deleted
  // Used to prevent the "Task not found" message from appearing
  // when we've already shown a "Task deleted successfully" message
  static bool isBeingDeleted = false;

  // Reset the state after a deletion operation is completed
  static void reset() {
    isBeingDeleted = false;
  }

  // Mark that a deletion operation is in progress
  static void markDeletionInProgress() {
    isBeingDeleted = true;
  }
}
