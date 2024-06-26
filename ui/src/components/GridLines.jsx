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

export function GridLines({ gridSize = 5, cubeSize = 10 }) {
  const gridElements = useMemo(() => {
    const elements = []
    const maxCoord = gridSize * cubeSize
    const minCoord = -maxCoord

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
    for (let x = minCoord; x <= maxCoord; x += cubeSize) {
      for (let y = minCoord; y <= maxCoord; y += cubeSize) {
        elements.push(
          <DashedLine
            key={`xy${x}${y}`}
            points={[new THREE.Vector3(x, y, minCoord), new THREE.Vector3(x, y, maxCoord)]}
          >
            {lineMaterial}
          </DashedLine>
        )
      }
    }

    // Create grid lines for XZ plane
    for (let x = minCoord; x <= maxCoord; x += cubeSize) {
      for (let z = minCoord; z <= maxCoord; z += cubeSize) {
        elements.push(
          <DashedLine
            key={`xz${x}${z}`}
            points={[new THREE.Vector3(x, minCoord, z), new THREE.Vector3(x, maxCoord, z)]}
          >
            {lineMaterial}
          </DashedLine>
        )
      }
    }

    // Create grid lines for YZ plane
    for (let y = minCoord; y <= maxCoord; y += cubeSize) {
      for (let z = minCoord; z <= maxCoord; z += cubeSize) {
        elements.push(
          <DashedLine
            key={`yz${y}${z}`}
            points={[new THREE.Vector3(minCoord, y, z), new THREE.Vector3(maxCoord, y, z)]}
          >
            {lineMaterial}
          </DashedLine>
        )
      }
    }

    return elements
  }, [gridSize, cubeSize])

  return <group>{gridElements}</group>
}