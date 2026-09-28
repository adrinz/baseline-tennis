const CELL_STEP = 0.05;

/** Round a point to a cell a few kilometers wide before it is stored on a player. */
export function coarseCell(lat: number, lng: number): { lat: number; lng: number } {
  return {
    lat: roundToStep(lat),
    lng: roundToStep(lng),
  };
}

function roundToStep(value: number): number {
  return Number((Math.round(value / CELL_STEP) * CELL_STEP).toFixed(2));
}

export function haversineKm(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const earthKm = 6371;
  const toRad = (degrees: number) => (degrees * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return 2 * earthKm * Math.asin(Math.sqrt(a));
}

/** Player responses use a band. They never include a distance in meters or a coordinate. */
export function distanceBand(distanceKm: number): string {
  if (distanceKm <= 1) return 'within 1 km';
  if (distanceKm <= 5) return 'within 5 km';
  if (distanceKm <= 10) return 'within 10 km';
  if (distanceKm <= 25) return 'within 25 km';
  return 'further than 25 km';
}
