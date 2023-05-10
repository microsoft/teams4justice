import { InjectModel } from '@nestjs/azure-database';
import { Global, Inject, Module, Provider, Scope } from '@nestjs/common';

const entityProviders: Provider<any>[] = [];

function getModelToken(model: string) {
  return `${model}AzureCosmosDbModel`;
}

function registerEntity(context: string) {
  const providerSymbol = Symbol(`ENTITY__${context}`);

  entityProviders.push({
    provide: providerSymbol,
    scope: Scope.TRANSIENT,
    useFactory: () => context,
  });

  return providerSymbol;
}

export function InjectEntity<T = any>(entity: T): any {
  return (target: object, key?: string, index?: number) => {
    const context = (entity as any).id;
    const model = registerEntity(context);
    key = key || 'entity';
    InjectModel(model)(target, key, index);
  };
}

export function RegisterModel(model: string): any {
  return (target: object, key?: string, index?: number) => {
    key = key || 'entity';
    Inject(model)(target, key, index);
  };
}

export const InjectEntityModel = (model: any) =>
  RegisterModel(getModelToken(model.name));

@Global()
@Module({
  providers: entityProviders,
  exports: entityProviders,
})
export class InjectModelModule {}
