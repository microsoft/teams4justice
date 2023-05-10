import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  UnprocessableEntityException,
  InternalServerErrorException,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { CourtService } from '../court/court.service';
import Court from '../entities/court.entity';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import Organisation from 'src/entities/organisation.entity';
import Courtroom from 'src/entities/courtroom.entity';
import { OrganisationService } from 'src/organisation/organisation.service';
import { CourtroomService } from 'src/courtroom/courtroom.service';

@ApiBearerAuth()
@ApiTags(process.env.PROJECT_API_TAG ?? 'T4J')
@Controller('dbconfig')
export class CourtController {
  constructor(
    private readonly courtService: CourtService,
    private readonly orgService: OrganisationService,
    private readonly courtroomService: CourtroomService,
  ) {}

  @Post('organisation/create')
  @ApiOperation({ summary: 'Create organisation of the court' })
  @ApiResponse({ status: 403, description: 'Forbidden.' })
  @ApiResponse({ status: 500, description: 'Internal Error.' })
  async createOrganisation(@Body() createOrganisation: Organisation) {
    try {
      this.orgService.create(createOrganisation);
    } catch (error) {
      return new BadRequestException(error);
    }
  }

  @Post('court/create')
  @ApiOperation({ summary: 'Create court' })
  @ApiResponse({ status: 403, description: 'Forbidden.' })
  async createCourt(@Body() createCourt: Court) {
    try {
      this.courtService.create(createCourt);
    } catch (error) {
      return new BadRequestException(error);
    }
  }

  @Post('courtroom/create')
  @ApiOperation({ summary: 'Create court courtroom' })
  @ApiResponse({ status: 403, description: 'Forbidden.' })
  async createCourtroom(@Body() createCourtroom: Courtroom) {
    try {
      this.courtroomService.create(createCourtroom);
    } catch (error) {
      return new BadRequestException(error);
    }
  }

  @Get()
  @ApiResponse({
    status: 200,
    description: 'All court entities',
    type: Array,
  })
  async findAll(): Promise<any[]> {
    try {
      return this.orgService.getAll();
    } catch (error) {
      if (error instanceof UnprocessableEntityException) {
        throw new NotFoundException(error);
      } else {
        throw error;
      }
    }
  }

  @Get('organisation')
  @ApiResponse({
    status: 200,
    description: 'All court organisations',
    type: Organisation,
  })
  async findAllOrganisations(): Promise<Organisation[]> {
    try {
      return this.orgService.getAllOrganisations();
    } catch (error) {
      if (error instanceof UnprocessableEntityException) {
        throw new NotFoundException(error);
      } else {
        throw error;
      }
    }
  }

  @Get('court')
  @ApiResponse({
    status: 200,
    description: 'All court records',
    type: Court,
  })
  async findAllCourts(): Promise<Court[]> {
    try {
      return this.courtService.getAll();
    } catch (error) {
      if (error instanceof UnprocessableEntityException) {
        throw new NotFoundException(error);
      } else {
        throw error;
      }
    }
  }

  @Get('courtroom')
  @ApiResponse({
    status: 200,
    description: 'All court courtrooms',
    type: Courtroom,
  })
  async findAllCourtrooms(): Promise<Courtroom[]> {
    try {
      return this.courtroomService.getAll();
    } catch (error) {
      if (error instanceof UnprocessableEntityException) {
        throw new NotFoundException(error);
      } else {
        throw error;
      }
    }
  }

  @Get('organisation/:id')
  @ApiParam({
    name: 'id',
    description: 'Organisation Id',
  })
  @ApiResponse({
    status: 200,
    description: 'The found organisation record',
    type: Organisation,
  })
  findOrganisation(@Param('id') id: string): Promise<Organisation> {
    try {
      return this.orgService.getOrganisation(id);
    } catch (error) {
      if (error instanceof UnprocessableEntityException) {
        throw new NotFoundException(error);
      } else {
        throw error;
      }
    }
  }

  @Get('court/:id')
  @ApiResponse({
    status: 200,
    description: 'The found court record',
    type: Court,
  })
  @ApiParam({
    name: 'id',
    description: 'Organisation Id',
  })
  findCourt(@Param('id') id: string): Promise<Court[]> {
    try {
      return this.courtService.getCourts(id);
    } catch (error) {
      if (error instanceof UnprocessableEntityException) {
        throw new NotFoundException(error);
      } else {
        throw error;
      }
    }
  }

  @Get('courtroom/:orgId/:courtId')
  @ApiResponse({
    status: 200,
    description: 'The found courtroom record',
    type: Courtroom,
  })
  @ApiParam({
    name: 'orgId',
    description: 'Organisation Id',
  })
  @ApiParam({
    name: 'courtId',
    description: 'Court Id',
  })
  findCourtroom(
    @Param('orgId') orgId: string,
    @Param('courtId') courtId: string,
  ) {
    try {
      return this.courtroomService.getCourtrooms(orgId, courtId);
    } catch (error) {
      if (error instanceof UnprocessableEntityException) {
        throw new NotFoundException(error);
      } else {
        throw error;
      }
    }
  }
}
