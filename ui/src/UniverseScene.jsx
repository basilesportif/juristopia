import React, { useRef, useCallback } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import { OrbitControls } from '@react-three/drei'
import { useStore } from './store'
import * as THREE from 'three'

function Point({ position, active, index }) {
  const scale = useStore((state) => state.pointScale)
  const togglePoint = useStore((state) => state.togglePoint)
  const meshRef = useRef()

  const color = active ? new THREE.Color(1, 1, 0) : new THREE.Color(0.2, 0.2, 0)

  useFrame(() => {
    if (meshRef.current) {
      meshRef.current.rotation.x += 0.01
      meshRef.current.rotation.y += 0.01
    }
  })

  const handleClick = useCallback((event) => {
    event.stopPropagation()
    console.log(`Point ${index} clicked`)  // Debug log
    togglePoint(index)
  }, [togglePoint, index])

  return (
    <mesh
      ref={meshRef}
      position={position}
      onClick={handleClick}
    >
      <boxGeometry args={[scale, scale, scale]} />
      <meshStandardMaterial color={color} emissive={color} emissiveIntensity={active ? 0.5 : 0.2} />
    </mesh>
  )
}

function PointCloud() {
  const points = useStore((state) => state.points)
  const groupRef = useRef()

  useFrame(() => {
    if (groupRef.current) {
      // groupRef.current.rotation.x += 0.001
      // groupRef.current.rotation.y += 0.001
    }
  })

  return (
    <group ref={groupRef}>
      {points.map((point, index) => (
        <Point index={index} position={point.position} active={point.active} />
      ))}
    </group>
  )
}

export function UniverseScene() {
  return (
    <Canvas camera={{ position: [0, 0, 15] }}>
      <color attach="background" args={['black']} />
      <ambientLight intensity={0.2} />
      <pointLight position={[10, 10, 10]} intensity={0.8} />
      <PointCloud />
      <OrbitControls makeDefault />
    </Canvas>
  )
}