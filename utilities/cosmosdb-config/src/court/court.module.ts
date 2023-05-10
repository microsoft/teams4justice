import { Module } from '@nestjs/common';
import { AzureCosmosDbModule } from '@nestjs/azure-database';
import Court from '../entities/court.entity';
import { CourtService } from './court.service';
import { CourtRepository } from './court.repository';
import { CourtController } from 'src/controllers/court.controller';
import { OrganisationService } from 'src/organisation/organisation.service';
import { CourtroomService } from 'src/courtroom/courtroom.service';
import { OrganisationRepository } from 'src/organisation/organisation.repository';
import { CourtroomRepository } from 'src/courtroom/courtroom.repository';
import { InjectModelModule } from 'src/common/inject.module';

@Module({
  imports: [AzureCosmosDbModule.forFeature([{ dto: Court }])],
  providers: [
    CourtService,
    CourtRepository,
    OrganisationService,
    OrganisationRepository,
    CourtroomService,
    CourtroomRepository,
  ],
  controllers: [CourtController],
})
export class CourtModule {}
