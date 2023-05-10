import { CosmosPartitionKey } from '@nestjs/azure-database';
import { EntityBase } from './base';
import CommsTemplate from './commstemplate';
import EditMetadata from './editmetadata';
import TerminologyDefinition from './terminologydefinition';

@CosmosPartitionKey('id')
export default class Organisation implements EntityBase {
  static entityType = 'organisation';

  static entitySchema = 'urn:organisation/v1';

  id!: string;

  readonly type = Organisation.entityType;

  readonly schema = Organisation.entitySchema;

  readonly partitionKey = 'id';

  name!: string;

  eventOrganiserEmail!: string;

  terminologySets?: { [setId: string]: TerminologyDefinition[] };

  sendEmailToExternalParticipants!: boolean;

  commsTemplates!: CommsTemplate[];

  status!: string;

  editMetadata!: EditMetadata;
}
