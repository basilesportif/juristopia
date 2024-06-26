import React, { useEffect } from 'react';
import { useStore } from './store'
import { UniverseScene } from './UniverseScene'
import cubesFixture from './fixtures/cubesFixture.json'

function App() {
  const { addWorld, setHalfSideLength, containingCubes, worlds } = useStore()

  // load cubes. Can do this via API later
  useEffect(() => {
    setHalfSideLength(cubesFixture.halfSideLength);
    cubesFixture.worlds.forEach(world => {
      addWorld(world);
    });
    console.log(worlds.length);
  }, []);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
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
      <div style={{ width: '1200px', height: '600px', marginTop: '20px' }}>
        <UniverseScene />
      </div>

    </div>
  )
}

export default App