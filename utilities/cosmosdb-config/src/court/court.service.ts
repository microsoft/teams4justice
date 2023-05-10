import { Injectable, NotFoundException } from '@nestjs/common';
import Court from '../entities/court.entity';
import { CourtRepository } from './court.repository';

@Injectable()
export class CourtService {
  constructor(private readonly courtRepository: CourtRepository) {}

  async create(court: Court): Promise<Court | string> {
    try {
      const result = this.courtRepository.create(court);
      if (result instanceof Court) {
        return result as Court;
      } else {
        return String(result);
      }
    } catch (error) {
      throw error;
    }
  }

  async update(id: string, courtData: Court): Promise<Court | string> {
    return this.courtRepository.update(id, courtData);
  }

  async delete(id: string) {
    const court = await this.courtRepository.findById(id);
    if (court) {
      return this.courtRepository.remove(id);
    }

    throw new NotFoundException('Item with id: ' + id + ' not found');
  }

  async getAll(): Promise<Court[]> {
    return this.courtRepository.findAll();
  }

  async getCourts(orgId: string): Promise<Court[]> {
    return this.courtRepository.findById(orgId);
  }
}
