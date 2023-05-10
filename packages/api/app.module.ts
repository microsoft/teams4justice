import { HttpModule, Module, ValidationPipe } from "@nestjs/common";
import { APP_INTERCEPTOR, APP_PIPE } from "@nestjs/core";
import { AuthenticationModule } from "./auth";
import AzureBlobStoreModule from "./blobstore/azure.blobstore.module";
import HttpBotServiceModule from "./botservice/http.botservice.module";
import { configModule, LoggerModule } from "./common";
import Controllers from "./controllers";
import TfjCqrsModule from "./cqrs/tfj-cqrs.module";
import {
  Case,
  Court,
  Courtroom,
  Hearing,
  HearingParticipant,
  HearingRoom,
  Organisation,
  SoloRoom,
  RoomOnlineMeeting,
  RoomParticipant,
} from "./entities";
import { AzureCosmosEntityStoreModule } from "./entitystore/azure-cosmos.entitystore.module";
import AzureEventGridPublishingModule from "./event-publishing/azure-event-grid-publishing.module";
// eslint-disable-next-line max-len
import IncomingIntegrationEventProcessingModule from "./events/incoming-integration-event-processing/incoming-integration-event-processing.module";
import IntegrationEventConverters from "./events/integration-event-converters";
import Handlers from "./handlers";
import QueryHelpersModule from "./handlers/queries/query-helpers/query-helpers.module";
import NoCacheInterceptor from "./interceptors/no-cache.interceptor";
import { QueryBus } from "@nestjs/cqrs";
import { InjectModule } from "./common/entity.module";

@Module({
  imports: [
    configModule,
    LoggerModule,
    TfjCqrsModule,
    AzureCosmosEntityStoreModule.forRoot([
      { entity: Organisation, containerName: "courts" },
      { entity: Court, containerName: "courts" },
      { entity: Courtroom, containerName: "courts" },
      { entity: Case, containerName: "hearings" },
      { entity: Hearing, containerName: "hearings" },
      { entity: HearingParticipant, containerName: "hearings" },
      { entity: HearingRoom, containerName: "hearings" },
      { entity: SoloRoom, containerName: "hearings" },
      { entity: RoomOnlineMeeting, containerName: "hearings" },
      { entity: RoomParticipant, containerName: "hearings" },
    ]),
    AzureBlobStoreModule,
    AzureEventGridPublishingModule,
    AuthenticationModule.register(),
    HttpBotServiceModule,
    HttpModule,
    IncomingIntegrationEventProcessingModule,
    QueryHelpersModule,
    InjectModule,
  ],
  controllers: [...Controllers],
  providers: [
    ...Handlers,
    ...IntegrationEventConverters,
    {
      provide: APP_PIPE,
      useClass: ValidationPipe,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: NoCacheInterceptor,
    },
  ],
})
export default class AppModule {}
