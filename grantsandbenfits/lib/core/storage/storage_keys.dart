abstract final class StorageKeys {
  static const users = 'gb.users';
  static const sessionUserId = 'gb.session.userId';
  static const authAudit = 'gb.auth.audit';
  static const documentAudit = 'gb.documents.audit';

  static String verifyChallenge(String email) => 'gb.challenge.verify.$email';

  static String resetChallenge(String email) => 'gb.challenge.reset.$email';
}
