import { Container } from '@azure/cosmos';
import { InjectModel } from '@nestjs/azure-database';
import {
  Logger,
  Injectable,
  UnprocessableEntityException,
} from '@nestjs/common';
import Organisation from '../entities/organisation.entity';
import Court from 'src/entities/court.entity';
import { InjectEntityModel } from 'src/common/inject.module';

@Injectable()
export class OrganisationRepository {
  private logger = new Logger(this.constructor.name);

  constructor(
    @InjectEntityModel(Court) private readonly container: Container,
  ) {}

  async create(item: Organisation): Promise<Organisation | string> {
    try {
      const response = await this.container.items.create(item);
      this.logger.verbose(`Create RUs: ${response.requestCharge}`);
      return response.resource as Organisation;
    } catch (error) {
      this.logger.error(error);
      if (error instanceof Error) {
        return error.message;
      }
      throw new UnprocessableEntityException(error);
    }
  }

  async update(id: string, data: Organisation): Promise<Organisation> {
    try {
      const { resource: item } = await this.container.item(id, 'type').read();

      // Disclaimer: Assign only the properties you are expecting!
      Object.assign(item, data);

      const { resource: replaced } = await this.container
        .item(id, 'type')
        .replace<Organisation>(item);
      return replaced!;
    } catch (error) {
      this.logger.error(error);
      throw new UnprocessableEntityException(error);
    }
  }

  async remove(id: string) {
    try {
      const { resource: deleted } = await this.container
        .item(id, 'type')
        .delete<Organisation>();

      return deleted;
    } catch (error) {
      this.logger.error(error);
      throw new UnprocessableEntityException(error);
    }
  }

  async findAll(): Promise<any[]> {
    const querySpec = {
      query: 'SELECT * FROM root r',
    };

    const results = await this.container.items
      .query<Organisation>(querySpec, {})
      .fetchAll();
    this.logger.verbose(`Find By Id RUs: ${results.requestCharge}`);
    return results.resources;
  }

  async findAllOrganisations(): Promise<Organisation[]> {
    const querySpec = {
      query: 'SELECT * FROM root r WHERE r.type = "organisation"',
    };

    const results = await this.container.items
      .query<Organisation>(querySpec, {})
      .fetchAll();
    this.logger.verbose(`Find By Id RUs: ${results.requestCharge}`);
    return results.resources;
  }

  async findById(id: string): Promise<Organisation> {
    try {
      const querySpec = {
        query:
          'SELECT * FROM root r WHERE r.id=@id and r.type = "organisation"',
        parameters: [
          {
            name: '@id',
            value: id,
          },
        ],
      };

      const results = await this.container.items
        .query<Organisation>(querySpec, {})
        .fetchAll();
      this.logger.verbose(`Find By Id RUs: ${results.requestCharge}`);
      return results.resources.shift()!;
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
