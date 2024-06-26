import React, { useRef, useEffect, useMemo } from 'react';
import { Box, Text } from '@react-three/drei';
import * as THREE from 'three';

function DashedLine({ points, ...props }) {
  const ref = useRef();

  useEffect(() => {
    if (ref.current) {
      ref.current.computeLineDistances();
    }
  }, [points]);

  return (
    <line ref={ref} {...props}>
      <bufferGeometry attach="geometry" {...new THREE.BufferGeometry().setFromPoints(points)} />
    </line>
  );
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
  );
}

function GridLines({ gridSize, cubeSize }) {
  const gridElements = useMemo(() => {
    const elements = [];
    const maxCoord = (gridSize + 1) * cubeSize;
    const minCoord = -maxCoord;

    const lineMaterial = (
      <lineDashedMaterial
        attach="material"
        color="#444444"
        opacity={0.7}
        transparent={false}
        dashSize={1}
        gapSize={1}
      />
    );

    // Create grid lines for all cube edges
    for (let x = minCoord; x <= maxCoord; x += cubeSize) {
      for (let y = minCoord; y <= maxCoord; y += cubeSize) {
        for (let z = minCoord; z <= maxCoord; z += cubeSize) {
          // X-axis lines
          elements.push(
            <DashedLine
              key={`x${x}${y}${z}`}
              points={[new THREE.Vector3(minCoord, y, z), new THREE.Vector3(maxCoord, y, z)]}
            >
              {lineMaterial}
            </DashedLine>
          );
          // Y-axis lines
          elements.push(
            <DashedLine
              key={`y${x}${y}${z}`}
              points={[new THREE.Vector3(x, minCoord, z), new THREE.Vector3(x, maxCoord, z)]}
            >
              {lineMaterial}
            </DashedLine>
          );
          // Z-axis lines
          elements.push(
            <DashedLine
              key={`z${x}${y}${z}`}
              points={[new THREE.Vector3(x, y, minCoord), new THREE.Vector3(x, y, maxCoord)]}
            >
              {lineMaterial}
            </DashedLine>
          );
        }
      }
    }

    return elements;
  }, [gridSize, cubeSize]);

  return <group>{gridElements}</group>;
}

const GridCubes = ({ gridSize = 2, cubeSize = 10, opacity = 0.6 }) => {
  const colors = ['#ff69b4', '#00ced1']; // Pink and turquoise

  const cubes = [];
  for (let x = -gridSize; x <= gridSize; x++) {
    for (let y = -gridSize; y <= gridSize; y++) {
      for (let z = -gridSize; z <= gridSize; z++) {
        const position = [
          x * cubeSize,
          y * cubeSize,
          z * cubeSize,
        ];
        const colorIndex = (Math.abs(x) + Math.abs(y) + Math.abs(z)) % 2;
        cubes.push(
          <Box
            key={`${x}-${y}-${z}`}
            position={position}
            args={[cubeSize, cubeSize, cubeSize]}
          >
            <meshStandardMaterial
              color={colors[colorIndex]}
              transparent
              opacity={opacity}
            />
          </Box>
        );
      }
    }
  }

  return (
    <>
      <Box
        position={[0, 0, 0]}
        args={[1, 1, 1]}
      >
        <meshStandardMaterial color="#ff0000" transparent opacity={0.8} />
      </Box>
      {cubes}
      <GridLines gridSize={gridSize} cubeSize={cubeSize} />
    </>
  );
};

export default GridCubes;