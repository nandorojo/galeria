import { StyleSheet, Text, View } from "react-native";

import * as Galeria from "galeria";

export default function App() {
  return (
    <View style={styles.container}>
      <Galeria.GaleriaView
        style={{
          width: 300,
          height: 300,
          backgroundColor: "red",
        }}
        name='hi'
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "center",
  },
});
