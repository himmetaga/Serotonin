import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const manifestPath = process.argv[2] ?? 'art/asset_manifest.json';
const manifest = JSON.parse(fs.readFileSync(path.resolve(root, manifestPath), 'utf8'));
const results = [];
for (const asset of manifest.assets ?? [manifest]) {
  const buffer = fs.readFileSync(path.join(root, asset.path));
  assert.equal(buffer.readUInt32LE(0), 0x46546c67, 'GLB magic');
  assert.equal(buffer.readUInt32LE(4), 2, 'glTF 2');
  assert.equal(buffer.readUInt32LE(8), buffer.length, 'complete GLB');
  assert.equal(buffer.readUInt32LE(16), 0x4e4f534a, 'JSON chunk');
  const json = JSON.parse(buffer.subarray(20,20+buffer.readUInt32LE(12)).toString());
  let triangles = 0;
  for (const mesh of json.meshes ?? []) {
    for (const primitive of mesh.primitives) {
      assert.equal(primitive.mode ?? 4, 4, 'triangle primitives only');
      const accessor = json.accessors[primitive.indices ?? primitive.attributes.POSITION];
      triangles += accessor.count / 3;
      const positions = json.accessors[primitive.attributes.POSITION];
      assert(positions.min.every(Number.isFinite) && positions.max.every(Number.isFinite));
    }
  }
  assert(triangles <= (asset.technical.budget ?? asset.technical.triangle_budget), `${asset.id} triangle budget`);
  assert.equal(triangles, asset.technical.triangles, `${asset.id} source/export triangle agreement`);
  assert((json.materials?.length ?? 0) <= 3, `${asset.id} material budget`);
  assert.equal(json.images?.length ?? 0, 0, 'no hidden texture dependencies');
  assert.equal(json.cameras?.length ?? 0, 0, 'studio cameras excluded');
  assert.equal(asset.technical.nonmanifold_edges, 0, 'closed source components');
  assert.equal(asset.technical.degenerate_faces, 0, 'nondegenerate source geometry');
  for (const node of json.nodes ?? []) {
    assert(!node.scale || node.scale.every(v => Math.abs(v-1) < 1e-6), 'applied scale');
  }
  results.push({asset:asset.id, triangles, materials:json.materials.length, bytes:buffer.length});
}
console.log(JSON.stringify({status:'PASS', assets:results}, null, 2));
