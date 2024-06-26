import React from 'react';
import { Box } from '@react-three/drei';

const GridCubes = ({ gridSize = 5, cubeSize = 10, opacity = 0.6 }) => {
  const colors = ['#ff69b4', '#00ced1']; // Pink and turquoise

  const cubes = [];
  for (let x = 0; x < gridSize; x++) {
    for (let y = 0; y < gridSize; y++) {
      for (let z = 0; z < gridSize; z++) {
        const position = [
          (x - Math.floor(gridSize / 2)) * cubeSize + cubeSize / 2,
          (y - Math.floor(gridSize / 2)) * cubeSize + cubeSize / 2,
          (z - Math.floor(gridSize / 2)) * cubeSize + cubeSize / 2,
        ];
        const colorIndex = (x + y + z) % 2;
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
    </>
  );
};

export default GridCubes;