import { Module } from '@nestjs/common';
import { AzureCosmosDbModule } from '@nestjs/azure-database';
import { CourtModule } from './court/court.module';
import { InjectModelModule } from './common/inject.module';

@Module({
  imports: [
    InjectModelModule,
    CourtModule,
    AzureCosmosDbModule.forRootAsync({
      useFactory: async () => ({
        dbName: process.env.AZURE_COSMOS_DB_NAME!,
        endpoint: process.env.AZURE_COSMOS_DB_ENDPOINT!,
        key: process.env.AZURE_COSMOS_DB_KEY!,
      }),
    }),
  ],
})
export class AppModule {}
