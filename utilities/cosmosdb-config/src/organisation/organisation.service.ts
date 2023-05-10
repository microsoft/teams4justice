import { Injectable, NotFoundException } from '@nestjs/common';
import Organisation from '../entities/organisation.entity';
import { OrganisationRepository } from './organisation.repository';

@Injectable()
export class OrganisationService {
  constructor(private readonly orgRepository: OrganisationRepository) {}

  async create(organisation: Organisation): Promise<Organisation | string> {
    try {
      const result = this.orgRepository.create(organisation);
      if (result instanceof Organisation) {
        return result as Organisation;
      } else {
        return String(result);
      }
    } catch (error) {
      throw error;
    }
  }

  async update(
    id: string,
    organisationData: Organisation,
  ): Promise<Organisation> {
    return this.orgRepository.update(id, organisationData);
  }

  async delete(id: string) {
    const organisation = await this.orgRepository.findById(id);
    if (organisation) {
      return this.orgRepository.remove(id);
    }

    throw new NotFoundException('Item with id: ' + id + ' not found');
  }

  async getAll(): Promise<any[]> {
    return this.orgRepository.findAll();
  }

  async getAllOrganisations(): Promise<Organisation[]> {
    return this.orgRepository.findAllOrganisations();
  }

  async getOrganisation(id: string): Promise<Organisation> {
    return this.orgRepository.findById(id);
  }
}
