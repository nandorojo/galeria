import { StyleSheet, Text, View } from "react-native";

import * as g from "galeria";

const Galeria = g.GaleriaView;

export default function App() {
  return (
    <View style={styles.container}>
      <Galeria
        style={{
          width: 200 * 1.2,
          height: 130 * 1.2,
        }}
        src='https://raw.githubusercontent.com/michaelhenry/MHFacebookImageViewer/master/Example/Demo/Assets.xcassets/cat1.imageset/cat1.jpg'
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "black",
    alignItems: "center",
    justifyContent: "center",
  },
});
