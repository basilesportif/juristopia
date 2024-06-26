import React, { useRef, useEffect, useMemo } from 'react';
import { Box, Text, Line } from '@react-three/drei';
import { useStore } from '../store';
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

function AxisLines({ axisLength, gridSize, cubeSize }) {
  const color = "green";
  const labelOffset = (gridSize + 2) * cubeSize; // Position labels slightly beyond the axis lines
  const labelSize = 3;
  const labelPositionOffset = 3;

  return (
    <>
      <Line
        points={[[-axisLength, 0, 0], [axisLength, 0, 0]]}
        color={color}
        lineWidth={2}
      />
      <Line
        points={[[0, -axisLength, 0], [0, axisLength, 0]]}
        color={color}
        lineWidth={2}
      />
      <Line
        points={[[0, 0, -axisLength], [0, 0, axisLength]]}
        color={color}
        lineWidth={2}
      />

      <Text position={[labelOffset, labelPositionOffset, labelPositionOffset]} color={color} fontSize={labelSize}>
        X
      </Text>
      <Text position={[labelPositionOffset, labelOffset, labelPositionOffset]} color={color} fontSize={labelSize}>
        Y
      </Text>
      <Text position={[labelPositionOffset, labelPositionOffset, labelOffset]} color={color} fontSize={labelSize}>
        Z
      </Text>
    </>
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
        opacity={0.9}
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

const GridCubes = ({ gridSize, cubeSize, opacity }) => {
  const { containingCubes } = useStore();
  const colors = ['#ff69b4', '#00ced1']; // Pink and turquoise

  const cubes = [];
  for (let x = -gridSize; x < gridSize; x++) {
    for (let y = -gridSize; y < gridSize; y++) {
      for (let z = -gridSize; z < gridSize; z++) {
        const position = [
          x * cubeSize + cubeSize / 2,
          y * cubeSize + cubeSize / 2,
          z * cubeSize + cubeSize / 2,
        ];
        const colorIndex = (Math.abs(x) + Math.abs(y) + Math.abs(z)) % 2;
        cubes.push(
          <Box
            key={`${x};${y};${z}`}
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
      {cubes}
      {<GridLines gridSize={gridSize} cubeSize={cubeSize} />}
      <AxisLines axisLength={(gridSize + 10) * cubeSize} gridSize={gridSize} cubeSize={cubeSize} />
    </>
  );
};

export default GridCubes;