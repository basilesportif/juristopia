import React, { useEffect } from 'react';
import { useStore } from './store'
import { UniverseScene } from './UniverseScene'
import cubesFixture from './fixtures/cubesFixture.json'

function App() {
  const { cubes, setCubesData } = useStore()

  useEffect(() => {
    setCubesData(cubesFixture);
  }, []);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
      <h1>3D Point Cloud</h1>
      <div style={{ width: '1200px', height: '600px', marginTop: '20px' }}>
        <UniverseScene />
      </div>
    </div>
  )
}

export default App