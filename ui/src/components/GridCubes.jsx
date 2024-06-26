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
    const maxCoord = gridSize * cubeSize;
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

    // Create grid lines for XY, XZ, and YZ planes
    for (let i = minCoord; i <= maxCoord; i += cubeSize) {
      elements.push(
        <DashedLine
          key={`xy${i}`}
          points={[new THREE.Vector3(i, minCoord, 0), new THREE.Vector3(i, maxCoord, 0)]}
        >
          {lineMaterial}
        </DashedLine>,
        <DashedLine
          key={`yx${i}`}
          points={[new THREE.Vector3(minCoord, i, 0), new THREE.Vector3(maxCoord, i, 0)]}
        >
          {lineMaterial}
        </DashedLine>,
        <DashedLine
          key={`xz${i}`}
          points={[new THREE.Vector3(i, 0, minCoord), new THREE.Vector3(i, 0, maxCoord)]}
        >
          {lineMaterial}
        </DashedLine>,
        <DashedLine
          key={`zx${i}`}
          points={[new THREE.Vector3(minCoord, 0, i), new THREE.Vector3(maxCoord, 0, i)]}
        >
          {lineMaterial}
        </DashedLine>,
        <DashedLine
          key={`yz${i}`}
          points={[new THREE.Vector3(0, i, minCoord), new THREE.Vector3(0, i, maxCoord)]}
        >
          {lineMaterial}
        </DashedLine>,
        <DashedLine
          key={`zy${i}`}
          points={[new THREE.Vector3(0, minCoord, i), new THREE.Vector3(0, maxCoord, i)]}
        >
          {lineMaterial}
        </DashedLine>
      );
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