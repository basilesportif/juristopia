import React, { useState, useEffect } from 'react';
import { useStore } from './store'
import { UniverseScene } from './UniverseScene'
import cubesFixture from './fixtures/cubesFixture.json'

function App() {
  const { addWorld, setHalfSideLength, containingCubes, worlds } = useStore()
  const [socket, setSocket] = useState(null);

  useEffect(() => {
    // Create WebSocket connection
    const url = "ws://localhost:8080/juristopia:juristopia:basilesex.os/ws"
    const ws = new WebSocket(url);

    ws.onopen = () => {
      console.log('WebSocket connected');
      setSocket(ws);
    };

    ws.onmessage = (event) => {
      console.log('Received message:', event.data);
      const message = JSON.parse(event.data);
      console.log('Received message:', message);
      // Handle the received message here
    };

    ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };

    ws.onclose = () => {
      console.log('WebSocket disconnected');
    };
    return () => {
      if (ws) {
        ws.close();
      }
    };
  }, []);

  // load cubes. Can do this via API later
  useEffect(() => {
    setHalfSideLength(cubesFixture.halfSideLength);
    cubesFixture.worlds.forEach(world => {
      addWorld(world);
    });
    console.log(worlds.length);
  }, []);

  const handleGetFromWS = () => {
    if (socket) {
      socket.send(JSON.stringify({ "Get": null }));
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
      <button onClick={handleGetFromWS}>Get from WS</button>
      <div style={{ width: '1200px', height: '600px', marginTop: '20px' }}>
        <UniverseScene />
      </div>
      <div style={{ marginBottom: '20px', textAlign: 'center' }}>
        <h2>Universe Statistics</h2>
        <p>Number of Worlds: {worlds.length}</p>
        <ul>
          {worlds.map((world, index) => (
            <li key={index}>{world.name}</li>
          ))}
        </ul>
        <p>Number of Containing Cubes: {Object.keys(containingCubes).length}</p>
        <h3>Containing Cube Densities:</h3>
        <ul>
          {Object.entries(containingCubes).map(([coords, count]) => (
            <li key={coords}>
              Cube {coords}: {count} world{count !== 1 ? 's' : ''}
            </li>
          ))}
        </ul>
      </div>
    </div>
  )
}

export default App