import { NestFactory } from "@nestjs/core";

if (process.env.NODE_ENV !== "production") {
  require("dotenv").config();
}
import AppModule from "./app.module";
import getCorsConfiguration from "./common/cors-configuration";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";

async function bootstrap() {
  console.log("Starting T4J API...");
  console.log("NODE_ENV: " + process.env.NODE_ENV);
  console.log("AZURE_COSMOS_DB_NAME: " + process.env.AZURE_COSMOS_DB_NAME);
  console.log(
    "AZURE_COSMOS_DB_ENDPOINT: " + process.env.AZURE_COSMOS_DB_ENDPOINT
  );
  console.log("AZURE_COSMOS_DB_KEY: " + process.env.AZURE_COSMOS_DB_KEY);
  console.log("Project Tag: " + process.env.PROJECT_API_TAG);

  const app = await NestFactory.create(AppModule);

  const options = new DocumentBuilder()
    .setTitle("Teams For Justice APIs")
    .setDescription(
      "APIs set of endpoints to support the Teams For Justice application."
    )
    .setVersion("1.0")
    .addTag(process.env.PROJECT_API_TAG ?? "T4J")
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, options);
  SwaggerModule.setup("api", app, document);

  await app.init();
  await app.listen(process.env.PORT || 3001);

  app.enableCors(getCorsConfiguration());
  console.log(`API Application is running on: ${await app.getUrl()}`);
}
bootstrap();
