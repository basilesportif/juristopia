import React, { useRef, useEffect, useMemo } from 'react'
import { useStore } from '../store'
import * as THREE from 'three'
import { Text } from '@react-three/drei'

function DashedLine({ points, ...props }) {
  const ref = useRef()

  useEffect(() => {
    if (ref.current) {
      ref.current.computeLineDistances()
    }
  }, [points])

  return (
    <line ref={ref} {...props}>
      <bufferGeometry attach="geometry" {...new THREE.BufferGeometry().setFromPoints(points)} />
    </line>
  )
}

function CoordinateLabel({ position, text }) {
  return (
    <Text
      position={position}
      fontSize={0.5}
      color="#666666"
      anchorX="center"
      anchorY="middle"
    >
      {text}
    </Text>
  )
}

export function GridLines() {
  const points = useStore((state) => state.points)

  const gridElements = useMemo(() => {
    const elements = []
    const padding = 50
    const maxX = Math.max(...points.map(p => p.position[0])) + padding
    const maxY = Math.max(...points.map(p => p.position[1])) + padding
    const maxZ = Math.max(...points.map(p => p.position[2])) + padding
    const minX = Math.min(...points.map(p => p.position[0])) - padding
    const minY = Math.min(...points.map(p => p.position[1])) - padding
    const minZ = Math.min(...points.map(p => p.position[2])) - padding

    const lineMaterial = (
      <lineDashedMaterial
        attach="material"
        color="#444444"
        opacity={0.7}
        transparent={false}
        dashSize={1}
        gapSize={1}
      />
    )

    // Create grid lines for XY plane
    for (let x = Math.floor(minX / 10) * 10; x <= maxX; x += 10) {
      for (let y = Math.floor(minY / 10) * 10; y <= maxY; y += 10) {
        elements.push(
          <DashedLine
            key={`xy${x}${y}`}
            points={[new THREE.Vector3(x, y, minZ), new THREE.Vector3(x, y, maxZ)]}
          >
            {lineMaterial}
          </DashedLine>
        )
        // Coordinate label removed
      }
    }

    // Create grid lines for XZ plane
    for (let x = Math.floor(minX / 10) * 10; x <= maxX; x += 10) {
      for (let z = Math.floor(minZ / 10) * 10; z <= maxZ; z += 10) {
        elements.push(
          <DashedLine
            key={`xz${x}${z}`}
            points={[new THREE.Vector3(x, minY, z), new THREE.Vector3(x, maxY, z)]}
          >
            {lineMaterial}
          </DashedLine>
        )
        // Coordinate label removed
      }
    }

    // Create grid lines for YZ plane
    for (let y = Math.floor(minY / 10) * 10; y <= maxY; y += 10) {
      for (let z = Math.floor(minZ / 10) * 10; z <= maxZ; z += 10) {
        elements.push(
          <DashedLine
            key={`yz${y}${z}`}
            points={[new THREE.Vector3(minX, y, z), new THREE.Vector3(maxX, y, z)]}
          >
            {lineMaterial}
          </DashedLine>
        )
        // Coordinate label removed
      }
    }

    return elements
  }, [points])

  return <group>{gridElements}</group>
}