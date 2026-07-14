class ShiftSyncException(Exception):
    """Base exception for ShiftSync application errors."""
    def __init__(self, message: str):
        self.message = message
        super().__init__(message)

class ScheduleConflictException(ShiftSyncException):
    """Raised when attempting to assign duplicate active shifts for the same nurse on the same date (RULE 3.5)."""
    pass

class ImmutableRecordException(ShiftSyncException):
    """Raised when attempting to modify a settled financial ledger record (RULE 3.4)."""
    pass
