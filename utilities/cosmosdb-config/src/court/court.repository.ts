import { Container } from '@azure/cosmos';
import { InjectModel } from '@nestjs/azure-database';
import {
  Logger,
  Injectable,
  UnprocessableEntityException,
} from '@nestjs/common';
import Court from '../entities/court.entity';
import { InjectEntityModel } from 'src/common/inject.module';

@Injectable()
export class CourtRepository {
  private logger = new Logger(this.constructor.name);

  constructor(
    @InjectEntityModel(Court) private readonly container: Container,
  ) {}

  async create(item: Court): Promise<Court | string> {
    try {
      const response = await this.container.items.create(item);
      this.logger.verbose(`Create Court with RUs: ${response.requestCharge}`);
      return response.resource as Court;
    } catch (error) {
      this.logger.error(error);
      if (error instanceof Error) {
        return error.message;
      }
      throw new UnprocessableEntityException(error);
    }
  }

  async update(id: string, data: Court): Promise<Court | string> {
    try {
      const { resource: item } = await this.container.item(id, 'type').read();

      // Disclaimer: Assign only the properties you are expecting!
      Object.assign(item, data);

      const { resource: replaced } = await this.container
        .item(id, 'type')
        .replace<Court>(item);
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
        .delete<Court>();

      return deleted;
    } catch (error) {
      this.logger.error(error);
      throw new UnprocessableEntityException(error);
    }
  }

  async findAll(): Promise<Court[]> {
    const querySpec = {
      query: 'SELECT * FROM root r WHERE r.type = "court"',
    };

    const results = await this.container.items
      .query<Court>(querySpec, {})
      .fetchAll();
    this.logger.verbose(`Find By Id RUs: ${results.requestCharge}`);
    return results.resources;
  }

  async findById(id: string): Promise<Court[]> {
    try {
      const querySpec = {
        query:
          'SELECT * FROM root r WHERE r.organisationId=@id and r.type = "court"',
        parameters: [
          {
            name: '@id',
            value: id,
          },
        ],
      };

      const results = await this.container.items
        .query<Court>(querySpec, {})
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
