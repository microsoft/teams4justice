import EditMetadata from './editmetadata';

export interface EntityBase {
  id: string;
  type: string;
  schema: string;
  editMetadata: EditMetadata;
  partitionKey: string;
}
