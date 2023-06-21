import * as React from 'react';

import { GaleriaViewProps } from './Galeria.types';

export default function GaleriaView(props: GaleriaViewProps) {
  return (
    <div>
      <span>{props.name}</span>
    </div>
  );
}
