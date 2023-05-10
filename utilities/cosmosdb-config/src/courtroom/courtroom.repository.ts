import { Container } from '@azure/cosmos';
import { InjectModel } from '@nestjs/azure-database';
import {
  Logger,
  Injectable,
  UnprocessableEntityException,
} from '@nestjs/common';
import Courtroom from '../entities/courtroom.entity';
import Court from 'src/entities/court.entity';
import { InjectEntityModel } from 'src/common/inject.module';

@Injectable()
export class CourtroomRepository {
  private logger = new Logger(this.constructor.name);

  constructor(
    @InjectEntityModel(Court) private readonly container: Container,
  ) {}

  async create(item: Courtroom): Promise<Courtroom | string> {
    try {
      const response = await this.container.items.create(item);
      this.logger.verbose(`Create RUs: ${response.requestCharge}`);
      return response.resource as Courtroom;
    } catch (error) {
      this.logger.error(error);
      if (error instanceof Error) {
        return error.message;
      }
      throw new UnprocessableEntityException(error);
    }
  }

  async update(id: string, data: Courtroom): Promise<Courtroom | string> {
    try {
      const { resource: item } = await this.container.item(id, 'type').read();

      // Disclaimer: Assign only the properties you are expecting!
      Object.assign(item, data);

      const { resource: replaced } = await this.container
        .item(id, 'type')
        .replace<Courtroom>(item);
      return replaced!;
    } catch (error) {
      this.logger.error(error);
      if (error instanceof Error) {
        return error.message;
      }
      throw new UnprocessableEntityException(error);
    }
  }

  async remove(id: string) {
    try {
      const { resource: deleted } = await this.container
        .item(id, 'type')
        .delete<Courtroom>();

      return deleted;
    } catch (error) {
      this.logger.error(error);
      throw new UnprocessableEntityException(error);
    }
  }

  async findAll(): Promise<Courtroom[]> {
    const querySpec = {
      query: 'SELECT * FROM root r WHERE r.type = "courtroom"',
    };

    const results = await this.container.items
      .query<Courtroom>(querySpec, {})
      .fetchAll();
    this.logger.verbose(`Find By Id RUs: ${results.requestCharge}`);
    return results.resources;
  }

  async findById(id: string): Promise<Courtroom> {
    try {
      const querySpec = {
        query: 'SELECT * FROM root r WHERE r.id=@id',
        parameters: [
          {
            name: '@id',
            value: id,
          },
        ],
      };

      const results = await this.container.items
        .query<Courtroom>(querySpec, {})
        .fetchAll();
      this.logger.verbose(`Find By Id RUs: ${results.requestCharge}`);
      return results.resources.shift()!;
    } catch (error) {
      // Entity not found
      this.logger.error(error);
      throw new UnprocessableEntityException(error);
    }
  }

  async findCourtroom(orgId: string, courtId: string): Promise<Courtroom[]> {
    try {
      const querySpec = {
        query:
          'SELECT * FROM root r WHERE r.organisationId=@orgId and r.courtId=@courtId and r.type = "courtroom"',
        parameters: [
          {
            name: '@orgId',
            value: orgId,
          },
          {
            name: '@courtId',
            value: courtId,
          },
        ],
      };

      const results = await this.container.items
        .query<Courtroom>(querySpec, {})
        .fetchAll();
      this.logger.verbose(`Find By Id RUs: ${results.requestCharge}`);
      return results.resources;
    } catch (error) {
      // Entity not found
      this.logger.error(error);
      throw new UnprocessableEntityException(error);
    }
  }

  async count(): Promise<number> {
    const querySpec = {
      query: 'SELECT VALUE COUNT(1) FROM root r',
    };

    const results = await this.container.items.query(querySpec).fetchAll();
    this.logger.verbose(`Count RUs: ${results.requestCharge}`);
    return results.resources.shift();
  }
}
