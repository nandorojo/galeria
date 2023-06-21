import { NativeModulesProxy, EventEmitter, Subscription } from 'expo-modules-core';

// Import the native module. On web, it will be resolved to Galeria.web.ts
// and on native platforms to Galeria.ts
import GaleriaModule from './GaleriaModule';
import GaleriaView from './GaleriaView';
import { ChangeEventPayload, GaleriaViewProps } from './Galeria.types';

// Get the native constant value.
export const PI = GaleriaModule.PI;

export function hello(): string {
  return GaleriaModule.hello();
}

export async function setValueAsync(value: string) {
  return await GaleriaModule.setValueAsync(value);
}

const emitter = new EventEmitter(GaleriaModule ?? NativeModulesProxy.Galeria);

export function addChangeListener(listener: (event: ChangeEventPayload) => void): Subscription {
  return emitter.addListener<ChangeEventPayload>('onChange', listener);
}

export { GaleriaView, GaleriaViewProps, ChangeEventPayload };
