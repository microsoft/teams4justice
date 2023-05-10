import { HttpModule, Module } from "@nestjs/common";
import { AzureAdConfiguration } from "./auth";
import AzureBlobStoreModule from "./blobstore/azure.blobstore.module";
import HttpBotServiceModule from "./botservice/http.botservice.module";
import { LoggerModule } from "./common/logger.module";
import Controllers from "./controllers";
import { TfjCqrsModule } from "./cqrs";
import Entities from "./entities";
import { InMemoryEntityStoreModule } from "./entitystore/inmemory.entitystore.module";
// eslint-disable-next-line max-len
import IncomingIntegrationEventProcessingModule from "./events/incoming-integration-event-processing/incoming-integration-event-processing.module";
import Handlers from "./handlers";
import InMemoryQueryHelpersModule from "./handlers/queries/query-helpers/in-memory-query-helpers.module";
import { InjectModule } from "./common/entity.module";

@Module({
  imports: [
    TfjCqrsModule,
    LoggerModule,
    InMemoryEntityStoreModule.forRoot([...Entities]),
    AzureBlobStoreModule,
    HttpBotServiceModule,
    HttpModule,
    IncomingIntegrationEventProcessingModule,
    InMemoryQueryHelpersModule,
    InjectModule,
  ],
  controllers: [...Controllers],
  providers: [...Handlers, AzureAdConfiguration],
})
export default class InMemoryAppModule {}
