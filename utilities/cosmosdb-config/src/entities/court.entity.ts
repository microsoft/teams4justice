import { CosmosPartitionKey } from '@nestjs/azure-database';
import { EntityBase } from './base';
import EditMetadata from './editmetadata';
import RoomDefinition from './roomdefinition';
import TerminologySet from './terminologyset';

@CosmosPartitionKey('id')
export default class Court implements EntityBase {
  static entityType = 'court';

  static entitySchema = 'urn:court/v1';

  id!: string;

  readonly type = Court.entityType;

  readonly schema = Court.entitySchema;

  readonly partitionKey = 'id';

  organisationId!: string;

  name!: string;

  ianaTimeZoneId!: string;

  terminologySets?: TerminologySet[];

  defaultRooms?: RoomDefinition[];

  msGraphResourceUri?: string;

  status!: string;

  editMetadata!: EditMetadata;
}
