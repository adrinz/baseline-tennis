import type { FastifyRequest } from 'fastify';
import { z } from 'zod';
import { ApiError, validationMessage } from './errors.ts';
import type { NearQuery } from './repository.ts';

export function parseBody<T>(schema: z.ZodType<T>, body: unknown): T {
  const result = schema.safeParse(body ?? {});
  if (!result.success) throw new ApiError(400, 'validation', validationMessage(result.error));
  return result.data;
}

export function queryRecord(request: FastifyRequest): Record<string, unknown> {
  const query = request.query;
  if (query && typeof query === 'object') return query as Record<string, unknown>;
  return {};
}

export function routeParam(request: FastifyRequest, name: string): string {
  const params = request.params as Record<string, unknown>;
  const value = params[name];
  if (typeof value !== 'string' || value.length === 0) {
    throw new ApiError(400, 'validation', 'Missing route parameter.');
  }
  return value;
}

function first(value: unknown): string | undefined {
  if (Array.isArray(value)) return first(value[0]);
  if (typeof value === 'string') return value;
  return undefined;
}

function optionalNumber(value: unknown, label: string): number | undefined {
  const raw = first(value);
  if (raw == null || raw === '') return undefined;
  const number = Number(raw);
  if (!Number.isFinite(number)) throw new ApiError(400, 'validation', `${label} must be a number.`);
  return number;
}

export function optionalBoolean(value: unknown, label: string): boolean | undefined {
  const raw = first(value);
  if (raw == null || raw === '') return undefined;
  if (raw === 'true' || raw === '1') return true;
  if (raw === 'false' || raw === '0') return false;
  throw new ApiError(400, 'validation', `${label} must be true or false.`);
}

export function optionalText(value: unknown): string | undefined {
  const raw = first(value);
  if (raw == null || raw.trim() === '') return undefined;
  return raw.trim();
}

export function parseNear(query: Record<string, unknown>): NearQuery {
  const lat = optionalNumber(query.lat, 'lat');
  const lng = optionalNumber(query.lng, 'lng');
  const radiusKm = optionalNumber(query.radiusKm, 'radiusKm');
  const city = optionalText(query.city);
  if ((lat == null) !== (lng == null)) {
    throw new ApiError(400, 'validation', 'lat and lng must be sent together.');
  }
  if (lat != null && (lat < -90 || lat > 90 || lng! < -180 || lng! > 180)) {
    throw new ApiError(400, 'validation', 'lat or lng is out of range.');
  }
  if (radiusKm != null && (lat == null || !(radiusKm > 0) || radiusKm > 200)) {
    throw new ApiError(400, 'validation', 'radiusKm needs a location and must be greater than 0.');
  }
  return {
    ...(lat != null ? { lat, lng } : {}),
    ...(radiusKm != null ? { radiusKm } : {}),
    ...(city ? { city } : {}),
  };
}

export function headerValue(value: string | string[] | undefined): string | undefined {
  if (Array.isArray(value)) return value[0];
  return value;
}
