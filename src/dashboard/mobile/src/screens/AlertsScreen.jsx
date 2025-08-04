// src/dashboard/mobile/src/screens/AlertsScreen.jsx
import React, { useState, useEffect } from 'react';
import { View, Text, FlatList, StyleSheet } from 'react-native';
import { Card } from 'react-native-ui-lib';

const AlertsScreen = () => {
  const [alerts, setAlerts] = useState([]);

  const renderAlert = ({ item }) => (
    <Card style={styles.alertCard}>
      <Text style={styles.alertTitle}>{item.title}</Text>
      <Text style={styles.alertDescription}>{item.description}</Text>
      <Text style={styles.alertTime}>{item.timestamp}</Text>
    </Card>
  );

  return (
    <View style={styles.container}>
      <FlatList
        data={alerts}
        renderItem={renderAlert}
        keyExtractor={item => item.id}
      />
    </View>
  );
};
