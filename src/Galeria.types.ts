import { ImageStyle } from "react-native";

export type ChangeEventPayload = {
  value: string;
};

export type GaleriaViewProps = {
  style?: ImageStyle;
  src: string;
  /**
   * Sets the background of the popup. Defaults to "dark".
   */
  theme?: "dark" | "light";
} & (
  | {}
  | {
      urls: string[];
      initialIndex: number;
    }
);
