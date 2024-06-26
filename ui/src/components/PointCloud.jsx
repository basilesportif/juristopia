import React, { useRef, useCallback } from 'react'
import { useFrame } from '@react-three/fiber'
import { useStore } from '../store'
import * as THREE from 'three'
import { Text } from '@react-three/drei'

function PointLabel({ position }) {
  return (
    <Text
      position={position}
      fontSize={0.1}
      color="#006400"
      anchorX="left"
      anchorY="middle"
    >
      {`${position[0].toFixed(2)}, ${position[1].toFixed(2)}, ${position[2].toFixed(2)}`}
    </Text>
  )
}

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
    togglePoint(index)
  }, [togglePoint, index])

  return (
    <group>
      <mesh
        ref={meshRef}
        position={position}
        onClick={handleClick}
      >
        <boxGeometry args={[scale, scale, scale]} />
        <meshStandardMaterial color={color} emissive={color} emissiveIntensity={active ? 0.5 : 0.2} />
      </mesh>
      <PointLabel
        position={[position[0] + scale, position[1], position[2]]}
      />
    </group>
  )
}

export function PointCloud() {
  const points = useStore((state) => state.points)
  const groupRef = useRef()

  useFrame(() => {
    if (groupRef.current) {
      // Uncomment if you want the entire point cloud to rotate
      // groupRef.current.rotation.x += 0.001
      // groupRef.current.rotation.y += 0.001
    }
  })

  return (
    <group ref={groupRef}>
      {points.map((point, index) => (
        <Point key={index} index={index} position={point.position} active={point.active} />
      ))}
    </group>
  )
}