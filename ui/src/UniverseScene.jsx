import React from 'react'
import { Canvas } from '@react-three/fiber'
import { OrbitControls } from '@react-three/drei'
import { GridLines } from './components/GridLines'
import GridCubes from './components/GridCubes';
import { PointCloud } from './components/PointCloud' // Assuming you have this component

export function UniverseScene() {
  return (
    <Canvas camera={{ position: [0, 0, 15] }}>
      <color attach="background" args={['#f0f0e8']} />
      <ambientLight intensity={0.2} />
      <pointLight position={[10, 10, 10]} intensity={0.8} />
      <GridCubes gridSize={3} cubeSize={10} opacity={0.12} />
      <GridLines gridSize={3} cubeSize={10} />
      <OrbitControls makeDefault />
    </Canvas>
  )
}