import { create } from 'zustand'

const INITIAL_POINT_COUNT = 100
const POINT_RANGE = 5

const createPoint = () => ({
  position: Array.from({ length: 3 }, () => Math.random() * 2 * POINT_RANGE - POINT_RANGE),
  active: false
})

const createPoints = (count) => Array.from({ length: count }, createPoint)

const initialState = {
  pointScale: 0.1,
  points: createPoints(INITIAL_POINT_COUNT),
}

export const useStore = create((set) => ({
  ...initialState,
  setPointScale: (scale) => set({ pointScale: scale }),
  togglePoint: (index) => set((state) => ({
    points: state.points.map((point, i) =>
      i === index ? { ...point, active: !point.active } : point
    )
  })),
}))