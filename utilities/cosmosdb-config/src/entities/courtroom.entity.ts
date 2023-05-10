import { CosmosPartitionKey } from '@nestjs/azure-database';
import { EntityBase } from './base';
import EditMetadata from './editmetadata';
import JudgeInfo from './judgeinfo';

@CosmosPartitionKey('id')
export default class Courtroom implements EntityBase {
  static entityType = 'courtroom';

  static entitySchema = 'urn:courtroom/v1';

  id!: string;

  readonly type = Courtroom.entityType;

  readonly schema = Courtroom.entitySchema;

  readonly partitionKey = 'id';

  courtId!: string;

  organisationId!: string;

  name!: string;

  presidingJudges!: JudgeInfo[];

  terminologySetId!: string;

  msGraphResourceUri?: string;

  status!: string;

  editMetadata!: EditMetadata;
}
