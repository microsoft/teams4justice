import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { writeFileSync } from 'fs';
import * as path from 'path';
import InMemoryAppModule from './in-memory.app.module';

async function bootstrap() {
  const app = await NestFactory.create(InMemoryAppModule);

  const APP_NAME = process.env.npm_package_name;
  const APP_VERSION = process.env.npm_package_version;

  const docOptions = new DocumentBuilder()
    .setTitle(APP_NAME!)
    .setVersion(APP_VERSION!)
    .build();
  const document = SwaggerModule.createDocument(app, docOptions);

  const outputPath = path.resolve(__dirname, '..', 'swagger.json');
  writeFileSync(outputPath, JSON.stringify(document, null, 2), {
    encoding: 'utf8',
  });

  await app.close();
}
bootstrap();
