import { requireNativeViewManager } from "expo-modules-core";
import * as React from "react";

import { GaleriaViewProps } from "./Galeria.types";

const NativeView: React.ComponentType<GaleriaViewProps> =
  requireNativeViewManager("Galeria");

export default function GaleriaView(props: GaleriaViewProps) {
  return <NativeView initialIndex={0} {...props} src={props.src} />;
}
