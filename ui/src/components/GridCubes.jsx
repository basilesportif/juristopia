import React from 'react';
import { Box } from '@react-three/drei';

const GridCubes = ({ gridSize = 5, cubeSize = 10, opacity = 0.6 }) => {
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

  // with a center box
  return (
    <>
      <Box
        position={[0, 0, 0]}
        args={[1, 1, 1]}
      >
        <meshStandardMaterial color="#00FF00" transparent opacity={0.8} />
      </Box>
      {cubes}
    </>
  );
};

export default GridCubes;