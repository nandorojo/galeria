import { ViewStyle } from "react-native";

export type ChangeEventPayload = {
  value: string;
};

export type GaleriaViewProps = {
  style?: ViewStyle;
  src: string;
} & (
  | {}
  | {
      urls: string[];
      initialIndex: number;
    }
);
