import EditUser from './edituser';

export default class EditMetadata {
  schema!: string;

  createdUTC!: string;

  lastModifiedUTC?: string;

  createdBy!: EditUser;

  lastModifiedBy?: EditUser;

  static CreateNew(schema: string, user: EditUser): EditMetadata {
    const md = new EditMetadata();
    md.schema = schema;
    md.createdUTC = new Date().toISOString();
    md.createdBy = {
      id: user.id,
      displayName: user.displayName ?? user.id,
      email: user.email,
    };
    return md;
  }

  static UpdateExisting(
    editMetadata: EditMetadata,
    user: EditUser,
  ): EditMetadata {
    let md = editMetadata;
    if (md === undefined) {
      md = new EditMetadata();
      md.createdUTC = new Date().toISOString();
      md.createdBy = {
        id: user.id,
        displayName: user.displayName ?? user.id,
        email: user.email,
      };
    }
    md.lastModifiedUTC = new Date().toISOString();
    md.lastModifiedBy = {
      id: user.id,
      displayName: user.displayName ?? user.id,
      email: user.email,
    };
    return md;
  }
}
