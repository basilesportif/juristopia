import React from 'react'
import { useStore } from './store'
import { Canvas } from '@react-three/fiber'
import { OrbitControls } from '@react-three/drei'
import GridCubes from './components/GridCubes';

export function UniverseScene() {
  const { halfSideLength } = useStore();

  return (
    <Canvas camera={{ position: [70, 60, 30] }}>
      <color attach="background" args={['#f0f0e8']} />
      <ambientLight intensity={0.2} />
      <pointLight position={[10, 10, 10]} intensity={0.8} />
      <GridCubes gridSize={3} cubeSize={halfSideLength * 2} opacity={0.2} />
      <OrbitControls makeDefault />
    </Canvas>
  )
}