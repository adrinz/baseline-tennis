import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import type { MemoryRepository } from './repository.ts';

export async function loadStore(repo: MemoryRepository, filePath: string): Promise<void> {
  try {
    const raw = await readFile(filePath, 'utf8');
    const parsed = JSON.parse(raw) as Record<string, unknown>;
    repo.importState(parsed);
  } catch (error) {
    const code = typeof error === 'object' && error !== null && 'code' in error ? error.code : '';
    if (code === 'ENOENT') return;
    throw error;
  }
}

export async function saveStore(repo: MemoryRepository, filePath: string): Promise<void> {
  await mkdir(path.dirname(filePath), { recursive: true });
  const body = JSON.stringify(repo.exportState());
  await writeFile(filePath, body);
}
