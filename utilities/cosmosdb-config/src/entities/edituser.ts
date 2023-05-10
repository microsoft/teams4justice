export default class EditUser {
  id!: string;

  displayName?: string;

  email?: string;

  static SystemUser(): EditUser {
    return {
      id: 'system',
      displayName: 'System User',
      email: undefined,
    };
  }
}
