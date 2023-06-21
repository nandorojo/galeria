import { StyleSheet, Text, View } from 'react-native';

import * as Galeria from 'galeria';

export default function App() {
  return (
    <View style={styles.container}>
      <Text>{Galeria.hello()}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
