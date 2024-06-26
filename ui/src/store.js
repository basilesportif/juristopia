import { create } from 'zustand'

const createPoints = (count) => {
  return Array.from({ length: count }, () => ({
    position: [
      Math.random() * 10 - 5,
      Math.random() * 10 - 5,
      Math.random() * 10 - 5
    ],
    active: false
  }))
}

export const useStore = create((set) => ({
  pointScale: 0.1,
  setPointScale: (scale) => set({ pointScale: scale }),
  points: createPoints(100),  // Create 100 random points
  togglePoint: (index) => set((state) => ({
    points: state.points.map((point, i) =>
      i === index ? { ...point, active: !point.active } : point
    )
  })),
}))