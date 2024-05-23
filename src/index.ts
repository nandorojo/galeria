// export { default as Galeria } from './GaleriaView'
import type ActualGaleria from './GaleriaView'
export type { GaleriaViewProps } from './Galeria.types'
import * as presentation from '../presentation/Galeria'

export const Galeria = presentation.Galeria as typeof ActualGaleria
