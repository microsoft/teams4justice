import { Injectable, NotFoundException } from '@nestjs/common';
import Courtroom from '../entities/courtroom.entity';
import { CourtroomRepository } from './courtroom.repository';

@Injectable()
export class CourtroomService {
  constructor(private readonly courtroomRepository: CourtroomRepository) {}

  async create(courtroom: Courtroom): Promise<Courtroom | string> {
    try {
      const result = this.courtroomRepository.create(courtroom);
      if (result instanceof Courtroom) {
        return result as Courtroom;
      } else {
        return String(result);
      }
    } catch (error) {
      throw error;
    }
  }

  async update(id: string, courtData: Courtroom): Promise<Courtroom | string> {
    return this.courtroomRepository.update(id, courtData);
  }

  async delete(id: string) {
    const courtroom = await this.courtroomRepository.findById(id);
    if (courtroom) {
      return this.courtroomRepository.remove(id);
    }

    throw new NotFoundException('Item with id: ' + id + ' not found');
  }

  async getAll(): Promise<Courtroom[]> {
    return this.courtroomRepository.findAll();
  }

  async getCourtrooms(orgId: string, courtId: string): Promise<Courtroom[]> {
    return this.courtroomRepository.findCourtroom(orgId, courtId);
  }
}
