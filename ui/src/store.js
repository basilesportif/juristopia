import { create } from 'zustand'

function hashCoords({ x, y, z }) {
  return `${x},${y},${z}`;
}

// Factored out addWorld function
function addWorld(state, world) {
  const worldExists = state.worlds.some(w => w.commitmentHash === world.commitmentHash);
  if (!worldExists) {
    const cubeHash = hashCoords(world.containingCube);
    return {
      worlds: [...state.worlds, world],
      containingCubes: {
        ...state.containingCubes,
        [cubeHash]: (state.containingCubes[cubeHash] || 0) + 1
      }
    };
  }
  return state;
}

export const useStore = create((set) => ({
  halfSideLength: 0,
  setHalfSideLength: (halfSideLength) => set((state) => ({ halfSideLength })),
  containingCubes: {},
  worlds: [],
  addWorld: (world) => set((state) => addWorld(state, world))
}));