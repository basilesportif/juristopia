import React from 'react'
import { useStore } from './store'
import { UniverseScene } from './UniverseScene'

function App() {
  const { points, togglePoint, pointScale, setPointScale } = useStore()

  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
      <h1>3D Point Cloud</h1>
      <div style={{ marginBottom: '20px' }}>
        <label htmlFor="pointScale">Point Scale: </label>
        <input
          id="pointScale"
          type="range"
          min="0.05"
          max="0.8"
          step="0.05"
          value={pointScale}
          onChange={(e) => setPointScale(parseFloat(e.target.value))}
        />
        <span>{pointScale.toFixed(2)}</span>
      </div>
      <div style={{ width: '1200px', height: '600px', marginTop: '20px' }}>
        <UniverseScene />
      </div>
      <div style={{ marginTop: '20px' }}>
        <h2>Toggle Points</h2>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(10, 1fr)', gap: '5px' }}>
          {points.map((_, index) => (
            <button
              key={index}
              onClick={() => togglePoint(index)}
              style={{
                width: '30px',
                height: '30px',
                backgroundColor: points[index].active ? 'yellow' : 'gray'
              }}
            >
              {index}
            </button>
          ))}
        </div>
      </div>
    </div>
  )
}

export default App