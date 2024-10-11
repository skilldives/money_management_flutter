// login exception
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// generic exception
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}

class DriveApiNotFoundException implements Exception {}

class UploadFailedException implements Exception {}

class SynchronizationFailedException implements Exception {}

class DownloadFailException implements Exception {}
