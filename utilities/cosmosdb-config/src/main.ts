import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';

if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}

import { AppModule } from './app.module';

async function bootstrap() {
  console.log('Starting Cosmos DB Configurator...');
  console.log('NODE_ENV: ' + process.env.NODE_ENV);
  console.log('AZURE_COSMOS_DB_NAME: ' + process.env.AZURE_COSMOS_DB_NAME);
  console.log(
    'AZURE_COSMOS_DB_ENDPOINT: ' + process.env.AZURE_COSMOS_DB_ENDPOINT,
  );
  console.log('Project Tag: ' + process.env.PROJECT_API_TAG);

  const app = await NestFactory.create(AppModule);

  const options = new DocumentBuilder()
    .setTitle('T4J Cosmos DB Configurator API')
    .setDescription(
      'T4J Cosmos DB Configurator API for configuring the Cosmos DB database',
    )
    .setVersion('1.0')
    .addTag(process.env.PROJECT_API_TAG ?? 'T4J')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, options);
  SwaggerModule.setup('api', app, document);

  await app.init();
  await app.listen(process.env.PORT || 3000);

  console.log(
    `Cosmos DB Configurator Application is running on: ${await app.getUrl()}`,
  );
}
bootstrap();
